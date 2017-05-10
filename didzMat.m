%function[didz,sdEr] = didzMat(imageStack,dz ,order)
function[didz,MSEmat] = didzMat(imageStack,dz ,order)

%z = (0:dz:(size(imageStack,3)-2)*dz);
%z = (0:20:100);
%z = (-100:10:100);
if (mod(size(imageStack,3),2))
	sub = 0;
else
	sub = 1;
end
range = (size(imageStack,3)/2 - sub - mod(size(imageStack,3),2)/2) * dz;
z = (-range:dz:range);
%z = (-dz*(size(imageStack,3)-2)/2-mod(size(imageStack,3)-2,2)/2:dz:dz*(size(imageStack,3)-2)/2-mod(size(imageStack,3)-2,2)/2) 

%This is a bit long %and unwieldy way to declare the axial distance (z), but essentially I am assuming the middle slice is in focuse.
%Future versions may due away with this altogether and calculate di/dz, and thus phase, for every slice.
didz = zeros(size(imageStack,1),size(imageStack,2)); %change in intensity with respect to z
MSEmat = zeros(size(imageStack,1),size(imageStack,2)); %a matrix to keep track of fitting error, can inform the desired order of poly fitting
%length(z);

cx = 1;
while cx <= size(imageStack,1)
	cy = 1;
	while cy <= size(imageStack,2)
		cz = 3; % because the first two matrices in imageStack are zeros
		tempData = zeros(1,size(imageStack,3));
		%length(tempData);
		while cz <= size(imageStack,3)
			tempData(cz) = imageStack(cx,cy,cz); %build vector as a function of z of a single pixel
			cz = cz+1;
		end
		%length(tempData)
		%tempData
		%length(z)
		%z	
		%size(z)
		%size(tempData)	
		[polyCo,simData] = polyfit(z,tempData,order);
		
		didz(cx,cy) = polyCo(length(polyCo)-1);
		%didz(cx,cy) = simData.yf(length(simData.yf)/2 - mod(length(simData.yf),2)/2+1)-simData.yf(length(simData.yf)/2 - mod(length(simData.yf),2)/2-1); %the difference between the intensity value of the model at either side of focus
		
		[y] = polyval(polyCo,tempData);
		%MSEmat(cx,cy) = meanSquareError(tempData,simData.yf);
		MSEmat(cx,cy) = meanSquareError(tempData,y);
		cy = cy+1;
	end
	cx = cx+1;
	end
end




