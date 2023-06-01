clc;clear;close all;

%% 读入图像
image_folder = fullfile(pwd, 'image');
image = imread(strcat(image_folder,'\','input.bmp'));

%% 最邻近插值法
img1 = nearest(image,2);
img1_1 = imresize(image, 2, 'nearest');

%% 双线性插值法
img2 = bilinear(image,2);
img2_2 = imresize(image, 2, 'bilinear');

%% 双三次插值法
img3 = bicubic(image,2); 
img3_3 = imresize(image, 2, 'bicubic');

%% 打印图片
figure;
subplot(2,4,[1 5]);imshow(image);title("原图");
subplot(2,4,2);imshow(img1);title("自行编写的最邻近插值法");
subplot(2,4,3);imshow(img2);title("自行编写的双线性插值法");
subplot(2,4,4);imshow(img3);title("自行编写的双三次插值法");
subplot(2,4,6);imshow(img1_1);title("matlab自带的最邻近插值法");
subplot(2,4,7);imshow(img2_2);title("matlab自带的双线性插值法");
subplot(2,4,8);imshow(img3_3);title("matlab自带的双三次插值法");

%% 最邻近插值法函数实现
function output_img = nearest(input_img, scale) % input_img为原始图像，scale为放大比例
    input_img = double(input_img) / 255;        % 将输入图像像素值归一化到 [0,1] 区间内
    
    % 判断输入图像是灰度图还是RGB图，并根据比例计算输出图像大小
    if ismatrix(input_img)     
        output_img = zeros(floor(size(input_img) * scale));
    else
        output_img = zeros([floor(size(input_img, 1, 2) * scale), 3]);
    end

    % 扩展输入图像，以便进行最邻近插值计算
    extended_img = zeros([size(input_img, 1, 2) + 2 * floor(scale), size(output_img, 3)]);
    for i = 1 : size(output_img, 3)    % 对每个 RGB 通道分别进行扩展
        tmp = padarray(input_img(:, :, i), [floor(scale), floor(scale)], 'symmetric');
        extended_img(:, :, i) = tmp;
    end

    % 遍历输出图像中的每个像素，并根据最邻近插值原理计算像素值
    for i = 1 : size(output_img, 1)
        for j = 1 : size(output_img, 2)          % 计算输入图像中对应的坐标位置
            img_x = round((i + 0.5) / scale - 0.5);
            img_y = round((j + 0.5) / scale - 0.5);
            nearest = extended_img(floor(img_x + scale), floor(img_y + scale), :);  % 从扩展后的图像中获取最邻近的像素值
            output_img(i, j, :) = nearest(:);    % 将获取到的像素值赋值给输出图像
        end
    end
end

%% 双线程差值法函数实现
function output_img = bilinear(input_img, scale)  % input_img为原始图像，scale为放大比例
    input_img = double(input_img) / 255;          % 将输入图像像素值归一化到 [0,1] 区间内
    
    % 判断输入图像是灰度图还是RGB图，并根据比例计算输出图像大小
    if ismatrix(input_img)     
        output_img = zeros(floor(size(input_img) * scale));
    else
        output_img = zeros([floor(size(input_img, 1, 2) * scale), 3]);
    end
    
    % 扩展原始图像
    extended_img = zeros([size(input_img, 1, 2) + 2 * floor(scale), size(output_img, 3)]);
    for i = 1 : size(output_img, 3)   % 对每个通道进行扩展
        tmp = padarray(input_img(:, :, i), [floor(scale), floor(scale)], 'symmetric');
        extended_img(:, :, i) = tmp;
    end
    
    % 进行双线性插值
    for i = 1 : size(output_img, 1)                   % 遍历目标图像的每个像素
        for j = 1 : size(output_img, 2)   
            img_x = floor((i + 0.5) / scale - 0.5);   % 计算目标图像上每个像素对应的原图像上的坐标
            img_y = floor((j + 0.5) / scale - 0.5);  
            u = ((i + 0.5) / scale - 0.5) - img_x;    % 计算目标像素在原图像上对应的四个像素坐标
            v = ((j + 0.5) / scale - 0.5) - img_y;
            tmp = (1 - u) * (1 - v) * extended_img(round(img_x + scale), round(img_y + scale), :) ...  %进行双线性插值
                + (1 - u) * v * extended_img(round(img_x + scale), round(img_y + scale) + 1, :) ...
                + u * (1 - v) * extended_img(round(img_x + scale) + 1, round(img_y + scale), :) ...
                + u * v * extended_img(round(img_x + scale) + 1, round(img_y + scale) + 1, :);
            output_img(i, j, :) = tmp(:);             % 将插值结果赋值给目标图像的当前像素
        end
    end
end

%% 双三次插值法函数实现
function output_img = bicubic(input_img, scale)   % input_img为原始图像，scale为放大比例
    input_img = double(input_img) / 255;          % 将输入图像像素值归一化到 [0,1] 区间内
    
    % 判断输入图像是灰度图还是RGB图，并根据比例计算输出图像大小
    if ismatrix(input_img) 
        output_img = zeros(floor(size(input_img) * scale)); 
    else
        output_img = zeros([floor(size(input_img, 1, 2) * scale), 3]);
    end
    [dstM, dstN, ~] = size(output_img);           % 获取输出图像矩阵的大小
    
    % 扩展原图像
    extended_img = zeros([size(input_img, 1, 2) + 2 * floor(scale), size(output_img, 3)]);
    for i = 1 : size(output_img, 3)   % 对于RGB图像，对每个通道单独进行处理
        tmp = padarray(input_img(:, :, i), [floor(scale), floor(scale)], 'symmetric');
        extended_img(:, :, i) = tmp;         % 把处理后的通道矩阵存储到misrc相应通道中
    end
     
    %逐像素点赋值
    for dstX = 1 : dstM   % 对于输出图像矩阵中每个像素点
        for dstY = 1 : dstN
            srcX = floor((dstX + 0.5) / scale - 0.5);  % 根据输出图像矩阵中的像素点坐标，计算其对应的源图像矩阵中的坐标
            srcY = floor((dstY + 0.5) / scale - 0.5);
            u = ((dstX + 0.5) / scale - 0.5) - srcX;   % 插值点水平位置
            v = ((dstY + 0.5) / scale - 0.5) - srcY;   % 插值点垂直位置
            X1 = zeros(4, 4);                          % 水平位置之差
            X2 = zeros(4, 4);                          % 垂直位置之差
            W1 = ones(4, 4); 
            W2 = ones(4, 4);   
            
            % 计算出每个插值点附近16个源像素点的权重和位置关系（即计算W）
            for i = 1 : 4               
                for j = 1 : 4
                    X1(i, j) = abs(u - i + 2);
                    X2(i, j) = abs(v - j + 2);
                    if X1(i, j) <= 1    % 计算W1
                        W1(i, j) = 1.5 * (X1(i, j)) ^ 3 - 2.5 * (X1(i, j)) ^ 2 + 1;
                    else
                        if X1(i, j) < 2
                            W1(i, j) = (-0.5) * (X1(i, j)) ^ 3 + 2.5 * (X1(i, j)) ^ 2 - 4 * X1(i, j) + 2;
                        else
                            W1(i, j) = 0;
                        end
                    end
                    if X2(i, j) <= 1    % 计算W2
                        W2(i, j) = 1.5 * (X2(i, j)) ^ 3 - 2.5 * (X2(i, j)) ^ 2 + 1;
                    else
                        if  X2(i, j) < 2
                            W2(i, j) = (-0.5) * (X2(i, j)) ^ 3 + 2.5 * (X2(i, j)) ^ 2 - 4 * X2(i, j) + 2;
                        else
                            W2(i, j) = 0;
                        end
                    end
                end
            end
            
            W = W1 .* W2;    % 计算出每个插值点附近的16个源像素点的权重之积
            Z = ones(4, 4);  % 存储16个源像素点的矩阵
            R = ones(4, 4);  % 存储16个加权后的源像素点的矩阵
            for dstC = 1 : size(output_img, 3)  % 对于RGB图像，对每个通道单独进行处理
                for i = 1 : 4
                    for j = 1 : 4
                        Z(i, j) = extended_img(srcX - 2 + i + round(scale), srcY - 2 + j + round(scale), dstC); 
                        R(i, j) = W(i, j) .* Z(i,j);     % 加权并存储对应的16个加权后的源像素点
                    end
                end
                result = sum(sum(R));                    % 对每个通道加权后的源像素点求和
                output_img(dstX, dstY, dstC) = result;   % 将加权后的结果存储到输出图像矩阵中
            end
        end
    end
end


