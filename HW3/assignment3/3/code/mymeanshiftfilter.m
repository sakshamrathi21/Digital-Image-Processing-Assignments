% Mean shift filtering
% Custom Mean Shift Filter Function
function filtered_img = mymeanshiftfilter(noisy_img, sigma_s, sigma_r, max_iter, tol)
    % Parameters:
    % sigma_s: spatial bandwidth
    % sigma_r: range (intensity) bandwidth
    % max_iter: maximum number of iterations
    % tol: tolerance for convergence

    [rows, cols, channels] = size(noisy_img); 
    filtered_img = noisy_img; % Initialize output
    spatial_radius = sigma_s;
    intensity_radius = sigma_r;
    
    % Create a spatial grid for the image
    [X, Y] = meshgrid(1:cols, 1:rows);
    
    % Iterate over all pixels
    for i = 1:rows
        for j = 1:cols
            % Initialize the window center (spatial and intensity)
            center_x = j;
            center_y = i;
            center_intensity = squeeze(noisy_img(i, j, :));
            
            for iter = 1:max_iter
                % Define a spatial window around the center
                xmin = max(1, round(center_x - spatial_radius));
                xmax = min(cols, round(center_x + spatial_radius));
                ymin = max(1, round(center_y - spatial_radius));
                ymax = min(rows, round(center_y + spatial_radius));
                
                % Extract the local neighborhood within the window
                local_patch = noisy_img(ymin:ymax, xmin:xmax, :);
                [localX, localY] = meshgrid(xmin:xmax, ymin:ymax);
                
                % Compute the spatial distance from the center
                spatial_dist = sqrt((localX - center_x).^2 + (localY - center_y).^2);
                
                % Compute the intensity distance from the center
                intensity_dist = sqrt(sum((local_patch - reshape(center_intensity, 1, 1, [])).^2, 3));
                
                % Compute the combined distance weights
                spatial_weight = exp(-(spatial_dist.^2) / (2 * sigma_s^2));
                intensity_weight = exp(-(intensity_dist.^2) / (2 * sigma_r^2));
                
                % Calculate the total weight
                total_weight = spatial_weight .* intensity_weight;
                
                % Normalize the weights
                total_weight_sum = sum(total_weight(:));
                
                % Compute the new center as the weighted mean of the patch
                new_x = sum(sum(total_weight .* localX)) / total_weight_sum;
                new_y = sum(sum(total_weight .* localY)) / total_weight_sum;
                new_intensity = sum(sum(total_weight .* local_patch), [1 2]) / total_weight_sum;
                
                % Shift the window center
                shift_x = new_x - center_x;
                shift_y = new_y - center_y;
                shift_intensity = norm(new_intensity - center_intensity);
                
                % Update the center
                center_x = new_x;
                center_y = new_y;
                center_intensity = new_intensity;
                
                % Check for convergence
                if sqrt(shift_x^2 + shift_y^2) < tol && shift_intensity < tol
                    break;
                end
            end
            
            % Assign the final intensity value to the filtered image
            filtered_img(i, j, :) = center_intensity;
        end
    end
end