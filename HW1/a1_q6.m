im1 = double(imread("goi1.jpg"));
im2 = double(imread("goi2_downsampled.jpg"));
% n = 12; % Number of points
% x1 = zeros(1, n);
% y1 = zeros(1, n);
% x2 = zeros(1, n);
% y2 = zeros(1, n);
% 
% for i=1:n
%     figure(1); 
%     imshow(im1/255); 
%     [x1(i), y1(i)] = ginput(1);
%     figure(2); 
%     imshow(im2/255); 
%     [x2(i), y2(i)] = ginput(1);
% end
% save('selected_points.mat', 'x1', 'y1', 'x2', 'y2');
im1 = double(imread("goi1.jpg"));
im2 = double(imread("goi2_downsampled.jpg"));

% Check if images loaded correctly
if isempty(im1)
    disp('Error: im1 is empty.');
end
if isempty(im2)
    disp('Error: im2 is empty.');
end

% Load the saved points
load('selected_points.mat', 'x1', 'y1', 'x2', 'y2');

% Display the loaded points
disp('Loaded points from Image 1:');
disp([x1' y1']);
disp('Loaded points from Image 2:');
disp([x2' y2']);

movingPoints = [x1' y1'];
fixedPoints = [x2' y2'];

% Compute the affine transformation
tform = fitgeotform2d(movingPoints, fixedPoints, 'affine');

% Check the transformation parameters
disp('Transformation Matrix:');
disp(tform);

% Apply the affine transformation to goi1
outputImage = imwarp(im1, tform, 'OutputView', imref2d(size(im2)));

% Display the original, target, and transformed images
figure;
subplot(1, 3, 1); imshow(im1 / 255); title('Original Image (goi1)');
subplot(1, 3, 2); imshow(im2 / 255); title('Target Image (goi2)');
subplot(1, 3, 3); imshow(outputImage / 255); title('Transformed Image (goi1 to goi2)');


