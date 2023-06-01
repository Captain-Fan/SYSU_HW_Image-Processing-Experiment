function character_recognition()
    
    %% 对原来的模板文件进行统一大小的操作
    % 指定文件夹路径
    folder_num = '5-carNumber/数字';
    folder_eng = '5-carNumber/英文';
    folder_chi = '5-carNumber/汉字';
    
    % 创建新的muban保存处理后的模板图片
    outputFolder = 'muban';
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    % 遍历数字文件夹中的图片
    fileList = dir(fullfile(folder_num, '*.bmp'));
    len_file1=length(fileList);
    for i = 1:length(fileList)
        filename = fullfile(folder_num, fileList(i).name);
        img = imread(filename);
        gray_img = rgb2gray(img);
        % 设定阈值
        threshold = 0.5;  
        % 对灰度图像进行二值化
        binary_img = imbinarize(gray_img, threshold);
        % disp(binaryImage);
        % 找到二值化图像中黑色像素的坐标，用于裁剪操作，此操作用于提高识别正确率
        [row, col] = find(~binary_img); 
        min_Row = min(row);  % 最小行坐标
        max_Row = max(row);  % 最大行坐标
        min_Col = min(col);  % 最小列坐标
        max_Col = max(col);  % 最大列坐标
        if i ~= 2
            enlarged_img = binary_img(min_Row:max_Row, min_Col:max_Col);  % 裁剪出黑色字母所在的区域
            resized_img = imresize(enlarged_img, [40, 30]);  % 大小统一化
        else    %此裁剪法需要对数字1特殊处理
            enlarged_img = binary_img(min_Row:max_Row, 1:size(binary_img,2));  % 裁剪出黑色字母所在的区域
            resized_img = imresize(enlarged_img, [40, 30]);  % 大小统一化
        end
