clear;clc;close all;

%% 载入字典获取 Dl，Dh，以及低分辨率图Y，对DI归一化
image_folder=fullfile(pwd, 'image');
img=imread(strcat(image_folder,'\','input.bmp'));
load('D_1024_0.15_5.mat');   % 载入预训练好的字典
[dict_size, ~] = size(Dh);   % 用于计算特征块大小
Norm = sqrt(sum(Dl.^2));     % 对Dl进行归一化处理
Dl_norm = Dl./Norm;

%% 获取特征块大小,自定义重叠域 overlap(也可以理解为步长)，超分系数 lambda（这里我们取 0.2）
patch_size = sqrt(dict_size);   % 获取字典中的特征块大小
overlap = 2;                    % 自定义步长，步长越小重建后的图像越清晰，但算法耗时加大
lambda = 0.2;

%% 对低分辨率图插值
scale = 4;                                 % 定义目标高分辨率图像的缩放倍数
img_l = imresize(img, scale, 'bicubic');   % 使用双三次插值算法对低分辨率图像进行放大
[row,col,~]=size(img_l);                   % 获取插值后的图像的尺寸
img_l_ycbcr = rgb2ycbcr(img_l);            % 将插值后的低分辨率图像从RGB颜色空间转换到YCbCr颜色空间
img_l_Y=img_l_ycbcr(:,:,1);                % 获取亮度分量Y、色度分量cb、色度分量cr
img_l_cb=img_l_ycbcr(:,:,2);
img_l_cr=img_l_ycbcr(:,:,3);

%% 提取低分辨率图特征
h1 = [-1,0,1];    % 定义一阶导和二阶导算子
h2 = h1.';
h3 = [1,0,-2,0,1];
h4 = h3.';

feature = zeros(row,col,4);                   % 生成四个特征图存储在feature矩阵中
feature(:,:,1) = conv2(img_l_Y, h1, 'same');  % 将卷积算子分别应用于低分辨率图像img_l_Y
feature(:,:,2) = conv2(img_l_Y, h2, 'same');
feature(:,:,3) = conv2(img_l_Y, h3, 'same');
feature(:,:,4) = conv2(img_l_Y, h4, 'same');

%% 对每个特征块求最优高分辨率块（循环）
X = zeros([size(img_l_Y,1),size(img_l_Y,2)]);    % 初始化高分辨率图像
flag = zeros([size(img_l_Y,1),size(img_l_Y,2)]); % 初始化统计像素格作加法次数的计数数组

% 循环遍历低分辨率图像块
for i = 1:overlap:size(img_l_Y,1)-patch_size+1
    for j = 1:overlap:size(img_l_Y,2)-patch_size+1       
        
        % 提取当前重叠区域的低分辨率块并计算均值
        block = img_l_Y(i:i+patch_size-1,j:j+patch_size-1,:);    
        m = mean(mean(block));    % 计算当前低分辨率块的均值
        
        % 获取特征向量展开并归一化
        feature_one_dem = zeros([patch_size*patch_size*4,1]);  % 将当前重叠区域内的四个特征图合并成一个一维特征向量
        for k = 1:4
            feature_map = feature(:,:,k);   
            feature_block = feature_map(i:i+patch_size-1,j:j+patch_size-1);  % 从四个特征图中提取当前重叠区域对应的小块
            feature_one_dem((k-1)*patch_size*patch_size+1:k*patch_size*patch_size)...
                = feature_block(:);                            % 将当前小块的像素值展开成一维向量，并加入特征向量中
        end
        Norm = sqrt(sum(feature_one_dem.^2));
        Fy = feature_one_dem./Norm;     % 对当前特征向量进行归一化处理得到Fy
        
        % 利用 Dl，Fy，求得 A，b，代入函数求得该块的最优稀疏系数 
        A = Dl_norm'*Dl_norm;
        b = -Dl_norm'*(Fy);
        a = L1QP(A, b, lambda);
        
        % 生成高分辨率图像块，并将其加入高分辨率图像
        x = Dh*a;
        x = reshape(x,[patch_size,patch_size]);  % 将线性放缩后的高分辨率块加入高分辨率图像中
        x = lin_scale(x, block, m);
        x = x + m;   % 将均值加回高分辨率块上
       
        % 累加高分辨率图像块，并统计像素格作加法的次数（用于解决过亮问题）
        X(i:i+patch_size-1,j:j+patch_size-1) = X(i:i+patch_size-1,j:j+patch_size-1) + x;
        flag(i:i+patch_size-1,j:j+patch_size-1) = flag(i:i+patch_size-1,j:j+patch_size-1) + 1;      
    end
end

% 利用之前求得的flag对像素值进行处理
flag(flag<1) = 1;
X = X./flag;

%% 结果输出
% 将重建的高分辨率图像从YCbCr颜色空间转回RGB颜色空间
img_h_ycbcr = zeros([row,col,3]);
img_h_ycbcr(:,:,1)=X;           %仅对Y域操作
img_h_ycbcr(:,:,2)=img_l_cb;    %cb域不变
img_h_ycbcr(:,:,3)=img_l_cr;    %cr域不变
img_h=ycbcr2rgb(uint8(img_h_ycbcr));

% 打印图像
figure;
subplot(1, 2, 1);
imshow(img_l);          % 显示重建前的低分辨率图像
title('低分辨率图像');
subplot(1, 2, 2);
imshow(img_h);          % 显示重建后的高分辨率图像
title('重建后的高分辨率图像');


