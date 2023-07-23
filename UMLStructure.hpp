#ifndef UML_STRUCTURE_H
#define UML_STRUCTURE_H

#include <iostream>
#include <list>

struct UMLVar
{
    std::string name;
    std::string type;
};

struct UMLAttribute
{
    char access;
    UMLVar value;
};

struct UMLMethod
{
    char access;
    std::string name;
    std::list<UMLVar> params;
    std::string returnType;
};

struct UMLClass
{
    std::string name;
    std::list<UMLAttribute> attributes;
    std::list<UMLMethod> methods;
    std::string theNamespace;
    // std::string extends;
};

#endif