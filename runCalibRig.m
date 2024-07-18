clear
close all

filename ='img_rig/20191105_081845.jpg';

[K, internal, I_out] = CalibRig(filename);
disp(' '); disp(internal);
figure, imshow(I_out, []); title('Undistorted');
