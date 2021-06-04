clc;
clear;
rH = 0.9;
rL = 0.5;
c = 1;
D_0 = 1;
alpha = 3;
beta = -10;
% 以上内容为各种参数，根据实际情况修改
img = imread("input/lane.jpg");
% 读取一张图片
img = im2double(img);
% 将图片转换为double形式（不转换后面会出错）
[height, width, channels] = size(img);
% 获取图像信息
middle_y = floor(height / 2);
middle_x = floor(width / 2);
% 计算中心像素坐标
final = img;
% 把图像复制到final
for t = 1:channels % 三通道，因此每个通道分别来一次
    img_C = log(img(:, :, t) + 1e-6);
    % 不进行计算会出错
    FT_img_C = fftshift(fft2(img_C));
    % 傅里叶变换
   for i=1:height
       for j=1:width
           D(i,j)=((i - middle_y) .^2 + (j - middle_x) .^ 2);
           H(i,j)=(rH - rL) .* (1 - exp(c * (-D(i,j) ./ (D_0 ^ 2)))) + rL;
           %高斯同态滤波
       end    
   end
    filtered_img_C = FT_img_C .* H;
    out = ifft2(ifftshift(filtered_img_C));
    out = real(exp(out));
    imshow(out, []);
     % 展示out
    out_name = "lane_channel" + string(t) + ".png";
    imwrite(out, out_name);
    % 输出每个通道形成的灰度图
    final(:, :, t) = out;
    % 挨个通道复制进final
end
minV = min(min(min(final)));
maxV = max(max(max(final)));
for t = 1:channels
    for i = 1:height
        for j = 1:width
            final(i, j ,t) = 255 * (final(i, j, t) - minV) ./ (maxV - minV);
        end
    end
end
% 归一化
final = uint8(alpha .* final + beta);
% 微调亮度与对比度
imshow(final);
res_name = "lane" + "_res.png";
imwrite(final, res_name);
    