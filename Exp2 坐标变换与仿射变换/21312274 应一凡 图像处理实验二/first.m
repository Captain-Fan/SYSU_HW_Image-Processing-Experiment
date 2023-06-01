clc;clear;close all;

%%%实验一坐标变换
%%%图片一
%一些已知参数
wai_can=[0,1,0,0;0,0,1,0;1,0,0,-2.9;0,0,0,1];  %外参矩阵
nei_can=[650.1821,0,315.8990;0,650.5969,240.3104;0,0,1.0000];   %内参矩阵
Zc=[37.5,64];
%用于等效替代外参矩阵的两个矩阵
R=[0,1,0;0,0,1;1,0,0];
T=[0,0,-2.9];
%获得像素坐标[u,v,1]
image_folder=fullfile(pwd,'image');
img=imread(strcat(image_folder,'\','1.jpg'));
figure();
subplot(111),imshow(img);
[circle,radii]=imfindcircles(img,[40,200],"ObjectPolarity","dark","Sensitivity",0.97);
viscircles(circle,radii,"color","b");
u=circle(:,1);
v=circle(:,2);
%计算世界坐标系
W1=inv(R)*(inv(nei_can)*(Zc(1).*[u(1);v(1);1])-T.');
W2=inv(R)*(inv(nei_can)*(Zc(2).*[u(2);v(2);1])-T.');
dis1=norm(W1-W2);
disp("第一幅图现实距离:");
disp(dis1);


%%%图片五
Zc=[21,27];
img1=imread(strcat(image_folder,'\','5.jpg'));
figure();
subplot(111),imshow(img1);
hold on;
[x,y]=ginput(2);
%计算世界坐标系
W1=inv(R)*(inv(nei_can)*(Zc(1).*[x(1);y(1);1])-T.');
W2=inv(R)*(inv(nei_can)*(Zc(2).*[x(2);y(2);1])-T.');
dis2=norm(W1-W2);
disp("第五幅图现实距离:");
disp(dis2);


%%%图片八
Zc=[33.5,46,37];
img2=imread(strcat(image_folder,'\','8.jpg'));
figure();
subplot(111),imshow(img2);
hold on;
[x,y]=ginput(3);
%计算世界坐标系
W1=inv(R)*(inv(nei_can)*(Zc(1).*[x(1);y(1);1])-T.');
W2=inv(R)*(inv(nei_can)*(Zc(2).*[x(2);y(2);1])-T.');
dis3=norm(W1-W2);
disp("第八幅图白球之间距离:");
disp(dis3);
W1=inv(R)*(inv(nei_can)*(Zc(2).*[x(2);y(2);1])-T.');
W2=inv(R)*(inv(nei_can)*(Zc(3).*[x(3);y(3);1])-T.');
dis4=norm(W1-W2);
disp("第八幅图小白球与黄球之间距离:");
disp(dis4);
W1=inv(R)*(inv(nei_can)*(Zc(1).*[x(1);y(1);1])-T.');
W2=inv(R)*(inv(nei_can)*(Zc(3).*[x(3);y(3);1])-T.');
dis4=norm(W1-W2);
disp("第八幅图大白球与黄球之间距离:");
disp(dis4);








