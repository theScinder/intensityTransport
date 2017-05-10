function [phase,phaseFilt] = phaseNewWorldRev03(Ia,I0,Ib,z)
%generate a phase map based on the defocused images Ia (above), Ib (below,
%focused image I0, and the defocused difference (in microns) z
% Detailed explanation goes here
%For starters we will split of the green channel and deal withit
%exclusively
if size(size(Ia)) == 3 % check for color/B&W image
Iag = Ia(1:size(Ia,1),1:size(Ia,2),2);
Ibg = Ib(1:size(Ia,1),1:size(Ia,2),2);
I0g = I0(:,:,2);
test = 'if statement'
else
Iag = Ia;
Ibg = Ib;
I0g = I0;
end
Iag = double(Iag); 
I0g = double(I0g);
Ibg = double(Ibg);
sizeX = size(Ia,1);
sizeY = size(Ia,2);
%Iavg is the uniform intensity distribution
Iavg = mean(mean(I0g));
%wavenumber k0 (inverse microns, for green light)
k0g = (2*pi())/(500);
%gofxy is the data that describe the change in field intensity per axial
%defocus (z). Ironically an assumption of this solution of the TIE is that
%the field intensity is assumed to be constant over z (see p. 223 Popescu 2011,
%QPI of cells and tissues)
gofxy = ((Iag - Ibg)) / (2*z);
%gofxy contains the phase information [gofxy = -I0/k0 $\nabla^2$ \phi(x,y)]
%To solve the Laplacian we convert gofxy to the frequency domain with the
%2D fft
GOFkxky = fft2(gofxy,sizeX*2,sizeY*2);
%debugging: show the frequency domain and difference image
%figure(1); subplot(2,1,1); title(’difference Ia-Ib’);
%imshow(Iag-Ibg);
%subplot(2,1,2); title(’FFT magnitude of dI/dz $\delta$’); imshow(abs(GOFkxky));
%Solve for the frequency domain phase:
%Declare memory to hold the fft of phase
PHI= zeros(sizeX*2,sizeY*2);
kx = 1;

for kx = 1:sizeX*2

	
	for ky = 1:sizeY*2
		PHI(kx,ky) = (1/4*pi^2*Iavg) * (GOFkxky(kx,ky) / (kx^2+ky^2));
		%ky = ky+1;
	end
	%kx = kx+1;
end
myfilt = zeros(sizeX*2,sizeY*2);
for kx = 1:sizeX*2
	for ky = 1:sizeY*2
	myfilt(kx,ky) = ((sqrt(kx^2+ky^2))^2+1.4142*(sqrt(kx^2+ky^2))+1)/((sqrt(sizeX^2+sizeY^2))^2+1.4142*(sqrt(sizeX^2+sizeY^2))+1);
	end
end
%PHI = PHI .* myfilt;
phase = ifft2(PHI);
phaseFilt = ifft2(PHI .* myfilt);%(1:sizeX,1:sizeY);%./I0g;

phase = phase(1:sizeX,1:sizeY);
phaseFilt = phaseFilt(1:sizeX,1:sizeY);
%figure(2); subplot(1,3,1); title(’defocused above’); imshow(Iag);
%subplot(1,3,2); title(’focused image’); imshow(I0g);
%subplot(1,3,3); title(’defocused below’); imshow(Ibg);
%figure(3);
%subplot(1,2,1); title(’difference image amplified 10X, d
%I/dz’); imshow(10*(Iag-Ibg));
%subplot(1,2,2); title(’recovered phase, surface plot’);
%mesh(abs(phase));
%figure(4); title(’recovered phase, surface plot’); mesh(
%abs(phase)); colormap(jet);
end
