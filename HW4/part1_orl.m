clear;

N = 32*6;
Ntest = 32*4;
d = 112*92;
A = zeros(d,N);
id = zeros(N,1);
count = 0;
for i=1:32
    for j=1:5
        fname = sprintf ('s%d\\%d.pgm',i,j);
        im = double(imread(fname));   
        count = count+1;
        A(:,count) = im(:);
        id(count) = i; % record the identity of the person
    end
end
meanA = mean(A,2);
A = A - repmat(meanA,1,N);
L = A'*A; % C = A*A' would be too big
[V,D] = eig(L);
V = A*V; % if v is an eigvec of L, then Av is an eigvec of C with the same eigenvalue
% multiplying v by Av destroys its unit-normality property, so we divide it
% by its magnitude as below
for i=1:N, V(:,i) = V(:,i)/norm(V(:,i)); end; 

% matlab stores eigenvectors in increasing order of eigenvalues. To make it convenient take
% first k eigenvectors, we will reverse the order of the columns of V
V = V(:,end-1:-1:1);
% compute eigencoefficients
eigcoeffs_training = V'*A;

for k = [1 2 3 5 10 20 30 50 55 60 65 66 67 68 69 75 100 150 155 160 165 170 174]
rec_rate = 0;
for i=1:32
    for j=7:10
        fname = sprintf ('s%d\\%d.pgm',i,j);
        im = double(imread(fname));   
        eigcoeffs_im = V'*(im(:)-meanA); % note: V as well as meanA was computed only in the training phase!
        
        diffs = eigcoeffs_training - repmat(eigcoeffs_im,1,N);
        diffs = sum(diffs(1:k,:).^2,1);
        [minval,minindex] = min(diffs); % id(minindex) is the identity of the nearest neighbor
        rec_rate = rec_rate + (i == id(minindex));
    end
end
rec_rate = rec_rate/Ntest;
fprintf ('\nFor k= %d,Rec rate = %f',k,100*rec_rate);
end

% With 32 people, 6 training images per person and 4 test images per person
% For k= 1,Rec rate = 8.593750
% For k= 2,Rec rate = 34.375000
% For k= 3,Rec rate = 46.093750
% For k= 5,Rec rate = 71.875000
% For k= 10,Rec rate = 84.375000
% For k= 20,Rec rate = 85.156250
% For k= 30,Rec rate = 85.937500
% For k= 50,Rec rate = 84.375000
% For k= 55,Rec rate = 83.593750
% For k= 60,Rec rate = 83.593750
% For k= 65,Rec rate = 82.812500
% For k= 66,Rec rate = 83.593750
% For k= 67,Rec rate = 82.812500
% For k= 68,Rec rate = 81.250000
% For k= 69,Rec rate = 81.250000
% For k= 75,Rec rate = 81.250000
% For k= 100,Rec rate = 82.031250
% For k= 150,Rec rate = 78.906250
% For k= 155,Rec rate = 78.906250
% For k= 160,Rec rate = 82.812500
% For k= 165,Rec rate = 87.500000
% For k= 170,Rec rate = 89.843750
% For k= 174,Rec rate = 90.625000

% With 35 people, 5 training images and 5 test images per person
% For k= 1,Rec rate = 18.285714
% For k= 2,Rec rate = 36.000000
% For k= 3,Rec rate = 48.571429
% For k= 5,Rec rate = 68.000000
% For k= 10,Rec rate = 84.000000
% For k= 20,Rec rate = 88.571429
% For k= 30,Rec rate = 87.428571
% For k= 50,Rec rate = 90.857143
% For k= 75,Rec rate = 90.285714
% For k= 100,Rec rate = 88.571429
% For k= 150,Rec rate = 90.857143
% For k= 155,Rec rate = 90.857143
% For k= 160,Rec rate = 90.285714
% For k= 165,Rec rate = 90.285714
% For k= 170,Rec rate = 90.285714
% For k= 174,Rec rate = 90.285714
