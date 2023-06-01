clc;close all;clear;

%%%实验二仿射变换
%任务一
image_folder=fullfile(pwd,'image');
img=imread(strcat(image_folder,'\','11.jpg'));
%平移变换
M1=[1,0,100;0,1,100;0,0,1];
M1=projective2d(M1');
img1=imwarp(img,M1);
%旋转变换
M2=[cos(pi/8),sin(pi/8),0;-sin(pi/8),cos(pi/8),0;0,0,1];
M2=projective2d(M2');
img2=imwarp(img,M2);
%缩放变换
M3=[2,0,0;0,1,0;0,0,1];
M3=projective2d(M3');
img3=imwarp(img,M3);
%反射变换
M4=[-1,0,0;0,1,0;0,0,1];
M4=projective2d(M4');
img4=imwarp(img,M4);
%错切变换
M5=[1,0.1,0;0.1,1,0;0,0,1];
M5=projective2d(M5');
img5=imwarp(img,M5);
%绘图
figure();
subplot(5,2,1);imshow(img);title("原图");
subplot(5,2,2);imshow(img1);title("平移变换后");
subplot(5,2,3);imshow(img);title("原图");
subplot(5,2,4);imshow(img2);title("旋转变换后");
subplot(5,2,5);imshow(img);title("原图");
subplot(5,2,6);imshow(img3);title("缩放变换后");
subplot(5,2,7);imshow(img);title("原图");
subplot(5,2,8);imshow(img4);title("反射变换后");
subplot(5,2,9);imshow(img);title("原图");
subplot(5,2,10);imshow(img5);title("错切变换后");


%任务二
img_=imread(strcat(image_folder,'\','img.jpg'));
m1=[1,0,0;0,1.8,0;0,0,1];     %此矩阵为缩放矩阵，y放大1.8倍
m2=[cos(-pi/4.7),sin(-pi/4.7),0;-sin(-pi/4.7),cos(-pi/4.7),0;0,0,1];  %此矩阵为旋转变换，逆时针旋转pi/4.7
m=projective2d(m1*m2);
img1_=imwarp(img_,m);
figure();
subplot(1,2,1);imshow(img_);title("原图");
subplot(1,2,2);imshow(img1_);title("变换后");


%任务三
img1=imread(strcat(image_folder,'\任务三\affine3_1.jpg'));
img2=imread(strcat(image_folder,'\任务三\affine3_2.jpg'));
M=[3.48,0.47,0.00067;0,1.35,0;0,0,1];
m=projective2d(M);
img3=imwarp(img2,m);
img3(1866,2800,3)=0;
img3=imtranslate(img3,[500, 110]);
img4=img1+img3;
figure();
imshow(img4);









