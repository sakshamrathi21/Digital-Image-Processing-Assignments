% Initialize a 1D image (array of 15 pixels) with random values
I = [5,5,5,4,3,2,1,1,1,1,1,6,6,6,6]

% Define the alpha value
alpha = 0.0001;

% Number of iterations
numIterations = 1000;

% Main loop: perform the operation 100 times
for iter = 1:numIterations
    % Create a copy of the image to compute the Laplacian
    I_new = I;
    flag = false;
    % Loop through each pixel and compute the Laplacian (excluding the boundary)
    for x = 2:length(I)-1
        % Compute the Laplacian for the pixel I(x)
        laplacian = I(x-1) - 2*I(x) + I(x+1);
        
        % Update I(x) using the Laplacian
        I_new(x) = I(x) - alpha * laplacian;
    end;
   for i = 1:length(I_new)
       if (I_new(i) < 0)
           flag = true;
           break;
       end;
   end;
   if (flag)
       display(iter);
       break;
   end;
    % Update the original image with the new values (ignoring boundary pixels)
    I(2:end-1) = I_new(2:end-1);
end

% Display the final result
disp('Final 1D image after 10000 iterations:');
disp(I);
