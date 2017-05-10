function[MSE] = meanSquareError(dataArray, simDataArray)


%MSE = 1.010101010 * 10^10;
%if length(dataArray) != length(simDataArray)
%	"The data array and simulated data array length do not match. MSE process aborted and arbitrary MSE of 10^6 returned)"
%	MSE = 10^6;	
%end %end of if

k = 1;
MSE = 0.0;
while k < length(dataArray)
	MSE = MSE + (dataArray(k) - simDataArray(k))^2;	%sum of squared errors
	k = k+1;
end %end of while
MSE;
MSE = MSE / length(dataArray); %take the mean of the sum, for MEAN square error

end % end of function

