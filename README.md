# Calibration Toolkit

### Andrea Fusiello, 2019

![banner](http://www.diegm.uniud.it/fusiello/demo/toolkit/bannerCal.jpg)

This toolkit is a collection of Matlab functions and scripts
implementing two calibration techniques.

It requires functions contained in the [Computer Vision Toolkit]
(http://www.diegm.uniud.it/fusiello/demo/toolkit/ComputerVisionToolkit.zip)
by the same author.

After installing the abovementioned dependencies, cd to the
toolkit main directory and type either `runCalibRig`,
`runCalibChecker`:

- `runCalibRig` implements camera calibration by resection [1],
   using a single picture of a non-planar reference object;

- `runCalibChecker` implements the Sturm-Maybank-Zhang [2,3]
  calibration algorithm, that uses multiple (~12) pictures of a
  planar object (a checkerboard). This is the same algorithm
  implemented in OpenCV and in the [Camera Calibration Toolbox
  for Matlab] (http://www.vision.caltech.edu/bouguetj/calib_doc/)
  by Jean-Yves Bouguet.
   
In both cases, grid points are detected with template matching on
a rectified image; four points for each plane must be specified
by the user in a predefined order by clicking on the image.
A final bundle adjustment is run in both cases.

As of 10/2020, the **NEW** script `runCalibApril` has been added:

- `runCalibApril`  implements the Sturm-Maybank-Zhang [2,3]
  calibration algorithm, using
  [AprilTags] (https://april.eecs.umich.edu/software/apriltag)
  instead of a checkerboard, with the advantage of being completely
  automatic. Detection is accomplished thanks to
  [this](https://pypi.org/project/apriltag/) Python module. 


The `img_*` folders contain images of the calibration
rig/checkerboard/tags and a PDF file where the order and the
position of the points to be clicked is specifieed. For the provided
images, the clicked points have been saved in a .mat file in order
to streamline the testing.

Several parameters can be changed by editing the two main
scripts. Code documentation should be clear enough to allow for
customization.
 
The checkerboardcan be downloaded from:
<http://www.vision.caltech.edu/bouguetj/calib_doc/htmls/pattern.pdf>.
A pattern of AprilTags ready to be printed is included in the
distribution. Both are to be printed at 100% scale in order to match the
dimensions in mm reported in the scripts. 


References:

1. Richard Hartley and Andrew Zisserman. 2003. Multiple View
Geometry in Computer Vision (2nd. ed.). Cambridge University
Press, USA.

2. Zhengyou Zhang. 2000. A Flexible New Technique for Camera
Calibration. IEEE Trans. Pattern Anal. Mach. Intell. 22,
11 (November 2000), 1330–1334.
 
3. Sturm, Peter F. and Stephen J. Maybank. On plane-based camera
calibration: A general algorithm, singularities,
applications. Proceedings. IEEE Comp. Soc. Conf. on Computer
Vision and Pattern Recognition (1999): 432-437


---
Andrea Fusiello                
Dipartimento Politecnico di Ingegneria e Architettura (DPIA)  
Università degli Studi di Udine, Via Delle Scienze, 208 - 33100 Udine  
email: <andrea.fusiello@uniud.it>

---


