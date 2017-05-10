function [phi] = phaseOdyssey(i0,dI,dz) %,varargin)
	
	%if !(dz)
	%	dz = 1;
	%end

	%determine first derivative of intensity, by forward, center, or backward difference.
	%if (ia) & (ib)
%		dI = ia - ib;
%	elseif (ia)
%		dI = ia - i0; 
%	else i
%		dI = i0 - ib; 
%	end	

	%Debugging line
	%imshow(dI);

	dI = dI ./ dz;

	%Take this party to the Fourier domain
	DI = fft2(dI);
	
	%set bounds for kx and ky, 
	kxMax = size(DI,1);
	kyMax = size(DI,2);
	
	%	populate kx
	[ky,kx] = meshgrid(1:kyMax,1:kxMax);
PSI = zeros(size(DI)); 
%whos
	%psi = I(x,y)\nabla(phi(x,y))
	PSI = DI ./ (4*pi()*(kx.^2+ky.^2));
	psi = zeros(size(PSI));
	%back to the spatial domain, also truncate the matrix to get rid of zero-padding
	psi = ifft2(PSI);%(1:size(PSI,1)/2,1:size(PSI,2)/2);
	
	%At this point, psi./k0 would give the solution for phi(x,y) (optical path length) under the perfect phase object assumption (i.e. \nabla(I(x,y) = 0)

	%continue solving the TIE
	%after truncating above, dx and dy should have the same dimensions as i0
	[dx,dy] = gradient(psi);
	%i0 = i0 +ones(size(i0))*i;
%	I0 = (i0.+j*zeros(size(i0)));
        i0 = complex(double(i0));
        %whos	
        %dxn = dx ./  complex(i0);
	%dyn = dy ./ complex(i0);
	
        dxn = dx ./  (i0);
	dyn = dy ./ (i0);
	
	nabla2phi = divergence(dxn,dyn);

	%Now we will repeat the Fourier treatment from above to solve for phi

	NABLA2PHI = fft2(nabla2phi);

	PHI = NABLA2PHI ./ (4*pi^2*(kx.^2+ky.^2));

	%way to go, you did it!	
	phi = ifft2(PHI);
	
	
end
