clear
close all

filename ='./img_rig/20191105_081845.jpg';

[K, internal, I_out] = CalibRig(filename,'file');
disp(' '); disp(internal);
figure, imshow(I_out, []); title('Undistorted');

