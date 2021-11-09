#!/usr/local/bin/python3

import sys
import apriltag
import cv2

img = cv2.imread(sys.argv[1],cv2.IMREAD_GRAYSCALE)

result = apriltag.Detector().detect(img)

corn = [item for s in [f.corners for f in result] for item in s]

# on stdout
for i in range(len(corn)):
     print(corn[i][0], end="  ")
     print(corn[i][1])
     
     
# on a a file     
#outname = 'corner_' + sys.argv[1].rsplit( ".", 1 )[ 0 ][-6:] + '.txt' 
#print('writing to ' + outname)

# f = open(outname ,'w')
# for i in range(len(corn)):
#     print(corn[i][0], end="  ", file=f)
#     print(corn[i][1], file=f)
# f.close()

