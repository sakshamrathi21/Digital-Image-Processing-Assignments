clear;
clc;

k = 50;

N = 32*6;
d = 112*92;
A = zeros(d,N);
id = zeros(N,1);
count = 0;
for i=1:32
    for j=1:6
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
V = V(:,end:-1:1);
% compute eigencoefficients
eigcoeffs_training = V'*A;

%%% we will pick the threshold tau for verification as follows: Consider person 'i'. For all
%%% pairs of images belonging to the same person 'i', we will compute the
%%% squared distance between eigencoefficients, and take the maximum out of
%%% these values denoting it as taus(i). We will repeat this for every person, and then take the
%%% median out of all these values, i.e. median(taus). You could also take
%%% mean(taus) or max(tau).
for i=1:32
    eigcoeffs_training_perperson = eigcoeffs_training(:,id == i);    
    dist = zeros(6,6);
    for k1=1:6
        for k2=1:6
            dist(k1,k2) = sum(eigcoeffs_training_perperson(1:k,k1)-eigcoeffs_training_perperson(1:k,k2)).^2;
        end
    end
    taus(i) = max(dist(:));    
end
tau = median(taus)*0.5;
fprintf ('\nThreshold tau for verification = %f',tau);


% NOTE: the verification system has to decide whether or not two given
% images belong to the same person. If the squared distance between the
% eigencoefficients of such images < tau, then it concludes that these
% imageas are indeed of one and the same person. Otherwise, it conlcudes
% that they belong to two different people.

% false negative rate: if two images really belong to the same person, yet
% their squared eigencoefficient distance is >= tau, then it is a false
% negative.
% false positive rate: if two images really belong to different people, but
% the verification system marks them as one and the same individual
% (because the distance was < tau),then it is a false positive.

false_neg = 0;
for i=1:32
    for j=7:10
        fname = sprintf ('s%d\\%d.pgm',i,j);
        im = double(imread(fname));   
        eigcoeffs_im = V'*(im(:)-meanA); % note: V as well as meanA was computed only in the training phase!
        
        diffs = eigcoeffs_training - repmat(eigcoeffs_im,1,N);
        diffs = sum(diffs(1:k,:).^2,1);
        [minval,minindex] = min(diffs); % id(minindex) is the identity of the nearest neighbor
        if minval >= tau, false_neg = false_neg + 1; end;
    end
end
false_neg = false_neg/(32*4);
fprintf ('\nFor k= %d, false negative rate = %f',k,100*false_neg);

false_pos = 0;
for i=33:40
    for j=1:10
        fname = sprintf ('s%d\\%d.pgm',i,j);
        im = double(imread(fname));   
        eigcoeffs_im = V'*(im(:)-meanA); % note: V as well as meanA was computed only in the training phase!
        
        diffs = eigcoeffs_training - repmat(eigcoeffs_im,1,N);
        diffs = sum(diffs(1:k,:).^2,1);
        [minval,minindex] = min(diffs); % id(minindex) is the identity of the nearest neighbor
        if minval < tau, false_pos = false_pos + 1; end;
    end
end
false_pos = false_pos/(8*10);
fprintf ('\nFor k= %d, false positive rate = %f',k,100*false_pos);

