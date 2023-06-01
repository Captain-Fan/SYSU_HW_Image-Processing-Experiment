clear;clc;close all;

%% 车牌识别

% 读取车辆图片并转为灰度图
car_img = imread('test1.jpeg');
gray_car_img = rgb2gray(car_img);

%% 车牌定位

% Canny边缘检测
edge_img = edge(gray_car_img,'Canny');
% 取反处理
edge_img = imcomplement(edge_img);
% 构造两个矩形模板
width1 = 8;height1 = 19;width2 = 10;height2 = 20;
SE1 = strel('rectangle',[width1 height1]);
SE2 = strel('rectangle',[width2 height2]);
% 开运算
opening_img = imopen(edge_img,SE1);
% 闭运算
closing_img = imclose(opening_img,SE2);
% 取反处理
closing_complement_img = imcomplement(closing_img);
% 去除小的连通成分（噪点）
min_area = 1000;  % 设置连通成分最小面积阈值
cleaned_img = bwareaopen(closing_complement_img, min_area);
cleaned_img = imcomplement(cleaned_img);

% 显示过程
figure;
subplot(1,4,1);
imshow(opening_img);
title('开运算后的图像','FontSize',12,'FontWeight','bold');
subplot(1,4,2);
imshow(closing_img);
title('闭运算后的图像','FontSize',12,'FontWeight','bold');
subplot(1,4,3);
imshow(cleaned_img);
title('去除小连通成分后的图像','FontSize',12,'FontWeight','bold');

%% 矩形化

% 获取二值化后的图片的行数和列数
[rows, cols] = size(cleaned_img);
binary_img=cleaned_img;

% 遍历图片的像素
for i = 2:rows-1
    for j = 2:cols-1
        % 获取当前像素的值及其四个邻居的值
        center_pixel = binary_img(i, j);
        neighbors = [binary_img(i-1, j), binary_img(i, j-1), binary_img(i+1, j), binary_img(i, j+1)];
        % 如果当前像素是黑色且其四个邻居中至少有两个白色像素，则将其设置为白色像素
        if center_pixel == 0 && sum(neighbors) >= 2
            binary_img(i, j) = 1;
        % 如果当前像素是白色且其四个邻居中至少有两个黑色像素，则将其设置为黑色像素
        elseif center_pixel == 1 && sum(neighbors) <= 2
            binary_img(i, j) = 0;
        end
    end
end

% 重复4次遍历操作，以完全矩形化图片
for i = rows-1:-1:2
    for j = 2:cols-1
        center_pixel = binary_img(i, j);
        neighbors = [binary_img(i-1, j), binary_img(i, j-1), binary_img(i+1, j), binary_img(i, j+1)];
        if center_pixel == 0 && sum(neighbors) >= 2
            binary_img(i, j) = 1;
        elseif center_pixel == 1 && sum(neighbors) <= 2
            binary_img(i, j) = 0;
        end
    end
end
for i = 2:rows-1
    for j = cols-1:-1:2
        center_pixel = binary_img(i, j);
        neighbors = [binary_img(i-1, j), binary_img(i, j-1), binary_img(i+1, j), binary_img(i, j+1)];
        if center_pixel == 0 && sum(neighbors) >= 2
            binary_img(i, j) = 1;
        elseif center_pixel == 1 && sum(neighbors) <= 2
            binary_img(i, j) = 0;
        end
    end
end
for i = rows-1:-1:2
    for j = cols-1:-1:2
        center_pixel = binary_img(i, j);
        neighbors = [binary_img(i-1, j), binary_img(i, j-1), binary_img(i+1, j), binary_img(i, j+1)];
        if center_pixel == 0 && sum(neighbors) >= 2
            binary_img(i, j) = 1;
        elseif center_pixel == 1 && sum(neighbors) <= 2
            binary_img(i, j) = 0;
        end
    end
end

% 显示处理后的二值化图片
binary_img=imcomplement(binary_img);
subplot(1,4,4);
imshow(binary_img);
title('矩形化后的图片','FontSize',12,'FontWeight','bold');

%% 区域选择

% 转换为HSV格式并进行连通性处理
hsv_img=rgb2hsv(car_img);
conn=4;
[L,n]=bwlabel(binary_img,conn);

% 获取每个候选区域的边界框信息
stats=regionprops(L,'BoundingBox');
selected_regions = [];
for i = 1:n
    % 获取当前候选区域的边界框信息
    bbox = stats(i).BoundingBox;
    % 计算矩形的长和宽的比例
    aspect_ratio = bbox(3) / bbox(4);
    % 根据长和宽的比例要求提取矩形区域
    if aspect_ratio<=4 && aspect_ratio>=1.5
        region = hsv_img(round(bbox(2)):round(bbox(2)+bbox(4)-1),...
            round(bbox(1)):round(bbox(1)+bbox(3)-1),:);
        blue=0;
        [r,c,~]=size(region);
        for j=1:r
            for k=1:c
                % 统计蓝色像素点的数量
                if region(r,c,1)<0.667 && region(r,c,1)>0.5
                    blue=blue+1;
                end
            end
        end
        % 计算蓝色像素点占比
        if (blue/sum(region(:)))>=0.5
            region2=car_img(round(bbox(2)):round(bbox(2)+bbox(4)-1),...
            round(bbox(1)):round(bbox(1)+bbox(3)-1),:);
            % 显示处理后的候选区域
            figure;
            subplot(1,3,1);
            imshow(region2);
            title('候选区域','FontSize',12,'FontWeight','bold');
        end
    end
end

%% 图像分割

% 转为灰度图并用Otsu's方法进行二值化处理
gray_img = rgb2gray(region2);
threshold = graythresh(gray_img);
binary_image = imbinarize(gray_img, threshold);
subplot(1,3,2);
imshow(binary_image);
title('二值化后','FontSize',12,'FontWeight','bold');

% 对二值化后的图像进行连通性处理和面积过滤
[x,y]=size(binary_image);
se = strel ('line', 1, 10) ;
closed_img = imclose (binary_image, se) ;
opened_img = bwareaopen (binary_image, 20) ;
subplot(1,3,3);
imshow (opened_img);
title('面积过滤后','FontSize',12,'FontWeight','bold');

% 获取每个字符的位置信息并保存图片
stats = regionprops (opened_img, 'BoundingBox', 'Centroid') ;
temp = 1;
for i = 1:length (stats) 
    if i == 2     % 将第二到第四个图像竖直合并,此处是为了避免不连通汉字内部的分割
        bb1 = stats(i).BoundingBox;
        bb2 = stats(i+1).BoundingBox;
        bb3 = stats(i+2).BoundingBox;
        I = binary_image(round(bb1(2)):round(bb3(2)+bb3(4))-1,round(bb1(1)):round(bb1(1)+bb1(3)),:);
        I = imresize(I,[40,30]);
        I=imcomplement(I);
        imwrite(I,strcat('test/',num2str(temp),'.','jpg'));   % 保存图片，存入test文件夹
        temp = temp + 1;
    elseif i == 3 || i == 4 
        continue;
    else         % 保存每个字符/数字的图片
        bb = stats(i).BoundingBox;
        I = binary_image(round(bb(2)):round(bb(2)+bb(4)),round(bb(1)):round(bb(1)+bb(3)),:);
        I = imresize(I,[40,30]);
        I=imcomplement(I);
        imwrite(I,strcat('test/',num2str(temp),'.','jpg'));   % 保存图片，存入test文件夹
        temp = temp + 1;
    end
end
%% 字符识别      
character_recognition();  %由于程序过长，将接下来的字符识别阶段包转成了函数

