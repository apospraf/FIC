clear finalImg


y = wgn(size(rImg,1)/dS,size(rImg,1)/dS,2); %white noise as the initial image
iter = 5; %number of IFS application

%finalImg as new input in each iteration, downsampled
for ite=1:iter
    dBlocks = zeros(N, N, size(y,1)^2/N^2); 
    newrBlocks = zeros(N, N, size(rImg,1)^2/N^2);

    b = 1;
    for i=1:N:size(y,1)
        for j=1:N:size(y,1)
            dBlocks(:,:,b) = y(i:i+N-1,j:j+N-1);
            b = b + 1;
        end
    end

    newrBlock = zeros(N,N,size(rImg,1)^2/N^2);
    
    for j=1:length(bestTrans)
        switch bestTrans(j)
            case 1
                newrBlock(:,:,j) = dBlocks(:,:,bestTransBlock(j));
            case 2
                newrBlock(:,:,j) = rNinety(dBlocks(:,:,bestTransBlock(j)));
            case 3
                newrBlock(:,:,j) = lNinety(dBlocks(:,:,bestTransBlock(j)));
            case 4
                newrBlock(:,:,j) = oneEighty(dBlocks(:,:,bestTransBlock(j)));
            case 5
                newrBlock(:,:,j) = flipRNinety(dBlocks(:,:,bestTransBlock(j)));
            case 6
                newrBlock(:,:,j) = flipLNinety(dBlocks(:,:,bestTransBlock(j)));
            case 7
                newrBlock(:,:,j) = flipOneEighty(dBlocks(:,:,bestTransBlock(j)));
            case 8
                newrBlock(:,:,j) = flipSimple(dBlocks(:,:,bestTransBlock(j)));
        end
    end

    % recreation of the final image threw each newrBlock
    row = 1;
    finalImg = zeros(size(rImg));
    col = 1;
    for k=1:size(rImg,1)^2/N^2-1
        if mod(k,size(rImg,1)/N) == 0 
            row = row + N;
            col = 1;
        end
        finalImg(row:row+N-1,col:col+N-1) = newrBlock(:,:,k);
        col = col + N;
    end
    y = imgaussfilt(finalImg(1:dS:end,1:dS:end));
    figure, imshow(finalImg);
end

