#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <fstream>
#include <iostream>
#include <numeric>
#include <vector>
#include <iterator>
#include <memory>
#include <iomanip>
#include <thread>
#include <mutex>

const char *version = "0.1";

// For use with istream_iterator to read complete lines (new line delimiter)
// std::vector<std::string> lines;
// std::copy(std::istream_iterator<line>(std::cin), std::istream_iterator<line>(), std::back_inserter(lines));
//http://stackoverflow.com/questions/1567082/how-do-i-iterate-over-cin-line-by-line-in-c/1567703#1567703

class Line
{
    std::string data;
public:
    friend std::istream &operator>>(std::istream &is, Line &l) { return std::getline(is, l.data); }
    operator std::string() const { return data; }
};

static std::vector<std::string> aggregate(const std::string &filename)
{
    std::vector<std::string> filenames;
    if( (filename.rfind(".txt") != std::string::npos) || (filename.rfind(".") == std::string::npos) )
    {
        std::ifstream file(filename.c_str());
        std::copy(std::istream_iterator<Line>(file), std::istream_iterator<Line>(), std::back_inserter(filenames));
    }
    else
    {
        filenames.push_back(filename);
    }
    return filenames;
}

class BatchProcessor : public cv::ParallelLoopBody
{
public:

    struct InputBuffer
    {
	std::vector<std::string> filenames;
	std::string output;
	bool doVerbose = false;
	bool doThreads = false;
    };

    struct OutputBuffer
    {
	std::mutex mutex;  
    };
    
    // Output must be reference type to work with cv::ParallelLoopBody API
    BatchProcessor(const BatchProcessor::InputBuffer &args, BatchProcessor::OutputBuffer &output)
	: m_args(args)
	, m_output(output)
    {
        
    }
    virtual void operator()(const cv::Range &r) const
    {
	for(int i = r.start; i < r.end; i++)
	{
	    { // Print filenames just to demonstrate code
		std::unique_lock<std::mutex> lock(m_output.mutex);
		std::cout << "processing file: " << m_args.filenames[i] << std::endl;
	    }

	    cv::Mat image = cv::imread(m_args.filenames[i], cv::IMREAD_COLOR);
	    if(!image.empty())
	    {
		cv::Laplacian(image, image, CV_8UC1, 5, 1.0, 0.0, cv::BORDER_DEFAULT);
		cv::normalize(image, image, 0, 255, cv::NORM_MINMAX, CV_8UC1);

		// Could do something here (visualize, etc)
		// cv::imshow("image", image), cv::waitKey(0);

		if(!m_args.output.empty())
		{
		    size_t index = m_args.filenames[i].rfind(".");
		    std::string ext = m_args.filenames[i].substr(index);
		    if(index != std::string::npos && !ext.compare(".png"))
		    {
			index = m_args.filenames[i].rfind("/");
			std::string filename = m_args.output + "/" +  m_args.filenames[i].substr(index);
			cv::imwrite( filename, image ); 

			std::unique_lock<std::mutex> lock(m_output.mutex);
			std::cout << "Wrote to: " << filename << std::endl;
		    }
		}
	    }
	}
    }
    
protected:
    const InputBuffer &m_args;
    OutputBuffer &m_output;
};

// Some abstraction to help with backwards compatibility in CommandLineParser API
static bool has(cv::CommandLineParser &p, const std::string &tag) { return p.has(tag); }
void print(cv::CommandLineParser &p) { p.printMessage(); }

const char *keys =
{
    "{i  input     |       | input file                                }"
    "{o  output    |       | output directory                          }"
    "{t  threads   | false | use worker threads when possible          }"
    "{   verbose   | false | print verbose diagnostics                 }"
    "{b  build     | false | print the OpenCV build information        }"
    "{h  help      | false | print help message                        }"
    "{v  version   | false | print the application version             }"
};

int main(int argc, char* argv[])
{
    cv::CommandLineParser parser(argc, argv, keys);
    
    std::string input = parser.get<std::string>("input");

#if 0
    if(!parser.check())
    {
        parser.printErrors();
        return 0;
    }
#endif
    if(argc < 2 || has(parser, "help"))
    {
        print(parser);
        return 0;
    }
    else if(has(parser, "build"))
    {
        std::cout << cv::getBuildInformation() << std::endl;
        return 0;
    }
    else if(has(parser, "version"))
    {
        std::cout << argv[0] << " v" << version << std::endl;
        return 0;
    }
    
    if(input.empty())
    {
        std::cerr << "No input filename or list specified!" << std::endl;
        return -1;
    }

    BatchProcessor::OutputBuffer results;
    BatchProcessor::InputBuffer args;
    args.output = parser.get<std::string>("output");
    args.doVerbose = parser.get<bool>("verbose");
    args.doThreads = parser.get<bool>("threads");
    args.filenames = aggregate(input);

    BatchProcessor body(args, results); // pass in ref to results output
    
    if(args.doThreads)
        cv::parallel_for_({0,int(args.filenames.size())}, body );
    else
        body( cv::Range(0, args.filenames.size()) );
    
    return 0;
}
