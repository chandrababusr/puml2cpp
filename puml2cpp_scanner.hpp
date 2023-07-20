#ifndef SCANNER_H
#define SCANNER_H

#if !defined(yyFlexLexerOnce)
#undef yyFlexLexer
#define yyFlexLexer puml_FlexLexer // the trick with prefix; no namespace here :(
#include <FlexLexer.h>
#endif

#undef YY_DECL
#define YY_DECL puml::Parser::symbol_type puml::Scanner::get_next_token()

#include "puml2cpp_parser.hpp" // this is needed for symbol_type

namespace puml
{
    class Scanner : public yyFlexLexer
    {
    public:
        Scanner(std::istream *arg_yyin) : yyFlexLexer(arg_yyin) {}
        virtual ~Scanner() {}
        virtual puml::Parser::symbol_type get_next_token();
    };
}

#endif