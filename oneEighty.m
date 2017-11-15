function [ transBlock ] = oneEighty( block )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

N = size(block,1);
transBlock = zeros(size(block));
for i=1:N
    for j=1:N
        transBlock(i,j) = block(N+1-i,N+1-j);
    end
end

end