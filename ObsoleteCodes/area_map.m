lasData = importdata('lasdata_to_safak_693_6175.txt');

coordinates = lasData(:,1:3);

c = coordinates;
% Xlocs = [693348 693686];
% Ylocs = [6175298 6175614];
% zTresholds =20:0.1:35;%[ 0 10 15 20 25];
% for i = 1:length(zTresholds)
%     zTreshold = zTresholds(i);
%     xFilter = (c(:,1)>Xlocs(1) & c(:,1)< Xlocs(2));
%     yFilter = (c(:,2)>Ylocs(1) & c(:,2)< Ylocs(2));
%     zFilter = c(:,3)>zTreshold;
%     c = c(xFilter&yFilter&zFilter,:);
%     c(c(:,3)<zTreshold,3) = 0.1;
%     c = c(xFilter&yFilter,:);
    X = c(:,1);
    Y = c(:,2);
    Z = c(:,3);
    figure
    plot3colour_greyscale(X(1:end),Y(1:end),Z(1:end), 0, 40,4);
    hold off
    view([0 0 1])
%     xlim([693348 693686])
%     ylim([6175298 6175614])

%     
%     p1.ZData = 100;
%     p2.ZData = 100;
%     p3.ZData = 100;
%     p4.ZData = 100;
%     p5.ZData = 100;
    
    title(['Filtered for Z>' num2str(zTreshold) 'm'])
%     print(['Filtered_for_' num2str(zTreshold) '_m'],'-dtiff')
% end