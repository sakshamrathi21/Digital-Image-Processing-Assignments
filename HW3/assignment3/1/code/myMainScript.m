clear; close all; clc;

% Read image
img = double(imread('../images/barbara256.png'));

% Display original image
figure(1); imshow(uint8(img)); colormap("gray"); title('Original Image');

% Get DFT of the image
img_DFT = get_DFT(img);

% Display logarithm of the DFT
display_logarithm(img_DFT, 'DFT of Original Image', '../images/barbara_original_DFT.png');

% Ideal Low pass filtered image (f = 40)
IdealLowPassFilter(img_DFT, 40, size(img));

% Ideal Low pass filtered image (f = 80)
IdealLowPassFilter(img_DFT, 80, size(img));

% Gaussian Low pass filtered image (sigma = 40)
GaussianLowPassFilter(img_DFT, 40, size(img));

% Gaussian Low pass filtered image (sigma = 80)
GaussianLowPassFilter(img_DFT, 80, size(img));

%% Extract DFT Function
function img_DFT = get_DFT(img)
    % Zero-padding the image
    padded_img = padarray(img, [size(img, 1) / 2, size(img, 2) / 2]);
    % Getting centered DFT
    img_DFT = fftshift(fft2(padded_img));
end

%% Display Logarithm Function
function display_logarithm(img, fig_title, fig_name)
    img_log_abs = log(abs(img) + 1);
    figure; imshow(img_log_abs, [min(img_log_abs(:)) max(img_log_abs(:))]); colormap("jet"); colorbar; title(fig_title);
    saveas(gcf, fig_name);
end

%% Ideal Low Pass Function
function IdealLowPassFilter(img_DFT, cutoff_freq, original_size)
    % Create a low pass filter of given cutoff frequency
    Filter = zeros(size(img_DFT));
    [p, q] = meshgrid(-size(Filter, 1) / 2:size(Filter, 1) / 2 - 1, -size(Filter, 2) / 2:size(Filter, 2) / 2 - 1);
    valid_indices = (p.^2 + q.^2) <= cutoff_freq^2;
    Filter(valid_indices) = 1;

    % Display the Filter
    display_logarithm(Filter, sprintf('Ideal Low Pass Filter (f = %d)', cutoff_freq), sprintf('../images/ideal_LPF_%d.png', cutoff_freq));

    % Filtering the image
    img_DFT_filtered = img_DFT .* Filter;

    % Display logarithm of the DFT of filtered image
    display_logarithm(img_DFT_filtered, sprintf('DFT of Ideal LP Filtered Image (f = %d)', cutoff_freq), sprintf('../images/barbara_DFT_ideal_LPF_%d.png', cutoff_freq));

    % Extract IDFT from the filtered DFT
    img_filtered = ifft2(ifftshift(img_DFT_filtered));

    % Extract the central part of the image
    img_filtered = img_filtered(original_size(1) / 2 + 1:original_size(1) / 2 + original_size(1), original_size(2) / 2 + 1:original_size(2) / 2 + original_size(2));

    % Display the final filtered image
    figure; imshow(uint8(img_filtered)); colormap("gray"); title(sprintf('Ideal LP Filtered Image (f = %d)', cutoff_freq));
    saveas(gcf, sprintf('../images/barbara_ideal_LPF_%d.png', cutoff_freq));
end

%% Gaussian Low Pass Function
function GaussianLowPassFilter(img_DFT, sigma, original_size)
    % Create a low pass filter of given cutoff frequency
    Filter = zeros(size(img_DFT));
    [p, q] = meshgrid(-size(Filter, 1) / 2:size(Filter, 1) / 2 - 1, -size(Filter, 2) / 2:size(Filter, 2) / 2 - 1);
    Filter = exp(-((p.^2 + q.^2) / (2 * sigma^2)));

    % Display the Filter
    display_logarithm(Filter, sprintf('Gaussian Low Pass Filter (sigma = %d)', sigma), sprintf('../images/gaussian_LPF_%d.png', sigma));

    % Filtering the image
    img_DFT_filtered = img_DFT .* Filter;

    % Display logarithm of the DFT of filtered image
    display_logarithm(img_DFT_filtered, sprintf('DFT of Gaussian LP Filtered Image (sigma = %d)', sigma), sprintf('../images/barbara_DFT_gaussian_LPF_%d.png', sigma));

    % Extract IDFT from the filtered DFT
    img_filtered = ifft2(ifftshift(img_DFT_filtered));

    % Extract the central part of the image
    img_filtered = img_filtered(original_size(1) / 2 + 1:original_size(1) / 2 + original_size(1), original_size(2) / 2 + 1:original_size(2) / 2 + original_size(2));

    % Display the final filtered image
    figure; imshow(uint8(img_filtered)); colormap("gray"); title(sprintf('Gaussian LP Filtered Image (sigma = %d)', sigma));
    saveas(gcf, sprintf('../images/barbara_gaussian_LPF_%d.png', sigma));
end