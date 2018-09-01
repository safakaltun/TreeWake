% function for plotting 'plot3' in colours 
function [] = plot3colour_greyscale(x,y,z, minZ, maxZ, MarkerSize)
% Create matrix with colors corresponding to NoOfBins

z(z < minZ) = nan;

cmap = colormap;
cmap = cmap(4:end,:);

Zvec = linspace(minZ,maxZ,size(cmap,1) +1);
NoOfBins = size(cmap,1);
for i = 1:NoOfBins
   Cmatrix = [0.6-(i-1)/NoOfBins*0.6  0.2+(i/NoOfBins)*0.8 0];
   I = z >= Zvec(i) & z < Zvec(i+1);
   h = plot3(x(I),y(I),z(I),'.','MarkerSize',MarkerSize);hold on
   set(h,'Color',cmap(i,:))
end

colorbar
colormap(cmap)
caxis([minZ maxZ])




