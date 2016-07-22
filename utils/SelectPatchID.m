% 在如下情况下使用该.m文件
% template_size = [32,32]
% patch_size = [16,16]
% local_size = [6,6]
% local_step = 3;
% 把小patch集分成9份（带重叠）

patch_id = 1:81;
patch_id = reshape( patch_id, 9 , 9 );
patch_id = patch_id';

select_patch_id = reshape( patch_id(1:4,1:4)', 1 , 16 );
select_patch_id = [select_patch_id , reshape( patch_id(1:4,4:7)', 1 , 16 )];
select_patch_id = [select_patch_id , reshape( patch_id(1:4,6:9)', 1 , 16 )];
select_patch_id = [select_patch_id , reshape( patch_id(4:7,1:4)', 1 , 16 )];
select_patch_id = [select_patch_id , reshape( patch_id(4:7,4:7)', 1 , 16 )];
select_patch_id = [select_patch_id , reshape( patch_id(4:7,6:9)', 1 , 16 )];
select_patch_id = [select_patch_id , reshape( patch_id(6:9,1:4)', 1 , 16 )];
select_patch_id = [select_patch_id , reshape( patch_id(6:9,4:7)', 1 , 16 )];
select_patch_id = [select_patch_id , reshape( patch_id(6:9,6:9)', 1 , 16 )];





