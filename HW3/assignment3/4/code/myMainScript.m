% Create the image
N = 201;
image = zeros(N, N);
image(:, 101) = 255;

% Compute the Fourier Transform
F = fft2(image);
F_shifted = fftshift(F); % Shift the zero frequency component to the center

% Compute the magnitude
magnitude = abs(F_shifted);
log_magnitude = log(1 + magnitude); % Logarithm for better visibility

% Plot
figure;
imagesc(log_magnitude);
colormap('gray');
colorbar;
title('Log Magnitude of Fourier Transform');
xlabel('Frequency u');
ylabel('Frequency v');
axis equal tight;

% Save the plot
saveas(gcf, '../images/fourier_log_magnitude_image.png');
