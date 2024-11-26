%load('ttl_data.mat', 'ttl_data')
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
rangeloco = 0:1:samprate-1;   % -2 * samprate : 1 : 2 * samprate - 1;
locodigits1 = zeros(length(rangeloco), length(tSoundOn));
locodigits2 = zeros(length(rangeloco), length(tSoundOn));
for i = 1:length(tSoundOn)
    locodigits1(:, i) = ttl_data(2,tSoundOn(i)+rangeloco);
    locodigits2(:, i) = ttl_data(3,tSoundOn(i)+rangeloco);
end
%%
speed1 = sum(locodigits1) .* (0.19*2*pi/100);
speed2 = sum(locodigits2) .* (0.19*2*pi/100);
%%
figure
histogram(speed2, 0:5:250)
%%
speedthresh = 200;
figure
hist(mod(stimnums(speed1>speedthresh), 17))
%%
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
%%
win = 10/1000*samprate;
segments = size(locodigits1, 1) ./ win;
for i = 1:segments
    loco_segs(i, :) = mean(locodigits1((i-1)*win+1:i*win, :), 1);
end
%%
figure
plot(mean(loco_segs, 2))
%%
for i = 1:85
    loc_ind(:, i) = find(stimnums == i);
end
%%
figure
for i = 1:85
    subplot(9, 10, i)
    loco_plot = locodigits1(:, loc_ind(:, i));
    plot(mean(loco_plot'))
    xline(2*samprate, 'r')
end