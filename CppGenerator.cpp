#include "CppGenerator.hpp"

#include <fstream>
#include <iostream>
#include <sys/stat.h>
// #include <sys/types.h>

#define YYSTYPE PUMLSTYPE
#include "puml2cpp_parser.hpp"
#include "puml2cpp_scanner.hpp"

using namespace puml;

CppGenerator::CppGenerator(std::string pumlFileName, std::string srcOutDir) : fileName(pumlFileName),
                                                                              outDir(srcOutDir),
                                                                              parsed(false)
{
}

int CppGenerator::parse()
{
    int result = 0;
    fstream umlFile;

    if (parsed)
    {
        std::cout << "Already parsed!";
        return 0;
    }

    umlFile.open(fileName, ios::in);
    if (!umlFile.is_open())
    {
        throw std::ios_base::failure("Error opening file " + fileName);
    }

    puml::Scanner scanner(&umlFile);
    puml::Parser parser(scanner, umlClassList);

    result = parser();

    umlFile.close();

    parsed = true;

    return result;
}

int CppGenerator::generate()
{
    if (!parsed)
    {
        std::cout << "File not parsed!. Call parse() first?" << std::endl;
        return 1;
    }

    if (umlClassList.empty())
    {
        std::cout << "No class data. Nothing to create." << std::endl;
        return 0;
    }

    // if (-1 == mkdir(outDir.c_str(), 0777))
    // {
    //     throw std::runtime_error("Error creating directory " + outDir);
    // }

    for (auto umlClass : umlClassList)
    {
        // std::cout << "Class Name: " << umlClass.name << std::endl;
        for (auto attrib : umlClass.attributes)
        {
            std::cout << "Attribute: " << std::endl;
            std::cout << "\taccess: " << attrib.access << std::endl;
            std::cout << "\tname: " << attrib.value.name << std::endl;
            std::cout << "\ttype: " << attrib.value.type << std::endl;
        }
        for (auto method : umlClass.methods)
        {
            std::cout << "Method: " << std::endl;
            std::cout << "\taccess: " << method.access << std::endl;
            std::cout << "\tname: " << method.name << std::endl;
            for (auto param : method.params)
            {
                std::cout << "\tParam: " << std::endl;
                std::cout << "\t\tname: " << param.name << std::endl;
                std::cout << "\t\ttype: " << param.type << std::endl;
            }
            std::cout << "\treturn type: " << method.returnType << std::endl;
        }
    }

    return 0;
}