#include "CppGenerator.hpp"

#include <fstream>
#include <iostream>
#include <sys/stat.h>
#include <vector>
#include <sstream>

#define YYSTYPE PUMLSTYPE
#include "puml2cpp_parser.hpp"
#include "puml2cpp_scanner.hpp"

using namespace puml;

#define TAB "\t"
#define NEWLINE "\n"

CppGenerator::CppGenerator(std::string pumlFileName, std::string srcOutDir) : fileName(pumlFileName),
                                                                              outDir(srcOutDir),
                                                                              parsed(false)
{
}

int CppGenerator::parse()
{
    int result = 0;
    std::fstream umlFile;

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

void writeToFile(std::string fileName, std::ostringstream &content)
{
    std::fstream fs;
    fs.open(fileName, ios::out);

    if (!fs.is_open())
    {
        throw std::ios_base::failure("Error opening file " + fileName);
    }

    fs << content.str();
    fs.close();
}

std::string getHeaderGuard(std::string className)
{
    std::string guard = className;

    for (size_t i = 0; i < guard.size(); ++i)
    {
        guard[i] = toupper(guard[i]);
    }

    return guard + "_H";
}

void putMethodParams(std::list<UMLVar> params, std::ostringstream &oss)
{
    oss << "(";

    for (auto iter = params.begin(); iter != params.end(); ++iter)
    {
        if (iter != params.begin())
        {
            oss << ", ";
        }
        UMLVar param = *iter;
        oss << param.type << " " << param.name;
    }

    oss << ")";
}

void putSection(char access, UMLClass umlClass, std::ostringstream &headerContent, std::string indent)
{
    switch (access)
    {
    case '+':
        headerContent << indent << "public:" << NEWLINE;
        break;

    case '#':
        headerContent << indent << "protected:" << NEWLINE;
        break;

    case '-':
        headerContent << indent << "private:" << NEWLINE;
        break;
    }

    indent += TAB;

    for (UMLAttribute attribute : umlClass.attributes)
    {
        if (attribute.access == access)
        {
            headerContent << indent << attribute.value.type << " " << attribute.value.name << ";" << NEWLINE;
        }
    }
    for (UMLMethod method : umlClass.methods)
    {
        if (method.access == access)
        {
            headerContent << indent << method.returnType << " " << method.name;
            putMethodParams(method.params, headerContent);
            headerContent << ";" << NEWLINE;
        }
    }

    headerContent << NEWLINE;
}

void putHeaderContent(UMLClass umlClass, std::ostringstream &headerContent)
{
    std::string headerGuard = getHeaderGuard(umlClass.name);
    std::string indent = "";

    headerContent
        << "#ifndef " << headerGuard << NEWLINE
        << "#define " << headerGuard << NEWLINE
        << NEWLINE;

    if (!umlClass.inherits.empty())
    {
        headerContent
            << "#include \"" << umlClass.inherits << ".hpp\"" << NEWLINE
            << NEWLINE;
    }

    if (!umlClass.umlNamespace.empty())
    {
        headerContent << "namespace " << umlClass.umlNamespace << " {" << NEWLINE;
        indent = TAB;
    }

    headerContent
        << indent << "class " << umlClass.name;
    if (!umlClass.inherits.empty())
    {
        headerContent << ": public " << umlClass.inherits;
    }
    headerContent
        << NEWLINE
        << indent << "{" << NEWLINE
        << NEWLINE;

    putSection('+', umlClass, headerContent, indent);
    putSection('#', umlClass, headerContent, indent);
    putSection('-', umlClass, headerContent, indent);

    headerContent
        << indent << "};" << NEWLINE;

    if (!umlClass.umlNamespace.empty())
    {
        headerContent << "}" << NEWLINE;
    }

    headerContent
        << NEWLINE
        << "#endif // " << headerGuard << NEWLINE;
}

void CppGenerator::createHeader(UMLClass umlClass)
{
    std::string headerFileName = outDir + "/include/" + umlClass.name + ".hpp";
    std::ostringstream headerContent;

    putHeaderContent(umlClass, headerContent);

    writeToFile(headerFileName, headerContent);
}

void CppGenerator::createSrc(UMLClass umlClass)
{
    std::string headerFileName = umlClass.name + ".hpp";
    std::string srcFileName = outDir + "/src/" + umlClass.name + ".cpp";
    std::ostringstream srcContent;

    srcContent << "#include \"" << headerFileName << "\"" << NEWLINE;

    if (!umlClass.umlNamespace.empty())
    {
        srcContent << NEWLINE << "using namespace " << umlClass.umlNamespace << ";" << NEWLINE;
    }

    for (auto method : umlClass.methods)
    {
        srcContent << NEWLINE
                   << method.returnType << " " << umlClass.name << "::" << method.name;
        putMethodParams(method.params, srcContent);
        srcContent << NEWLINE
                   << "{" << NEWLINE
                   << "}" << NEWLINE;
    }

    writeToFile(srcFileName, srcContent);
}

void CppGenerator::createSrcFiles()
{

    for (auto umlClass : umlClassList)
    {
        createHeader(umlClass);
        createSrc(umlClass);
    }
}

void CppGenerator::createSrcDirs()
{
    std::vector<std::string> dirs = {outDir,
                                     outDir + "/src",
                                     outDir + "/include"};

    for (auto dir : dirs)
    {
        if (-1 == mkdir(dir.c_str(), 0777))
        {
            throw std::runtime_error("Error creating directory " + dir);
        }
    }
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

    createSrcDirs();

    createSrcFiles();

    // createMakefile();

    // createMain();

    return 0;
}