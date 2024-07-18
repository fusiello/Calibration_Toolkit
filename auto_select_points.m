function [pA, pB, props] = auto_select_points(I)

% find 8 corners to initializerig calibration
% replaces user input
% still EXPWERIMENTAL

addpath('/Users/andrea/Dropbox/ComputerVision/Distribution/CalibrationToolkit/aux_fun  ');

BW = ~ imbinarize(I,'adaptive','ForegroundPolarity','dark','Sensitivity',0.3);
BW = imclearborder(BW);

BW = imclose(BW,strel("square",5));
BW = bwareafilt(BW,[0.0005,0.007]*numel(I));
BW = bwpropfilt(BW,'Eccentricity',[.65, .96]);      
BW = bwpropfilt(BW,'Solidity',[.53, 1]);
BW = bwcircfilt(BW,[.14, .85]);  % Circularity
BW = bwcustfilt(BW,32,.009);  % Solidity and Area together

% BW = bwpropfilt(BW,'Solidity',32);

figure,imshow(BW,'InitialMagnification','fit');
hold on

S = regionprops(BW,'Area');
C = vertcat(S.Area);
props(1,1) = min(C)/ numel(I);
props(1,2) = max(C)/ numel(I);

S = regionprops(BW,'Perimeter');
perim = vertcat(S.Perimeter);
C = (4*pi*C)./perim.^2;

%S = regionprops(BW,'Solidity');
% C = vertcat(S.Solidity);
props(2,1) = min(C);
props(2,2) = max(C);

S = regionprops(BW,'Eccentricity');
C = vertcat(S.Eccentricity);
props(3,1) = min(C);
props(3,2) = max(C);

% calcola i centroidi dei blobs
S = regionprops(BW,'centroid');
C = vertcat(S.Centroid); % centers of all dots


%% stima una griglia di riferimento
max1=max(C(:,1));
min1=min(C(:,1));
max2=max(C(:,2));
min2=min(C(:,2));
% plot([max1, min1, max1, min1],[max2, max2, min2, min2],'d')

step1  = linspace(min1,max1,9);
step1(5)=[];

step2  = linspace(min2,max2,4);
[x,y] = meshgrid(step1, step2);
% plot(x(:),y(:), 'ob')

%% risolve assegnamento con la griglia
cost = distmat([x(:), y(:)], C);
[assignment,~] = munkres(cost);
C = C(assignment,:);

% centers of the 8 squares
pA = C([1, 4, 16, 13],:);
pB = C([29, 17, 20, 32],:);

plot(pA(:,1), pA(:,2), 'rd', 'MarkerFaceColor', 'r')
plot(pB(:,1), pB(:,2), 'rd', 'MarkerFaceColor', 'r')

% adjust with diagonals
S = regionprops(BW,'area');
A = vertcat(S.Area); % area of blobs
D = sqrt(2*A)/2; % diagonals
D = D(assignment,:);

pA =[C(1,1)-D(1),C(1,2)-D(2)
    C(4,1)-D(4),C(4,2)+D(4)
    C(16,1)+D(16),C(16,2)+D(16)
    C(13,1)+D(13),C(13,2)-D(13)]';

pB =[C(29,1)+D(29),C(29,2)-D(29)
    C(17,1)-D(17),C(17,2)-D(17)
    C(20,1)-D(20),C(20,2)+D(20)
    C(32,1)+D(32),C(32,2)+D(32)]';

hold off

end