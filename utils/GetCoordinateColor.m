function [coordinate,all_coor] = GetCoordinateColor( img, angle )
%%得到图像中满足给定角度的像素点坐标
%img：给定的图像，m*n*k
%angle：给定的角度，0，45,90,135,180,225,270,315
%coordinate：满足条件的坐标点集合，分开表示，表示成k个矩阵，coordinate(1).c 、 coordinate(2).c 、...、 coordinate(k).c
%all_coor：满足条件的坐标点集合，整体表示，表示成一个矩阵，2*x
%% 
[m,n,cn,k] = size(img);

hy = fspecial('sobel');% y方向的sobel算子
hx = hy';% x方向的sobel算子

img(:,[n+1 n+2],:,:) = zeros( m,2,cn,k );%在每幅图之后填充两列零元素
allimg = reshape( permute(img,[1,2,4,3]), m, (n+2)*k, cn );%把所有的图像拉伸成一个大图像

gx = cat(3, filter2(hx,allimg(:,:,1)), filter2(hx,allimg(:,:,2)), filter2(hx,allimg(:,:,3)));
gy = cat(3, filter2(hy,allimg(:,:,1)), filter2(hy,allimg(:,:,2)), filter2(hy,allimg(:,:,3)));

gx = max(gx,[],3);
gy = max(gy,[],3);

angle_img = atand( gy./gx );%求出了每一个像素点的梯度方向，但是这些方向都是在（-90~90）之间，下面应该把这些角度区分到（-180~180）之间

temp = ( gy<0 ).*( gx<0 );
angle_img = angle_img - temp*180 ;
temp = ( gy>0 ).*( gx<0 );
angle_img = angle_img + temp*180 ;% 此时的梯度方向在（-180~180）之间

%angle_img角度规范化
angle_img( angle_img>= -22.5 & angle_img<  22.5 ) = 0;
angle_img( angle_img>=  22.5 & angle_img<  67.5 ) = 45;
angle_img( angle_img>=  67.5 & angle_img< 112.5 ) = 90;
angle_img( angle_img>= 112.5 & angle_img< 157.5 ) = 135;
angle_img( angle_img>= 157.5 | angle_img<-157.5 ) = 180;
angle_img( angle_img>=-157.5 & angle_img<-112.5 ) = 225;
angle_img( angle_img>=-112.5 & angle_img< -67.5 ) = 270;
angle_img( angle_img>= -67.5 & angle_img< -22.5 ) = 315;
%把angle_img还原成k个子图
angle_img = reshape( angle_img, m, n+2, k );
angle_img( :,[n+1 n+2],: ) = [];

all_coor = [];
for i=1:k
    [x,y] = find( angle_img(:,:,i)==angle );
    coordinate(i).c = [x y]';
    all_coor = [ all_coor,coordinate(i).c ];
end

end

