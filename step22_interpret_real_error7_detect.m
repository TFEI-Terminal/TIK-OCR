function [class] = step22_interpret_real_error7_detect(mask,net2)

%% test
% load('net_resnet18v3_error2.mat','net_resnet18v3_error2')
% clear

% d = dir('C:\Users\felix\Desktop\New folder (3)\*.png');

% for file_id = 1 : length(d)
%     input_filename = fullfile(d(file_id).folder,d(file_id).name);
%
%     %% get "_" y = 52-57, x = 33 pixels
%     % input_filename = 'C:\Users\felix\Desktop\New folder (3)\176.png';
%     im = uint8(imread(input_filename)*255);

%% main
im = mask;
horzi_sum = sum(im,2); % horizontal summation
underscore_locations0 = horzi_sum > 31; % find underscore locations

im1 = im;
im_underscore = im;
im_underscore(~underscore_locations0,:) = 0;
stats = regionprops(im_underscore>0,'Area','Extent','BoundingBox','Centroid');
location_undersocre = 0;
class_undercore = "";
if ~isempty(stats)
    area = zeros(1,length(stats));
    extent = zeros(1,length(stats));
    centroid = zeros(1,length(stats));
    for i = 1 : length(stats)
        area(i) = stats(i).Area;
        extent(i) = stats(i).Extent;
        centroid(i) = stats(i).Centroid(2);
    end

    ind0 = find(area > 165 & extent > .9 & centroid > 40);
    for i = 1 : length(ind0)
        bbox = stats(ind0(i)).BoundingBox;
        im1(ceil(bbox(2)):ceil(bbox(2)+bbox(4))...
            ,ceil(bbox(1)):ceil(bbox(1)+bbox(3))) = 0;


        [area1,area_ind] = max(area);
        length_underscore = stats(area_ind).BoundingBox(3); % length of the underscore
        n_underscore = round(length_underscore/34); % number of underscore
        location_undersocre = stats(area_ind).Centroid(1); % horizontal location of the underscore
        class_undercore = repelem('_',n_underscore); % output underscores
    end
end
%%
% underscore_locations = underscore_locations0;
% im1(underscore_locations,:) = 0; % im with underscore removed
im1 = im1 > 0;
im1_mask = imdilate(im1,strel('line',7,90)) > 0; % connect vertial missed parts
class_letters = "";
location_letters = 0;
if sum(im1(:)) > 50 % then the image contains underscore only

    % split remaining elements
    stats1 = regionprops(im1_mask,"PixelIdxList","Centroid");
    for i = 1 : length(stats1)
        ind1 = stats1(i).PixelIdxList;
        im2 = zeros(size(im1));
        im3 = zeros(size(im1));
        im2(ind1) = 1;
        im3(im1 & im2) = 1; % the image processed by mask
        stats2 = regionprops(double(im3),'Image','Area');
        if stats2.Area > 50
            im4 = stats2.Image;
            im5 = prepare_img(im4);

            class_letters(i) = string(classify(net2,im5));
            location_letters(i) = stats1(i).Centroid(1); %#ok<SAGROW>

%             if class_letters(i) == "IMCOMPLETE"
%                 error('fucked')
%             end
            %                 pause
%             output_folder = ['\\DESKTOP-TE9TUHL\research_localfiles\2023_02_12_TikTok_Follower\Train_20230309\New folder (3)\Train\train_error3\',char(class_letters(i))];
%             output_filename = [output_folder,'\',num2str(rand*100),'.png'];
%             fprintf('\n Eror Saved... class = %5s',class_letters(i))
%             if ~exist(output_folder, 'dir')
%                 mkdir(output_folder)
%             end
%             imwrite(im5,output_filename)
%             figure(1)
%             imagesc(im5)
%             pause
        else
            class_letters(i) = "";
        end
    end
end

if sum(class_letters == "INCOMPLETE") > 0    % skip incomplete
    class = "INCOMPLETE";
else
    locations = [location_undersocre,location_letters];
    classes = [class_undercore class_letters];
    [~,d_locations] = sort(locations);
    class0 = classes(d_locations);
    class = lower(join(class0,""));

    if isempty(char(class)) % nothing detected
        class = "INCOMPLETE";
    end
end

% if class == "INCOMPLETE";
%         error('fucked')
% end


% plot

%     figure(1)
%     imagesc(im)
%     title(class, 'Interpreter', 'none')
%     pause
% end
