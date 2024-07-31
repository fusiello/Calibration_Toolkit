clear
close all

datadir = 'img_april'; % folder containing the images

grid.stepmm = 16; % side of the square in millimeters
grid.rows = 10 ;  % # rows by # columns
grid.cols = 16 ; %  # rows by # columns

[K, internal, I_out] = CalibApril(datadir,grid);
disp(' '); disp(internal);
figure, imshow(I_out, []); title('Undistorted');


