%{
#include "parser.tab.h"  // Ensure this matches your actual Bison-generated header name
%}

DIGIT       [0-9]
INT         {DIGIT}+
FLOAT       [0-9]+"."[0-9]+
WS          [ \t\n]
LETTER      [a-zA-Z]
STRING      ({LETTER}|{FLOAT})+
CHAR        [a-zA-Z0-9]
ADD         \+
SUB         \-
MUL         \*
DIV         \/
DOT         \.
ASSIGN      =
LPAREN      \(
RPAREN      \)
LBRACE      \{
RBRACE      \}
COMMA       ,
SEMICOLON   ;
COLON       :
END       return END;
RETURN      return RETURN;


%%

{WS}        {/* Ignore whitespace */}

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }


{INT}    { yylval.intValue = atoi(yytext); return INT; }
{FLOAT}  { yylval.floatValue = atof(yytext); return FLOAT; }
{CHAR}   { yylval.charValue = yytext[0]; return CHAR; }
{STRING} { yylval.stringValue = strdup(yytext); return STRING; }

.           { fprintf(stderr, "LEXER Error: Invalid character '%s'\n", yytext); }

%%

