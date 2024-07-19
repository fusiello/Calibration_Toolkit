function [m_grid,detected] = findGridPoints(I,M_grid,template,m4,indices4,scale)
% Find grid points in image I that match template T
% Transform I with H and look near positions determined by M_grid
% 
% Input:
%       - I: image
%       - M_grid: grid points in 2D object-space (mm)
%       - template: {Butterfly, Corner}
%       - m4: four points in the image
%       - indices4: indices of the same 4 points in M_grid
%       - scale: dimension in mm of 1 pixel of the rectified image
%         The larger the scale, the smaller the rectified image, the faster
%         the detection, the lower the accuray (.5 is a good default)
% Output:
%       - m_grid: grid points detected in image space (pixels)

addpath('./aux_fun');

% scale M_grid (mm) to pixels
M_grid = M_grid(1:2,:)./scale;
% step size in pixels
size_pix = round(M_grid(1,2) - M_grid(1,1));

% initialization points  (match the ones clicked by the user)
M4 = M_grid(:,indices4);

switch template
    case 'Butterfly'
        T = 255*ones(size_pix);
        T(1:ceil(size_pix/2), 1+ceil(size_pix/2):end ) = 0;
        T(1+ceil(size_pix/2):end, 1:ceil(size_pix/2) ) = 0;
    case 'Corner'
        % T = 255*ones(size_pix);
        % T(1:ceil(size_pix/2) , 1:ceil(size_pix/2) ) = 0;
        load('corner_template.mat')

    otherwise
        error('unrecognised template\n');
end

% Homography from actual image to rectified image
H = hom_lin(M4,m4);

% set the bounding box of the rectified image
bb = [1; 1; max(M_grid(1,:))+size_pix; max(M_grid(2,:))+size_pix];
M_grid = M_grid - bb(1:2) + 1; % shift the origin

% rectify the image
If = imwarp(I,@(x)htx(inv(H),x),bb);

% template matching score
S = real(tempMatching(If,T,'rot'));
% compute extrema of the score
[val, idx] = extrema2(S);
idx = idx(val>.7);
[i,j] = ind2sub(size(S), idx');
detected = [j;i];

% solve assignment problem (hungarian method)
cost = distmat(M_grid', detected');
[assignment,~] = munkres(cost);
detected = detected(:,assignment);

% Alternative: find score max in a neighborhood of grid points
%     ws = ceil(radius/3);
%     detected = [];
%     for M = ceil(M_grid)
%         W = S(M(2)-ws:M(2)+ws, M(1)-ws:M(1)+ws);
%       %  figure(10), imshow(W,[])
%         [~,ind] = max(W(:)) ;
%         [r,c] = ind2sub(size(W), ind);
%         detected = [detected, [M(1)-ws+c; M(2)-ws+r]];
%     end
%

% tiles = cutImageIntoTiles(If, detected', [20, 20]);
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
