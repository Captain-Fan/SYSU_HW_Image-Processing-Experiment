clc;clear;close all;

%实验一：暗通道先验去雾
%设置图像文件夹路径为当前工作目录下的 "fog" 文件夹
image_folder=fullfile(pwd, 'fog');
%循环读取"fog"文件夹下的三张图片，进行去雾处理
for num=1:3
    %读取当前循环到的图像
    input_image=imread(strcat(image_folder,'\','fog',num2str(num),'.jpg'));
    %将图像转换为双精度浮点数，并将像素值归一化到 [0,1] 范围内
    input_image=double(input_image)/255;
    %获取图像的行数和列数
    [rows,cols,~]=size(input_image);
    %在画布上绘制原始图像
    subplot(3,5,5*num-4);
    imshow(input_image);
    title('原图');

    %% 暗通道
    %计算暗通道
    dark_channel=zeros(rows, cols);
    for i=1:rows
        for j=1:cols
            dark_channel(i, j)=min(input_image(i,j,:));
        end
    end
    %设置窗口大小
    window_size = 5;
    %最小值滤波
    dark_channel_filtered=ordfilt2(dark_channel,1,ones(window_size));
    %在画布上绘制暗通道图形
    subplot(3,5,5*num-3);
    imshow(dark_channel_filtered);
    title("暗通道");
    %% 计算参数 A（大气光）和 t（透射率）
    %获取大气光
    A=max(max(dark_channel_filtered));
    %设置去雾程度因子w并计算透射率
    w=[1,0.8,0.6];
    for k=1:length(w)
        t=1-w(k)*(dark_channel_filtered/A);
        %% 输出
        %设置阈值
        threshold=0.1;
        t=max(threshold,t);
        %计算去雾后的图像
        output_image=zeros(rows,cols,3);
        for channel=1:3
            for i=1:rows
                for j=1:cols
                    output_image(i,j,channel)=(input_image(i,j,channel)-A)./t(i, j)+A;
                end
            end
        end
        %在画布上绘制去雾后的图像
        subplot(3,5,5*num-3+k);
        imshow(output_image,[]);
        title(sprintf('去雾因子w=%.1f',w(k)));
    end
end


