clear



%% initialize

load('net_resnet18v2.mat','net_resnet18v2')
load('net_resnet18v4_error2.mat','net_resnet18v4_error2')
uids_folder = 'mielchiv19\TikTok_uids'
net = net_resnet18v2;
net2 = net_resnet18v4_error2;
count_file = 0;

    %% read user ids
    standby_space = 20000;
    count = 1;
    user_ids = strings(standby_space,1); % max length is 5000 for each user, allow some duplicates
    verfied_status = zeros(standby_space,1);


    time_read = tic;
    d_uids = dir([uids_folder,'\*.png']);
    % f = waitbar(0,sprintf('Processing %4i out of %4i, time %4.4f',i,length(d_uids),toc(time_read)));
    for i = 1 : length(d_uids)
        filename = fullfile(d_uids(i).folder,d_uids(i).name);
        im = imread(filename);
        [user_id,user_verified] = asyncio_step2_interpret_user_ids8(im,net,net2);


        user_ids(count : count + length(user_id)-1) = user_id;
        verfied_status(count : count + length(user_id)-1) = user_verified;
        count = count + length(user_id);

        fprintf('\n Processing %4i out of %4i, time %4.4f, avg %4.4f'...
            ,i,length(d_uids),toc(time_read),toc(time_read)/i)
        %     waitbar(i./length(d_uids),f,sprintf('Processing %4i out of %4i, time %4.4f',i,length(d_uids),toc(time_read)));
    end
    % close(f)

    remove_ind = user_ids == "";
    user_ids(remove_ind) = [];
    verfied_status(remove_ind) = [];
    [user_ids,ia,~] = unique(user_ids);
    verfied_status = verfied_status(ia);

    fprintf('\n %4i user_ids obtained, %4i verified account',length(user_ids),sum(verfied_status))


 
