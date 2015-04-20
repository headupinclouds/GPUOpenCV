#include <iostream>
#include <cvmatio/include/MatlabIOContainer.hpp>

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
}
