function W = constructWLU(L,y,U,options)
%
% Name: constructWLU
%
% Description:
%    Compute similarity matrix of labeled data and unlabeled data
%
% Input; L: labeled data, each row is a data point
%        y: labels of Z
%        U: unlabeled data, each row is a data point
%        options: struct
%            k         -   The parameter needed under 'KNN' NeighborMode.
%                          Default will be 5.
%        isSupervised  -   Default will be 0.
%
% Output: W: similarity matrix
%
% Author: Min Yang, 10/2013

if ~isfield(options,'isSupervised')
    options.isSupervised = 0;
end

if ~isfield(options,'bSelfConnected')
    options.bSelfConnected = 0;
end

% d1 = size(L,2);
% d2 = size(U,2);
% if d1~=d2
%     error('inconsistency between label data and unlabeled data!');
% end

if ~options.isSupervised
    U = [L;U];
    u = size(U,1);
    dist3 = EuDist2(U,U,1);
    dump3 = zeros(u,options.k+1);
    idx3 = dump3;
    for j = 1:options.k+1
        [dump3(:,j),idx3(:,j)] = min(dist3,[],2);
        temp = (idx3(:,j)-1)*u+(1:u)';
        dist3(temp) = 1e100;
    end
    T3 = dump3(:,options.k+1);
    G3 = zeros(u*(options.k+1),3);
    G3(:,1) = repmat((1:u)',[options.k+1,1]);
    G3(:,2) = idx3(:);
    G3(:,3) = dump3(:);
    G3(:,3) = exp(-(G3(:,3).^2)./(T3(G3(:,1)).*T3(G3(:,2))+1e-10));
    Wuu = sparse(G3(:,1),G3(:,2),G3(:,3),u,u);
    W = max(Wuu,Wuu');
    if ~options.bSelfConnected
        W = W - diag(diag(W));
    end
    return;
end

l = size(L,1);
u = size(U,1);

% labeled data
G = zeros(l,l);
Label = unique(y);
nLabel = length(Label);
for i=1:nLabel
    classIdx = find(y==Label(i));
    G(classIdx,classIdx) = 1;
end
Wll = sparse(G);

% labeled data and unlabeled data
dist = EuDist2(L,U,1);
dist1 = dist;
dump1 = zeros(l,options.k);
idx1 = dump1;
for j = 1:options.k
    [dump1(:,j),idx1(:,j)] = min(dist1,[],2);
    temp = (idx1(:,j)-1)*l+(1:l)';
    dist1(temp) = 1e100;
end
T1 = dump1(:,options.k);
G1 = zeros(l*(options.k),3);
G1(:,1) = repmat((1:l)',[options.k,1]);
G1(:,2) = idx1(:);
G1(:,3) = dump1(:);
dist2 = dist';
dump2 = zeros(u,options.k);
idx2 = dump2;
for j = 1:options.k
    [dump2(:,j),idx2(:,j)] = min(dist2,[],2);
    temp = (idx2(:,j)-1)*u+(1:u)';
    dist2(temp) = 1e100;
end
T2 = dump2(:,options.k);
G2 = zeros(u*(options.k),3);
G2(:,1) = repmat((1:u)',[options.k,1]);
G2(:,2) = idx2(:);
G2(:,3) = dump2(:);
G1(:,3) = exp(-(G1(:,3).^2)./(T1(G1(:,1)).*T2(G1(:,2))+1e-10));
G2(:,3) = exp(-(G2(:,3).^2)./(T2(G2(:,1)).*T1(G2(:,2))+1e-10));
W1 = sparse(G1(:,1),G1(:,2),G1(:,3),l,u);
W2 = sparse(G2(:,1),G2(:,2),G2(:,3),u,l);
Wlu = max(W1,W2');


% unlabel data
dist3 = EuDist2(U,U,1);
dump3 = zeros(u,options.k+1);
idx3 = dump3;
for j = 1:options.k+1
    [dump3(:,j),idx3(:,j)] = min(dist3,[],2);
    temp = (idx3(:,j)-1)*u+(1:u)';
    dist3(temp) = 1e100;
end
T3 = dump3(:,options.k+1);
G3 = zeros(u*(options.k+1),3);
G3(:,1) = repmat((1:u)',[options.k+1,1]);
G3(:,2) = idx3(:);
G3(:,3) = dump3(:);
G3(:,3) = exp(-(G3(:,3).^2)./(T3(G3(:,1)).*T3(G3(:,2))+1e-10));
Wuu = sparse(G3(:,1),G3(:,2),G3(:,3),u,u);
Wuu = max(Wuu,Wuu');

W = [Wll,  Wlu;...
     Wlu', Wuu];

if ~options.bSelfConnected
    W = W - diag(diag(W));
end



