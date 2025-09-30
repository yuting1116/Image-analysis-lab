function [medianImg] = medianFunc(img,kernelSize)
[h,w] = size(img);
medianImg = zeros(h,w);
medianIdx = ceil(kernelSize*kernelSize / 2);
stride = floor(kernelSize / 2);
for i = 1 + stride:h - stride
    for j = 1 + stride:w - stride
        patch = img(i-stride:i+stride, j-stride:j+stride);
        sorted = sort(patch(:));
        medianImg(i,j) = sorted(medianIdx);
    end
end

end