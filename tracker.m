

%% Initial

config;
%% ------save tracking results
resultDir = [ 'Result_' int2str(temp_p) '\' ]; %
resultpath = [ resultDir title '\' ];  
if exist(resultpath,'dir') == 0 
    mkdir(resultpath);
end

template_size = [32,32];% size of template
template_num = 25;% number of templates

affparam = [p(1), p(2), p(3)/template_size(1), p(5), p(4)/p(3), 0];% affine parameter setting


imFiles = dir( [datapath '*.jpg'] );
frame_num = length(imFiles);
im = imread( [datapath '0001.jpg'] );
[frame_height, frame_width] = size(im(:,:,1));

%% ---size and number of patches------
patch_size = [16,16];
patch_step = 8;
patch_num(1) = length( patch_size(1) : patch_step : template_size(1) );
patch_num(2) = length( patch_size(2) : patch_step : template_size(2) );

%% ---size and number of local features
local_size = [6,6];
local_step = 3;
local_num(1) = length( local_size(1) : local_step : patch_size(1) );
local_num(2) = length( local_size(2) : local_step : patch_size(2) );

%---incremental PCA for tempate update----
tmpl.mean = [];
tmpl.basis = [];
tmpl.eigval = [];
tmpl.num = 0;

glo_gauss_num = 5;   %number of global gmms
coord_gauss_num = 3; %number of coordinate gmms
local_gauss_num = 2; %number of local gmms

angle = 0;%

%----------LCC coding-----------------
patch_dic_num = 30;  %number of dictionary items
knn = 3;   %number of nearest dictionary iterms

%---positive and negative samples
pos_num = 25; %positive
neg_num = 200; %negative

max_num = 72; %max number of templates in template pool.
%%%%%%%%%%
SelectPatchID;

% Laplacian Regularized Regression parameters
LLRoptions.alpha = 1e-1;      % graph Laplacian regularizer
LLRoptions.beta  = 1e-3;      % Tikhonov regularizer
LLRoptions.k = 7;
LLRoptions.isSupervised = 0;

%% obtain dictionary and FV
all_affparam = repmat(affparam(:),1,template_num);
temp = zeros(6,template_num);
temp(1,:) = [-1 1  0 0 -1 1 -1 1 0 -2 2  0 0 -2 2 -2  2 -1 1 -1 1 -2 2 -2 2];
temp(2,:) = [ 0 0 -1 1 -1 1 1 -1 0  0 0 -2 2 -2 2  2 -2 -2 2 2 -2 -1 1 1 -1];
all_affparam = all_affparam + temp;

img_color = imread( [datapath imFiles(1).name] );
if size(img_color,3) == 1
    img_color = cat(3, img_color, img_color, img_color);
end
img = RGB2Lab(img_color);

template_set = WarpImgColor(img, affparam2mat(all_affparam), template_size);
template_fea = GetPatchColor(template_set, local_size, local_step);
result_track = template_set(:,:,:,9);


patch_coord = GetPatchCoord( template_size, local_size, local_step );%get coordinate of each path
patch_coord = 2*patch_coord;
temp_patch_coord = repmat( patch_coord, 1, template_num );
temp_patch_coord = reshape( temp_patch_coord, 2, size(temp_patch_coord,2)/template_num, template_num );

template_fea = [ template_fea; temp_patch_coord ];%intensity + coordinates

%------------obtain LCC dictionary---
pospatch = reshape( template_fea, size(template_fea,1), size( template_fea,2 )*size( template_fea,3 )  ); 
[patch_dic,~] = vl_kmeans( pospatch, patch_dic_num, 'Initialization', 'plusplus');%

%-------------LCC of local feature in each template--------------
template_alpha = lcc2(pospatch',patch_dic',knn);
template_alpha = template_alpha';

%-------------GMM model for global template-----------
[temp_gmm.mean, temp_gmm.cov, temp_gmm.w] = vl_gmm( template_alpha, glo_gauss_num );%train gmm
template_alpha = reshape( template_alpha, patch_dic_num, size( template_fea,2 ), size( template_fea,3 ) );%10*81*25
temp_FV = [];
for i=1:template_num
    temp_FV(:,i) = vl_fisher( template_alpha(:,:,i), temp_gmm.mean, temp_gmm.cov, temp_gmm.w, 'Improved' );%FV for each gmm
end

[ temp_coord, all_temp_coord ] = GetCoordinateColor( template_set, angle ); %
[coord_gmm.mean, coord_gmm.cov, coord_gmm.w] = vl_gmm( all_temp_coord, coord_gauss_num );% train coordinate gmm
temp_coord_FV = [];
for i=1:template_num
    temp_coord_FV(:,i) = vl_fisher( temp_coord(i).c, coord_gmm.mean, coord_gmm.cov, coord_gmm.w, 'Improved' );%calculate FV
end

temp_FV = [temp_FV;temp_coord_FV];
%-------------LCC of local feature for each patch ----------
template_patch_alpha = template_alpha(:,select_patch_id,:);
template_patch_alpha = reshape(template_patch_alpha,size(template_patch_alpha,1),prod(local_num), prod(patch_num)*template_num );

%--------------multi gmms based on patches---------
GMM_num = prod(patch_num);
for i=1:GMM_num
    train_data = template_patch_alpha( :,:,[i:GMM_num:prod(patch_num)*template_num ] );
    train_data = reshape( train_data, patch_dic_num, prod(local_num)*template_num );
    [ patch_gmm(i).mean, patch_gmm(i).cov, patch_gmm(i).w ] = vl_gmm( train_data, local_gauss_num ); %train local gmm
end

temp_patch_FV = [];
l = 0;
for i=1:template_num
    for j=1:GMM_num
        l = l + 1;
        temp_patch_FV(:,l) = vl_fisher( template_patch_alpha(:,:,l), patch_gmm(j).mean, patch_gmm(j).cov, patch_gmm(j).w, 'Improved' );%每个模板的每个patch块的FV
    end
end
%--------------negative samples sampling-------------
[~, neg_samples] = GetSamplesColor(img, affparam, template_size, pos_num, neg_num, affsig);%obtian negative samples
neg_fea = GetPatchColor( neg_samples, local_size, local_step );%36*81*100，
neg_patch_coord = repmat( patch_coord, 1, neg_num );
neg_patch_coord = reshape( neg_patch_coord, 2, size(neg_patch_coord,2)/neg_num, neg_num );%coordiante

neg_fea = [ neg_fea; neg_patch_coord ];%

%--------------LCC of negative samples------------
[temp_size1,temp_size2,temp_size3] = size( neg_fea );
neg_fea = reshape( neg_fea, temp_size1, temp_size2*temp_size3 );
neg_alpha = lcc2(neg_fea',patch_dic',knn);%
neg_alpha = neg_alpha';
neg_alpha = reshape( neg_alpha, patch_dic_num, temp_size2, temp_size3 );%10*81*100

neg_patch_alpha = neg_alpha(:,select_patch_id,:);
neg_patch_alpha = reshape(neg_patch_alpha,size(neg_patch_alpha,1),prod(local_num), prod(patch_num)*neg_num );
%-------------FV of negative samples------------
neg_FV = [];
for i=1:neg_num
    neg_FV(:,i) = vl_fisher( neg_alpha(:,:,i), temp_gmm.mean, temp_gmm.cov, temp_gmm.w, 'Improved' );%
end

[ neg_coord, ~ ] = GetCoordinate( neg_samples, angle ); 
neg_coord_FV = [];
for i=1:neg_num
    neg_coord_FV(:,i) = vl_fisher( neg_coord(i).c, coord_gmm.mean, coord_gmm.cov, coord_gmm.w, 'Improved' );%每个负样本坐标点形成的FV
end

neg_FV = [neg_FV;neg_coord_FV];

neg_patch_FV = [];
l = 0;
for i=1:neg_num
    for j=1:GMM_num
        l = l + 1;
        neg_patch_FV(:,l) = vl_fisher( neg_patch_alpha(:,:,l), patch_gmm(j).mean, patch_gmm(j).cov, patch_gmm(j).w, 'Improved' );%每个负样本的每个patch块的FV
    end
end
%% collect training samples
global_pos_FV = temp_FV; %global positive samples
global_neg_FV = neg_FV;  %global negitive samples
local_pos_FV = temp_patch_FV;%local positive samples
local_neg_FV = neg_patch_FV; %local negtive samples

update_flag = 'true'; %update flag of classifier

%% start tracking
%-------initialization of incremental PCA -----------------------
update_vectors = reshape( template_set, prod(template_size)*3, template_num );
tmpl.mean = mean(update_vectors,2);%mean
[tmpl.basis,tmpl.eigval,tmpl.mean,tmpl.num] = sklm(update_vectors,tmpl.basis,tmpl.eigval,tmpl.mean,tmpl.num);%
update_vectors = [];
%-------particles ---------------
all_affparam = repmat( affparam(:),1,particle_num );
all_affparam = all_affparam + randn(6,particle_num).*repmat( affsig(:),1,particle_num );
all_affparam(:,end) = affparam(:);
CheckParticle;%particle check
%------show tracking results--------------------------------- 
 ShowResult(img_color,affparam,1,template_size);
%% ----- save tracking results----------------------------------
% path = [resultpath imFiles(1).name];
% fff = getframe(gcf);
% imwrite(fff.cdata,path);

if exist([resultDir title '\PosInfo.txt'],'file') ~= 0   
    dos( ['del ' pwd '\' resultDir title '\PosInfo.txt'] ); 
    if exist([resultDir title '\PosInfo.txt'],'file') == 0
        disp('Delete PosInfo.txt success！');
    else
        disp('Delete PosInfo.txt failed！');
    end
else
    disp('new PosInfo.txt！');
end
FV_SavePosInfo(resultpath,affparam,template_size);
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---start from 2th frame--------------
pos_sample_set = [];
temp = temp(:,1:9);

for f = 2 : frame_num
    disp( ['frame: ' num2str(f)] );
    img_color = imread( [datapath imFiles(f).name] );
%     if size(img_color,3) == 3
%         img = double(rgb2gray(img_color))/256;
%     else
%         img = double(img_color)/256;
%     end
    if size(img_color,3) == 1
        img_color = cat(3, img_color, img_color, img_color);
    end
    img = RGB2Lab(img_color);

    Y_mat = WarpImgColor(img, affparam2mat(all_affparam), template_size);
    Y_fea = GetPatchColor(Y_mat, local_size, local_step);
    
    
    Y_patch_coord = repmat( patch_coord, 1, particle_num );
    Y_patch_coord = reshape( Y_patch_coord, 2, size(Y_patch_coord,2)/particle_num, particle_num );%coordinate

    Y_fea = [ Y_fea; Y_patch_coord ];
    
    %-----LCC of candidates
    
    [temp_size1,temp_size2,temp_size3] = size( Y_fea );
    Y_fea = reshape( Y_fea, temp_size1, temp_size2*temp_size3 );
    Y_alpha = lcc2(Y_fea',patch_dic',knn);
    Y_alpha = Y_alpha';
    Y_alpha = reshape( Y_alpha, patch_dic_num, temp_size2, temp_size3 );%10*81*600
    
    Y_patch_alpha = Y_alpha(:,select_patch_id,:);
    Y_patch_alpha = reshape(Y_patch_alpha,size(Y_patch_alpha,1),prod(local_num), prod(patch_num)*particle_num );
    %--------FV of candidates--------------
    Y_FV = [];
    for i=1:particle_num
        Y_FV(:,i) = vl_fisher( Y_alpha(:,:,i), temp_gmm.mean, temp_gmm.cov, temp_gmm.w, 'Improved' ); %global FV
    end
    
    [ Y_coord, ~ ] = GetCoordinateColor( Y_mat, angle ); %coordinate
    Y_coord_FV = [];
    for i=1:particle_num
        Y_coord_FV(:,i) = vl_fisher( Y_coord(i).c, coord_gmm.mean, coord_gmm.cov, coord_gmm.w, 'Improved' );%negative FV
    end
    
    Y_FV = [Y_FV;Y_coord_FV;ones(1,particle_num)];
    
    Y_patch_FV = [];
    l = 0;
    for i=1:particle_num
        for j=1:GMM_num
            l = l + 1;
            Y_patch_FV(:,l) = vl_fisher( Y_patch_alpha(:,:,l), patch_gmm(j).mean, patch_gmm(j).cov, patch_gmm(j).w, 'Improved' ); %候选目标的局部FV
        end
    end
    Y_patch_FV = [Y_patch_FV;ones(1,GMM_num*particle_num)];
    
    %--------------------- train clasifier------------------------
    if ( strcmp(update_flag,'true') )
        %--------global classifier--------------
        n1 = size( global_pos_FV,2 ); 
        n2 = size( global_neg_FV,2 ); 
        Z = [global_pos_FV, global_neg_FV; ones(1,n1+n2) ];
        label = [1*ones(n1,1); 0*ones(n2,1)];
        global_w = LapRLS(Z,label,Y_FV,LLRoptions);
        
        %--------local classifier--------------
        local_w = []; % 
        for i=1:GMM_num
            pos_data = local_pos_FV( :,[ i:GMM_num:size(local_pos_FV,2) ] ); 
            neg_data = local_neg_FV( :,[ i:GMM_num:size(local_neg_FV,2) ] ); 
            unlabel_data = Y_patch_FV( :,[ i:GMM_num:size(Y_patch_FV,2) ] ); 
            n1 = size( pos_data,2 ); 
            n2 = size( neg_data,2 ); 
            Z = [pos_data, neg_data; ones(1,n1+n2) ];
            label = [1*ones(n1,1); 0*ones(n2,1)];
            local_w(:,i) = LapRLS(Z,label,unlabel_data,LLRoptions);
        end
        
        %-------update flag--------------
        update_flag = 'false';
    end
    
    %---------global likelihood -------------------
    glo_pro = global_w' * Y_FV; 
    glo_pro = exp(-(glo_pro-1.5).^2);
    
    local_pro = sum( repmat( local_w,1,particle_num ).*Y_patch_FV );
    local_pro = exp(-(local_pro-1.5).^2);
    local_pro = reshape( local_pro, prod(patch_num), particle_num );
    local_pro = sum( local_pro );% local likelihood
    
    a = 0.2;
    likelihood = (a)*glo_pro + (1-a)/9*local_pro;
    likelihood = exp( 5*likelihood );
    
    %---------best affine parameter------------------------
    [~,max_id] = max(likelihood);
    affparam = all_affparam(:,max_id);
    
    %---------obtian positive samples-----------------------------
    if( f <=9 )
        result_track(:,:,:,f) = Y_mat(:,:,:,max_id);
    end
    
    pos_sample_affparam = repmat(affparam(:),1,9);
    pos_sample_affparam = pos_sample_affparam + temp;
    pos_samples = WarpImgColor( img, affparam2mat( pos_sample_affparam ), template_size );
    pos_samples = reshape( pos_samples, prod(template_size)*3, 9 );
    pos_sample_set = [pos_sample_set, pos_samples];
    
    possize = size( pos_sample_set,2 );
    if (possize > max_num ) 
        remove_num = possize - max_num;
        pos_sample_set(:,1:remove_num) = [];
    end
        
    %---------add new template set--------------
    if ( size(pos_sample_set,2) == 27 )
        template_set = reshape( template_set, prod(template_size)*3, size(template_set,4) );
        template_set = [template_set,pos_sample_set(:,1:25)];
        template_num = size( template_set,2 );
        template_set = reshape( template_set, [template_size(1), template_size(2), 3, template_num] );
    end
    
    %---------template update---------------------
    update_vector = reshape( Y_mat(:,:,:,max_id), prod(template_size)*3, 1 );
    [~, ~, E] = LSS( update_vector-tmpl.mean, tmpl.basis,tmpl.basis');
    update_vector = (E==0).*update_vector + (E~=0).*tmpl.mean;
    update_vectors = [update_vectors, update_vector];

    
    if size(update_vectors,2) == interval  
        [tmpl.basis,tmpl.eigval,tmpl.mean,tmpl.num] = sklm(update_vectors,tmpl.basis,tmpl.eigval,tmpl.mean,tmpl.num);
        update_vectors = [];
        if size(tmpl.basis,2)>10
            tmpl.basis = tmpl.basis(:, 1:10);
            tmpl.eigval = tmpl.eigval(1:10);
        end
        
        curr_vec = reshape( Y_mat(:,:,:,max_id), prod(template_size)*3, 1 );
        [~, coef, E] = LSS( curr_vec-tmpl.mean, tmpl.basis,tmpl.basis');
        rec_template = tmpl.basis*coef + tmpl.mean;%rebuild new template
        rec_template = reshape(rec_template,[template_size,3]);
        
        %---find template to be updated
        temp_FV_num = size( temp_FV,2 );
        glo_score = global_w' * [temp_FV;ones(1,temp_FV_num)]; % global score
        glo_score = exp(-(glo_score-1.5).^2);
        
        local_score = sum( repmat( local_w,1,temp_FV_num ).*[temp_patch_FV;ones(1,temp_FV_num*GMM_num)] );
        local_score = exp(-(local_score-1.5).^2);
        local_score = reshape( local_score, prod(patch_num), temp_FV_num );
        local_score = sum( local_score );% local score

        temp_score = a*glo_score + (1-a)/9*local_score; %total score
        [~,min_id] = min(temp_score);
        template_set(:,:,:,min_id) = rec_template;%update old template
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% ------------retrain LCC ditionary, GMM models and classifiers etc.------------
        template_fea = GetPatchColor( template_set, local_size, local_step );%36*81*25，
        
        temp_patch_coord = repmat( patch_coord, 1, template_num );
        temp_patch_coord = reshape( temp_patch_coord, 2, size(temp_patch_coord,2)/template_num, template_num );

        template_fea = [ template_fea; temp_patch_coord ];%
        %--------------lcc dictionary------------------------
        pospatch = reshape( template_fea, size(template_fea,1), size( template_fea,2 )*size( template_fea,3 )  );
        [patch_dic,~] = vl_kmeans( pospatch, patch_dic_num, 'Initialization', 'plusplus');
        
   
        template_alpha = lcc2(pospatch',patch_dic',knn);
        template_alpha = template_alpha';

        [temp_gmm.mean, temp_gmm.cov, temp_gmm.w] = vl_gmm( template_alpha, glo_gauss_num );%gmm
        template_alpha = reshape( template_alpha, patch_dic_num, size( template_fea,2 ), size( template_fea,3 ) );%10*81*25
        temp_FV = [];
        for i=1:template_num
            temp_FV(:,i) = vl_fisher( template_alpha(:,:,i), temp_gmm.mean, temp_gmm.cov, temp_gmm.w, 'Improved' );%FV of each temlalte
        end

        [ temp_coord, all_temp_coord ] = GetCoordinate( template_set, angle ); 
        [coord_gmm.mean, coord_gmm.cov, coord_gmm.w] = vl_gmm( all_temp_coord, coord_gauss_num );
        temp_coord_FV = [];
        for i=1:template_num
            temp_coord_FV(:,i) = vl_fisher( temp_coord(i).c, coord_gmm.mean, coord_gmm.cov, coord_gmm.w, 'Improved' );
        end

        temp_FV = [temp_FV;temp_coord_FV];
        
        %-------------lcc of each patch ---------
        template_patch_alpha = template_alpha(:,select_patch_id,:);
        template_patch_alpha = reshape(template_patch_alpha,size(template_patch_alpha,1),prod(local_num), prod(patch_num)*template_num );
        
        %--------------gmm based patches---------
        GMM_num = prod(patch_num);
        for i=1:GMM_num
            train_data = template_patch_alpha( :,:,[i:GMM_num:prod(patch_num)*template_num ] );
            train_data = reshape( train_data, patch_dic_num, prod(local_num)*template_num );
            [ patch_gmm(i).mean, patch_gmm(i).cov, patch_gmm(i).w ] = vl_gmm( train_data, local_gauss_num ); 
        end

        temp_patch_FV = [];
        l = 0;
        for i=1:template_num
            for j=1:GMM_num
                l = l + 1;
                temp_patch_FV(:,l) = vl_fisher( template_patch_alpha(:,:,l), patch_gmm(j).mean, patch_gmm(j).cov, patch_gmm(j).w, 'Improved' );
            end
        end
        %% sampling
        [~, neg_samples] = GetSamplesColor(img, affparam, template_size, pos_num, neg_num, affsig);
        RemoveSample;
        neg_samples( :,:,:,remove_neg_id ) = [];
        ture_neg_num = size(neg_samples,4);
        
        neg_fea = GetPatchColor( neg_samples, local_size, local_step );%36*81*100
        neg_patch_coord = repmat( patch_coord, 1, ture_neg_num );
        neg_patch_coord = reshape( neg_patch_coord, 2, size(neg_patch_coord,2)/ture_neg_num, ture_neg_num );

        neg_fea = [ neg_fea; neg_patch_coord ];
        

        pos_sample_set( :,remove_pos_id ) = [];
        pos_train_sample = pos_sample_set;
        real_pos_train_num = size( pos_sample_set,2 );
        
        pos_train_sample = reshape( pos_train_sample, [template_size(1), template_size(2), 3 real_pos_train_num]);
        
        pos_fea = GetPatchColor( pos_train_sample, local_size, local_step );%36*81*100
        pos_patch_coord = repmat( patch_coord, 1, real_pos_train_num );
        pos_patch_coord = reshape( pos_patch_coord, 2, size(pos_patch_coord,2)/real_pos_train_num, real_pos_train_num );

        pos_fea = [ pos_fea; pos_patch_coord ];%
        
        %-------------lcc of negative samples-----------
        [temp_size1,temp_size2,temp_size3] = size( neg_fea );
        neg_fea = reshape( neg_fea, temp_size1, temp_size2*temp_size3 );
        neg_alpha = lcc2(neg_fea',patch_dic',knn);
        neg_alpha = neg_alpha';
        neg_alpha = reshape( neg_alpha, patch_dic_num, temp_size2, temp_size3 );%10*81*100

        neg_patch_alpha = neg_alpha(:,select_patch_id,:);
        neg_patch_alpha = reshape(neg_patch_alpha,size(neg_patch_alpha,1),prod(local_num), prod(patch_num)*ture_neg_num );
        
        %--------------lcc of positive samples-----------
        [temp_size1,temp_size2,temp_size3] = size( pos_fea );
        pos_fea = reshape( pos_fea, temp_size1, temp_size2*temp_size3 );
        pos_alpha = lcc2(pos_fea',patch_dic',knn);%
        pos_alpha = pos_alpha';
        pos_alpha = reshape( pos_alpha, patch_dic_num, temp_size2, temp_size3 );%10*81*100

        pos_patch_alpha = pos_alpha(:,select_patch_id,:);
        pos_patch_alpha = reshape(pos_patch_alpha,size(pos_patch_alpha,1),prod(local_num), prod(patch_num)*temp_size3 );
        
        %-------------FV of negative samples--------------
        neg_FV = [];
        for i=1:ture_neg_num
            neg_FV(:,i) = vl_fisher( neg_alpha(:,:,i), temp_gmm.mean, temp_gmm.cov, temp_gmm.w, 'Improved' );
        end
        
        [ neg_coord, ~ ] = GetCoordinate( neg_samples, angle ); 
        neg_coord_FV = [];
        for i=1:ture_neg_num
            neg_coord_FV(:,i) = vl_fisher( neg_coord(i).c, coord_gmm.mean, coord_gmm.cov, coord_gmm.w, 'Improved' );
        end

        neg_FV = [neg_FV;neg_coord_FV];
        
        neg_patch_FV = [];
        l = 0;
        for i=1:ture_neg_num
            for j=1:GMM_num
                l = l + 1;
                neg_patch_FV(:,l) = vl_fisher( neg_patch_alpha(:,:,l), patch_gmm(j).mean, patch_gmm(j).cov, patch_gmm(j).w, 'Improved' );
            end
        end
        %-------------FV of positive samples-------------
        pos_FV = [];
        for i=1:real_pos_train_num
            pos_FV(:,i) = vl_fisher( pos_alpha(:,:,i), temp_gmm.mean, temp_gmm.cov, temp_gmm.w, 'Improved' );
        end
        
        [ pos_coord, ~ ] = GetCoordinate( pos_train_sample, angle );
        pos_coord_FV = [];
        for i=1:real_pos_train_num
            pos_coord_FV(:,i) = vl_fisher( pos_coord(i).c, coord_gmm.mean, coord_gmm.cov, coord_gmm.w, 'Improved' );
        end

        pos_FV = [pos_FV;pos_coord_FV];
        
        pos_patch_FV = [];
        l = 0;
        for i=1:real_pos_train_num
            for j=1:GMM_num
                l = l + 1;
                pos_patch_FV(:,l) = vl_fisher( pos_patch_alpha(:,:,l), patch_gmm(j).mean, patch_gmm(j).cov, patch_gmm(j).w, 'Improved' );%每个负样本的每个patch块的FV
            end
        end
        
        global_pos_FV = [temp_FV,pos_FV]; %positive samples for global classifier
        local_pos_FV = [temp_patch_FV,pos_patch_FV];%positive samples for local classifier
        global_neg_FV = neg_FV;  %negative samples for global classifier
        local_neg_FV = neg_patch_FV; %negative samples for local classifier

        update_flag = 'true'; 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    %------resampling-----------------------
    all_affparam = repmat( affparam(:),1,particle_num );
    all_affparam = all_affparam + randn(6,particle_num).*repmat( affsig(:),1,particle_num );
    all_affparam(:,end) = affparam(:);
    CheckParticle;
    
    %------show tracking results---------------------------------- 
     ShowResult(img_color,affparam,f,template_size);
     pause(0.1)
%     %------save tracking results----------------------------------
%     path = [resultpath imFiles(f).name];
%     fff = getframe(gcf);
%     imwrite(fff.cdata,path);
    FV_SavePosInfo(resultpath,affparam,template_size);
end


















