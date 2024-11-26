m=readmatrix("coordsDL.csv");
f = fopen("Log_2019_04_15_14_20_28.txt");
dataLog = cell2mat(textscan(f, '%f%*[^\n]'));
fclose(f);
count = 0;
maxFrame = 626397;
%Sampling Rate is 20,000Hz
n = diff(dataLog);
indexChange = find(diff(ttl_data(1,:)) == 1) * 60 / 20000;
 % offset eg. 0.5s = 60 frames
impFrames = zeros(2550,120, 25);
%iFrames = cell(2550,120);
%%
for x = 1:2550
    for y = 1:120
        % y= whole time/frames
        impFrames(x,y,:) = m(int64(indexChange(1,x)) - 60 + y, :);
        %disp([m(int64(indexChange(1,x)) - 60 + y, :)])
        %iFrames(x,y) = num2cell(m(int64(indexChange(1,x)) - 60 + y, :));
    end
end
%% 
frame = 1;
for x = 2:25
    if not(rem(x-1,3) == 0)
        if x - 3 < 1
            figure("Name", "Head")
        elseif x - 6 < 1
            figure("Name", "Top Right Ear")
        elseif x - 9 < 1
            figure("Name", "Bottom Right Ear 1")
        elseif x - 12 < 1
            figure("Name", "Bottom Right Ear 2")
        elseif x - 15 < 1
            figure("Name", "Top Left Ear")
        elseif x - 18 < 1
            figure("Name", "Bottom Left Ear 1")
        elseif x - 21 < 1
            figure("Name", "Bottom Left Ear 2")
        elseif x - 24 < 1
            figure("Name", "Brain")
        else
            figure(x)
        end
        plot(impFrames(1,:,1), impFrames(1,:,x))
    end
end
%%
figure
hold on
for x = 2:25
    if not(rem(x-1,3) == 0)
        plot(impFrames(1,:,1), impFrames(1,:,x))
    end
end
hold off
%%

%%
%{
for i = 1:4
    d = nnz(diff(ttl_data(1,:))==1);
    subplot(1, 4, i)
    plot(ttl_data(i,:))
end
%}
%%
figure;
plot(1:120, squeeze(impFrames(:, :, 1)))
%%
titles = {'Head', 'Top R', 'Bottom R 1', 'Bottom R 2', 'Top left', 'Bottom L 1', 'Bottom L 2', 'Brain'};
for i = 1:8
    figure 
    % setsize(6, 14)
    subplot(4, 1, 1)
    x_base(i) = mean(impFrames(:, 1:20, 2+(i-1)*3), "all");
    plot(1:120, mean(impFrames(1, :, 2+(i-1)*3), 1) - x_base(i))
    xline(60, 'r')
    title([titles{i}, ' x'])
    xlabel('Frames')
%     ylabel('')
    subplot(4, 1, 2)
    y_base(i) = mean(impFrames(:, 1:20, 3+(i-1)*3), "all");
    plot(1:120, mean(impFrames(1, :, 3+(i-1)*3), 1) - y_base(i))
    xline(60, 'r')
    xlabel('Frames')
    title([titles{i}, ' y'])
    subplot(4, 1, 3)
    plot3(1:120, mean(impFrames(1, :, 2+(i-1)*3), 1) - x_base(i), mean(impFrames(1, :, 3+(i-1)*3), 1) - y_base(i))
    subplot(4, 1, 4)
    plot(impFrames(1:1500, :, 2+(i-1)*3) - x_base(i), impFrames(1:1500, :, 3+(i-1)*3) - y_base(i), '.')
    xlabel('x')
    ylabel('y')
    ylim([-20 50])
    xlim([-60 80])
end
