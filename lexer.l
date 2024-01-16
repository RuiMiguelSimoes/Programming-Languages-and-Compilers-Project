%{
#include "parser.tab.h"
%}

DIGIT       [0-9]
INT         {DIGIT}+
FLOAT       [0-9]+"."[0-9]+
WS          [ \t\n]
LETTER      [a-zA-Z]
BOOL        true|false
STRING      \"([a-zA-Z]|[0-9])*\"
CHAR        \'[a-zA-Z0-9]\' 
ID          {LETTER}({LETTER}|{DIGIT})*
ADD         \+
SUB         \-
MUL         \*
MOD         \%
DIV         \/
DOT         \.
ASSIGN      =
LPAREN      \(
RPAREN      \)
LBRACE      \{
RBRACE      \}
LSQBRACE    \[
RSQBRACE    \]
EQ          ==
COMMA       ,
SEMICOLON   ;
COLON       :
END       return END;
RETURN      return RETURN;
FUNCTION    return FUNCTION;
MAIN        return MAIN;
INT_TYPE    return INT_TYPE;
FLOAT_TYPE  return FLOAT_TYPE;
CHAR_TYPE   return CHAR_TYPE;
BOOL_TYPE   return BOOL_TYPE;
NEWLINE     return NEWLINE;
PRINT       return PRINT;
if          return IF;
else        return ELSE;
%%

{WS}        {if (yytext[0] == '\n') { yylineno++; } else { ; }}
"//"(.*)\n    /* Single-line comments */

"/*"([^*]|\*+[^*/])*\*+"/" /* Multi-line comments */

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"%"         { return MOD; }
"=="        { return EQ; }
","         { return COMMA; }
":"         { return COLON; }
"="         { return ASSIGN; }
"["         { return LSQBRACE; }
"]"         { return RSQBRACE; }
"func"      { return FUNCTION; }
"main"      { return MAIN; }
"int"    { return INT_TYPE; }
"float"  { return FLOAT_TYPE; }
"char"   { return CHAR_TYPE; }
"bool"   { return BOOL_TYPE; }
"string" { return STRING_TYPE; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
";"         { return SEMICOLON; }
"print"     { return PRINT; }

{ID}        { yylval.stringValue = strdup(yytext); return ID; }
{INT}    { yylval.intValue = atoi(yytext); return INT; }
{FLOAT}  { yylval.floatValue = atof(yytext); return FLOAT; }
{CHAR}   { yylval.charValue = yytext[1]; return CHAR; }
\"[^\"]*\"   { yylval.stringValue = strdup(yytext); return STRING; }

.           { fprintf(stderr, "LEXER Error: Invalid character '%s'\n", yytext); }

%%

int yywrap() {
    return 1;
}