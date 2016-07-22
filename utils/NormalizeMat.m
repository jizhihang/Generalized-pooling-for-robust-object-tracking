function A = NormalizeMat( A )
%%
% NormalizeMat：对A进行标准化
% A：可以是向量，也可以是矩阵
%    若是向量，则d*1，d维数
%    若是矩阵，则d*n，d维数，n样本个数
%%
A_norm = sqrt( sum(A.*A) );
A = A ./ ( ones( size(A,1),1 )*A_norm + eps );

end

