clc;clear;close all;

%% 读入图像
image_folder=fullfile(pwd, 'image');
I=imread(strcat(image_folder,'\','demo1.jpg'));
I=rgb2gray(I);   % 将彩色图像转化为灰度图

%% 添加运动模糊
h = fspecial('motion', 14, 90);      % 生成一个运动模糊滤波器
H = fft2(h, size(I, 1), size(I, 2)); % 对滤波器进行傅里叶变换，并通过零填充来使其和I的大小相同
G = H .* fft2(double(I));            % 对I进行傅里叶变换后和H相乘

%% 添加高斯噪声
mean_noise = 0;      % 设置高斯噪声的均值为0
var_noise = 0.001;   % 设置高斯噪声的方差为0.001
noise = sqrt(var_noise) * randn(size(I)) + mean_noise;  % 生成高斯白噪声，并伸缩使得其符合给定的均值和方差
G = G + fft2(noise); % 将高斯噪声加到G中
noisy_motion_blur=real(ifft2(G));    % 计算添加了运动模糊和高斯噪声的图像

%% 构建维纳滤波器
K = 0.5; 
F_hat = conj(H) ./ (abs(H).^2 + K*var_noise./abs(fft2(double(I))).^2);  % 计算维纳滤波器的频域表达式F_hat
restored = real(ifft2(G .* F_hat));      % 对加上了运动模糊和高斯噪声的图像进行维纳滤波处理，得到恢复后的图像

%% 显示结果
figure;
subplot(1,3,1); imshow(I); title('原图');
subplot(1,3,2); imshow(uint8(noisy_motion_blur)); title('有运动模糊且包含噪声的图片');
subplot(1,3,3); imshow(uint8(restored), []); title('维纳滤波后的图像');

