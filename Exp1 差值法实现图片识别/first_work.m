clc;clear;close all;

%选取模板集放入文件夹并进行重命名操作
model_num=20;      %每个数字对应的模板数量，模板越多能使结果更精确
num=[9000 0 1000 2000 3000 4000 5000 6000 7000 8000];   %此数组用于简单化图片地址的表示
for i=1:10
    mkdir('IMAGE',num2str(i-1));   %建立文件夹
    for j=1:model_num
        model_img{i,j}=imread(strcat('./train_dataset/',num2str(i-1),'/image',num2str(num(i)+j*20),'.png')); %挑选model_num张图片存入文件夹
        imwrite(model_img{i,j},strcat('IMAGE/',num2str(i-1),'/model',num2str(j),'.png'));  %对图片重命名操作
    end
end

%选取测试集放入文件夹并进行重命名操作
test_num=10;      %每个数字的用于测试的图片数量
for i=1:10
    mkdir('TEST', num2str(i-1));
    for j=1:test_num
        test_img{i,j}=imread(strcat('./train_dataset/',num2str(i-1),'/image',num2str(num(i)+j*20+1),'.png')); %取模板集之后的那一张图片避免重复
        imwrite(test_img{i,j},strcat('TEST/',num2str(i-1),'/test',num2str(j),'.png'));    %重命名操作
    end
end

%一些数据的初始化
[s1,s2]=size(model_img{1,1});  %以此图片的大小为标准对之后图片进行imresize操作
count=0;  %正确率计数器
result=zeros(10,test_num);   %记录识别结果
dist=zeros(10,model_num);    %记录差值
            
%实现图片识别的主循环
for k=1:10
    for i=1:test_num
        test_img{k,i}=imread(strcat('./TEST/',num2str(k-1),'/test',num2str(i),'.png'));  %读入重命名后的测试集图片
        %对测试集图片进行处理
        temp=test_img{k,i};            %备份
        temp2=imresize(temp,[s1,s2]);  %图片大小标准化   
        temp3=mat2gray(temp2);         %灰度化                                     
        temp4=imbinarize(temp3);       %二值化              
        %对模板集图片进行相同操作用于计算差值
        for j=1:10
            for m=1:model_num
                model=imread(strcat('./IMAGE/',num2str(j-1),'/model',num2str(m),'.png')); %读取模板集图片
                model=imresize(model,[s1,s2]);         %大小标准化
                model=imbinarize(model);               %二值化
                dist(j,m)=sum(sum(abs(temp4-model)));  %计算与各个模板之间的误差，储存在dist数组中
            end
        end
        %得到差值数组后即可进行图片识别
        best=min(dist,[],'all');       %找到误差最小值
        [row,col]=find(dist==best);    %找到误差最小值对应的索引
        result(k,i)=row(1)-1;          %索引中行数减一即为识别结果，因为模板即集序号从1开始但是内含数字从0开始 
        if result(k,i)==k-1            %若判断正确，计数器加一
            count=count+1;
        end
    end
end

%结果输出
display(result);
correct_rate=count/(10*test_num);
display(correct_rate);
