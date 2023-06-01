clc;clear;close all;

%实验二:图像增强技术
image_folder=fullfile(pwd,'fog');
img=imread(strcat(image_folder,'\fog3.jpg'));
img_g=rgb2gray(img); %灰度化
%imshow(img_g);
%% 直方图均衡化
img1=histeq(img_g);
figure();
imshow([img_g,img1]);
title('左：原图  右：直方图均衡化后的图');
%% 均值滤波
img2=imfilter(img_g,fspecial('average'),'replicate','same');
img3=imfilter(img_g,fspecial('average',1),'replicate','same');
img4=imfilter(img_g,fspecial('average',20),'replicate','same');
figure();
subplot(2,2,1);imshow(img_g);title("原图");
subplot(2,2,2);imshow(img2);title("均值滤波，hsize=[3,3]");
subplot(2,2,3);imshow(img3);title("均值滤波，hsize=[1,1]");
subplot(2,2,4);imshow(img4);title("均值滤波，hsize=[20,20]");
%% 高斯滤波
img5=imfilter(img_g,fspecial('gaussian',3,0.5),'replicate','same');
img6=imfilter(img_g,fspecial('gaussian',1,0.5),'replicate','same');
img7=imfilter(img_g,fspecial('gaussian',20,0.5),'replicate','same');
figure();
subplot(2,2,1);imshow(img_g);title("原图");
subplot(2,2,2);imshow(img5);title("高斯滤波，hsize=[3,3]");
subplot(2,2,3);imshow(img6);title("高斯滤波，hsize=[1,1]");
subplot(2,2,4);imshow(img7);title("高斯滤波，hsize=[20,20]");
%% 中值滤波
img8=medfilt2(img_g,[3,3]);
img9=medfilt2(img_g,[1,1]);
img10=medfilt2(img_g,[20,20]);
figure();
subplot(2,2,1);imshow(img_g);title("原图");
subplot(2,2,2);imshow(img8);title("中值滤波，hsize=[3,3]");
subplot(2,2,3);imshow(img9);title("中值滤波，hsize=[1,1]");
subplot(2,2,4);imshow(img10);title("中值滤波，hsize=[20,20]");

