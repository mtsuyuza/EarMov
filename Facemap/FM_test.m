h5=("earMov_FacemapPose.h5");
%h5disp(h5);
info = h5info(h5, '/Facemap');
%%
%bodypart_name={"eye(back)","eye(bottom)","eye(front)","eye(top)","nose(r)","nose(tip)","nose(top)","nosebridge","whisker(I)","whisker(II)","whisker(III)"};
%dataset={"likelihood","x","y"};
%eye_b_like=h5read("earMov_FacemapPose.h5", '/Facemap/eye(back)/likelihood');
%% organizing original h5 datafile
group_names = {info.Groups.Name};
num_groups = numel(group_names);
data = cell(num_groups, 3);

for i = 1:num_groups
    group_name = group_names{i};
    for j = 1:3  % 3 datasets (likelihood, x, y)
        dataset_name = info.Groups(i).Datasets(j).Name;
        data{i, j} = h5read(h5, [group_name '/' dataset_name]);
    end
end
%% removing unused bodyparts
m = cell2mat(data);
data_FM = reshape(m,626398,45); % # of frames multiplied by 15 bodyparts*3 datasets
data_FM(:,[5:7,12,20:22,27,35:37,42]) = []; %bodyparts removed: lowerlip, mouth, nose(bottom), paw
%% removing outliers
% outlier = isoutlier(data_FM, "quartiles");
% removed = rmoutliers(data_FM, "quartiles");
% %% keypoint trajectory
% x = data_FM(:,12:22);
% y = data_FM(:, 23:33);
% scatter(x,y, "b");
% hold on
% x_clean = removed(:,12:22);
% y_clean = removed(:, 23:33);
% scatter(x_clean,y_clean, "r","*");
% title("Facemap Keypoint Model")
% xlabel("x Keypoint position")
% ylabel("y Keypoint Position")
%%
load('ttl_data.mat', 'ttl_data')
%%
indexChange = find(diff(ttl_data(1,:)) == 1) * 120 / 20000; % Sampling Rate = 20,000Hz
 % offset eg. 0.5s = 60 frames
indexChangeins =  find(diff(ttl_data(1,:)) == 1) / 20000;
%%
rec_length = [5 10 15 20 25 30]; % time of video reording in sec
for i = 1:length(rec_length)
    [min_t(i), min_ind(i)] = min(abs(rec_length(i) - indexChangeins(1:2550)));
end

%%
% the goal is to get 2s before and 2 s after each sound
% 120*2*2 x 2550 x 33 
range_t = -480:1:480; % negative = one second (120 frames) before movement to one second after movement
for i = 1:2550
    movement(i, :, :) = data_FM(round(indexChange(i)) + range_t, :);
end
%%
% baseline = mean(mov_frames(:,1:33),2);
% sub = abs(mov_frames - baseline);
%% identifying baseline
% sub_mat = [];
% like_base = mean(mov_frames(:,:,1:11));
% x_base = mean(mov_frames(:,:,12:22));
% y_base = mean(mov_frames(:,:,23:33));
% 
% like_sub = abs(mov_frames(:,:,1:11)-like_base);
% x_sub = abs(mov_frames(:,:,12:22)-x_base);
% y_sub = abs(mov_frames(:,:,23:33)-y_base);
% 
% sub_mat = cat(3,like_sub,x_sub,y_sub);

%%
%% face movement with baseline
% figure
% sgtitle('Overall Movement Separated by Facial Bodyparts')
% bodypart = {"eye(back)","eye(bottom)","eye(front)","eye(top)","nose(r)","nose(tip)","nose(top)","nosebridge","whisker(I)","whisker(II)","whisker(III)"};
% dataset={"likelihood","x","y"};
% 
% for r=1:3
%     for o=1:11
%     subplot (3,11,(r-1)*11+o)
%     plot (range_t, sub_mat(:,:,(r-1)*11+o))
%     xline(0, '--')
%     xlabel(bodypart{o})
%     ylabel(dataset{r})
%     end
% end
%%
%%
bodypart = {"eye(back)","eye(bottom)","eye(front)","eye(top)","nose(r)","nose(tip)","nose(top)","nosebridge","whisker(I)","whisker(II)","whisker(III)"};
dataset={'likelihood','x','y'};
for j = 1:3
    figure;
    % sgtile(dataset{j})
    coordinate_range = (j-1)*11 + 1 : (j-1)*11 + 11;
    for r2=1:11
        subplot(11,1,r2)
        plot(squeeze(mean(movement(:, :, coordinate_range(r2)))));
        xline(241, '--')
        % plot (rec_length, sub_mat(:,:,r2))
        % xline(indexChangeins, '--')
        ylabel(bodypart{r2})
    end
end
%%
time_range = 1:5220;
x_mean = mean(data_FM(time_range, 16));
x_std = std(data_FM(time_range, 16));
y_mean = mean(data_FM(time_range, 31));
y_std = std(data_FM(time_range, 31));
figure
plot(data_FM(time_range, 16), data_FM(time_range, 31), '.')
xlim([0 658])
ylim([0 494])
hold on
% errorbar(x_mean, y_mean, y_std, y_std)

hold on
I = imread('img615866.png'); 
background = image(xlim,flip(ylim),I); 
uistack(background,'bottom')
%%
% this determines whether the 
mov_amp = sqrt((x_mean)^2+(y_mean)^2);
bodypart = {"eye(back)","eye(bottom)","eye(front)","eye(top)","nose(r)","nose(tip)","nose(top)","nosebridge","whisker(I)","whisker(II)","whisker(III)"};
dataset={'likelihood','x','y'};
for j = 1:3
    figure;
    % sgtile(dataset{j})
    coordinate_range = (j-1)*11 + 1 : (j-1)*11 + 11;
    for r2=1:11
        subplot(11,1,r2)
        plot(range_t,mov_amp);
        xline(241, '--')
        % plot (rec_length, sub_mat(:,:,r2))
        % xline(indexChangeins, '--')
        ylabel(bodypart{r2})
    end
end
%%
% baseline = av. of the location of the keypoint of that certain body part.
% we need to subtract the baseline from the raw location at line 105-117

