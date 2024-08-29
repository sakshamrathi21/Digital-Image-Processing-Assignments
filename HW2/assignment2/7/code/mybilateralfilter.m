function output = mybilateralfilter(image, sigma_s, sigma_r)
    [rows, cols] = size(image);
    output = zeros(size(image));
    
    % Define the window size based on sigma_s
    win_size = 2*ceil(3 * sigma_s)+1;
    
    % Create Gaussian spatial kernel
    [X, Y] = meshgrid(-floor(win_size/2):floor(win_size/2), -floor(win_size/2):floor(win_size/2));
    spatial_kernel = exp(-(X.^2 + Y.^2) / (2 * sigma_s^2));
    
    % Traverse the image with nested loops
    for i = 1:rows
        for j = 1:cols
            % Extract local region
            iMin = max(i-floor(win_size/2), 1);
            iMax = min(i+floor(win_size/2), rows);
            jMin = max(j-floor(win_size/2), 1);
            jMax = min(j+floor(win_size/2), cols);
            region = image(iMin:iMax, jMin:jMax);
            
            % Compute Gaussian range kernel
            range_kernel = exp(-((region - image(i,j)).^2) / (2 * sigma_r^2));
            
            % Combined filter response
            bilateral_filter = spatial_kernel((iMin:iMax)-i+floor(win_size/2)+1, (jMin:jMax)-j+floor(win_size/2)+1) .* range_kernel;
            output(i,j) = sum(bilateral_filter(:) .* region(:)) / sum(bilateral_filter(:));
        end
    end
end
