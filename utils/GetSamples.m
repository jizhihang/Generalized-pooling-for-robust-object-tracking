function [A_pos, A_neg] = GetSamples( image, affpara, template_size, pos_num, neg_num, affsig )
%
%
%
%% �õ�pos_num��������
all_affpara = repmat(affpara(:),1,pos_num);
temp = zeros(6,pos_num);
temp(1,:) = [-1 1  0 0 -1 1 -1 1 0 -2 2  0 0 -2 2 -2  2 -1 1 -1 1 -2 2 -2 2];
temp(2,:) = [ 0 0 -1 1 -1 1 1 -1 0  0 0 -2 2 -2 2  2 -2 -2 2 2 -2 -1 1 1 -1];
all_affpara = all_affpara + temp;%�õ�25���������


% all_affpara = repmat( affpara(:), 1, pos_num);%��ʼ�������������ķ������
% 
% sigma = [0.75, 0.75, 0.0, 0.0, 0.0, 0.0];
% all_affpara = all_affpara + randn(6,pos_num).*repmat( sigma(:), 1, pos_num);%�����еķ����������Ŷ�

all_affpara_mat = affparam2mat( all_affpara );%�����еķ����������ת�����õ�ת����ķ������
A_pos = warpimg( image, all_affpara_mat, template_size );%��������������õ������ķ���ͼ

%% �õ�neg_num��������
candi_neg_num = neg_num*10;%��ѡ������������
all_affpara = repmat( affpara(:), 1, candi_neg_num);%��ʼ�����и������ķ������
affsig(:,3:6) = 0;
all_affpara = all_affpara + 2*randn(6,candi_neg_num).*repmat( affsig(:), 1, candi_neg_num);%�����еķ����������Ŷ�

%-----------������и�������Ŀ�����ĵľ����Ƿ����һ����ֵ-----------------
dist_x = 10;%������λ�õĺ�������룬��������������λ�õĺ��������Ҫ���ڸ�ֵ��
center_x = affpara(1);%����λ�õĺ�����
left = center_x - dist_x;%����߽�
right = center_x + dist_x;%���ұ߽�

dist_y = 10;
center_y = affpara(2);
top = center_y - dist_y;%���ϱ߽�
bottom = center_y + dist_y;%���±߽�

id = all_affpara(1,:)<= right & all_affpara(1,:)>=left & all_affpara( 2,: )>= top & all_affpara( 2,: ) <= bottom; % ȥ��������ĸ�������
all_affpara(:,id) = [];

%-----------��鸺�����Ƿ�Խ��--------------------------
[img_h,img_w] = size(image);
box_w = round( affpara(3)*template_size(1) );
box_h = round( affpara(3)*template_size(1)*affpara(5) );

id = ( all_affpara(1,:)-box_w/2-1<0 | all_affpara(1,:)+box_w/2+1>img_w | all_affpara(2,:)-box_h/2-1<0 | all_affpara(2,:)+box_h/2+1>img_h );% ȥ��������ĸ�������
all_affpara(:,id) = [];
num = size(all_affpara,2);
neg_id = unidrnd(num,[1,neg_num]);
all_affpara = all_affpara(:,neg_id);

all_affpara_mat = affparam2mat( all_affpara );%�����еķ����������ת�����õ�ת����ķ������
A_neg = warpimg( image, all_affpara_mat, template_size );%��������������õ������ķ���ͼ
end

