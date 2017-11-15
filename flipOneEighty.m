function [ transBlock ] = flipOneEighty( block )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

N = size(block,1);
transBlock = zeros(size(block));
for i=1:N
    for j=1:N
        transBlock(i,j) = block(j,N+1-i);
    end
end
transBlock = transBlock';

end

