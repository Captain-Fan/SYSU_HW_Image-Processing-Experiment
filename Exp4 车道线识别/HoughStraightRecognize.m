%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%该函数为霍夫变换识别直线的函数
%input：图像（可以是二值图，也可以是灰度图）
%output：直线的struct结构，其结构组成为线段的两个端点
%以及在极坐标系下的坐标【rho，theta】
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lines = HoughStraightRecognize(BW)
    [H,T,R] = hough(BW);
    % imshow(H,[],'XData',T,'YData',R,...
    %             'InitialMagnification','fit');
    % xlabel('\theta'), ylabel('\rho');
        % axis on, axis normal, hold on;
    P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    %x = T(P(:,2)); y = R(P(:,1));
    %plot(x,y,'s','color','white');
    lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
    %FillGap 两个线段之间的距离，小于该值会将两个线段合并
    %MinLength 最小线段长度
end