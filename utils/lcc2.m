function alpha = lcc2(X,D,knn)
%% 另一种LCC的优化方法
%找到每个样本的k近邻的字典
%function alpha = lcc2(X,D,mu)
%输入：
%   X：样本集，nxd
%   D：字典集合，kxd
%   knn:k近邻的个数
%输出：
%   alpha：每个样本对于的编码，nxk
%参考文章是：Large-scale Image Classification:Fast Feature Extraction and SVM Training

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
% %寻找向量中k个最小的元素及其位置
% [Y I] = sort(X);
% Y = Y(1:k);
% I = I(1:k);
% end
