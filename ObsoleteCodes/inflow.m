% make nice plot about inflow conditions for the single tree experiment

clear all

A = imread('DSM_1km_6175_693.tif');
B = imread('DSM_1km_6175_694.tif');
C = imread('DSM_1km_6176_693.tif');
D = imread('DSM_1km_6176_694.tif');

E = double([C,D;A,B;]);
E(1,1) = 0;E(2,1) = 0;E(3,1) = 0;

%I = E == -9999;
%E(I) = 0;
Ethin = E(1:5:end,1:5:end);
Ethin = flipud(Ethin);
Ethin = Ethin -0.2;
Ethin = [Ethin;Ethin(end,:)];
Ethin = [Ethin Ethin(:,end)];
%%
%[X,Y] = meshgrid((693:0.0004:(695-0.0004)),(6175:0.0004:(6177-0.0004)));  
[X,Y] = meshgrid((693:0.002:(695)),(6175:0.002:(6177))); 

figure;clf
a = pcolor(X,Y,Ethin);set(a,'EdgeAlpha',0);
set(gca,'FontSize',16);
xlabel('UTM x, zone 32 [km]');
ylabel('UTM y, zone 32 [km]');
axis square
colorbar
demcmap([-0.2 40])
trees = [693.422000000000 6175.54400000000;693.484000000000 6175.55600000000;693.458000000000 6175.47400000000;693.412000000000 6175.40200000000;693.570000000000 6175.37400000000];
hold on
% plot(trees(1,1),trees(1,2),'sr','MarkerSize',60,'LineWidth',1.5)
% plot(trees(2,1),trees(2,2),'sr','MarkerSize',40,'LineWidth',1.5)
% plot(trees(3,1),trees(3,2),'sr','MarkerSize',40,'LineWidth',1.5)
% plot(trees(4,1),trees(4,2),'sr','MarkerSize',50,'LineWidth',1.5)
% plot(trees(5,1),trees(5,2),'sr','MarkerSize',100,'LineWidth',1.5)



% xlim([693.3480 693.6860])
% ylim([6175.298 6175.614])

box on
set(gca, 'Layer', 'top');
set(gcf,'color','w');
grid off
%%export_fig 'inflow_2m.pdf' -transparent



