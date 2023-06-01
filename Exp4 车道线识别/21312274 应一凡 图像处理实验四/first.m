clc;clear;close all;

%% 任务一
%------------------------------------%
%         任务一 边缘检测
%------------------------------------%
%% 导入图像
image_folder=fullfile(pwd, 'image');
img=imread(strcat(image_folder,'\','2.jpg'));

%% 将彩色图像转为灰度图像
img_gray=rgb2gray(img);
%imshow(img);

%% 高斯滤波
gw=fspecial('gaussian',[5,5],0.5);              %高斯滤波设置核，5*5，标准差为0.5
img_filter=imfilter(img_gray,gw,'replicate');   %进行高斯滤波
img_f=img_filter;

%% 利用 Sobel 算子计算像素梯度
Sobel_X=[-1,0,1;-2,0,2;-1,0,1];                 %X方向Sobel算子
Sobel_Y=[-1,-2,-1;0,0,0;1,2,1];                 %Y方向Sobel算子
[row,col]=size(img_f);
%创建f_extend是为了在计算Sobel梯度时处理图像边界,由于Sobel算子的计算需要使用像素点周围的邻域信息
%而图像边界的像素点没有完整的邻域，因此需要对图像进行扩展，以便正确处理边界上的像素点
f_extend=zeros(row+2,col+2);                    %图像扩充，边界补0
for i=2:row+1
    for j=2:col+1
        f_extend(i,j)=img_f(i-1,j-1);
    end
end
Gx=zeros(row,col);
Gy=zeros(row,col);
for i=2:row+1                                   %计算x向和y向梯度
    for j=2:col+1
        temp=[f_extend(i-1,j-1),f_extend(i-1,j),f_extend(i-1,j+1);...
              f_extend(i,j-1),f_extend(i,j),f_extend(i,j+1);...
              f_extend(i+1,j-1),f_extend(i+1,j),f_extend(i+1,j+1)];
        Gx(i-1,j-1)=sum(sum(Sobel_X.*temp));    %计算x向梯度
        Gy(i-1,j-1)=sum(sum(Sobel_Y.*temp));    %计算y向梯度
    end
end
Gxy=sqrt(Gx.*Gx+Gy.*Gy);                        %梯度强度矩阵计算

%% 非极大值抑制
index=zeros(row,col);                             %判断梯度方向所属区间,并用index记录
for i=1:row                   
    for j=1:col
        gx=Gx(i,j);
        gy=Gy(i,j);
        if (gy<=0&&gx>-gy)||(gy>=0&&gx<-gy)       %梯度方向属于区间1
            index(i,j)=1;
        elseif (gx>0&&gx<=-gy)||(gx<0&&gx>=-gy)   %梯度方向属于区间2
            index(i,j)=2;
        elseif (gx<=0&&gx>gy)||(gx>=0&&gx<gy)     %梯度方向属于区间3
            index(i,j)=3;
        elseif (gy<0&&gx<=gy)||(gy>0&&gx>=gy)     %梯度方向属于区间4
            index(i,j)=4;
        else                                      %无梯度，判定为非边缘，index记为5
            index(i,j)=5;
        end
    end
end

Gup=zeros(row,col);
Gdown=zeros(row,col);
for i=2:row-1                                               %计算非边界处的插值梯度强度
    for j=2:col-1
        gx=Gx(i,j);
        gy=Gy(i,j);
        if index(i,j)==1                                    %计算区间1内插值梯度
            t=abs(gy./gx);
            Gup(i,j)=Gxy(i,j+1).*(1-t)+Gxy(i-1,j+1).*t;
            Gdown(i,j)=Gxy(i,j-1).*(1-t)+Gxy(i+1,j-1).*t;
        elseif index(i,j)==2                                %计算区间2内插值梯度
            t=abs(gx./gy);
            Gup(i,j)=Gxy(i-1,j).*(1-t)+Gxy(i-1,j+1).*t;
            Gdown(i,j)=Gxy(i+1,j).*(1-t)+Gxy(i+1,j-1).*t;
        elseif index(i,j)==3                                %计算区间3内插值梯度
            t=abs(gx./gy);
            Gup(i,j)=Gxy(i-1,j).*(1-t)+Gxy(i-1,j-1).*t;
            Gdown(i,j)=Gxy(i+1,j).*(1-t)+Gxy(i+1,j+1).*t;
        elseif index(i,j)==4                                %计算区间4内插值梯度
            t=abs(gy./gx);
            Gup(i,j)=Gxy(i,j-1).*(1-t)+Gxy(i-1,j-1).*t;
            Gdown(i,j)=Gxy(i,j+1).*(1-t)+Gxy(i+1,j+1).*t;
        end
    end
end

max_record=zeros(row,col);
for i=1:row                                     
    for j=1:col
        if(Gxy(i,j)>=Gup(i,j))&&(Gxy(i,j)>=Gdown(i,j))     %保留极大值
            max_record(i,j)=Gxy(i,j);                      %抑制非极大值
        end
    end
end

%% 阈值滞后处理
img_result=zeros(row,col);
low_num=180;       %定义低阈值         
high_num=200;      %定义高阈值
connect_num=1;     %孤立性检测中的连接数阈值，用于判断弱边缘是否为边缘

for i=2:row-1      %遍历非边缘像素                                
    for j=2:col-1
        if max_record(i,j)>=high_num        %高于高阈值的像素为强边缘
            img_result(i,j)=1;
        elseif max_record(i,j)<=low_num     %低于低阈值的像素为非边缘
            img_result(i,j)=0;
        else                                %位于高低阈值之间的像素为弱边缘，需进行孤立性检测
            count=0;
            if max_record(i-1,j-1)~=0       %左上方像素
                count=count+1;
            end
            if max_record(i-1,j)~=0         %上方像素
                count=count+1;
            end
            if max_record(i-1,j+1)~=0       %右上方像素
                count=count+1;
            end
            if max_record(i,j-1)~=0         %左方像素
                count=count+1;
            end
            if max_record(i,j+1)~=0         %右方像素
                count=count+1;
            end
            if max_record(i+1,j-1)~=0       %左下方像素
                count=count+1;
            end
            if max_record(i+1,j)~=0         %下方像素
                count=count+1;
            end
            if max_record(i+1,j+1)~=0       %右下方像素
                count=count+1;
            end
            if count>=connect_num           %弱边缘周围像素中强边缘个数大于设置个数，则为强边缘
                img_result(i,j)=1;
            end
        end
    end
end

%% 调用matlab内置函数进行边缘检测
BW=edge(img_gray,'canny');

%% 显示边缘检测结果
figure();
subplot(1,3,1);
imshow(img);
title('原始图像');
subplot(1,3,2);
imshow(img_result);
title('自行编写的Canny边缘检测');
subplot(1,3,3);
imshow(BW);
title('MATLAB内置的Canny边缘检测');



%% 任务二
%------------------------------------%
%         任务二 车道线识别   
%------------------------------------%
%% 选取ROI区域生成蒙版图像
%这里使用鼠标手动选择ROI区域
figure;
imshow(img);
title('请选择ROI区域');
h=drawrectangle;
position=h.Position;
ROI=createMask(h);
close;
%应用ROI蒙版图像
maskedImg=img_result.*ROI;
figure;
imshow(maskedImg);
title("蒙版后的图");
%% 霍夫变换
lines = HoughStraightRecognize(maskedImg);

%% 根据先验知识筛选直线
validLines=[];   %用于储存符合条件的直线
minLength=50;
maxLength=1000;
for i=1:length(lines)
    %计算直线长度
    lineLength=sqrt((lines(i).point1(1)-lines(i).point2(1))^2+...
        (lines(i).point1(2)-lines(i).point2(2))^2);
    %判断直线是否符合车道线要求
    if lineLength>=minLength&&lineLength<=maxLength 
        validLines=[validLines, lines(i)];
    end
end

%% 在原图上绘制检测到的直线
figure;
imshow(img);
hold on;
for k=1:length(validLines)
    xy=[validLines(k).point1;validLines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','red');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','blue');
end
title('车道线识别结果');
hold off;

%% 霍夫变换函数
function lines = HoughStraightRecognize(BW)
    [H,T,R] = hough(BW);
    % imshow(H,[],'XData',T,'YData',R,...
    %             'InitialMagnification','fit');
    % xlabel('\theta'), ylabel('\rho');
        % axis on, axis normal, hold on;
    P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    %x = T(P(:,2)); y = R(P(:,1));
    %plot(x,y,'s','color','white');
    lines = houghlines(BW,T,R,P,'FillGap',2.5,'MinLength',10);
    %FillGap 两个线段之间的距离，小于该值会将两个线段合并
    %MinLength 最小线段长度
end
























