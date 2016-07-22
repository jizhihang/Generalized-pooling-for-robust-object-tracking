function patch_coord = GetPatchCoord( template_size, patch_size, patch_step )
%% 求每一个patch块的坐标
%
%
%
%%
patch_x = 1:patch_step:template_size(1)-patch_size(1)+1;
patch_y = 1:patch_step:template_size(2)-patch_size(2)+1;
patch_y = patch_y';
row_num = size( patch_y,1 );
line_num = size( patch_x,2 );
l = 0;
for i=1:row_num
    for j=1:line_num
        temp = [ patch_y(i);patch_x(j) ];
        l = l + 1;
        patch_coord(:,l) = temp;
    end
end
patch_coord = patch_coord + ( patch_size(1)/2-1 );%每个patch块的中心坐标
patch_coord = patch_coord./template_size(1);
end

