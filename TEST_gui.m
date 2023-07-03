% A GUI to review VocalMat classification

% Select the folder containing VocalMat output files - mainly images and xlsx file
selpath = uigetdir
disp(['Selected Path: ', selpath]);

% Get the audio filename which is the folder name
[~, audio_name, ~] = fileparts(selpath);

% Get the xlsx file
xlsx_file = fullfile(selpath, [audio_name, '.xlsx']);
disp(['XLSX File: ', xlsx_file]);

% Read the xlsx file
[~, ~, raw] = xlsread(xlsx_file);
start_times = raw(2:end, 2);
end_times = raw(2:end, 3);
classes = raw(2:end, 19);
is_harmonic = raw(2:end, 20);
is_noisy = raw(2:end, 21);

% ++++++++ CHANGE LOOP START and END ++++++++
loop_start = 1;
loop_end = length(start_times); % some number of length(start_times)

% paranoid checks regarding length of variable
paranoid_checks;

% class 11 to class 5 map
all5_types = {'single', 'harmonic', 'jump', 'other', 'noise'};

class11_to_class5_map = containers.Map;
class11_to_class5_map('chevron') = 'single';
class11_to_class5_map('complex') = 'other';
class11_to_class5_map('down_fm') = 'single';
class11_to_class5_map('flat') = 'single';
class11_to_class5_map('multsteps') = 'harmonic';
class11_to_class5_map('revchevron') = 'single';
class11_to_class5_map('short') = 'noise';
class11_to_class5_map('step_down') = 'jump';
class11_to_class5_map('step_up') = 'jump';
class11_to_class5_map('two_steps') = 'other';
class11_to_class5_map('up_fm') = 'single';
class11_to_class5_map('noise_dist') = 'noise';




% final data
if exist('syllable_data.mat', 'file') == 2
    syllable_data = load('syllable_data.mat').syllable_data;
else
    syllable_data = struct('start_time', {}, 'end_time', {}, 'class_11_by_machine', {}, 'class_5_by_machine', {}, 'class_5_by_human', {}, 'is_harmonic', {}, 'is_noisy', {});
    save('syllable_data.mat', 'syllable_data')
end


% Get the image files
image_files = dir(fullfile(strcat(selpath,'/All'), '*.png'));
image_file_names = {image_files.name};

