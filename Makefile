PROJECT := puml2cpp

PARSER_Y := ${PROJECT}.yy
PARSER_NAME := ${PROJECT}_parser
PARSER_CC := ${PARSER_NAME}.cpp
PARSER_OBJ := ${PARSER_NAME}.o
PARSER_EXTRA := ${PARSER_NAME}.output ${PARSER_NAME}.hpp location.hh

LEXER_L := ${PROJECT}.l
LEXER_NAME := ${PROJECT}_scanner
LEXER_CC := ${LEXER_NAME}.cpp
LEXER_OBJ := ${LEXER_NAME}.o

MAIN_SRC := main.cpp
MAIN_OBJ := main.o

PROJECT_OBJS := ${PARSER_OBJ} ${LEXER_OBJ} ${MAIN_OBJ}

CC := g++
CFLAGS := -g --std=c++14 -Wall

.PHONY: clean parser-clean parser main main-clean

${PROJECT}: ${PROJECT_OBJS}
	${CC} $(CFLAGS) ${PROJECT_OBJS} -o $@

${PROJECT}-clean:
	rm -f ${PROJECT}

#
# main rules
#
main: ${MAIN_OBJ}

${MAIN_OBJ}: ${MAIN_SRC}
	${CC} ${CFLAGS} -c $? -o $@

main-clean:
	rm -f ${MAIN_OBJ}


#
# Parser rules
#
parser: ${PARSER_OBJ}

${PARSER_OBJ}: ${PARSER_CC}
	${CC} ${CFLAGS} -c $? -o $@

${PARSER_CC}: ${PARSER_Y}
	bison -v $? -o $@

parser-clean:
	rm -f ${PARSER_CC} ${PARSER_OBJ} ${PARSER_EXTRA}

#
# Scanner rules
#
scanner: ${LEXER_OBJ}

${LEXER_OBJ}: ${LEXER_CC}
	${CC} ${CFLAGS} -c $? -o ${LEXER_OBJ}

${LEXER_CC}: ${LEXER_L}
	flex++ -o${LEXER_CC} $?

scanner-clean:
	rm -f ${LEXER_CC} ${LEXER_OBJ}


#
# Clean rule
#
clean: ${PROJECT}-clean parser-clean scanner-clean main-clean
