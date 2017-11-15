clear;
clc;

rImg = im2double(im2bw(imread('p.png')));
dS = 4;
dImg = imgaussfilt(rImg(1:dS:end,1:dS:end));

N = 4;

rBlocks = zeros(N, N, size(rImg,1)^2/N^2);
dBlocks = zeros(N, N, size(dImg,1)^2/N^2);

b = 1;
for i=1:N:size(rImg,1)
    for j=1:N:size(rImg,1)
        rBlocks(:,:,b) = rImg(i:i+N-1,j:j+N-1);
        b = b + 1;
    end
end

b = 1;
for i=1:N:size(rImg,1)/dS
    for j=1:N:size(rImg,1)/dS
        dBlocks(:,:,b) = dImg(i:i+N-1,j:j+N-1);
        b = b + 1;
    end
end

transforms = ['none', 'rNinety', 'lNinety', 'oneEighty', 'flipRNinety', 'flipLNinety', 'flipOneEighty', 'flipSimple'];

msEr = zeros(1,8);
z = zeros(1,size(rImg,1)^2/N^2);
er = zeros(1,size(dImg,1)^2/N^2);
bestTrans = zeros(1,size(rImg,1)^2/N^2);
bestTransBlock = zeros(1,size(rImg,1)^2/N^2);
for i=1:size(rImg,1)^2/N^2
    block = rBlocks(:,:,i);
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
    [~, bestErrorInd] = min(er); 
    bestTrans(i) = z(bestErrorInd);
    bestTransBlock(i) = bestErrorInd;
    i
end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        