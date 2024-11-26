%%
load('ttl_data.mat')
%%
ff = fopen('fullfield.txt');
el = fgetl(ff);
az = fgetl(ff);
stimnums = [];
while 1
    tline = fgetl(ff);
    if ~ischar(tline), break, end
    stimnums = [stimnums str2num(tline)];
end
fclose(ff);
%%
tSoundOn = find(diff(ttl_data(1, :)) == 1);
%%
samprate = 20000;
rangeloco = -2 * samprate : 1 : 2 * samprate - 1;
locodigits1 = zeros(length(rangeloco), length(tSoundOn));
locodigits2 = zeros(length(rangeloco), length(tSoundOn));
for i = 1:length(tSoundOn)
    locodigits1(:, i) = ttl_data(2,tSoundOn(i)+rangeloco);
    locodigits2(:, i) = ttl_data(3,tSoundOn(i)+rangeloco);
end
%% overall sti in recording
figure
plot(mean(locodigits1'))
xline(2*samprate, 'r')
%%
loco_10ms1 = squeeze(mean(reshape(locodigits1, [size(locodigits1, 1) ./ (samprate ./ 50), samprate ./ 50, ...
    length(tSoundOn)]), 1));
% loco_10ms2 = squeeze(mean(reshape(locodigits2, [samprate ./ 50, ...
%     size(locodigits1, 1) ./ (samprate ./ 50), length(tSoundOn)]), 2));
figure
plot(mean(loco_10ms1'))
xline(200, 'r')
% figure
% plot(mean(loco_10ms2'))
% xline(200, 'r')
%% segmentation of overall
win = 10/1000*samprate;
segments = size(locodigits1, 1) ./ win;
for i = 1:segments
    loco_segs(i, :) = mean(locodigits1((i-1)*win+1:i*win, :), 1);
end
%% average graph
figure
plot(mean(loco_segs, 2))
%%
for i = 1:84
    loc_ind(:, i) = find(stimnums == i);
end
%%
figure
for i = 1:84
    subplot(9, 10, i)
    loco_plot = locodigits1(:, loc_ind(:, i));
    plot(mean(loco_plot'))
    xline(2*samprate, 'r')
end

%%
    tr_segments = size(loco_plot, 1) ./ win;
for i = 1:tr_segments
    tr_loco_segs(i, :) = mean(loco_plot((i-1)*win+1:i*win, :), 1);
end
%%
figure
sgtitle('Average Movement at Each Location ID')
for i = 1:84
    subplot(9, 10, i)
    tr_loco_segs = loco_segs(:, loc_ind(:, i));
    plot(mean(tr_loco_segs, 2))
end
%%
range_s = 0:1:120;

spd1 = sum(locodigits1) .* (0.19*pi/400);
spd2 = sum(locodigits2) .* (0.19*pi/400);

figure
histogram(spd1, range_s)
histogram(spd2, range_s)
%%
spd_th = 60;
figure
histogram(mod(stimnums(spd1>spd_th), 17))
%%
for i = 1:84
    loc_spd1(i,:) = locodigits1(i).*speed +range_s;
end

for i = 1:84
    loc_spd2(i,:) = locodigits2(i).*speed +range_s;
end

 figure
 histogram(loc_spd1)
 histogram(loc_spd2)
%%
 figure
histogram(speed2, 0:5:250)