for i=loop_start:loop_end
% for i=1:length(image_file_names)
    image_path = fullfile(strcat(selpath,'/All'), image_file_names{i});
    f = figure('NumberTitle', 'off', 'Name', "Review VocatMat classification", 'Units', 'normalized', 'Position', [0 0 1 1], 'UserData', 0);
    

    % Load and display an image
    img = imread(image_path); % replace with your image file path
    subplot('Position', [0 0.5 1 0.5]); % create a subplot for the image in the top half of the screen
    imshow(img);

    % classification info
    class5_type = class11_to_class5_map(classes{i});
    machine_classification_info = ['Syllable ', num2str(i), '/', num2str(length(image_file_names)) ' Machine Classification - Class 11: ' classes{i} ' Class 5: ' class5_type];
    textLabel1 = uicontrol('Style', 'text', 'String', machine_classification_info, ...
            'Units', 'normalized', 'Position', [0.25 0.45 0.5 0.05], 'FontWeight', 'bold', 'FontSize', 16);

    % question
    question = 'Accept or Choose the correct class for the syllable';
    textLabel2 = uicontrol('Style', 'text', 'String', question, ...
            'Units', 'normalized', 'Position', [0.25 0.35 0.5 0.05], 'FontWeight', 'bold','FontSize', 16);

    % buttons to click
    accept_msg = ['Accept ', class5_type];
    rest4_types = setdiff(all5_types, class5_type,'stable');


    % Get start times, end times, classes, is_harmonic, is_noisy
    xlsx_file_data = struct;
    xlsx_file_data.start_time = start_times{i};
    xlsx_file_data.end_time = end_times{i};
    xlsx_file_data.class_11_by_machine = classes{i};
    xlsx_file_data.class_5_by_machine = class5_type;
    xlsx_file_data.is_harmonic = is_harmonic{i};
    xlsx_file_data.is_noisy = is_noisy{i};

    accept_btn = uicontrol('Style', 'pushbutton', 'String', accept_msg, ...
        'Units', 'normalized', 'Position', [0.15 0.25 0.2 0.05], 'Callback', @(hObject,eventdata)option_button_Callback(hObject,eventdata,struct('row_num', i, 'human_marked_class5', class5_type, 'xlsx_file_data', xlsx_file_data)), 'BackgroundColor', [0 1 0]);
    button1 = uicontrol('Style', 'pushbutton', 'String', rest4_types{1}, ...
        'Units', 'normalized', 'Position', [0.4 0.25 0.2 0.05], 'Callback', @(hObject,eventdata)option_button_Callback(hObject,eventdata,struct('row_num', i, 'human_marked_class5', rest4_types{1}, 'xlsx_file_data', xlsx_file_data)));
    button2 = uicontrol('Style', 'pushbutton', 'String', rest4_types{2}, ...
        'Units', 'normalized', 'Position', [0.65 0.25 0.2 0.05], 'Callback', @(hObject,eventdata)option_button_Callback(hObject,eventdata,struct('row_num', i, 'human_marked_class5', rest4_types{2}, 'xlsx_file_data', xlsx_file_data)));
    button3 = uicontrol('Style', 'pushbutton', 'String', rest4_types{3}, ...
        'Units', 'normalized', 'Position', [0.15 0.15 0.2 0.05], 'Callback', @(hObject,eventdata)option_button_Callback(hObject,eventdata,struct('row_num', i, 'human_marked_class5', rest4_types{3}, 'xlsx_file_data', xlsx_file_data)));
    button4 = uicontrol('Style', 'pushbutton', 'String', rest4_types{4}, ...
        'Units', 'normalized', 'Position', [0.4 0.15 0.2 0.05], 'Callback', @(hObject,eventdata)option_button_Callback(hObject,eventdata,struct('row_num', i, 'human_marked_class5', rest4_types{4}, 'xlsx_file_data', xlsx_file_data)));

    % additional info about harmonic and noisy
    additional_info = ['Additional Info: Harmonic: ', num2str(is_harmonic{i}), ' Noisy: ', num2str(is_noisy{i})]
    textLabel3 = uicontrol('Style', 'text', 'String', additional_info, ...
            'Units', 'normalized', 'Position', [0.25 0.05 0.5 0.05], 'FontWeight', 'bold','FontSize', 16);


    waitfor(f, 'UserData')
    f.UserData = 0;  % Reset UserData for the next iteration
    close all;
    
end

% Callback functions for buttons
function option_button_Callback(hObject, eventdata, data)
    update_syllable_data(data.row_num, data.human_marked_class5, data.xlsx_file_data);
    f = gcf;  % Get the handle to the current figure
    f.UserData = 1;  % Change the UserData property
end

function update_syllable_data(row_num, class_5_by_human, xlsx_file_data)
   syllable_data = load('syllable_data.mat').syllable_data;
    % save data
    syllable_data(row_num).start_time = xlsx_file_data.start_time;
    syllable_data(row_num).end_time = xlsx_file_data.end_time;
    syllable_data(row_num).class_11_by_machine = xlsx_file_data.class_11_by_machine;
    syllable_data(row_num).class_5_by_machine = xlsx_file_data.class_5_by_machine;
    syllable_data(row_num).class_5_by_human = class_5_by_human;
    syllable_data(row_num).is_harmonic = xlsx_file_data.is_harmonic;
    syllable_data(row_num).is_noisy = xlsx_file_data.is_noisy;

    save('syllable_data', "syllable_data")
    disp('------ saving data ------')
end