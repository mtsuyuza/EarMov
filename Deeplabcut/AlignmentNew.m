load('ttl_data.mat', 'ttl_data')
%%
data=readmatrix("NewCoords.csv");
%%
data(:,1)=[];
m=data(:,[1,4,7,10,13,16,19,22,2,5,8,11,14,17,20,23,3,6,9,12,15,18,21,24]);
%%
%Sampling Rate is 20,000Hz
indexChange = find(diff(ttl_data(1,:)) == 1) * 120 / 20000;
 % offset eg. 0.5s = 60 frames
impFrames = zeros(2550,120, 25);
%iFrames = cell(2550,120);
indexChangeins =  find(diff(ttl_data(1,:)) == 1) / 20000;
%% alignment of video to data = ear movement
earmove_inVideo = [35, 68, 149, 171, 204.5, 253, 295, 318.5, 329, 331, 332, 374.5, 382.5, 394.5, 396.5, 462.5, 484.5, 487, 588.5, 590.5]; % shows timestamps of ear movement (s)
% 33 = non-moving ctrl
for i = 1:length(earmove_inVideo)
    [min_t(i), min_ind(i)] = min(abs(earmove_inVideo(i) - indexChangeins(1:2550)));
end
%% alignment of video to data = locomotion
% locomotion_inVideo = [42, 172, 206, 259, 299, 320.5, 335, 340, 376, 408, 445, 465, 488, 517, 535, 573, 592, 601.5, 613, 636, 678, 733, 751]; % shows timestamps of ear movement (s)
% for i = 1:length(locomotion_inVideo)
%     [min_t(i), min_ind(i)] = min(abs(locomotion_inVideo(i) - indexChangeins(1:2550)));
% end
%% alignment of video to data = ear movement
earmove_inVideo = 42; % shows timestamps of ear movement (s)
for i = 1:length(earmove_inVideo)
    [min_t(i), min_ind(i)] = min(abs(earmove_inVideo(i) - indexChangeins(1:2550)));
end
%%
range_t = -50:1:50; % negative = one second before movement to one second after movement
for i = 1:length(min_ind)
    earmove_frames(i, :, :) = data(round(indexChange(min_ind(i))) + range_t, :);
end

%% identifying baseline
sub_mat = [];
x_base = mean(earmove_frames(:,:,1:8));
y_base = mean(earmove_frames(:,:,9:16));
like_base = mean(earmove_frames(:,:,17:24));

like_sub = abs(earmove_frames(:,:,1:8)-like_base);
x_sub = abs(earmove_frames(:,:,9:16)-x_base);
y_sub = abs(earmove_frames(:,:,17:24)-y_base);

sub_mat = cat(3,like_sub,x_sub,y_sub);

%%
figure
sgtitle('Ear Movement Separated by Different Bodyparts')
bodypart = {"brain","top right","bottom right 1", "bottom right 2", "top left", "bottom left 1", "bottom left 2", "head"};
dataset={"x","y","likelihood"};

for r=1:3
    for o=1:8
    subplot (3,8,(r-1)*8+o)
    plot (range_t, sub_mat(:,:,(r-1)*8+o))
    xline(0, '--')
    xlabel(bodypart{o})
    ylabel(dataset{r})
    end
end
%% plot movement
% %figure
% sgtitle('Overall Movement')
% titles = {"Head", "Top R Ear", "Bottom R Ear 1", "Bottom R Ear 2"};
% for i = 2:4
%     subplot(8, 2, (i-1)*2+1)
%     plot(mean(earmove_frames(:, :, (i-1)*3+2))')
%     title([titles{i}, ' x'])
%     hold on
%     plot(earmove_frames(:, :, (i-1)*3+2)')
%     xline(120)
%     subplot(8, 2, 2*i)
%     plot(mean(earmove_frames(:, :, (i-1)*3+3))')
%     title([titles{i}, ' y'])
%     hold on 
%     plot(earmove_frames(:, :, (i-1)*3+3)')
%     xline(120)
%     xlabel("time (s)")
% end
%% plot dist
figure
sgtitle('Movement vs. Auditory Stimulus')
titles = {"Head", "Top R Ear", "Bottom R Ear 1", "Bottom R Ear 2"};
for i = 2:4
   subplot(8, 2, (i-1)*2+1)
   dist = sqrt(earmove_frames(:, :, (i-1)*3+2) .^ 2 - earmove_frames(:, :, (i-1)*3+3) .^ 2);
   plot(dist')
   xline(120)
   title(titles{i})
end
%% plot angle
alpha = atan(abs(earmove_frames(:, :, 9)-earmove_frames(:, :, 3))./abs(earmove_frames(:, :, 2)-earmove_frames(:, :, 8)));
beta = atan(abs(earmove_frames(:, :, 6)-earmove_frames(:, :, 3))./abs(earmove_frames(:, :, 2)-earmove_frames(:, :, 5)));
rad = beta - alpha;
theta = rad2deg(rad);
%figure
%plot(theta')
%% plot dist and angle
figure
subplot(1,2,1)
plot(dist')
title ("Distance")
xline(120)
xlabel("frames")
ylabel("distance (mm)")
subplot(1,2,2)
plot(theta')
xline(120)
title("Angle")
xlabel("frames")
ylabel("degrees")
%% baseline = 0
dist_baseline = mean(dist(:, 1:50), 2);
angle_baseline = mean(theta(:, 1:50), 2);
dist_sub = dist - dist_baseline;
theta_sub = theta - angle_baseline;

figure
subplot(1 ,2, 1)
plot(dist_sub')
xline(780, 'k')
title ("Distance")
xlabel("frames")
ylabel("distance change (mm)")
subplot(1, 2, 2)
plot(theta_sub')
xline(780, 'k')
title("Angle")
xlabel("frames")
ylabel("degree change")

%%
%%
% ff = fopen('fullfield.txt');
% elevation = fgetl(ff);
% azimuth= fgetl(ff);
% stimnums = [];
% while 1
%     tline = fgetl(ff);
%     if ~ischar(tline), break, end
%     stimnums = [stimnums str2num(tline)];
% end
% fclose(ff);
% 
% location_id = 0:84;
%  ff_id = (stimnums(min_ind));
% 
%  figure
% histogram(ff_id, 85)
% 
% az_id = mod(ff_id, 17);
% el_id = ceil((ff_id+1)./17);
% 
% figure
% histogram(az_id)
% histogram(el_id)
% 
%  %%
% range_s = 0:1:120;
% 
% s1 = sum(locodigits1) .* (0.19*pi/400);
% s2 = sum(locodigits2) .* (0.19*pi/400);
% 
% figure
% histogram(s1, range_s)
% histogram(s2, range_s)
% %%
% spd_th = 110;
% figure
% histogram(mod(stimnums(speed1>spd_th), 17))