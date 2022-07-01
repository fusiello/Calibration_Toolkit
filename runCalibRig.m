clear
close all

NumIntPar  = 4; % # of internal parameters (typ. 4 or 5)
NumRadDist = 1; % # of radial distortion coefficients (typ. 1 or 2).

file.folder = 'img_rig';  % folder containing the images
file.name = '20191105_081845.jpg';

% Generate world point coordinates for the pattern
stepSize = 20; % side of the square in millimeters
gridArrangement = [8,8];  % # rows by # columns
M_grid  = generateGridPoints(gridArrangement, stepSize, 'Rig');

% read  the (single) image
fprintf('Processing img %s ... \n', file.name);
I = imread([file.folder,'/',file.name]);
if size(I,3) > 1
    I = rgb2gray(I);
end
figure(1), imshow(I,[],'InitialMagnification','fit');

% detect points on face 1
face1 = M_grid(1:2,1:size(M_grid,2)/2);
m_grid_face1 = findGridPoints(I,face1,'Rig',1,file);

% detect points on face 2
face2 = M_grid(2:3,size(M_grid,2)/2+1:end);
m_grid_face2 = findGridPoints(I, face2,'Rig',2,file);

% plot detected points
m_grid=[m_grid_face1,m_grid_face2];
figure(1), hold on;
plot(m_grid(1,:), m_grid(2,:), 'oc','MarkerSize',15);

P = resect_lin(m_grid, M_grid);
fprintf('Resection ___lin reproj RMS error:\t %0.5g \n', ...
    rmse(reproj_res_batch({P},M_grid,{m_grid})));

P = resect_nonlin(P, m_grid, M_grid);
fprintf('Resection nonlin reproj RMS error:\t %0.5g \n',...
    rmse(reproj_res_batch({P},M_grid,{m_grid})));

% Use BA as a non linear resection with radial distortion
[P,M,kappa] = bundleadj({P},M_grid,{m_grid},'AdjustCommonIntrinsic',...
    'IntrinsicParameters',NumIntPar, 'FixedPoints',size(M_grid,2),...
    'DistortionCoefficients', num2cell(zeros(NumRadDist,1),1) );

fprintf('BA reproj RMS error:\t %0.5g \n', ...
    rmse(reproj_res_batch(P,M,{m_grid},'DistortionCoefficients', kappa)));

% Here P is the camera matrix and kappa contains the radial distortion
% coefficient.

m_est = htx(P{1},M_grid);  % project with estimated camera
figure(1), plot(m_est(1,:),m_est(2,:),'+m','MarkerSize',15)
legend('Detected','Reprojected')

% 3D plot
figure, plot3(M_grid(1,:),M_grid(2,:),M_grid(3,:),'+k'), hold on
plotcam(P{1}, 50)
xlabel('X'), ylabel('Y'), zlabel('Z')

% Put the internal parameters in a table for pretty printing
K = krt(P{1});
internal = table;
internal.focal_u    = K(1,1);
internal.focal_v    = K(2,2);
internal.u_0        = K(1,3);
internal.v_0        = K(2,3);
internal.skew       = K(1,2);
internal.radial     = kappa{1}';
disp(' '); disp(internal);

% correct the input image
% (use this as a template to correct other images)
bb  = [1;1;size(I,2);size(I,1)];
I_out = imwarp(double(I), @(x)rdx(kappa{1},x,K), bb);
figure, imshow(I_out, []); title('Undistorted');
