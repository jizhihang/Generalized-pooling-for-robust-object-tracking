function A = NormalizeMat( A )
%%
% NormalizeMat����A���б�׼��
% A��������������Ҳ�����Ǿ���
%    ������������d*1��dά��
%    ���Ǿ�����d*n��dά����n��������
%%
A_norm = sqrt( sum(A.*A) );
A = A ./ ( ones( size(A,1),1 )*A_norm + eps );

end

