% Read the images
img1 = imread('../images/barbara256.png');
img2 = imread('../images/kodak24.png');

% Convert images to double for processing
img1 = double(img1);
img2 = double(img2);

% Define noise parameters
sigma_noises = [5, 10]; % Standard deviations of Gaussian noise

% Define parameter configurations for mean shift filter
param_configs = [
    2, 2;
    15, 3;
    3, 15
];

% Set maximum iterations and tolerance for mean shift convergence
max_iter = 10; % Maximum number of iterations
tol = 1; % Tolerance for convergence

% Loop through noise levels
for noise_idx = 1:length(sigma_noises)
    sigma_noise = sigma_noises(noise_idx);
    
    % Add Gaussian noise to the images
    noisy_img1 = img1 + sigma_noise * randn(size(img1));
    noisy_img2 = img2 + sigma_noise * randn(size(img2));
    
    % Save noisy images
    imwrite(uint8(noisy_img1), ['../images/noisy_barbara256_sigma_', num2str(sigma_noise), '.png']);
    imwrite(uint8(noisy_img2), ['../images/noisy_kodak24_sigma_', num2str(sigma_noise), '.png']);
    
    % Loop through parameter configurations and apply mean shift filter
    for i = 1:size(param_configs, 1)
        sigma_s = param_configs(i, 1);
        sigma_r = param_configs(i, 2);
        
        filtered_img1 = mymeanshiftfilter(noisy_img1, sigma_s, sigma_r, max_iter, tol);
        filtered_img2 = mymeanshiftfilter(noisy_img2, sigma_s, sigma_r, max_iter, tol);
        
        % Save the filtered images
        imwrite(uint8(filtered_img1), ['../images/filtered_barbara256_meanshift_sigma_', num2str(sigma_noise), '_sigma_s_', num2str(sigma_s), '_sigma_r_', num2str(sigma_r), '.png']);
        imwrite(uint8(filtered_img2), ['../images/filtered_kodak24_meanshift_sigma_', num2str(sigma_noise), '_sigma_s_', num2str(sigma_s), '_sigma_r_', num2str(sigma_r), '.png']);
        
        % Display results
        figure;
        subplot(1, 2, 1), imshow(uint8(filtered_img1)), title(['barbara256.png - \sigma_{noise} = ', num2str(sigma_noise), ', \sigma_s = ', num2str(sigma_s), ', \sigma_r = ', num2str(sigma_r)]);
        subplot(1, 2, 2), imshow(uint8(filtered_img2)), title(['kodak24.png - \sigma_{noise} = ', num2str(sigma_noise), ', \sigma_s = ', num2str(sigma_s), ', \sigma_r = ', num2str(sigma_r)]);
    end
end
