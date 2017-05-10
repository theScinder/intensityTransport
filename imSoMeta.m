function [phiPPO, phi, dicPPO, dic, LapPPO, Lap, mod2PPO, mod2, bwhpfPPO] = imSoMeta(imgs,dz)
%%% This function takes  a z-stack and returns z-stacks of different imaging modes derived from quantitative phase imaging
% input is a z-stack of intensity images (imgs)
%	
%From measured dI/dz: 
%	quantitative phase map assuming perfect phase object (z-stack)
%		digital DIC z-stack, x
%		digital DIC z -stack y
%		dig. DIC z-stack x+y
%		Laplacian 
%		Mod-squared
%		Butterworth HPF phase map
%
%
% 	QP map without perfect phase object assumption (z-stack). Derivatives:
%	 	digital DIC z-stack, x
%		digital DIC z -stack y
%		dig. DIC z-stack x+y
%		Laplacian 
%		Mod-squared
%		Butterworth HPF phase map
%
%	Polynomial Model estimates of dI/dz
%	

% allocate zeros for the phi z-stack, since we will use the middle difference method in this case
% 	the phi z-stack will be two shorter than the intensity z-stack
	phi = zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2);
	phiPPO =zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2);
	bwhpfPPO = zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2); 
	%whos
	for cz = 2:size(imgs,3)-1

		%Compute phase map without perfect phase object (PPO) assumption
		phi(:,:,cz-1) = real(phaseOdyssey(imgs(:,:,cz),imgs(:,:,cz+1)-imgs(cz-1),1));

		%compute phase map z-stack with perfect phase object (PPO) assumption
		%Also compute the phase map computed by multiplying the phase map with a Butterworth HPF in the Fourier domain
		[phiPPO(:,:,cz-1), bwhpfPPO(:,:,cz-1)] = phaseNewWorldRev03(imgs(:,:,cz-1),imgs(:,:,cz),imgs(:,:,cz+1),1);
		phiPPO = -real(phiPPO);
		bwhpfPPO = -real(bwhpfPPO); 
	end
	
	%allocate memory for dic stack with 3 channels, x, y, and x+y (and other image modes)
	dicPPO = zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2,3);
	dic = zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2,3);	
	lapPPO = zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2);	
	lap = zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2);
	mod2PPO = zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2);
	mod2 = zeros(size(imgs,1),size(imgs,2),size(imgs,3)-2);
