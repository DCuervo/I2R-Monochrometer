from time import sleep
import picamera
import picamera.array
import os
import numpy
from fractions import Fraction
import sys

##########
# Arguement format should be
# 'Output Directory' Number_of_Frames Exposures_to test
#   The exposures to test should just be space separated in ascending order
#       EX: 100 200 300 400 500 600 ...

#EXP_LIST = list(range(1000, 10000, 1000))
#Path = '/mnt/constant_framerate_1/'

if len(sys.argv) < 2:
    EXP_LIST = [6000]
    num_frames = 1
    Path = '/home/pi/Desktop/data/'
else:
    Path = sys.argv[1]
    num_frames = int(sys.argv[2])
    EXP_LIST = list(map(int, sys.argv[3:len(sys.argv)]))

if not os.path.exists(Path):
    os.makedirs(Path)

for EXP in EXP_LIST:
    print('On {} exposure'.format(EXP))
    with picamera.PiCamera() as camera:
        camera.framerate = Fraction(1,5)
        camera.exposure_mode = 'off'
        camera.awb_mode = 'off'
        camera.iso = 100

        with picamera.array.PiBayerArray(camera, output_dims=2) as output:
            camera.shutter_speed = EXP * 1000
            sleep(7)
            while (camera.exposure_speed <=(EXP*1000-500)):
                print('Exposure time not set properly, trying again.')
                print('Currently set at {}, should be near {}'.format(camera.exposure_speed, EXP*1000))
                camera.shutter_speed = EXP*1000
                sleep(7)

            print('Exposure set to: {}'.format(camera.exposure_speed))

            #if not os.path.exists(Path + '{}ms/'.format(EXP)):
            #    os.makedirs(Path + '{}ms/'.format(EXP))

            image = 0

            while image < num_frames:
                sleep(2)

                camera.capture(output, 'jpeg', bayer = True)

                print('Image {} Taken'.format(image + 1))
                print()

                arr = output.array
                image += 1
                numpy.save(Path + '{}ms_{}'.format(EXP,image), arr)

    camera.close()
