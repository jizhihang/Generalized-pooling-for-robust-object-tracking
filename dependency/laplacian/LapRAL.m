function [smpRank,smpCandi] = LapRAL(Z,y,X,selectNum,options)
% LapRAL:  Laplacian Regularized Active Learning with Sequential Optimization 
%
%     [smpRank,smpCandi] = LapRAL(Z,X,selectNum,options)
%   
%
%   Written by Min Yang
%

V = [Z,X];

dim  = size(V,1);
nSel = size(Z,2);
nSmp = size(X,2);
nTol = size(V,2);

if selectNum > nSmp
    error('You are requiring too many points!');
end

W = constructWLU(Z',y,X',options);
D = full(sum(W,2));
L = spdiags(D,0,nTol,nTol)-W;

A = options.alpha*V*L*V' + options.beta*eye(dim);
M = inv(A);
K = V'*M*V;

splitLabel = [true(nSel,1);false(nSmp,1)];
if sum(splitLabel)
    Klabel = K(splitLabel,splitLabel);
    K = K - (K(:,splitLabel)/(Klabel+eye(size(Klabel))))*K(splitLabel,:);
end

splitCandi = true(nTol,1);
if sum(splitLabel)
    splitCandi = splitCandi & ~splitLabel;
end

[smpRank,smpCandi] = LapRALseq(K,selectNum,splitCandi);
smpRank = smpRank-nSel;
smpCandi = smpCandi(nSel+1:end);