function [K, internal, I_out] = CalibChecker(datadir, grid, input,NumIntPar,NumRadDist)
% calibration  with the rig
% datadir  where the images are
% input = 'auto'| 'file' | 'user'  is where the input comes from
% NumIntPar  =  # of internal parameters (typ. 4 or 5)
% NumRadDist =  # of radial distortion coefficients (typ. 1 or 2).

if nargin < 5
    NumIntPar  = 4; % # of internal parameters (typ. 4 or 5)
    NumRadDist = 1; % # of radial distortion coefficients (typ. 1 or 2).
end
if nargin < 3
    input = 'file';
end

rect_gsd = .25; %  dimension in mm of 1 pixel of the rectified image
% it should match the actual GSD of the original images, but it can be a
% little bit larger (up to x10) thanks to subpixel detection

files = findImages(datadir);
num_imgs = numel(files);

% Generate world point coordinates for the pattern
M_grid  = generateGridPoints([grid.rows,grid.cols], grid.stepmm, 'Checker');

switch input
    case 'auto'
        disp('not implemented yet')
    case 'file'
        % this is only for testing, normally the user should provide input
        load([datadir,'/m4']);
    case 'user'
        for i=1:num_imgs
            % get points from the user anticlockwise fron the top-left
            disp('click on 4 points in a given order (see instructions)')
            I = imread([files(i).folder, '/', files(i).name]);
            figure(1), imshow(I,[],'InitialMagnification','fit');
            m4{i} = ginput(4)';
        end
        save([files(i).folder,'/m4'],"m4");
end

% read images
for i=1:num_imgs
    close all

    fprintf('Processing img %d: %s ... \n', i, files(i).name);
    I = imread([files(i).folder, '/', files(i).name]);
    if size(I,3) > 1
        I = rgb2gray(I);
    end
    figure(1), imshow(I,[],'InitialMagnification','fit');

    % detect grid points
    m_grid{i} = findGridPoints(I, M_grid(1:2,:),'Butterfly',m4{i}, grid.corners, rect_gsd);

    figure(1), hold on;
    %plot(m_grid{i}(1,:), m_grid{i}(2,:), 'oc','MarkerSize',15);
    scatter(m_grid{i}(1,:), m_grid{i}(2,:), [],lines(size(m_grid{i},2)),'+');

    H_lin = hom_lin(m_grid{i}, M_grid(1:2,:));
    fprintf('\tHomography ___lin RMS error:\t %0.5g \n', ...
        rmse(sampson_hom(H_lin, M_grid(1:2,:), m_grid{i})));

    H{i} = hom_nonlin(H_lin, m_grid{i}, M_grid(1:2,:));
    fprintf('\tHomography nonlin RMS error:\t %0.5g \n', ...
        rmse(sampson_hom(H{i}, M_grid(1:2,:), m_grid{i})));

    m_est = htx(H{i}, M_grid(1:2,:));
    figure(1), scatter(m_est(1,:), m_est(2,:), [],lines(size(m_est,2)),'o');
    % plot(m_est(1,:),m_est(2,:),'+m','MarkerSize',15)
    legend('Detected','Reprojected')

    m4{i} = m_grid{i}(:, grid.corners);
end

%% All the homographies computed, ready to run calibSMZ
[P_est,K_est] = calibSMZ(H);

fprintf('CalibSMZ reproj RMS error:\t %0.5g \n',...
    rmse(reproj_res_batch(P_est,M_grid, m_grid)) );

% refine with BA (with fixed points)
[P,M,kappa] = bundleadj(P_est,M_grid,m_grid,'AdjustCommonIntrinsic',...
    'IntrinsicParameters',NumIntPar, 'FixedPoints',size(M_grid,2),...
    'DistortionCoefficients', num2cell(zeros(NumRadDist,num_imgs),1) );

fprintf('BA reproj RMS error:\t %0.5g \n', ...
    rmse(reproj_res_batch(P,M,m_grid,'DistortionCoefficients', kappa)) );

% Here P is a cell array of 3x4 camera matrices and
% kappa contains the radial distortion coefficients.

% 3D plot
figure, plot3(M(1,:),M(2,:),M(3,:),'+k'), hold on
xlabel('X'), ylabel('Y'), zlabel('Z')
for i = 1: length(P)
    plotcam(P{i}, 50)
    [K,R,t]=krt( P{i} );
    [t1, t2] = gsd(K,norm(t),R);
    gsds(i) = (t1+t2)/2;
end
fprintf('GSD min max: \t %0.3g %0.3g\n',min(gsds), max(gsds));


% Put the internal parameters in a table for pretty printing
K = krt(P{1});
internal = table;
internal.focal_u    = K(1,1);
internal.focal_v    = K(2,2);
internal.u_0        = K(1,3);
internal.v_0        = K(2,3);
internal.skew       = K(1,2);
internal.radial     = kappa{1}';

% correct the last input image
% (use this as a template to correct other images)
bb  = [1;1;size(I,2);size(I,1)];
I_out = imwarp(double(I), @(x)rdx(kappa{1},x,K), bb);
%figure, imshow(I_out, []); title('Undistorted');

