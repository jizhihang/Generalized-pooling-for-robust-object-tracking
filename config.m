
warning off;
addpath(genpath('./dependency'));
addpath('utils');

seq_path = '../benchmark_seq/'; %video path

run('dependency\vlfeat-0.9.18-bin\vlfeat-0.9.18\toolbox\vl_setup');

%-------parameters setting--------------
temp_p = 12;
affsig = [ temp_p, temp_p, 0.008, 0.00, 0.00, 0.00 ]; %affine parameters
particle_num = 600; %number of particles
interval = 1; %update step

path = [seq_path num2str(title) '\img\']; %video sequences path
gt = load([seq_path num2str(title) '\groundtruth_rect.txt']);%ground truth path
p0 = gt(1,:);
p = [p0(1:2) + (p0(3:4)-1)/2 p0(3) p0(4) 0];

update_thr = 0.1;

datapath = path;
if exist(datapath,'dir') == 0   
    disp('Can not find this video£¡');
    break;
end