%         figure;
%         subplot(1,3,1);imshow(binary_img);title("binary_img");
%         subplot(1,3,2);imshow(enlarged_img);title("enlarged_img");
%         subplot(1,3,3);imshow(resized_img);title("resized_img");
        new_file_name = fullfile(outputFolder, strcat(num2str(i),'.jpg'));
        imwrite(resized_img, new_file_name);  % 保存处理后的模板图片
    end
    
    % 遍历字母文件夹中的图片，执行相同的操作
    fileList = dir(fullfile(folder_eng, '*.bmp'));
    len_file2=length(fileList);
    for i = 1:length(fileList)
        filename = fullfile(folder_eng, fileList(i).name);
        img = imread(filename);
        gray_img = rgb2gray(img);
        % 设定阈值
        threshold = 0.5;  
        % 对灰度图像进行二值化
        binary_img = imbinarize(gray_img, threshold);
        [row, col] = find(~binary_img);  % 找到二值化图像中黑色像素的坐标
        min_Row = min(row);  % 最小行坐标
        max_Row = max(row);  % 最大行坐标
        min_Col = min(col);  % 最小列坐标
        max_Col = max(col);  % 最大列坐标
        if i ~= 9   
            enlarged_img = binary_img(min_Row:max_Row, min_Col:max_Col);  % 裁剪出黑色字母所在的区域
            resized_img = imresize(enlarged_img, [40, 30]);  % 大小统一化
        else                 % 同理需对字母i进行特殊操作
            enlarged_img = binary_img(min_Row:max_Row, 1:size(binary_img,2));  % 裁剪出黑色字母所在的区域
            resized_img = imresize(enlarged_img, [40, 30]);  % 大小统一化
        end
        new_file_name = fullfile(outputFolder, strcat(num2str(len_file1+i),'.jpg'));
        imwrite(resized_img, new_file_name);
    end
    
    % 遍历汉字文件夹中的图片，执行相同的操作
    fileList = dir(fullfile(folder_chi, '*.bmp'));
    for i = 1:length(fileList)
        filename = fullfile(folder_chi, fileList(i).name);
        img = imread(filename);
        gray_img = rgb2gray(img);
        % 设定阈值
        threshold = 0.5;  
        % 对灰度图像进行二值化
        binary_img = imbinarize(gray_img, threshold);
        [row, col] = find(~binary_img);  % 找到二值化图像中黑色像素的坐标
        min_Row = min(row);  % 最小行坐标
        max_Row = max(row);  % 最大行坐标
        min_Col = min(col);  % 最小列坐标
        max_Col = max(col);  % 最大列坐标
        if i == 13           % 此操作为提高正确率
            enlarged_img = binary_img(min_Row:max_Row, min_Col:max_Col);  % 裁剪出黑色字母所在的区域
            resized_img = imresize(enlarged_img, [40, 30]);  % 大小统一化
        else   
            resized_img = imresize(binary_img, [40, 30]);    % 大小统一化
        end
        new_file_name = fullfile(outputFolder, strcat(num2str(len_file1+len_file2+i),'.jpg'));
        imwrite(resized_img, new_file_name);
    end
    
    %% 车牌识别（自由发挥）
    
    % 获取测试文件夹内所有图片用于识别
    fileList = dir(fullfile('test', '*.jpg'));
    length_2=length(fileList);
    num = 0;

    % 建立自动识别字符代码表，包括数字、英文字母和省份简称
    liccode=char(['0':'9' 'A':'Z' '赣湘浙粤沪闽苏皖桂辽黑吉鲁晋冀豫鄂琼川贵云津京藏港澳渝青甘']); 
    
    figure;
    for i = length_2:-1:1
        % 读取测试图片
        img_test = imread(strcat('test/',num2str(i),'.jpg'));
        % 二值化处理，便于匹配模板
        img_test = imbinarize(img_test, threshold);
        
        if i>=length_2-4  % 根据位置匹配数字和英文
            % 初始化误差为最大值
            error=100000;
            for j=1:36  
                % 读取数字和英文字母的模板
                img_muban=imread(strcat('muban/',num2str(j),'.','jpg'));
                img_muban = imbinarize(img_muban, threshold);
                % 计算测试图片和模板之间的误差
                temp=abs(img_test-img_muban);
                error_=sum(temp(:));
                % 选取最小的误差
                if error_<error
                    error=error_;
                    error_idx=j;
                end
            end
            % 找到最小的误差并记录下是哪个数字或字母，判断是否成功识别
            subplot(1,7,7-num);
            imshow(img_test);
            title(liccode(error_idx),'FontSize', 30, 'FontWeight', 'bold', 'Color', 'blue');
        
        elseif i==length_2-5  % 匹配英文字母
            % 初始化误差为最大值
            error=100000;
            for j=11:36  % 英文字母的编号从11开始
                % 读取英文字母的模板
                img_muban=imread(strcat('muban/',num2str(j),'.','jpg'));
                img_muban = imbinarize(img_muban, threshold);
                % 计算测试图片和模板之间的误差
                temp=abs(img_test-img_muban);
                error_=sum(temp(:));
                % 选取最小的误差
                if error_<error
                    error=error_;
                    error_idx=j;
                end
            end
            % 找到最小的误差并记录下是哪个字母，判断是否成功识别
            subplot(1,7,7-num);
            imshow(img_test);
            title(liccode(error_idx),'FontSize', 30, 'FontWeight', 'bold', 'Color', 'blue');
        
        else  % 匹配汉字
            % 初始化误差为最大值
            error=100000;
            for j=37:65  % 省份简称的编号从37开始
                % 读取省份简称的模板
                img_muban=imread(strcat('muban/',num2str(j),'.','jpg'));
                img_muban = imbinarize(img_muban, threshold);
                % 计算测试图片和模板之间的误差
                temp=abs(img_test-img_muban);
                error_=sum(temp(:));
                % 选取最小的误差
                if error_<error
                    error=error_;
                    error_idx=j;
                end
            end
            % 找到最小的误差并记录下是哪个省份简称，判断是否成功识别
            subplot(1,7,7-num);
            imshow(img_test);
            title(liccode(error_idx),'FontSize', 30, 'FontWeight', 'bold', 'Color', 'blue');
        end
        num = num+1;
        if num==7  % 车牌上只有七个字符，识别完成
            break;
        end
    end

end