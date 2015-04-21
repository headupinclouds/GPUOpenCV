#include <iostream>
#include <cvmatio/include/MatlabIO.hpp>
#include <cvmatio/include/MatlabIOContainer.hpp>

// File: a.mat
// MATLAB 5.0 MAT-file, Platform: MACI64, Created on: Mon Apr 20 18:26:18 2015                                         
// Variables:
// a:  Mat
// -------------------------
// [1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1;
//  1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

int main(int argc, char **argv)
{
    std::string filename = argv[1];

    MatlabIO matio;

    // create a new reader
    bool ok = matio.open(filename, "r");
    if (!ok) 
	return -1;
        
    // read all of the variables in the file
    auto variables = matio.read();
    matio.close();

    // display the file info
    matio.whos(variables);

    cv::Mat d = variables[0].data< cv::Mat >();

    std::cout << d << std::endl;
}
