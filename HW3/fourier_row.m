clear;
clc;

A = zeros(201);
A(101,:) = 255;

FA = fftshift(fft2(A));
lFA = log(abs(FA)+1);
imshow(lFA,[min(lFA(:)) max(lFA(:))]); colormap('jet'); colorbar;
impixelinfo;