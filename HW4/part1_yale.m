clear;

dbdir = '.\CroppedYale\';

NumPeople = 38;
NumTrainingImagesPerPerson = 40;
NumTestImagesPerPerson = 20;

N = NumPeople*NumTrainingImagesPerPerson;
Ntest = NumPeople*NumTestImagesPerPerson;
d = 192*168;

A = zeros(d,N);
id = zeros(N,1);

count = 0;
for i=1:NumPeople+1
    if i == 14, continue; end;
    fprintf (' %d',i);
    if i < 10
        dirc = dir(sprintf('%s\\yaleB0%d\\*.pgm',dbdir,i));
        currdir = sprintf('%s\\yaleB0%d\\',dbdir,i);
    else
        dirc = dir(sprintf('%s\\yaleB%d\\*.pgm',dbdir,i));
        currdir = sprintf('%s\\yaleB%d\\',dbdir,i);
    end
    
    for j=1:NumTrainingImagesPerPerson
        fname = sprintf ('%s\\%s',currdir,dirc(j).name);
        im = double(imread(fname));
        
        count = count+1;
        A(:,count) = im(:);
        id(count) = i; % record the identity of the person
    end
end
A = single(A);
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

fprintf ('\n');

TestImages = zeros(d,Ntest);
testid = zeros(Ntest,1);

count = 0;
for i=1:NumPeople+1
    if i == 14, continue; end;
    fprintf (' %d',i);
    if i < 10
        dirc = dir(sprintf('%s\\yaleB0%d\\*.pgm',dbdir,i));
        currdir = sprintf('%s\\yaleB0%d\\',dbdir,i);
    else
        dirc = dir(sprintf('%s\\yaleB%d\\*.pgm',dbdir,i));
        currdir = sprintf('%s\\yaleB%d\\',dbdir,i);
    end        

    for j=NumTrainingImagesPerPerson+1:NumTrainingImagesPerPerson+NumTestImagesPerPerson    
        fname = sprintf ('%s\\%s',currdir,dirc(j).name);
        im = double(imread(fname)); 

        count = count+1;
        TestImages(:,count) = im(:)-meanA;
        testid(count) = i;
    end
end
eigcoeffs_im = V'*(TestImages);

for k = [1 2 3 5 10 20 30 50 55 60 65 66 67 70 75 77 100 200 300 500 1000]
    rec_rate = 0;
    rec_rate_remove3 = 0;
    for i=1:Ntest        
        diffs = eigcoeffs_training - repmat(eigcoeffs_im(:,i),1,N);
        diffs1 = sum(diffs(1:k,:).^2,1);
        [~,minindex] = min(diffs1); % id(minindex) dis the identity of the nearest neighbor
        rec_rate = rec_rate + (testid(i) == id(minindex));

        diffs1 = sum(diffs(4:k+3,:).^2,1);
        [minval,minindex] = min(diffs1); % id(minindex) dis the identity of the nearest neighbor
        rec_rate_remove3 = rec_rate_remove3 + (testid(i) == id(minindex));
    end
    rec_rate = rec_rate/Ntest;
    rec_rate_remove3 = rec_rate_remove3/Ntest;
    fprintf ('\nFor k= %d,Rec rate = %f, Rec rate removing three = %f',k,100*rec_rate,100*rec_rate_remove3);
end

% For k= 1,Rec rate = 2.368421, Rec rate removing three = 6.315789
% For k= 2,Rec rate = 3.026316, Rec rate removing three = 11.973684
% For k= 3,Rec rate = 4.605263, Rec rate removing three = 14.605263
% For k= 5,Rec rate = 9.473684, Rec rate removing three = 26.315789
% For k= 10,Rec rate = 19.868421, Rec rate removing three = 39.736842
% For k= 20,Rec rate = 29.868421, Rec rate removing three = 50.921053
% For k= 30,Rec rate = 35.131579, Rec rate removing three = 55.789474
% For k= 50,Rec rate = 40.789474, Rec rate removing three = 60.657895
% For k= 55,Rec rate = 40.921053, Rec rate removing three = 61.447368
% For k= 60,Rec rate = 41.973684, Rec rate removing three = 61.315789
% For k= 65,Rec rate = 42.500000, Rec rate removing three = 61.842105
% For k= 66,Rec rate = 42.368421, Rec rate removing three = 62.631579
% For k= 67,Rec rate = 42.368421, Rec rate removing three = 62.763158
% For k= 70,Rec rate = 42.763158, Rec rate removing three = 62.894737
% For k= 75,Rec rate = 43.157895, Rec rate removing three = 62.894737
% For k= 77,Rec rate = 43.289474, Rec rate removing three = 63.026316
% For k= 100,Rec rate = 44.605263, Rec rate removing three = 63.684211
% For k= 200,Rec rate = 45.657895, Rec rate removing three = 65.789474
% For k= 300,Rec rate = 46.315789, Rec rate removing three = 66.052632
% For k= 500,Rec rate = 46.973684, Rec rate removing three = 66.315789
% For k= 1000,Rec rate = 46.973684, Rec rate removing three = 66.710526>> 
