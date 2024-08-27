barbara = imread('../images/barbara256.png');
kodak = imread('../images/kodak24.png');
barbara = double(barbara);
kodak = double(kodak);
sigma1 = 5;
sigma2 = 10;

noisy_barbara_5 = barbara + sigma1 * randn(size(barbara));
noisy_kodak_5 = kodak + sigma1 * randn(size(kodak));

noisy_barbara_10 = barbara + sigma2 * randn(size(barbara));
noisy_kodak_10 = kodak + sigma2 * randn(size(kodak));

figure;
subplot(2,3,1), imshow(uint8(barbara)), title('Original Barbara');
subplot(2,3,2), imshow(uint8(noisy_barbara_5)), title('Barbara with Noise (\sigma = 5)');
subplot(2,3,3), imshow(uint8(noisy_barbara_10)), title('Barbara with Noise (\sigma = 10)');
subplot(2,3,4), imshow(uint8(kodak)), title('Original Kodak');
subplot(2,3,5), imshow(uint8(noisy_kodak_5)), title('Kodak with Noise (\sigma = 5)');
subplot(2,3,6), imshow(uint8(noisy_kodak_10)), title('Kodak with Noise (\sigma = 10)');

imwrite(uint8(noisy_barbara_5), '../images/noisy_barbara_5.png');
imwrite(uint8(noisy_kodak_5), '../images/noisy_kodak_5.png');
imwrite(uint8(noisy_barbara_10), '../images/noisy_barbara_10.png');
imwrite(uint8(noisy_kodak_10), '../images/noisy_kodak_10.png');
