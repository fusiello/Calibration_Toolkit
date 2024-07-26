clear
close all

datadir = 'img_checker'; % folder containing the images

grid.stepmm = 30; % side of the square in millimeters
grid.rows = 8 ;  % # rows by # columns
grid.cols = 6 ; %  # rows by # columns
grid.corners = [1,8,48,41];

[K, internal, I_out] = CalibChecker(datadir, grid);
disp(' '); disp(internal);
figure, imshow(I_out, []); title('Undistorted');
