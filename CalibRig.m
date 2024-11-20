function [K, internal, I_out] = CalibRig(filename,input,NumIntPar,NumRadDist)
% calibration  with the rig
% filename is the image of the rig
% input = 'auto'| 'file' | 'user'  is where the input comes from
% NumIntPar  =  # of internal parameters (typ. 4 or 5)
% NumRadDist =  # of radial distortion coefficients (typ. 1 or 2).

if nargin < 3
    NumIntPar  = 4; % # of internal parameters (typ. 4 or 5)
    NumRadDist = 1; % # of radial distortion coefficients (typ. 1 or 2).
end
if nargin < 2
    input = 'user'; 
end

rect_gsd = .2; %  dimension in mm of 1 pixel of the rectified image
% it should match the actual GSD of the original images, but can be a
% little bit larger (up to x10) thanks to subpixel detection

[file.folder,file.name,ext] = fileparts(filename);

% Generate world point coordinates for the pattern
stepSize = 20; % side of the square in millimeters
gridArrangement = [8,8];  % # rows by # columns
M_grid  = generateGridPoints(gridArrangement, stepSize, 'Rig');

% read  the (single) image
fprintf('Processing img %s ... \n', file.name);
I = imread([file.folder,'/',file.name,ext]);
if size(I,3) > 1
    I = rgb2gray(I);
end
figure(1), imshow(I,[],'InitialMagnification','fit');

switch input
    case 'auto'
        [m4{1}, m4{2}] = autoSelectPoints(I); % still experimental
    case 'file'
        % this is only for testing, normally the user should provide input
        load([file.folder,'/m4']);
    case 'user'
        for i = 1:2
            % get points from the user anticlockwise fron the top-left
            disp('click on 4 points in a given order (see instructions)')
            figure(1),  m4{i} = ginput(4)';
        end
        save([file.folder,'/m4'],"m4");
end

% initialization points  (match the ones clicked by the user)
corner_indices = [64,8,1,57];

M_grid_face = M_grid(1:2,1:size(M_grid,2)/2);

% do it twice with better estimate of corners
for t = [10, 1]
    % detect points on each face
    m_grid=[];
    for i = 1:2
        m_grid_face =  findGridPoints(I,M_grid_face,'Corner',m4{i},corner_indices, rect_gsd*t);
        m_grid=[m_grid,m_grid_face];
        % better estimate of corners
        m4{i} = m_grid_face(:, corner_indices);
    end
end

% plot detected points
figure(1), hold on;
plot(m_grid(1,:), m_grid(2,:), 'oc','MarkerSize',15);

P = resect_lin(m_grid, M_grid);
fprintf('Resection ___lin reproj RMS error:\t %0.5g \n', ...
    rmse(reproj_res_batch({P},M_grid,{m_grid})));

P = resect_nonlin(P, m_grid, M_grid);
fprintf('Resection nonlin reproj RMS error:\t %0.5g \n',...
    rmse(reproj_res_batch({P},M_grid,{m_grid})));

% Use BA as a non linear resection with radial distortion
[P,M,kappa] = bundleadj({P},M_grid,{m_grid},'Verbose','AdjustCommonIntrinsic',...
    'IntrinsicParameters',NumIntPar, 'FixedPoints',size(M_grid,2),...
    'DistortionCoefficients', num2cell(zeros(NumRadDist,1),1),'GaussNewton');

fprintf('BA reproj RMS error:\t %0.5g \n', ...
    rmse(reproj_res_batch(P,M,{m_grid},'DistortionCoefficients', kappa)));

% Here P is the camera matrix and kappa contains the radial distortion
% coefficient.

m_est = htx(P{1},M_grid);  % project with estimated camera
figure(1), plot(m_est(1,:),m_est(2,:),'+m','MarkerSize',15)
legend('Detected','Reprojected')

% 3D plot
figure, plot3(M_grid(1,:),M_grid(2,:),M_grid(3,:),'+k'), hold on
xlabel('X'), ylabel('Y'), zlabel('Z')
plotcam(P{1}, 50)
[K,R,t]=krt( P{1} );
[t1,t2] = gsd(K,norm(t),R);
fprintf('GSD avg: \t %0.3g \n',(t1+t2)/2);

% Put the internal parameters in a table for pretty printing
K = krt(P{1});
internal = table;
internal.focal_u    = K(1,1);
internal.focal_v    = K(2,2);
internal.u_0        = K(1,3);
internal.v_0        = K(2,3);
internal.skew       = K(1,2);
internal.radial     = kappa{1}';

% correct the input image
% (use this as a template to correct other images)
bb  = [1;1;size(I,2);size(I,1)];
I_out = imwarp(double(I), @(x)rdx(kappa{1},x,K), bb);
% figure, imshow(I_out, []); title('Undistorted');
