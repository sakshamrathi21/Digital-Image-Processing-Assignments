% %% MyMainScript

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
% localHistEqLC1 = transformImage(LC1,7,7);
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

tic;
%% Your code here
LC1 = imread('../images/LC1.png');
globalHistEqLC1 = histeq(LC1);

LC2 = imread('../images/LC2.jpg');
globalHistEqLC2 = histeq(LC2);
localHistEqLC1 = transformImage(LC1, 71, 71);
localHistEqLC2 = transformImage(LC2, 71, 71);
figure;
subplot(2, 2, 1);
imshow(globalHistEqLC1);
title('Global Histogram Equalization');
subplot(2, 2, 2);
imshow(localHistEqLC1, []);
title('Local Histogram Equalization');
subplot(2, 2, 3);
imshow(globalHistEqLC2);
title('Global Histogram Equalization');
subplot(2, 2, 4);
imshow(localHistEqLC2, []);
title('Local Histogram Equalization');
toc;

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

function output = localHistEq(region, centerX, centerY)
    % Extract the center pixel value
    centerValue = region(centerX, centerY);
    
    % Perform histogram equalization on the local region
    eqRegion = histeq(region);
    
    % Return the value of the center pixel from the equalized region
    output = eqRegion(centerX, centerY);
end
