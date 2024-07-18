clear
close all

NumIntPar  = 4; % # internal parameters (typ. 4 or 5)
NumRadDist = 1; % # radial distortion coefficients (typ. 1 or 2).

datadir = 'img_april'; % folder containing the images

[K, internal, I_out] = CalibApril(datadir);
disp(' '); disp(internal);
figure, imshow(I_out, []); title('Undistorted');


