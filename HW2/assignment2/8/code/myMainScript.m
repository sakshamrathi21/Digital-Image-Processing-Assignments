%% MyMainScript

% tic;
% %% Your code here
% LC1 = imread('../images/LC1.png');
% [rows, cols] = size(LC1);
% disp(rows);
% disp(cols);
% L = max(max(LC1));
% disp(L);
% globalHistEqLC1 = histeq(LC1);
% imshow(globalHistEqLC1);
% localHistEqLC1 = transformImage(LC13,7,7);
% imshow(localHistEqLC1);
% function output = transformImage(input,pc,pr)
%     [rows,cols] = size(input);
%     output = zeros(rows,cols);
%     for i = 1:rows
%         for j = 1:cols
%             out = localHistEq(input,i,j,pc,pr);
%             output(i,j) = out((pr + 1)/2,(pc + 1)/2);
%         end;
%     end;
% end;

% function output = localHistEq(input,x,y,pc,pr)
%     out = zeros(pc,pr);
%     [rows,cols] = size(input);
%     r = (pr + 1)/2;
%     c = (pc + 1)/2;
%     for i = 1:(r - 1)
%         for j = 1:(c - 1)
%             if ((x - i > 0) && (y - j > 0))
%                 out(i,j) = input(x - i,y - j);
%             end;
%             if ((x + i <= rows) && (y + j <= cols))
%                 out(r + i,c + j) = input (x + i,y + j);
%             end;
%         end;
%     end;
%     out(r,c) = input(x,y);
%     output = histeq(out);
% end;

% toc;
%% MyMainScript

% tic;
% %% Your code here
% LC1 = imread('../images/LC1.png');
% globalHistEqLC1 = histeq(LC1);

% LC2 = imread('../images/LC2.jpg');
% globalHistEqLC2 = histeq(LC2);
% localHistEqLC1 = transformImage(LC1, 71, 71);
% localHistEqLC2 = transformImage(LC2, 71, 71);
% figure;
% subplot(2, 2, 1);
% imshow(globalHistEqLC1);
% title('Global Histogram Equalization');
% subplot(2, 2, 2);
% imshow(localHistEqLC1, []);
% title('Local Histogram Equalization');
% subplot(2, 2, 3);
% imshow(globalHistEqLC2);
% title('Global Histogram Equalization');
% subplot(2, 2, 4);
% imshow(localHistEqLC2, []);
% title('Local Histogram Equalization');
% toc;

% function output = transformImage(input, pc, pr)
%     [rows, cols] = size(input);
%     output = zeros(rows, cols, 'like', input);
%     padSize = floor(max(pc, pr) / 2);
%     paddedImage = padarray(input, [padSize, padSize], 'replicate', 'both');
    
%     for i = 1:rows
%         for j = 1:cols
%             % Extract the local region
%             localRegion = paddedImage(i:i+pc-1, j:j+pr-1);
            
%             % Perform local histogram equalization
%             output(i, j) = localHistEq(localRegion, ceil(pc/2), ceil(pr/2));
%         end
%     end
% end

% function output = localHistEq(region, centerX, centerY)
%     % Extract the center pixel value
%     centerValue = region(centerX, centerY);
    
%     % Perform histogram equalization on the local region
%     eqRegion = histeq(region);
    
%     % Return the value of the center pixel from the equalized region
%     output = eqRegion(centerX, centerY);
% end
% Start timer
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

%% Create the figure for LC1
figure;
subplot(2, 3, 1);
imshow(LC1);
title('Original LC1');

subplot(2, 3, 2);
imshow(globalHistEqLC1);
title('Global HistEq LC1');

subplot(2, 3, 3);
imshow(localHistEqLC1_7x7, []);
title('Local HistEq 7x7 LC1');

subplot(2, 3, 4);
imshow(localHistEqLC1_31x31, []);
title('Local HistEq 31x31 LC1');

subplot(2, 3, 5);
imshow(localHistEqLC1_51x51, []);
title('Local HistEq 51x51 LC1');

subplot(2, 3, 6);
imshow(localHistEqLC1_71x71, []);
title('Local HistEq 71x71 LC1');
saveas(gcf, 'LC1_hist_eq.png');

%% Create the figure for LC2
figure;
subplot(2, 3, 1);
imshow(LC2);
title('Original LC2');

subplot(2, 3, 2);
imshow(globalHistEqLC2);
title('Global HistEq LC2');

subplot(2, 3, 3);
imshow(localHistEqLC2_7x7, []);
title('Local HistEq 7x7 LC2');

subplot(2, 3, 4);
imshow(localHistEqLC2_31x31, []);
title('Local HistEq 31x31 LC2');

subplot(2, 3, 5);
imshow(localHistEqLC2_51x51, []);
title('Local HistEq 51x51 LC2');

subplot(2, 3, 6);
imshow(localHistEqLC2_71x71, []);
title('Local HistEq 71x71 LC2');

saveas(gcf, 'LC2_hist_eq.png');

toc;

%% Function to perform local histogram equalization
function output = transformImage(input, pc, pr)
    [rows, cols] = size(input);
    output = zeros(rows, cols, 'like', input);
    padSize = floor(max(pc, pr) / 2);
    paddedImage = padarray(input, [padSize, padSize], 'replicate', 'both');
    
    for i = 1:rows
        for j = 1:cols
            % Extract the local region
            localRegion = paddedImage(i:i+pc-1, j:j+pr-1);
            
            % Perform local histogram equalization
            output(i, j) = localHistEq(localRegion, ceil(pc/2), ceil(pr/2));
        end
    end
end

%% Function to perform histogram equalization on a local region
function output = localHistEq(region, centerX, centerY)
    % Perform histogram equalization on the local region
    eqRegion = histeq(region);
    
    % Return the value of the center pixel from the equalized region
    output = eqRegion(centerX, centerY);
end
