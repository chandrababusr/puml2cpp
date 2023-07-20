#include <iostream>
#include <fstream>

using namespace std;

#define YYSTYPE PUMLSTYPE
#include "puml2cpp_parser.hpp"
#include "puml2cpp_scanner.hpp"

int main(int argc, char **argv)
{
    if (argc != 2)
    {
        cerr << "Usage: " << argv[0] << " <puml_file>" << endl;
        cerr << "Example: " << argv[0] << " example.wsd" << endl;
        return 1;
    }

    string fileName{argv[1]};

    fstream umlFile;
    umlFile.open(fileName, ios::in);

    if (!umlFile.is_open())
    {
        cerr << "Error opening file " << argv[0] << endl;
        return 2;
    }

    string testStr = "@startuml testProject @enduml";
    puml::Scanner scanner(&umlFile);
    puml::Parser parser(scanner);

    int res = parser();

    cout << "Parsing result: " << res << endl;

    umlFile.close();

    return res;
}