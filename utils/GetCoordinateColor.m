function [coordinate,all_coor] = GetCoordinateColor( img, angle )
%%�õ�ͼ������������Ƕȵ����ص�����
%img��������ͼ��m*n*k
%angle�������ĽǶȣ�0��45,90,135,180,225,270,315
%coordinate����������������㼯�ϣ��ֿ���ʾ����ʾ��k������coordinate(1).c �� coordinate(2).c ��...�� coordinate(k).c
%all_coor����������������㼯�ϣ������ʾ����ʾ��һ������2*x
%% 
[m,n,cn,k] = size(img);

hy = fspecial('sobel');% y�����sobel����
hx = hy';% x�����sobel����

img(:,[n+1 n+2],:,:) = zeros( m,2,cn,k );%��ÿ��ͼ֮�����������Ԫ��
allimg = reshape( permute(img,[1,2,4,3]), m, (n+2)*k, cn );%�����е�ͼ�������һ����ͼ��

gx = cat(3, filter2(hx,allimg(:,:,1)), filter2(hx,allimg(:,:,2)), filter2(hx,allimg(:,:,3)));
gy = cat(3, filter2(hy,allimg(:,:,1)), filter2(hy,allimg(:,:,2)), filter2(hy,allimg(:,:,3)));

gx = max(gx,[],3);
gy = max(gy,[],3);

angle_img = atand( gy./gx );%�����ÿһ�����ص���ݶȷ��򣬵�����Щ�������ڣ�-90~90��֮�䣬����Ӧ�ð���Щ�Ƕ����ֵ���-180~180��֮��

temp = ( gy<0 ).*( gx<0 );
angle_img = angle_img - temp*180 ;
temp = ( gy>0 ).*( gx<0 );
angle_img = angle_img + temp*180 ;% ��ʱ���ݶȷ����ڣ�-180~180��֮��

%angle_img�Ƕȹ淶��
angle_img( angle_img>= -22.5 & angle_img<  22.5 ) = 0;
angle_img( angle_img>=  22.5 & angle_img<  67.5 ) = 45;
angle_img( angle_img>=  67.5 & angle_img< 112.5 ) = 90;
angle_img( angle_img>= 112.5 & angle_img< 157.5 ) = 135;
angle_img( angle_img>= 157.5 | angle_img<-157.5 ) = 180;
angle_img( angle_img>=-157.5 & angle_img<-112.5 ) = 225;
angle_img( angle_img>=-112.5 & angle_img< -67.5 ) = 270;
angle_img( angle_img>= -67.5 & angle_img< -22.5 ) = 315;
%��angle_img��ԭ��k����ͼ
angle_img = reshape( angle_img, m, n+2, k );
angle_img( :,[n+1 n+2],: ) = [];

all_coor = [];
for i=1:k
    [x,y] = find( angle_img(:,:,i)==angle );
    coordinate(i).c = [x y]';
    all_coor = [ all_coor,coordinate(i).c ];
end

end

