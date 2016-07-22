function FV_SavePosInfo (resultpath,affparam,template_size)
%%
%VidioName：目标视频
%affparam：最佳仿射参数
%%

if exist(resultpath,'dir') == 0 %如果保存跟踪结果的文件夹不存在，则创建一个
    mkdir(resultpath);
end

fileName = [resultpath 'PosInfo.txt'];
fid=fopen(fileName,'a+');

x = round( affparam(1) );
y = round( affparam(2) );
w = round( affparam(3)*template_size(1) );
h = round( affparam(3)*affparam(5)*template_size(1) );

fprintf(fid,'%g %g %g %g \n',x,y,w,h);
fclose(fid);
end

