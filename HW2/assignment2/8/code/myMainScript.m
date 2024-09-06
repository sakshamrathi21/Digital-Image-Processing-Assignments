%% MyMainScript
tic;

% Load the images
LC1 = imread('../images/LC1.png');
LC2 = imread('../images/LC2.jpg');

% Global Histogram Equalization
globalHistEqLC1 = histeq(LC1);
globalHistEqLC2 = histeq(LC2);

% Local Histogram Equalization with patch sizes 7x7, 31x31, 51x51 for LC1
localHistEqLC1_7x7 = transformImage(LC1, 7, 7);
localHistEqLC1_31x31 = transformImage(LC1, 31, 31);
localHistEqLC1_51x51 = transformImage(LC1, 51, 51);
localHistEqLC1_71x71 = transformImage(LC1, 71, 71);

% Local Histogram Equalization with patch sizes 7x7, 31x31, 51x51 for LC2
localHistEqLC2_7x7 = transformImage(LC2, 7, 7);
localHistEqLC2_31x31 = transformImage(LC2, 31, 31);
localHistEqLC2_51x51 = transformImage(LC2, 51, 51);
localHistEqLC2_71x71 = transformImage(LC2, 71, 71);

titleFontSize = 10;

% Set title font size
titleFontSize = 12; 

figure;
imshow(globalHistEqLC1);
title('Global HistEq', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC1_globalHistEq.png');

figure;
imshow(localHistEqLC1_7x7, []);
title('Local HistEq 7x7', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC1_localHistEq_7x7.png');

figure;
imshow(localHistEqLC1_31x31, []);
title('Local HistEq 31x31', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC1_localHistEq_31x31.png');

figure;
imshow(localHistEqLC1_51x51, []);
title('Local HistEq 51x51', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC1_localHistEq_51x51.png');

figure;
imshow(localHistEqLC1_71x71, []);
title('Local HistEq 71x71', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC1_localHistEq_71x71.png');


figure;
imshow(globalHistEqLC2);
title('Global HistEq', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC2_globalHistEq.png');

figure;
imshow(localHistEqLC2_7x7, []);
title('Local HistEq 7x7', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC2_localHistEq_7x7.png');

figure;
imshow(localHistEqLC2_31x31, []);
title('Local HistEq 31x31', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC2_localHistEq_31x31.png');

figure;
imshow(localHistEqLC2_51x51, []);
title('Local HistEq 51x51', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC2_localHistEq_51x51.png');

figure;
imshow(localHistEqLC2_71x71, []);
title('Local HistEq 71x71', 'FontSize', titleFontSize);
saveas(gcf, '../images/LC2_localHistEq_71x71.png');



toc;

%% Function to perform local histogram equalization
function output = transformImage(input, pr, pc)
    [rows, cols] = size(input);
    output = zeros(rows, cols);
    padSize = floor(max(pr, pc)/2);
    paddedImage = padarray(input, [padSize, padSize], 'replicate', 'both');
    
    for i = ceil(pr/2):(floor(pr/2) + rows) 
        for j = ceil(pc/2):(floor(pc/2) + cols)
            localRegion = paddedImage(i - padSize:i + padSize, j - padSize:j + padSize);            
            output(i - floor(pr/2), j - floor(pc/2)) = localHistEq(localRegion, ceil(pr/2), ceil(pc/2));
        end
    end
end

%% Function to perform histogram equalization on a local region
function output = localHistEq(region, centerX, centerY)
    eqRegion = histeq(region);    
    output = eqRegion(centerX, centerY);
end
