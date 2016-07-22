%% 
%---一范数求解要用到的参数
param.lambda = 0.01;
param.lambda2 = 0;
param.mode = 2;

neg_data = neg_samples;
pos_data = reshape(pos_sample_set, [32, 32, 3, size(pos_sample_set,2)] );
template_data = result_track;

neg_data = GetPatchColor( neg_data, patch_size, patch_step );
pos_data = GetPatchColor( pos_data, patch_size, patch_step );
template_data = GetPatchColor( template_data, patch_size, patch_step );

num_neg = size( neg_data,3 );
num_pos = size( pos_data,3 );
num_template = size( template_data,3 );

neg_data = reshape( neg_data, prod(patch_size)*3, prod(patch_num)*num_neg );
pos_data = reshape( pos_data, prod(patch_size)*3, prod(patch_num)*num_pos );
template_data = reshape( template_data, prod(patch_size)*3, prod(patch_num)*num_template );

neg_data = NormalizeMat(neg_data);
pos_data = NormalizeMat(pos_data);
template_data = NormalizeMat(template_data);

param.L = size(neg_data,1);
neg_coef = mexLasso( neg_data, template_data, param);
neg_coef = full( neg_coef );

pos_coef = mexLasso( pos_data, template_data, param);
pos_coef = full( pos_coef );

%---计算正负样本的重建误差-----
ww = eye( prod(patch_num) );
w_neg = repmat(ww,num_template,num_neg);
w_pos = repmat(ww,num_template,num_pos);

neg_error = sum( ( neg_data - template_data*( w_neg.*neg_coef ) ).^2 );%重建误差
neg_error = sum( reshape(neg_error,prod(patch_num),num_neg) );

pos_error = sum( ( pos_data - template_data*( w_pos.*pos_coef ) ).^2 );%重建误差
pos_error = sum( reshape(pos_error,prod(patch_num),num_pos) );

if( f<=9 )
    remove_neg_id = zeros(1,num_neg);
    remove_neg_id = remove_neg_id>0;%转换成logical值
    remove_pos_id = zeros(1,num_pos);
    remove_pos_id = remove_pos_id>0;
else
    remove_neg_id = neg_error<5.0;
    remove_pos_id = pos_error>3.5;
end

%---- result_track更新 ------
if mod(f,20) == 0
    rand1 = randi(9); %被替换掉的跟踪结果
    rand2 = randi(num_pos);
    while pos_error(rand2) > 3.5
        rand2 = randi(num_pos);
    end
    temp_result = pos_sample_set(:,rand2);
    temp_result = reshape( temp_result, [32, 32, 3] );
    result_track(:,:,:,rand1) = temp_result;
end
















