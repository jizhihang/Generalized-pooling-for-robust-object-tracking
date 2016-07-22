function w = LapRLS(Z,y,U,LLRoptions)
%
% Name: LapRLS
%
% Description:
%    Laplacian Regularized Least Square Regression
%
% Input; Z: labeled data points, each column is a data point
%        y: a column vector indicating the labels of Z
%        U: unlabeled data points
%        LLRoptions: (struct)
%           alpha: graph Laplacian regularizer
%           beta: Tikhonov regularizer
%           k: put an edge between two nodes if and only if they are 
%              among the k nearst neighbors of each other.
%
% Output: w: the coefficients of LLR
%
% Author: Min Yang, 10/2013

X = [Z,U];
dim = size(X,1);
nSmp = size(X,2);

W = constructWLU(Z',y,U',LLRoptions);
D = full(sum(W,2));
L = spdiags(D,0,nSmp,nSmp)-W;

H = Z*Z' + LLRoptions.alpha*X*L*X' + LLRoptions.beta*eye(dim);
w = H\(Z*y);
