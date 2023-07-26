%require "3.2"
%language "c++"
%defines
%define api.parser.class { Parser }

%define api.prefix {puml}

%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define api.namespace { puml }
%code requires
{
    #include <iostream>
    #include <string>
    #include <list>

    using namespace std;

    namespace puml {
        class Scanner;
    }

    #include "UMLStructure.hpp"

    enum MemberType {ATTR, METH};

    struct UMLMember
    {
        MemberType type;
        UMLAttribute attribute;
        UMLMethod method;
    };
}

%code top
{
    #include <iostream>
    #include "puml2cpp_scanner.hpp"
    #include "puml2cpp_parser.hpp"
    #include "UMLStructure.hpp"

    static puml::Parser::symbol_type pumllex (puml::Scanner& scanner) {
        return scanner.get_next_token();
    }

    using namespace puml;

    std::string umlNamespace = "";
}

%lex-param { puml::Scanner& scanner}
%parse-param { puml::Scanner& scanner}
%parse-param { std::list<UMLClass>& umlClassList }
%locations
%define parse.trace
%define parse.error verbose

%define api.token.prefix {TOKEN_}

%token STARTTAG "start tag"
%token ENDTAG "end tag"
%token <std::string> STRING  "string";
%token NEWLINES "newlines"
%token NAMESPACE "namespace"
%token LEFTCURL "left curl"
%token RIGHTCURL "right curl"
%token CLASS "class"
%token <char> ACCESS "access"
%token COLON "colon"
%token COMMA "comma"
%token LEFTPAR "left parenthesis"
%token RIGHTPAR "right parenthesis"
%token DASH "dash"
%token END 0 "end of file"

%type <UMLVar> var;
%type <std::list<UMLVar>> vars;
%type <std::list<UMLVar>> varlist;
%type <UMLAttribute> attribute;
%type <UMLMethod> method;
%type <UMLMember> member;
%type <std::list<UMLMember>> members;
%type <UMLClass> class;

%start pumlroot

%%

pumlroot:
    starttag declarations ENDTAG
        { std::cout << "[puml2cpp::Parser]: Project root" << std::endl; }
;

starttag:
    STARTTAG NEWLINES
        { std::cout << "[puml2cpp::Parser]: Unnamed project" << std::endl; }
    | STARTTAG STRING NEWLINES
        { std::cout << "[puml2cpp::Parser]: Project name: " << $2 << std::endl; }
;


declarations:
    %empty
    | declarations class
    | declarations relationship
    | declarations empty_namespace
    | declarations namespace_start declarations namespace_end
;

empty_namespace:
    NAMESPACE STRING LEFTCURL RIGHTCURL NEWLINES
;

namespace_start:
    NAMESPACE STRING LEFTCURL NEWLINES
        {
            std::cout << "[puml2cpp::Parser]: Namespace start: " << $2 << std::endl;
            umlNamespace = $2;
        }
    | NAMESPACE STRING NEWLINES LEFTCURL NEWLINES
        {
            std::cout << "[puml2cpp::Parser]: Namespace start: " << $2 << std::endl;
            umlNamespace = $2;
        }
;

namespace_end:
    RIGHTCURL NEWLINES
        {
            std::cout << "[puml2cpp::Parser]: Namespace end" << std::endl;
            umlNamespace = "";
        }
;

class:
    CLASS STRING NEWLINES
        {
            std::string name = $2;
            std::cout << "[puml2cpp::Parser]: Class name: " << name << std::endl;
            std::list<UMLAttribute> la;
            std::list<UMLMethod> lm;

            UMLClass umlClass{name, la, lm, umlNamespace};
            umlClassList.push_back(umlClass);
        }
    | CLASS STRING LEFTCURL NEWLINES members RIGHTCURL NEWLINES
        {
            std::string name = $2;
            std::cout << "[puml2cpp::Parser]: Class name: " << name << std::endl;
            std::list<UMLAttribute> la;
            std::list<UMLMethod> lm;

            std::list<UMLMember> umlMembers = $5;
            for(auto& umlMember: umlMembers)
            {
                if(umlMember.type == ATTR) {
                    UMLAttribute attr = umlMember.attribute;
                    la.push_back(attr);
                } else {
                    UMLMethod meth = umlMember.method;
                    lm.push_back(meth);
                }
            }

            UMLClass umlClass{name, la, lm, umlNamespace};
            umlClassList.push_back(umlClass);
        }
;

members:
    member
        {
            std::list<UMLMember> memberList;
            memberList.push_back($1);
            $$ = memberList;
        }
    | members member
        {
            std::list<UMLMember> memberList = $1;
            memberList.push_back($2);
            $$ = memberList;
        }
;

member:
    attribute
        {
            UMLMember umlMember;
            umlMember.type = ATTR;
            umlMember.attribute = $1;
            $$ = umlMember;
        }
    | method
        {
            UMLMember umlMember;
            umlMember.type = METH;
            umlMember.method = $1;
            $$ = umlMember;
        }
;

method:
    ACCESS STRING LEFTPAR varlist RIGHTPAR COLON STRING NEWLINES
        {
            char access = $1;
            std::string name = $2;
            std::list<UMLVar> params = $4;
            std::string returnType = $7;

            $$ = UMLMethod{access, name, params, returnType};
        }
;

varlist:
    %empty
        {
            $$ = std::list<UMLVar>();
        }
    | vars
        {
            $$ = $1;
        }
;

vars:
    var
        {
            std::list<UMLVar> umlParams;
            umlParams.push_back($1);
            $$ = umlParams;
        }
    | vars COMMA var
        {
            std::list<UMLVar> umlParams = $1;
            umlParams.push_back($3);
            $$ = umlParams;
        }
;

var:
    STRING COLON STRING
        {
            $$ = UMLVar{$1, $3};
        }
;

attribute:
    ACCESS var NEWLINES
        {
            $$ = UMLAttribute{$1, $2};
        }
;

relationship:
    STRING DASH STRING
        { std::cout << "[puml2cpp::Parser]: Dash" << std::endl; }
;

%%

void puml::Parser::error(const location &loc , const std::string &message)
{
    std::cout << "[puml2cpp::Parser]: " << message << ". Error location: " << loc << std::endl;
}

