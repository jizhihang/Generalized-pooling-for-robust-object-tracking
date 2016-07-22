function patch = GetPatch( all_affimg, patch_size, patch_step )
%GetPatch����ͼ��ָ����patch���С���ָ��һϵ��patch�飬��������patch��
%all_affimg:Ҫ�ָ�patch��ͼ��w*h*n
%patch_size��patch���С
%patch_step:
%patch����������patch�飬d*m*n
%% 
sample_num = size( all_affimg, 3 );
template_size = size( all_affimg(:,:,1) );
patch_num(1) = length( patch_size(1)/2 : patch_step : (template_size(1)-patch_size(1)/2) );%ÿһ�а�����patch��
patch_num(2) = length( patch_size(2)/2 : patch_step : (template_size(2)-patch_size(1)/2) );%ÿһ�а�����patch��
patch = zeros( prod(patch_size), prod(patch_num), sample_num );

x = patch_size(1)/2;
y = patch_size(2)/2;
patch_centerx = x : patch_step : ( template_size(1)-x ) ;% ����patch������x����
patch_centery = y : patch_step : ( template_size(2)-y ) ;% ����patch������y����

l = 1;
for j = 1:patch_num(1)
    for k = 1:patch_num(2)
        data = all_affimg( patch_centerx(j)-x+1:patch_centerx(j)+x , patch_centery(k)-y+1:patch_centery(k)+y , : );
        data = reshape( data, prod(patch_size), 1, sample_num );
        patch(:,l,:) = data;
        l = l + 1;
    end
end

end

