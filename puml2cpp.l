%option noyywrap nounput noinput batch debug

%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <cstring> // strerror
# include <string>

#include "puml2cpp_scanner.hpp"
#include "puml2cpp_parser.hpp"

#include <iostream>
using namespace std;


#define yyterminate() puml::Parser::make_END(puml::location());

%}

%option yyclass="Scanner"
%option prefix="puml_"


rightcurl \{
leftcurl  \}
newlines  [\n]+|["\r\n"]+
access    [-+#]
colon     :
comma     ,
leftpar   \(
rightpar  \)
larrow    "<|-- "
rarrow    "--|>"

%%


@startuml {
    cout << "[puml2cpp::Scanner]: " << "Start Tag" << endl;
    return puml::Parser::make_STARTTAG(puml::location());
}

@enduml {
    cout << "[puml2cpp::Scanner]: " << "End Tag" << endl;
    return puml::Parser::make_ENDTAG(puml::location());
}

namespace {
    cout << "[puml2cpp::Scanner]: " << "Namespace" << endl;
    return puml::Parser::make_NAMESPACE(puml::location());
}

class {
    cout << "[puml2cpp::Scanner]: Class" << endl;
    return puml::Parser::make_CLASS(puml::location());
}

{rightcurl} {
    cout << "[puml2cpp::Scanner]: Left curl" << endl;
    return puml::Parser::make_LEFTCURL(puml::location());
}

{leftcurl} {
    cout << "[puml2cpp::Scanner]: Right curl" << endl;
    return puml::Parser::make_RIGHTCURL(puml::location());
}

{access} {
    cout << "[puml2cpp::Scanner]: Access [" << yytext[0] << "]" << endl;
    return puml::Parser::make_ACCESS(yytext[0], puml::location());
}

{colon} {
    cout << "[puml2cpp::Scanner]: Colon" << endl;
    return puml::Parser::make_COLON(puml::location());
}

{comma} {
    cout << "[puml2cpp::Scanner]: Comma" << endl;
    return puml::Parser::make_COMMA(puml::location());
}

{leftpar} {
    cout << "[puml2cpp::Scanner]: Left parenthesis" << endl;
    return puml::Parser::make_LEFTPAR(puml::location());
}

{rightpar} {
    cout << "[puml2cpp::Scanner]: RIGHT parenthesis" << endl;
    return puml::Parser::make_RIGHTPAR(puml::location());
}

{larrow} {
    cout << "[puml2cpp::Scanner]: Left arrow " << yytext << endl;
    return puml::Parser::make_LARROW(puml::location());
}

{rarrow} {
    cout << "[puml2cpp::Scanner]: Right arrow " << yytext << endl;
    return puml::Parser::make_RARROW(puml::location());
}

[a-zA-Z_][a-zA-Z_0-9]* {
    cout << "[puml2cpp::Scanner]: STRING [" << yytext << "]" << endl;
    return puml::Parser::make_STRING(yytext, puml::location());
}

{newlines} {
    cout << "[puml2cpp::Scanner]: " << "Newlines" << endl;
    return puml::Parser::make_NEWLINES(puml::location());
}

[ \t]* {
    cout << "[puml2cpp::Scanner]: " << "Whitespace" << endl;
    // return puml::Parser::make_BLANK(puml::location());
}

<<EOF>> {
    cout << "[puml2cpp::Scanner]: EOF" << endl;
    return yyterminate();
}

%%

