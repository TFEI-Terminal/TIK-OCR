function output_string = step21_interpret_error6(letter_im0,net,net2)
% clear

%% test
% d = dir('C:\Users\felix\Desktop\ERROR_ims\*.mat');
% load('net_resnet18.mat')
% net = net_resnet18;
%
% output_folder = 'C:\Users\felix\Desktop\Train_ERROR\';
% count = 0;

% for i = 1 : length(d)
%     filename = fullfile(d(i).folder,d(i).name);
%     load(filename)

mask0 = letter_im0 > 55;

% remove blank
mask_blank = (sum(mask0) > 0);
letter_im2 = letter_im0(:,mask_blank);
mask = letter_im2 > 55;
ref = sum(letter_im2); % x axis intensity reference

%% findpeaks
[pks,locs] = findpeaks(-ref,'MinPeakProminence',80);
if length(locs) > 7 % max pks  = 5
    [~,d_pks] = sort(pks,'descend');
    locs = locs(d_pks(1:7));
end
combos = dec2bin(0:2^length(locs)-1) - '0'; % all possible combinations of cut of
scores0 = zeros(1,size(combos,1)); % average scores of each combo
classes0 = cell(1,size(combos,1));
imgs0 = cell(1,size(combos,1));
for id = 2 : size(combos,1)
    splits = [locs(logical(combos(id,:))) size(mask,2)] ;
    splits = sort(splits);
    split0 = 1; % initialize splits
    scores = zeros(1,length(splits));
    classes = strings(1,length(splits));
    imgs = zeros(50,50,length(splits));
    for id2 = 1 : length(splits) % split images
        split1 = splits(id2);
        temp = mask(:,split0:split1);
        temp1 = double(bwareaopen(temp,20)); % remove small objects and convert to double
        stats = regionprops(temp1,"image","Area","Centroid");

        if ~isempty(stats)
            temp2 = stats.Image;
            temp2 = prepare_img(temp2);
            [class,score] = classify(net,temp2); % classify
        else
            class = "ERROR";
            score = -inf;
            temp2 = prepare_img(temp1);
        end


        classes(id2) = class;
        scores(id2) = max(score);
        imgs(:,:,id2) = temp2;


        if class == "DOT"  &&  stats.Centroid(2) < 40
            class = "ERROR";
        end


        if class == "ERROR" || max(score) < .85
            scores(id2) = -inf; % break if still finds ERROR
            classes = strings(1,length(splits));
            break
        end

        split0 = split1 + 1;
    end
    scores0(id) = mean(scores);
    classes0{id} = classes;
    imgs0{id} = imgs;
    %         scores0
    [~,id3] = max(scores0);
    %         combos(id3,:)
end

%% res
if isempty(locs) || id3 == 1
%     res_class = "None";
%     step22_interpret_real_error6_detect(mask,net_resnet18v3_error2)
%     fprintf('\n Error Detected !!')
    class = step22_interpret_real_error7_detect(mask,net2);
    res_class = class;


    % write errors
%     d = dir('\\DESKTOP-TE9TUHL\research_localfiles\2023_02_12_TikTok_Follower\Train_20230309\New folder (3)\*.png');
%     output_filename = ['\\DESKTOP-TE9TUHL\research_localfiles\2023_02_12_TikTok_Follower\Train_20230309\New folder (3)\',num2str(length(d)+1),'.png'];
%     imwrite(mask,output_filename)

else
    res_class = classes0{id3};
    res_imgs = imgs0{id3};
end

output_string = join(res_class,"");
% end




