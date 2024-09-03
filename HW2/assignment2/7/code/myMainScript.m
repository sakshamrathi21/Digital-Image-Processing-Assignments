% The following lines of the code create the noisy images and save them, since we have already saved, these lines are commented out.
% Reading the input images:
% barbara = imread('../images/barbara256.png');
% kodak = imread('../images/kodak24.png');
% barbara = double(barbara);
% kodak = double(kodak);
% sigma1 = 5;
% sigma2 = 10;

% Adding Gaussian noise:
% noisy_barbara_5 = barbara + sigma1 * randn(size(barbara));
% noisy_kodak_5 = kodak + sigma1 * randn(size(kodak));
% noisy_barbara_10 = barbara + sigma2 * randn(size(barbara));
% noisy_kodak_10 = kodak + sigma2 * randn(size(kodak));

% Plotting the images
% figure;
% subplot(2,3,1), imshow(uint8(barbara)), title('Original Barbara');
% subplot(2,3,2), imshow(uint8(noisy_barbara_5)), title('Barbara with Noise (\sigma = 5)');
% subplot(2,3,3), imshow(uint8(noisy_barbara_10)), title('Barbara with Noise (\sigma = 10)');
% subplot(2,3,4), imshow(uint8(kodak)), title('Original Kodak');
% subplot(2,3,5), imshow(uint8(noisy_kodak_5)), title('Kodak with Noise (\sigma = 5)');
% subplot(2,3,6), imshow(uint8(noisy_kodak_10)), title('Kodak with Noise (\sigma = 10)');

% Saving the noisy versions
% imwrite(uint8(noisy_barbara_5), '../images/noisy_barbara_5.png');
% imwrite(uint8(noisy_kodak_5), '../images/noisy_kodak_5.png');
% imwrite(uint8(noisy_barbara_10), '../images/noisy_barbara_10.png');
% imwrite(uint8(noisy_kodak_10), '../images/noisy_kodak_10.png');

% Reading the noisy images:
noisy_barbara_5 = imread('../images/noisy_barbara_5.png');
noisy_kodak_5 = imread('../images/noisy_kodak_5.png');
noisy_barbara_10 = imread('../images/noisy_barbara_10.png');
noisy_kodak_10 = imread('../images/noisy_kodak_10.png');
noisy_barbara_5 = double(noisy_barbara_5);
noisy_kodak_5 = double(noisy_kodak_5);
noisy_barbara_10 = double(noisy_barbara_10);
noisy_kodak_10 = double(noisy_kodak_10);

% sigma_s and sigma_r values which we will be using
params = [
    2, 2; 
    0.1, 0.1;
    3, 15;
];

% Iterating over the pairs of values:
for p = 1:size(params, 1)
    sigma_s = params(p, 1);
    sigma_r = params(p, 2);
    % Applying the filter:
    filtered_barbara_5 = mybilateralfilter(noisy_barbara_5, sigma_s, sigma_r);
    filtered_kodak_5 = mybilateralfilter(noisy_kodak_5, sigma_s, sigma_r);
    filtered_barbara_10 = mybilateralfilter(noisy_barbara_10, sigma_s, sigma_r);
    filtered_kodak_10 = mybilateralfilter(noisy_kodak_10, sigma_s, sigma_r);
    % Plotting the values and saving the images
    figure;
    subplot(2,2,1), imshow(uint8(filtered_barbara_5)), title(['Barbara (\sigma_s = ', num2str(sigma_s), ', \sigma_r = ', num2str(sigma_r), ')']);
    subplot(2,2,2), imshow(uint8(filtered_kodak_5)), title(['Kodak (\sigma_s = ', num2str(sigma_s), ', \sigma_r = ', num2str(sigma_r), ')']);
    subplot(2,2,3), imshow(uint8(filtered_barbara_10)), title(['Barbara (\sigma_s = ', num2str(sigma_s), ', \sigma_r = ', num2str(sigma_r), ')']);
    subplot(2,2,4), imshow(uint8(filtered_kodak_10)), title(['Kodak (\sigma_s = ', num2str(sigma_s), ', \sigma_r = ', num2str(sigma_r), ')']);
    imwrite(uint8(filtered_barbara_5), ['../images/filtered_barbara_5_sigma_s_', num2str(sigma_s), '_sigma_r_', num2str(sigma_r), '.png']);
    imwrite(uint8(filtered_kodak_5), ['../images/filtered_kodak_5_sigma_s_', num2str(sigma_s), '_sigma_r_', num2str(sigma_r), '.png']);
    imwrite(uint8(filtered_barbara_10), ['../images/filtered_barbara_10_sigma_s_', num2str(sigma_s), '_sigma_r_', num2str(sigma_r), '.png']);
    imwrite(uint8(filtered_kodak_10), ['../images/filtered_kodak_10_sigma_s_', num2str(sigma_s), '_sigma_r_', num2str(sigma_r), '.png']);
end
