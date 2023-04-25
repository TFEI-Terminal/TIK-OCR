function [user_ids,user_ids0,user_verified] = asyncio_step1_read_user_ids_letters_v8(im)
% returns user ids in 50 x 50 (user_ids)
% and returns user ids in their original size
% close all

%% test

% load('im1.mat')


%%
%
% im = screencapture(0);
r = im(:,:,1);
g = im(:,:,2);
b = im(:,:,3);

% blue marker r = 32, g = 213, b = 236
im_marker = r == 32 & g == 213 & b == 236; % verified account marker
follow_marker = r == 254 & g == 44 & b == 85; % follow icon marker
follow_marker1 =  bwareaopen(follow_marker,2600);
follow_marker2 = imfill(follow_marker1,'holes');
follow_marker3 = follow_marker2;
im1 = rgb2gray(im);
% im1 = im(:,:,2);
im2 = im1; % get useful window


%% initialize
% im_follow = im2(:,ceil(end*0.85):end);
% im_follow2 = (im_follow(:,60))>150;
im_follow = follow_marker3(:,ceil(end*0.85):end);
im_follow2 = (im_follow(:,60))==0;
im_follow_end = find(diff(im_follow2) == 1);
im_user = im2(:,90:floor(end/1.5));
user_ids = cell(1,length(im_follow_end));
user_ids0 = cell(1,length(im_follow_end));
user_ids_remove_ind = zeros(1,length(im_follow_end));
user_verified = zeros(1,length(im_follow_end));
for i = 1 : length(im_follow_end)
% for i = 10
    im_user_marker = im_marker(im_follow_end(i)-35:im_follow_end(i)-17,90:floor(end/1.5)); % check if verified account
    if sum(im_user_marker(:)) > 25
        user_verified(i) = 1;
    end
    if im_follow_end(i)+3 > size(im_user,1) % skip when the last follow touches the end
        user_ids_remove_ind(i) = 1;
        continue
    end
    im_user_id = im_user(im_follow_end(i)-11:im_follow_end(i)+3,:);
    im_user_id_xl = imresize(im_user_id,4);
    im_user_id_xl1 = abs(double(im_user_id_xl)-255);
    mask = im_user_id_xl < 200;
    stats = regionprops(mask,'Area','Centroid','PixelIdxList');
    centrox = zeros(1,length(stats));
    centroy = zeros(1,length(stats));
    area = zeros(1,length(stats));
    letters = zeros(size(im_user_id_xl,1),size(im_user_id_xl,2),length(stats));
    for idx1 = 1 : length(stats)
        centrox(idx1) = stats(idx1).Centroid(1);
        centroy(idx1) = stats(idx1).Centroid(2);
        area(idx1) = stats(idx1).Area;
        templetter = zeros(size(im_user_id_xl));
        templetter(stats(idx1).PixelIdxList) = 1;
        letters(:,:,idx1) = templetter;
    end

    if max(area) > 3000 % skip the top bar, sometimes may happen
%         pause
        user_ids_remove_ind(i) = 1;
        continue
    end

    %% merge i, j
    letters1 = letters;
    merge_ind = find(area < 50 & centroy < mean(centroy)); % find i, j
    for idx2 = 1 : length(merge_ind)
%         pause
        %      for idx2 = 5
        d_centrox = abs(centrox - centrox(merge_ind(idx2)));
        d_centrox(merge_ind(idx2)) = inf;
        [~,merge_target] = min(d_centrox);
        letters1(:,:,merge_target) = letters1(:,:,merge_target) + letters1(:,:,merge_ind(idx2));
    end
    letters1(:,:,merge_ind) = [];


    %% merge a
    flag = 0;
    remove_ind = zeros(1,size(letters1,3));
    letters2 = zeros(50,50,size(letters1,3));
    letters3 = zeros(size(letters1,1),size(letters1,2),size(letters1,3));
    for idx3 = 1 : size(letters1,3)
        if flag % merged splited lower part of letter 'a'
            letters1(:,:,idx3) = letters1(:,:,idx3) + letters1(:,:,idx3-1);
        end
%     for idx3 = 9
        % project mask to the original image
        temp_im = im_user_id_xl1; 
        temp_idx = letters1(:,:,idx3);
        temp_im(~temp_idx) = 0; % original image with only the letter
        stats1 = regionprops(temp_idx,"image","Extent","BoundingBox");
        bbox = stats1.BoundingBox;
        letter = stats1.Image;
        [y,~] = size(letter);        
        if y < 25 && stats1.Extent < .65 % then it`s splited letter 'a'
%             letter_lower_a = letter;
            flag = 1;
            remove_ind(idx3) = 1;
            continue
        end    
        flag = 0;
        temp_im1 = temp_im(ceil(bbox(2)) : floor(bbox(2)+bbox(4)),...
            ceil(bbox(1)) : floor(bbox(1)+bbox(3)));


        %% prepare img for CNN
        letter1 = prepare_img(temp_im1); % use letter image
        letters2(:,:,idx3) = letter1;
        letters3(:,:,idx3) = temp_im;
%         letter1 = prepare_img(letter);
%         letters2(:,:,idx3) = letter1;
    end
    letters2(:,:,logical(remove_ind)) = [];  % letters in 50 x 50 
    letters3(:,:,logical(remove_ind)) = [];  % letters in orginal size
    user_ids{i} = letters2;
    user_ids0{i} = letters3;
end
user_ids(logical(user_ids_remove_ind)) = [];  % letters in 50 x 50 
user_ids0(logical(user_ids_remove_ind)) = []; % letters in orginal size
user_verified(logical(user_ids_remove_ind)) = [];