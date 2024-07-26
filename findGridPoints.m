function [m_grid,detected] = findGridPoints(I,M_grid,template,m4,indices4,gsd)
% Find grid points in image I that match template T
% Transform I with H and look near positions determined by M_grid
%
% Input:
%       - I: image
%       - M_grid: grid points in 2D object-space (mm)
%       - template: {Butterfly, Corner}
%       - m4: four points in the image
%       - indices4: indices of the same 4 points in M_grid
%       - gsd: dimension in mm of 1 pixel of the rectified image
%         The larger the scale, the smaller the rectified image, the faster
%         the detection, the lower the accuray (.5 is a good default)
% Output:
%       - m_grid: grid points detected in image space (pixels)

addpath('./aux_fun');

% scale M_grid (mm) to pixels
M_grid = M_grid(1:2,:)./gsd;
% initialization points  (match the ones clicked by the user)
M4 = M_grid(:,indices4);
% template size in pixels
T_size = round((M_grid(1,2) - M_grid(1,1)));

switch template
    case 'Butterfly'
        T = 255*ones(T_size);
        T(1:ceil(T_size/2), 1+ceil(T_size/2):end ) = 0;
        T(1+ceil(T_size/2):end, 1:ceil(T_size/2) ) = 0;
        %load('butterfly_template.mat')
        rots = [1];
    case 'Corner'
        T = 255*ones(T_size);
        T(1:ceil(T_size/2) , 1:ceil(T_size/2) ) = 0;
        %load('corner_template.mat')
        rots = [1,2,3];
    otherwise
        error('unrecognised template\n');
end

% Homography from actual image to rectified image
H = hom_lin(M4,m4);

% set the bounding box of the rectified image
bb = [1; 1; max(M_grid(1,:))+T_size; max(M_grid(2,:))+T_size];
M_grid = M_grid - bb(1:2) + 1; % shift the origin

% rectify the image
If = imwarp(I,@(x)htx(inv(H),x),bb);

% template matching score
S = real(tempMatching(If,T,rots));
% compute extrema of the score
[val, idx] = extrema2(S);
idx = idx(val>.7);
[i,j] = ind2sub(size(S), idx');
detected = [j;i];

% solve assignment problem (hungarian method)
cost = distmat(M_grid', detected');
[assignment,~] = munkres(cost);
detected = detected(:,assignment);

% tiles = cutImageIntoTiles(If, detected', [30, 30]);
% save tiles tiles

% subpixel refinement
for i = 1:length(detected)
    x = detected(2,i) + [-1, 0, 1];
    y = detected(1,i);
    [dx, ~] = subPix(x, S(x,y) );

    x = detected(2,i);
    y = detected(1,i) + [-1, 0, 1];
    [dy, ~] = subPix(y, S(x,y) );
    detected(:,i) = detected(:,i) + [dy;dx];
end

% fitting a full 2D paraboloid is worse
% for i = 1:length(detected)
%     x = detected(2,i) + [-1, 0, 1];
%     y = detected(1,i) + [-1, 0, 1];
%     [X,Y] =  meshgrid(x ,y);
%     Z = S(x,y);
%     detected(:,i) = fitParaboloid([Y(:), X(:), Z(:)]);
% end


% show score in green overlaied onto the image
figure, imshow(If,[], 'InitialMagnification', 'fit'), hold on;
green = cat(3, zeros(size(S)),ones(size(S)), zeros(size(S)));
hold on, h = imshow(green);  hold off
set(h, 'AlphaData',S.^2), hold on
plot(detected(1,:),detected(2,:),'+m','MarkerSize',15);
plot(M_grid(1,:), M_grid(2,:),   'or','MarkerSize',15);
title('Score')

% bring back detected points to the original image
m_grid = htx(inv(H),detected + bb(1:2) -1 );
end


%%
function tiles = cutImageIntoTiles(image, tilePositions, tileRad)
% image: input image
% tilePositions: Nx2 matrix containing the row and column positions for each tile
% tileSize: Size of each tile [height, width]

% Check if the input image is grayscale or RGB
if size(image, 3) == 3
    isRGB = true;
else
    isRGB = false;
end

% Initialize cell array to store tiles
tiles = cell(size(tilePositions, 1), 1);

% Cut tiles from the image and store in the cell array
for i = 1:size(tilePositions, 1)
    row = tilePositions(i, 2);
    col = tilePositions(i, 1);

    % Calculate the indices for the current tile
    rowIndices = row-tileRad(1) : row + tileRad(1);
    colIndices = col-tileRad(2) : col + tileRad(2);

    % Extract the current tile from the image
    if isRGB
        tiles{i} = image(rowIndices, colIndices, :);
    else
        tiles{i} = image(rowIndices, colIndices);
    end
end


end



function apex = fitParaboloid(data)
% FITPARABOLOID Fits a 2D paraboloid to given data and returns the apex coordinates.
%   APEX = FITPARABOLOID(DATA) fits a 2D paraboloid to the data points in DATA.
%   DATA is an n x 3 matrix, where each row contains an (x, y, z) point.
%   APEX is a 3x1 vector containing the x, y, and z coordinates of the apex.

% Extract data
x = data(:,1);
y = data(:,2);
z = data(:,3);

% Create the design matrix
X = [x.^2, y.^2, x.*y, x, y, ones(size(x))];

% Solve for coefficients using least squares
coef = X\z;

% Extract coefficients
a = coef(1);
b = coef(2);
c = coef(3);
d = coef(4);
e = coef(5);
f = coef(6);

% Find the apex
x_apex = -(2*b*d - c*e)/(4*a*b - c^2);
y_apex = -(2*a*e - c*d)/(4*a*b - c^2);


z_apex = a*x_apex^2 + b*y_apex^2 + c*x_apex*y_apex + d*x_apex + e*y_apex + f;

apex = [x_apex; y_apex];
end




