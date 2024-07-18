clear
close all

datadir = 'img_checker'; % folder containing the images

[K, internal, I_out] = CalibChecker(datadir);
disp(' '); disp(internal);
figure, imshow(I_out, []); title('Undistorted');

