function [user_id,user_verified] = asyncio_step2_interpret_user_ids8(im,net,net2)
% clear

%% test
% load('net_resnet18.mat') % the net needs to be passed from outside
% net = net_resnet18;

% load('C:\Users\felix\OneDrive\research_psu\2023_02_13_TikTok_getfollower_clean\net_resnet18v2.mat','net_resnet18v2')
% net = net_resnet18v2;
% im = screencapture(0);
% im = im1;
%% main
[user_ids,user_ids0,user_verified] = asyncio_step1_read_user_ids_letters_v8(im); % get user id letters
% [user_ids] = step1_read_user_ids_letters_v2; % get user id letters
user_id = strings(length(user_ids),1);
remove_ind = false(length(user_ids),1);
for idx0 = 1 : length(user_ids)
    letters = user_ids{idx0};
    user_id0 = strings(1,size(letters,3));
    for idx1 = 1 : size(letters,3)
        letter_im = letters(:,:,idx1);
        letter_bw = letter_im > 55;



        class = classify(net,letter_bw);
        if string(class) == "DOT"
            class = ".";
        end

        if string(class) == "ERROR"
            letters0 = user_ids0{idx0};
            letter_im0 = letters0(:,:,idx1);
            output_string = step21_interpret_error6(letter_im0,net,net2);
            if output_string == "INCOMPLETE"
                remove_ind(idx0) = true; % remove incomplete
                %                 error('Fucked')
            end
            %             figure(1)
            %             imagesc(letter_im0)
            %             title(output_string)

            %             pause
            user_id0(idx1) = string(output_string);
        else
            user_id0(idx1) = string(class);
        end
    end
    user_id(idx0) = lower(join(user_id0,""));
    %% save files
%     im_user_id = sum(user_ids0{idx0},3);
%     im_user_id1 = im_user_id(:,1:750);
%     img_filename = ['C:\Users\felix\Desktop\TikTok_plots2\original\',char(user_id(idx0)),'.png'];
%     img_filename1 = ['C:\Users\felix\Desktop\TikTok_plots2\short\',char(user_id(idx0)),'.png'];
%     imwrite(im_user_id,img_filename)
%     imwrite(im_user_id1,img_filename1)

end
user_verified(remove_ind) = [];
user_id(remove_ind) = [];
