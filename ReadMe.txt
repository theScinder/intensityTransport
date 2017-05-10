%2015/September/14
%Q. Tyrell Davis
%scripts updated to remove some debugging output and fix some persnickety things while running in MATLAB instead of octave. 

%Sample images cropped out of [1], Figure 2a. (mitotic yeast) 
%Based on a 3X3 grid containing a 9 image focus stack, so I0 is image 5. The focus step between planes is 0.380 microns. 

%Usage examples:
%cd into a Samples folder


Ib = imread('MFMYeastz4.tif');
I0 = imread('MFMYeastz5.tif');
Ia = imread('MFMYeastz6.tf');
dz = 0.380;

%For the old version of the algorithm:
%Returns phase, the quantitative phase image assuming a pure phase object (illumination at best focus entirely uniform)
% and phaseFilt, the same with a 2D Butterworth high pass filter to bring out the details
[phase, phaseFilt] = phaseNewWorldRev03(Ia, I0, Ib, dz);

%For the new version (similar maths as [2]), the assumption of uniform intensity is not so important, results are better:

[phase] = phaseOdyseey(I0, dIdz, dz);


%to calculate first derivative of intensity

dI = Ia - Ib; %(central difference) %or I0 - Ia (forward difference) or I0 - Ib (backward difference

%-OR- using a multi-image polynomial fit 

Istack = zeros(size(I1,1),size(I1,2),9);

for ck = 1:9
	IStack(:,:,ck) = imread(strcat('MFMYeastz',int2str(ck),'.tif'));
end

[dIdz, MSEMat] = didzMat(Istack,dz,order);


%********************************************************************
%TL:DR Alternatively, just run imSoMeta(Istack,dz); to get an example of solving the TIE both ways and additional computational imaging modes using the TIE %%%data
%*******************************************************************
[1] Abrahamsson, S., Chen, J., Hajj, B., Stallinga, S., Katsov, A. Y., Wisniewski, J., … Gustafsson, M. G. L. (2013). Fast multicolor 3D imaging using aberration-corrected multifocus microscopy. Nature Methods, 10(1), 60–3. http://doi.org/10.1038/nmeth.2277

[2] Gorthi, S. S., & Schonbrun, E. (2012). Phase imaging flow cytometry using a focus-stack collecting microscope. Optics Letters, 37(4), 707. http://doi.org/10.1364/OL.37.000707
