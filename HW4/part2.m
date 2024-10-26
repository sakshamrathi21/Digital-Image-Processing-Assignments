clear;

N = 35*5;
d = 112*92;
A = zeros(d,N);
id = zeros(N,1);
count = 0;
for i=1:35
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
V = V(:,end:-1:1); D = diag(D); D = D(end:-1:1);
% compute eigencoefficients
eigcoeffs_training = V'*A;

for k = [2 10 20 50 100 175]
    im = V(:,1:k)*eigcoeffs_training(1:k,100) + meanA; % we are reconstructing the 100^th face (100^th col. of A) using first k eigenvectors corresp. to k largest eigenvalues
    im = reshape(im,112,92);
    imshow (im/max(im(:))); title (sprintf('%d',k));
    pause;
end

Fim = zeros(112,92,25);
for i=1:25
    im = V(:,i); im = reshape(im,112,92); 
    im = (im - min(im(:)))/(max(im(:))-min(im(:)));
    figure(3); subplot(5,5,i); imshow(im);    
    Fim(:,:,i) = abs(fftshift(fft2(im)));
    Fim(:,:,i) = log(squeeze(Fim(:,:,i))+1);
    %figure(4); subplot(5,5,i); imshow(Fim/max(Fim(:)));
end

maxval = max(abs(Fim(:)));
for i=1:25
   figure(4); subplot(5,5,i); imshow(squeeze(Fim(:,:,i))/maxval); 
end