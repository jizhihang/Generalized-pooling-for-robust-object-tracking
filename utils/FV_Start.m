%
%
%%

run('vlfeat-0.9.18-bin\vlfeat-0.9.18\toolbox\vl_setup');
addpath('./Laplacian Functions');


temp_p = 13;
%------参数设置---------------
affsig = [ temp_p, temp_p, 0.005, 0.00, 0.00, 0.00 ]; %动力学参数
particle_num = 600; %粒子数
interval = 1; %更新间隔

%------跟踪不同的视频----------
title = 'deer';
FV_Demo;

title = 'jumping';
FV_Demo;

title = 'mountainBike';
FV_Demo;

title = 'boy';
FV_Demo;

title = 'crossing';
FV_Demo;

title = 'couple';
FV_Demo;

title = 'woman';
FV_Demo;

title = 'singer2';
FV_Demo;

title = 'subway';
FV_Demo;

title = 'david3';
FV_Demo;

title = 'shaking';
FV_Demo;

title = 'david';    
FV_Demo;

title = 'freeman4';
FV_Demo;

title = 'carScale';
FV_Demo;

title = 'fleetface';
FV_Demo;

title = 'football';
FV_Demo;

title = 'david2';
FV_Demo;

title = 'freeman1';
FV_Demo;

title = 'freeman3';
FV_Demo;

title = 'fish';  
FV_Demo;

title = 'faceocc2';
FV_Demo;

title = 'tiger1';
FV_Demo;

title = 'tiger2';
FV_Demo;

title = 'walking';
FV_Demo;

title = 'car4';
FV_Demo;

title = 'bolt';
FV_Demo;

title = 'singer1';
FV_Demo;

title = 'basketball';
FV_Demo;

title = 'skating1';
FV_Demo;

title = 'carDark';
FV_Demo;

title = 'coke';
FV_Demo;

title = 'dog1';
FV_Demo;

title = 'dudek';
FV_Demo;

title = 'faceocc1';  
FV_Demo;

title = 'football1';
FV_Demo;

title = 'girl';  
FV_Demo;

title = 'ironman';
FV_Demo;

title = 'lemming';
FV_Demo;

title = 'liquor';
FV_Demo;

title = 'matrix';
FV_Demo;

title = 'mhyang';
FV_Demo;

title = 'motorRolling';
FV_Demo;

title = 'skiing';
FV_Demo;

title = 'soccer';
FV_Demo;

title = 'suv';  
FV_Demo;

title = 'sylvester';
FV_Demo;

title = 'doll';
FV_Demo;

title = 'trellis';  
FV_Demo;

title = 'walking2';     
FV_Demo;

title = 'jogging-1';
FV_Demo;

title = 'jogging-2';
FV_Demo;
%----------------------------
clear all;
close all;
clc;