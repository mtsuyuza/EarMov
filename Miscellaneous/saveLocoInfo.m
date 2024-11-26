function saveLocoInfo(datafolder, carryover)
% extract locomotion information from the rotary encoder, and save it to
% disk.
if nargin < 2
    carryover = 2048; % wavelet filter
end


datafolder = slashappend(datafolder);
dinfo = dir([datafolder, 'R_UCSC*']);

locoinfo = logical([]);
lococarry = logical([]);
for i = 1:length(dinfo)
    fname = [datafolder dinfo(i).name];
    read_Intan_RHD2000_filename(fname, 1);
    
    locoinfo_this = logical(evalin('base', 'board_dig_in_data(2:3, :)'));

    
    if i == 1
        endtime = size(locoinfo_this, 2) - carryover;
        offset = carryover / 2; % offset time used for writing TTL channels
    else
        endtime = size(locoinfo_this, 2);
        offset = 0;
    end

    locoinfo = [locoinfo, lococarry(:, end/2+1:end) locoinfo_this(:,1+offset:end-carryover/2)];
    lococarry = locoinfo_this(:, end-carryover+1:end);
end
save('-v7.3', [datafolder 'locoinfo.mat'], 'locoinfo')
