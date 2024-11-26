%% check the ttl data

% the first channel stores the sound stimuli pulses
% the second and third channels are for locomotion
% the fourth channel stores the stamps of video frames
load("ttl_data.mat")

range = 10^7 : 2 * 10^7; % this is the time range of interest

for i = 1:4 
    test = (ttl_data(i, range)); % checking the ttl pulses of a channel
    rs(i) = length(range) ./ nnz(diff(test) == 1); % this gives the number of time stamps between signals 
end

%% load the video stamps

logttl = load('Log_2019_04_15_14_20_28.txt');
videoTTL = logttl(:, 1);

%% match the video frames from the TTL track and the video log
% whenever the camera captures a frame, it sends out a TTL pulse
% (robustly), but not all frames are written into the video (dropping frames)

% calculate the video frames from the ttl
ttlFrameNum = nnz(diff(ttl_data(4, :)) == 1);
logFrameNum = length(videoTTL);
% this gives the number of frames dropped by the recording system
ttlFrameNum - logFrameNum; % 80 out of 626480 frames were dropped
% note that the video has two frames less than the log

%% matching the sound stimuli and the video timestamps

% 85 (directions) x 30 (repeat) auditory stims, one per 2 seconds
% 85 (minutes) x 60 (seconds) x 120 (frame rate) frames recorded
ttlsNum = nnz(diff(ttl_data(1, :)) == 1);
stiminfo = ReadAuditoryStimfile('fullfield.txt');
%%
ttlsAud = find(diff(ttl_data(1, :)) == 1);
ttlsVideo = find(diff(ttl_data(4, :)) == 1);

FRcorrTTL = videoTTL ./ 120 .* 20000 + ttlsVideo(1);

%%
FR = 120;
timewindow_before = 0;
timewindow_after = 1; % in seconds
numFrames = FR .* timewindow_after;

%%
ttlsAud = [ttlsAud, ttlsAud(end) + 20000 * 2];
ttlinterp = interp1(ttlsAud, 1:ttlsNum + 1, ttlsVideo);
for i = 1:ttlsNum
   framePerStim{i} = find(ttlinterp >= i & ttlinterp < i+1);
end



% %%
% 
% endtime = 20000;
% psths = fastttldivide(FRcorrTTL, ttlsAud', endtime);
% % patterns = FormatAuditoryPSTH(FRcorrTTL, ttlsAud', stiminfo, 1000)

%%
    nmeta1 = length(stiminfo.meta1);
    nmeta2 = length(stiminfo.meta2);
    nreps = stiminfo.nreps;
    serial = stiminfo.serial;
    npattern = stiminfo.npattern;
    ntypes = 1;
    %%
    nstim = 1;
    nNeu = 1;
    
    prevstim = [0 stiminfo.stimnums(1:end-1) + 1];
    
    snumt = reshape(stiminfo.stimnums(1:(npattern * nreps)), [npattern, nreps]) + 1;
    frames4stims_base = reshape(framePerStim, [npattern, nreps, nstim, nNeu]);
    frames4stimsmat_stimcorrected = cell(npattern, nreps, nstim, nNeu);
    
    prevstim_base = reshape(prevstim, [npattern, nreps, nstim]);
    prevstim_stimcorrected = zeros(npattern, nreps, nstim);
    for i = 1:nreps
        frames4stimsmat_stimcorrected(snumt(:,i), i, :, :) = frames4stims_base(:, i, :, :);
        prevstim_stimcorrected(snumt(:,i), i, :, :) = prevstim_base(:, i, :, :);
    end

%%

mov = VideoReader("earMov.m4v");

%%

% get the first and last frome # for each stim
% sort the stims
% get the clips

test = read(mov, [frames4stimsmat_stimcorrected{9, 1}(1), ...
    frames4stimsmat_stimcorrected{9, 1}(end)]);

%%
v = VideoWriter('test.mp4');
open(v);
%%
for i = 1:size(test, 4)
    
    test = read(mov, [frames4stimsmat_stimcorrected{9, 1}(1), ...
    frames4stimsmat_stimcorrected{9, 1}(end)]);
   
    test1 = test(:, :, :, i);
    imagesc(test1);
%     pause;
    writeVideo(v, test1);
end
close(v)


figure;
v = VideoWriter('test.mp4');
open(v);
for i = 1:240
    for j = 1:30
    test = read(mov, frames4stimsmat_stimcorrected{9, j}(i));
    subplot(5, 6, j)
    imagesc(test);
    end
%     pause;
    writeVideo(v, gcf);
end
close(v)






    
    


