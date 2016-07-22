OCVRoot = 'D:\OpenCV2.4.3\build';
IPath1 = ['-I',fullfile(OCVRoot,'include')];
LPath = fullfile(OCVRoot, 'x86\vc9\lib');
lib1 = fullfile(LPath,'opencv_core243.lib');
%lib2 = fullfile(LPath,'opencv_highgui243.lib');

mex('LapRALseq.cpp', IPath1, lib1);