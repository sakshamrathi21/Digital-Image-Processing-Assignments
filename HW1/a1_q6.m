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

% Load the saved points
load('selected_points.mat', 'x1', 'y1', 'x2', 'y2');

% Display the loaded points
disp('Loaded points from Image 1:');
disp([x1' y1']);
disp('Loaded points from Image 2:');
disp([x2' y2']);

