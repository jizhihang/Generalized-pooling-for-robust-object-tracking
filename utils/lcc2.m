function alpha = lcc2(X,D,knn)
%% ��һ��LCC���Ż�����
%�ҵ�ÿ��������k���ڵ��ֵ�
%function alpha = lcc2(X,D,mu)
%���룺
%   X����������nxd
%   D���ֵ伯�ϣ�kxd
%   knn:k���ڵĸ���
%�����
%   alpha��ÿ���������ڵı��룬nxk
%�ο������ǣ�Large-scale Image Classification:Fast Feature Extraction and SVM Training

[n,~] =  size(X);
k = size(D,1);
alpha = zeros(n,k);
dist = pdist2(D,X,'euclidean');
[~,id] = sort(dist);
id = id( 1:knn,: );
for i = 1:n
%     [~,I] = findmink(dist(:,i),knn);
    I = id( :,i );
    D1 = D(I,:);    
    a1 = (D1*D1')\D1*X(i,:)';   
%     a1 = ones(1,knn)*0.2;
    alpha(i,I)  = a1;
end
end

% function [Y I] = findmink(X,k)
% %Ѱ��������k����С��Ԫ�ؼ���λ��
% [Y I] = sort(X);
% Y = Y(1:k);
% I = I(1:k);
% end