%whos
	for cz = 1:size(imgs,3)-2
		%calculate x, y gradient for dic in those directions, divergence for x+y dic
		[dicPPO(:,:,cz,1), dicPPO(:,:,cz,2)] = gradient(phiPPO(:,:,cz));
		dicPPO(:,:,cz,3) = dicPPO(:,:,cz,1)+dicPPO(:,:,cz,2);
		LapPPO(:,:,cz) = del2(phiPPO(:,:,cz));
		mod2PPO(:,:,cz) = (dicPPO(:,:,cz,1)+dicPPO(:,:,cz,2)).^2;
		 
		
		%compute the same DIC images for the phase map computed w/o perfect phase object assumption
		[dic(:,:,cz,1), dic(:,:,cz,2)] = gradient(phi(:,:,cz));	
		dic(:,:,cz,3) = dic(:,:,cz,1)+dic(:,:,cz,2);
		Lap(:,:,cz) = del2(phi(:,:,cz));
		mod2(:,:,cz) = (dic(:,:,cz,1)+dic(:,:,cz,2)).^2;
		 
		
	end
	
	%Now display all those things
	fig = 0;
        %whos
	for cz = 1:7
		%fig = fig+1;		
		%h1 = figure(1);
		figure(1); 
		subplot(3,3,cz); 
                %size(phi)
		surf(phi(:,:,cz));
		colormap(hot);
		title('phase map z-stack');
		view(45,75);
		
		%print(h1,'-dpng','-color','./vib_plt.png')

		%fig = fig+1;		
		figure(2); 
		subplot(3,3,cz); 
		surf(phiPPO(:,:,cz));
		colormap(hot);
		title('phase map z-stack, (assume perfect phase object)');
		view(45,75);

		%fig = fig+1;		
		figure(3); 
		subplot(3,3,cz); 
		surf(dic(:,:,cz,3));
		axis equal;
		colormap(gray);
		title('digital DIC z-stack (x+y)');
		view(90,90);

		%fig = fig+1;		
		figure(4); 
		subplot(3,3,cz); 
		surf(dicPPO(:,:,cz,3));
		grid off;
		axis equal;
		colormap(gray);
		title('dig. DIC z-stack, (x+y, assume perfect phase object)');
		view(90,90);


		%fig = fig+1;		
		figure(5); 
		subplot(3,3,cz); 
		surf(Lap(:,:,cz));
		colormap(cool);
		title('Laplacian z-stack');
		view(45,75);

		%fig = fig+1;		
		figure(6); 
		subplot(3,3,cz); 
		surf(LapPPO(:,:,cz));
		colormap(cool)
		title('Laplacian (assume perfect phase object)');
		view(45,75);


		%fig = fig+1;		
		figure(7); 
		subplot(3,3,cz); 
		surf(mod2(:,:,cz));
		colormap(cool);
		title('mod^2 z-stack');
		view(45,75);

		%fig = fig+1;		
		figure(8); 
		subplot(3,3,cz); 
		surf(mod2PPO(:,:,cz));
		colormap(cool);
		title('mod^2 (assume perfect phase object)');
		view(45,75);

		%fig = fig+1;		
		figure(9); 
		subplot(3,3,cz); 
		surf(bwhpfPPO(:,:,cz));
		colormap(autumn);
		title('phase map* Butterworth HPF (assume perfect phase object)');
		view(45,75);

					
	end
	fig = 9;
	fig = fig+1;
	figure(fig);
	%surf(phi(:,:,4));
        surf(phi(:,:,1));
	colormap(hot);
	title('phase map');
	view(45,75);

	fig = fig+1;
	figure(fig);
	%surf(phiPPO(:,:,4));
        surf(phiPPO(:,:,1));
	colormap(hot);
	title('phase map  (assume perfect phase object))');
	view(45,75);

	fig = fig+1;
	figure(fig);
	%surf(dic(:,:,2,3));
        surf(dic(:,:,1));
	colormap(gray);
	title('dig. DIC ');	
	view(90,90);

% 	fig = fig+1;
% 	figure(fig);
% 	surf(dicPPO(:,:,2,3));	
% 	colormap(gray);
% 	title('dig. DIC  (assume perfect phase object))');
% 	view(90,90);

% 	fig = fig+1;
% 	figure(fig);
% 	imshow(( dic(:,:,4,3)-min(min(min(min(dic)))) )./(2*max(max(max(max(dic))))) );
% 	colormap(gray);
% 	title('dig. DIC ');	
% 	view(90,90);
% 
% 	fig = fig+1;
% 	figure(fig);
% 	imshow((dicPPO(:,:,4,3)-min(min(min(min(dicPPO)))))./(2*max(max(max(max(dicPPO))))) );	
% 	colormap(gray);
% 	title('dig. DIC  (assume perfect phase object))');
% 	view(90,90);
	
	fig = fig+1;
	figure(fig);
	%surf(Lap(:,:,4));
        surf(Lap(:,:,1));
	colormap(cool);
	title('Laplacian');			
	view(45,75);

	fig = fig+1;
	figure(fig);
	%surf(LapPPO(:,:,4));
        surf(LapPPO(:,:,1));
	colormap(cool);
	title('Laplacian (assume perfect phase object)');
	view(45,75);

	fig = fig+1;
	figure(fig);
	%surf(mod2(:,:,4));
        surf(mod2(:,:,1));
	colormap(cool);
	title('mod^2');
	view(45,75);
	
	fig = fig+1;
	figure(fig);
	%surf(mod2PPO(:,:,4));
        surf(mod2PPO(:,:,1));
	colormap(cool);
	title('mod^2 (assume perfect phase object)');
	view(45,75);
	
	fig = fig+1;
	figure(fig);
	%surf(bwhpfPPO(:,:,4));
        surf(bwhpfPPO(:,:,1));
	colormap(autumn);	
	title('phase map* Butterworth HPF (assume perfect phase object)');
	view(45,75);

end
