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
newlines  \n|\r\n{1,}

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

-- {
    cout << "[puml2cpp::Scanner]: Dash" << endl;
    return puml::Parser::make_DASH(puml::location());
}

[a-zA-Z_][a-zA-Z_0-9]* {
    cout << "[puml2cpp::Scanner]: STRING [" << yytext << "]" << endl;
    return puml::Parser::make_STRING(yytext, puml::location());
}

{newlines} {
    cout << "[puml2cpp::Scanner]: " << "Newlines" << endl;
    return puml::Parser::make_NEWLINES(puml::location());
}

[ \t]+ {
    cout << "[puml2cpp::Scanner]: " << "BLANK" << endl;
    return puml::Parser::make_BLANK(puml::location());
}

<<EOF>> {
    cout << "[puml2cpp::Scanner]: EOF" << endl;
    return yyterminate();
}

%%

