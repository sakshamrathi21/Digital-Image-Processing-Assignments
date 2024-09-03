% Function which applies bilateral filter on the input image. The other parameters are sigma_s and sigma_r
function output = mybilateralfilter(image, sigma_s, sigma_r)
    % Size of the image and initializing the output image to be a zero matrix
    [rows, cols] = size(image);
    output = zeros(size(image));
    
    % Defining the window size based on sigma_s (making it an odd number)
    win_size = 2*ceil(3 * sigma_s)+1;
    
    % Creating Gaussian spatial kernel of the size calculated above
    [X, Y] = meshgrid(-floor(win_size/2):floor(win_size/2), -floor(win_size/2):floor(win_size/2));
    spatial_kernel = exp(-(X.^2 + Y.^2) / (2 * sigma_s^2));
    
    % Traversing the image with two nested loops
    for i = 1:rows
        for j = 1:cols
            % Extracting local region and checking for appropriate bounds on the four sides of the image
            iMin = max(i-floor(win_size/2), 1);
            iMax = min(i+floor(win_size/2), rows);
            jMin = max(j-floor(win_size/2), 1);
            jMax = min(j+floor(win_size/2), cols);
            region = image(iMin:iMax, jMin:jMax);
            
            % Computing Gaussian range kernel
            range_kernel = exp(-((region - image(i,j)).^2) / (2 * sigma_r^2));
            
            % Combining the two kernels
            bilateral_filter = spatial_kernel((iMin:iMax)-i+floor(win_size/2)+1, (jMin:jMax)-j+floor(win_size/2)+1) .* range_kernel;
            % Applying the filter and normalizing:
            output(i,j) = sum(bilateral_filter(:) .* region(:)) / sum(bilateral_filter(:));
        end
    end
end
