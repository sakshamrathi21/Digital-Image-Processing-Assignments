function  [U,S,V] = MySVD(A)

[m,n] = size(A);
min_mn = min ([m n]);

% first the "wrong" method
[U,D] = eig(A*A');
if m >= n,
    S = sqrt(D(1:m,1:n));
else
   S = real(sqrt(D));
   S = [S zeros(m,n-m)];
end
[V,~] = eig(A'*A);
fprintf('\nError between A and USV^T is %f',sum(sum((A-U*S*V').^2)));

% now the correct method
[U,D] = eig(A*A');
V = A'*U;
ncols = size(V,2);
for i=1:ncols, V(:,i) = V(:,i)/norm(V(:,i)); end;
S = sqrt(D);
fprintf('\nError between A and USV^T is %f',sum(sum((A-U*S*V').^2)));

