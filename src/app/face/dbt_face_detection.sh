#!/bin/bash

export PATH=${PWD}:${PATH}

dbt_face_detection lbp_face_detection "../../../../../prebuilt/osx/opencv-3.0.0-osx-static/share/OpenCV/lbpcascades/lbpcascade_frontalface.xml"
