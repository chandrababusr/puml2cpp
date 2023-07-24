#ifndef CPP_GENERATOR_H
#define CPP_GENERATOR_H

#include <string>
#include <list>

#include "UMLStructure.hpp"

namespace puml
{
    class CppGenerator
    {
        std::string fileName;
        std::string outDir;
        bool parsed;
        std::list<UMLClass> umlClassList;

        void createSrcDirs();
        void createSrcFiles();
        void createHeader(UMLClass umlClass);
        void createSrc(UMLClass umlClass);

    public:
        CppGenerator(std::string pumlFileName, std::string srcOutDir);
        int parse();
        int generate();
    };
}

#endif