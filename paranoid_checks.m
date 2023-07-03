% check size of the below variables to make sure they are the same

% [~, ~, raw] = xlsread(xlsx_file);
% start_times = raw(2:end, 2);
% end_times = raw(2:end, 3);
% classes = raw(2:end, 19);

% start_times
if length(start_times) ~= size(raw,1) - 1
    disp('Start times do not match')
end

% end_times
if length(end_times) ~= size(raw,1) - 1
    disp('End times do not match')
end

% classes
if length(classes) ~= size(raw,1) - 1
    disp('Classes do not match')
end


