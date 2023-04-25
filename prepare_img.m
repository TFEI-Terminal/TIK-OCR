function [out] = prepare_img(in)

in(50,50) = 0;
out = imresize(in,[50 50]);
