function [dist, coef, error] = LSS( y, A, P )
% y :ȥ���Ļ���ĺ�ѡĿ��
% A :ģ�弯
%dist : y��A�ġ����롱
%error: �������
%%
lssparam.lambda = 0.1;    %�������ʱ�õ�
lssparam.maxLoopNum = 20; %��ϵ��ʱ������������
lssparam.stopThr = 0.001; %��ϵ��ʱ��������ֹ����

coef = zeros( size(A,2),1 );%��ʼ��ϵ��
error = zeros( size(y) );   %��ʼ���������
temp_error = zeros( size(y) );
dist_old = 0;%����ǰ�ľ���
dist_new = 0;%���º�ľ���

for i=1:lssparam.maxLoopNum
    coef = P*(y-error);
    
    temp_error = y-A*coef;
    error = max( abs(temp_error)-lssparam.lambda, 0 ).*sign(temp_error);
    
    dist_new = 0.5*sum( (temp_error-error).^2 ) + lssparam.lambda*sum( abs(error) );
    if abs( dist_new - dist_old ) < lssparam.stopThr
        break;
    end
    dist_old = dist_new;
end

dist = dist_new;
end

