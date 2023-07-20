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

    using namespace std;

    namespace puml {
        class Scanner;
    }
}

%code top
{
    #include <iostream>
    #include "puml2cpp_scanner.hpp"
    #include "puml2cpp_parser.hpp"
    
    // yylex() arguments are defined in parser.y
    static puml::Parser::symbol_type pumllex (puml::Scanner& scanner) {
        return scanner.get_next_token();
        // return 0;
    }

    using namespace puml;
}

%lex-param { puml::Scanner& scanner}
%parse-param { puml::Scanner& scanner}
%locations
%define parse.trace
%define parse.error verbose

%define api.token.prefix {TOKEN_}

%token STARTTAG "start tag"
%token ENDTAG "end tag"
%token <std::string> STRING  "string";
%token NEWLINES "newlines"
%token BLANK "blank"
%token NAMESPACE "namespace"
%token LEFTCURL "left curl"
%token RIGHTCURL "right curl"
%token CLASS "class"
%token DASH "dash"
%token END 0 "end of file"

%start pumlroot

%%

pumlroot:
    starttag declarations ENDTAG
        { std::cout << "[puml2cpp::Parser]: Project root" << std::endl; }
;

starttag:
    STARTTAG NEWLINES
        { std::cout << "[puml2cpp::Parser]: Unnamed project" << std::endl; }
    | STARTTAG BLANK STRING NEWLINES
        { std::cout << "[puml2cpp::Parser]: Project name: " << $3 << std::endl; }
    | STARTTAG BLANK STRING BLANK NEWLINES
        { std::cout << "[puml2cpp::Parser]: Project name: " << $3 << std::endl; }
;

declarations:
    named_declarations
        { std::cout << "[puml2cpp::Parser]: named_declarations" << std::endl; }
    | unnamed_declarations
        { std::cout << "[puml2cpp::Parser]: unnamed_declarations" << std::endl; }
;

named_declarations:
    NAMESPACE STRING LEFTCURL items RIGHTCURL
        { std::cout << "[puml2cpp::Parser]: Namespace name: " << $2 << std::endl; }
;

unnamed_declarations:
    items
        { std::cout << "[puml2cpp::Parser]: No namespace" << std::endl; }
;

items:
    %empty
        { std::cout << "[puml2cpp::Parser]: Empty items " << std::endl; }
    | items class
        { std::cout << "[puml2cpp::Parser]: Classes" << std::endl; }
    | items relationship
        { std::cout << "[puml2cpp::Parser]: Relationships" << std::endl; }
;

class:
    CLASS STRING
        { std::cout << "[puml2cpp::Parser]: Class name: " << $2 << std::endl; }
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

