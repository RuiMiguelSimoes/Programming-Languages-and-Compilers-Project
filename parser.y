%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern int yylex();
void yyerror(const char* s);
%}

%union {
    int intValue;
    double floatValue;
    char charValue;
    char* stringValue;
}

%token <intValue> INT
%token <floatValue> FLOAT
%token <charValue> CHAR
%token <stringValue> STRING

%token ADD SUB MUL DIV POW
%token SEMICOLON
%token END;

%type <intValue> expr_int_operations
%type <floatValue> expr_float_operations

%%
expr_list:    
        | expr_list expr_int_operations SEMICOLON { printf("%d\n", $2); } 
        | expr_list expr_float_operations SEMICOLON { printf("%f\n", $2); }
        | expr_list END  { exit(0); }
;

expr_int_operations: INT { $$ = $1; }
    | expr_int_operations ADD expr_int_operations { $$ = $1 + $3;  }
    | expr_int_operations SUB expr_int_operations { $$ = $1 - $3;  }
    | expr_int_operations MUL expr_int_operations { $$ = $1 * $3;  }
    | expr_int_operations DIV expr_int_operations { if($3 != 0) $$ = $1 / $3; else yyerror("division by zero");  }
;

expr_float_operations: FLOAT { $$ = $1; }
    | expr_float_operations ADD expr_float_operations { $$ = $1 + $3;  }
    | expr_float_operations SUB expr_float_operations { $$ = $1 - $3;  }
    | expr_float_operations MUL expr_float_operations { $$ = $1 * $3;  }
    | expr_float_operations DIV expr_float_operations { if($3 != 0) $$ = $1 / $3; else yyerror("division by zero"); }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parser Error: %s\n", s);
    exit(EXIT_FAILURE);
}   

int main() {
    yyparse();
    return 0;
}