#if defined(__linux__) || defined(LINUX) || defined(__APPLE__) || defined(ANDROID)

#include <opencv2/imgproc/imgproc.hpp>  // Gaussian Blur
#include <opencv2/core/core.hpp>        // Basic OpenCV structures (cv::Mat, Scalar)
#include <opencv2/videoio/videoio.hpp>
#include <opencv2/highgui/highgui.hpp>  // OpenCV window I/O
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/objdetect/objdetect.hpp>

#include "detection_based_tracker.hpp" // local gpucv:: override to fix unique_lock bug

#include <stdio.h>
#include <string>
#include <vector>

#include <iostream>

using namespace std;
//using namespace cv;

//const string WindowName = "Face Detection example";

class CascadeDetectorAdapter: public gpucv::DetectionBasedTracker::IDetector
{
    public:
        CascadeDetectorAdapter(cv::Ptr<cv::CascadeClassifier> detector):
            IDetector(),
            Detector(detector)
        {
            CV_Assert(detector);
        }

        void detect(const cv::Mat &Image, std::vector<cv::Rect> &objects)
        {
            Detector->detectMultiScale(Image, objects, scaleFactor, minNeighbours, 0, minObjSize, maxObjSize);
        }

        virtual ~CascadeDetectorAdapter()
        {}

    private:
        CascadeDetectorAdapter();
        cv::Ptr<cv::CascadeClassifier> Detector;
 };

int main(int argc, char** argv )
{
    std::string WindowName = argv[1];
    std::string cascadeFrontalfilename = argv[2]; //  "../../data/lbpcascades/lbpcascade_frontalface.xml";    

    std::cout << "WindowName: " << WindowName << "\n" << "Cascade: " << cascadeFrontalfilename << std::endl;

    //namedWindow(WindowName);

    cv::VideoCapture VideoStream(0);

    if (!VideoStream.isOpened())
    {
        printf("Error: Cannot open video stream from camera\n");
        return 1;
    }

    cv::Ptr<gpucv::DetectionBasedTracker::IDetector> MainDetector, TrackingDetector;
    {
      cv::Ptr<cv::CascadeClassifier> cascade = cv::makePtr<cv::CascadeClassifier>(cascadeFrontalfilename);
      MainDetector = cv::makePtr<CascadeDetectorAdapter>(cascade);
    }

    {
      cv::Ptr<cv::CascadeClassifier> cascade = cv::makePtr<cv::CascadeClassifier>(cascadeFrontalfilename);
      TrackingDetector = cv::makePtr<CascadeDetectorAdapter>(cascade);
    }

    gpucv::DetectionBasedTracker::Parameters params;
    params.maxTrackLifetime = 20;
    params.minDetectionPeriod = 7;

    gpucv::DetectionBasedTracker Detector(MainDetector, TrackingDetector, params);

    if (!Detector.run())
    {
        printf("Error: Detector initialization failed\n");
        return 2;
    }

    cv::Mat ReferenceFrame;
    cv::Mat GrayFrame;
    std::vector<cv::Rect> Faces;

    while(true)
    {
        VideoStream >> ReferenceFrame;
	cv::cvtColor(ReferenceFrame, GrayFrame, cv::COLOR_RGB2GRAY);
       
	Detector.process(GrayFrame);
        Detector.getObjects(Faces);

        for (size_t i = 0; i < Faces.size(); i++)
        {
	  rectangle(ReferenceFrame, Faces[i], cv::Scalar(0,255,0));
        }

	cv::imshow(WindowName, ReferenceFrame);

        if (cv::waitKey(30) >= 0) break;
    }

    Detector.stop();

    return 0;
}

#else

#include <stdio.h>
int main()
{
    printf("This sample works for UNIX or ANDROID only\n");
    return 0;
}

#endif
