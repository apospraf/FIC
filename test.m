clear;
clc;

rImg = im2double(im2bw(imread('p.png'))); %range image
dS = 4; %down sampling ratio
dImg = imgaussfilt(rImg(1:dS:end,1:dS:end)); %domain image

N = 4; %dimension of blocks
ovrl = N/2; %overlap ratio

rBlocks = zeros(N, N, size(rImg,1)^2/N^2); %range blocks
dBlocks = zeros(N, N, (2*size(dImg,1)/N-1)^2);%domain blocks

% partition of range image, creation of range blocks
b = 1;
for i=1:N:size(rImg,1)
    for j=1:N:size(rImg,1)
        rBlocks(:,:,b) = rImg(i:i+N-1,j:j+N-1);
        b = b + 1;
    end
end

% partition of domain image, creation of domain blocks
b = 1;
for i=1:ovrl:size(rImg,1)/dS-ovrl
    for j=1:ovrl:size(rImg,1)/dS-ovrl
        dBlocks(:,:,b) = dImg(i:i+N-1,j:j+N-1);
        b = b + 1;
    end
end


%type of transformation
transforms = ['none', 'rNinety', 'lNinety', 'oneEighty', 'flipRNinety', 'flipLNinety', 'flipOneEighty', 'flipSimple'];


msEr = zeros(1,8); %mean square error of each transformation
z = zeros(1,size(rImg,1)^2/N^2); %index of best transfomation
er = zeros(1,size(dImg,1)^2/N^2);%minimum error between a range block and every domain block
bestTrans = zeros(1,size(rImg,1)^2/N^2); %best transformation for each range block
bestTransBlock = zeros(1,size(rImg,1)^2/N^2); %address of domain block
for i=1:size(rImg,1)^2/N^2
    block = rBlocks(:,:,i);
    tic
    for j=1:size(dImg,1)^2/N^2
        msEr(1) = mse(block, dBlocks(:,:,j));
        msEr(2) = mse(rNinety(block), dBlocks(:,:,j));
        msEr(3) = mse(lNinety(block), dBlocks(:,:,j));
        msEr(4) = mse(oneEighty(block), dBlocks(:,:,j));
        msEr(5) = mse(flipRNinety(block), dBlocks(:,:,j));
        msEr(6) = mse(flipLNinety(block), dBlocks(:,:,j));
        msEr(7) = mse(flipOneEighty(block), dBlocks(:,:,j));
        msEr(8) = mse(flipSimple(block), dBlocks(:,:,j));
        [er(j), z(j)] = min(msEr);
    end
    toc
    [~, bestErrorInd] = min(er); 
    bestTrans(i) = z(bestErrorInd);
    bestTransBlock(i) = bestErrorInd;
    i
end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        