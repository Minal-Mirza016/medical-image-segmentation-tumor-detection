clc;
clear;
close all;

% Read Image
img = imread('images/Y2.jpg');

figure,imshow(img),title('Original Image');

% Grayscale
if size(img,3)==3
    gray = rgb2gray(img);
else
    gray = img;
end

% Preprocessing
[rows, cols] = size(gray);

filtered = zeros(rows, cols, 'uint8');

for i = 2:rows-1
    for j = 2:cols-1

        window = gray(i-1:i+1 , j-1:j+1);

        filtered(i,j) = median(window(:));

    end
end
figure,imshow(filtered),title('Preprocessed Image');

% Thresholding
binary = filtered > 180;

figure,imshow(binary),title('Thresholding');

% Select Seed Point

figure;
imshow(filtered);
title('Click Inside Tumor');

[x,y] = ginput(1);

seedX = round(x);
seedY = round(y);

% Region Growing

region = false(size(filtered));

region(seedY,seedX)=1;

for k=1:500

    dilated = imdilate(region,ones(3));

    newPixels = dilated & ~region;

    similar = abs(double(filtered)-double(filtered(seedY,seedX))) < 30;

    region = region | (newPixels & similar);

end
figure,imshow(region),title('Region Growing');

% Morphological Operation

region = imfill(region,'holes');

region = bwareaopen(region,100);

figure,imshow(region),title('Morphological Result');

% Boundary

boundary = bwperim(region);

figure,imshow(boundary),title('Boundary Detection');

% Final Result

RGB = cat(3,gray,gray,gray);

[B,~] = bwboundaries(region,'noholes');

figure,imshow(RGB)
title('Detected Tumor');
hold on

for k=1:length(B)

    plot(B{k}(:,2),B{k}(:,1),'r','LineWidth',2);

end

% Tumor Detection Report

stats = regionprops(region,'Area');

if ~isempty(stats)

    tumorArea = stats(1).Area;

fprintf('Selected Seed = (%d,%d)\n',seedX,seedY);
fprintf('Tumor Area = %.0f pixels\n',tumorArea);
fprintf('Tumor Detected\n');

else

    fprintf('Tumor Not Detected\n');

end