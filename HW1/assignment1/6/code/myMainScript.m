% The following few lines of the code have been commented, because we have
% already stored the coordinates of the 12 pair of points in
% "selected_points.mat". But these can be used to take the user input
% again:

% Reading the two images, casting them into double and storing them into
% the two variables:
% im1 = double(imread("../images/goi1.jpg"));
% im2 = double(imread("../images/goi2_downsampled.jpg"));

% The number of points:
% n = 12;

% The pair of points where we will store user input:
% x1 = zeros(1, n);
% y1 = zeros(1, n);
% x2 = zeros(1, n);
% y2 = zeros(1, n);

% We will display the images one by one and take user input (through mouse
% click):
% for i=1:n
%     figure(1); 
%     imshow(im1/255); 
%     [x1(i), y1(i)] = ginput(1);
%     figure(2); 
%     imshow(im2/255); 
%     [x2(i), y2(i)] = ginput(1);
% end

% We will save the points in this file for future use:
% save('selected_points.mat', 'x1', 'y1', 'x2', 'y2');

% Reading the two images, casting them into double and storing them into
% the two variables:
im1 = double(imread("../images/goi1.jpg"));
im2 = double(imread("../images/goi2_downsampled.jpg"));

% Load the saved points
load('selected_points.mat', 'x1', 'y1', 'x2', 'y2');

% We intend to transform the points from img1 to img2, so we call the first
% set of points as movingpoints and second set as fixed points:
movingPoints = [x1' y1'];
fixedPoints = [x2' y2'];
n = size(movingPoints, 1); % n = 12 (we have already set it before)

% The matrices which we will be using for calculating the transformation
% matrix. A will contain the points from img1, b will contain the points
% from img2.
A = zeros(3, n);
b = zeros(3, n);

% Every column of A will of the form [x, y, 1]. Same for b.
for i = 1:n
    A(1, i) = movingPoints(i, 1);
    A(2, i) = movingPoints(i, 2);
    A(3, i) = 1;
    b(1, i) = fixedPoints(i, 1);
    b(2, i) = fixedPoints(i, 2);
    b(3, i) = 1;
end

% T is the transformation matrix. The equation which we will be solving is
% TA = b. This is equivalent to (A^T)(T^T) = (b^T). This equation can be
% solved using "\" in MATLAB, after which we take the transpose of the
% result matrix to get T:
T_transpose = (A') \ (b');
T = T_transpose';

% Since we are using reverse warping, we need to calculate the inverse of
% T:
invT = inv(T);

% Calculating the size of the first image:
[rows, cols, channels] = size(im1);

% Initializing the warped image with zeroes and to be of the same size as that of img2
warpedImg = zeros(size(im2), 'uint8');

% Iterating over the points of img2 and calculating the corresponding point
% in img1
for r = 1:size(im2, 1)
    for c = 1:size(im2, 2)
        % Calculating the coordinates with respect to (c, r) for img1 using
        % T:
        originalCoords = invT * [c; r; 1];
        xOriginal = originalCoords(1);
        yOriginal = originalCoords(2);
        % Rounding them to the nearest integer:
        xNearest = round(xOriginal);
        yNearest = round(yOriginal);
        % Checking if they are in bounds, if yes, then we will take the
        % intensity values from im1:
        if xNearest >= 1 && xNearest <= cols && yNearest >= 1 && yNearest <= rows
            warpedImg(r, c, :) = im1(yNearest, xNearest, :);
        end
    end
end

% Concatenating the original and the transformed images side by side:
combinedImgNear = [im1, im2, warpedImg];
% Displaying the final image and giving it an appropriate title:
% imshow(combinedImgNear);
% title('Original Image (Left), Target Image (Middle), Warped Image (Right) using nearest neighbout interpolation');

% Now we need to use bilinear interpolation, instead of nearest neighbour
% interpolation:
warpedImg = zeros(size(im2), 'uint8');

% Iterating over the points of img2 and calculating the corresponding point
% in img1:
for r = 1:size(im2, 1)
    for c = 1:size(im2, 2)
        % Calculating the coordinates with respect to (c, r) for img1 using
        % T:
        originalCoords = invT * [c; r; 1];
        xOriginal = originalCoords(1);
        yOriginal = originalCoords(2);
        % Calculating the coresponding lower and upper (floor and ceiling)
        % values for each point:
        x1 = floor(xOriginal);
        y1 = floor(yOriginal);
        x2 = x1 + 1;
        y2 = y1 + 1;
        % Differences for calculating the area of the 4 rectangles:
        dx = xOriginal - x1;
        dy = yOriginal - y1;
        pixelValue = zeros(1, channels);
        % Now, based on the position of the current point, we might not
        % find all the 4 neighbours in bounds, so we will check for bounds,
        % weigh them with the areas and then add the weighted sums:
        if x1 >= 1 && x1 <= cols && y1 >= 1 && y1 <= rows
            pixelValue = (1-dx)*(1-dy)*double(im1(y1, x1, :));
        end
        if x2 >= 1 && x2 <= cols && y1 >= 1 && y1 <= rows
            pixelValue = pixelValue + dx*(1-dy)*double(im1(y1, x2, :));
        end
        if x1 >= 1 && x1 <= cols && y2 >= 1 && y2 <= rows
            pixelValue = pixelValue + (1-dx)*dy*double(im1(y2, x1, :));
        end
        if x2 >= 1 && x2 <= cols && y2 >= 1 && y2 <= rows
            pixelValue = pixelValue + dx*dy*double(im1(y2, x2, :));
        end
        % Converting into integer and then assigning:
        warpedImg(r, c, :) = uint8(pixelValue);
    end
end

% Concatenating the images side by side
combinedImgBil = [im1, im2, warpedImg];

% Displaying the final image and giving it an appropriate title:
% imshow(combinedImgBil);
% title('Original Image (Left), Target Image (Middle), Warped Image using Bilinear Interpolation (Right)');

% Displaying the entire set for comaprison:
% Concatenate the images horizontally
combinedAll = cat(1, combinedImgNear, combinedImgBil);

% Display the final image and give it an appropriate title
imshow(combinedAll);
title('Nearest Neighbor: Original (Left), Target (Middle), Warped (Right) | Bilinear: Original (Left), Target (Middle), Warped (Right)');