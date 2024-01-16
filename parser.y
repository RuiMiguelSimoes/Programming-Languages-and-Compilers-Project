%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define INT_TYPE_DEF 1
#define FLOAT_TYPE_DEF 2
#define CHAR_TYPE_DEF 3
#define STRING_TYPE_DEF 4

extern int yylex();
void yyerror(const char* s);

extern int yylineno;
extern char* yytext;

struct SymbolTable {
    char* name; // tipo nome mas é da variavel 
    int intValue;
    double floatValue;
    char charValue;
    char* stringValue;
    int type; // Add this line
};

struct SymbolTable symbol_table[100]; // ns se 100 symbols é bom ou n mas é o que temos
int symbol_count = 0; // Keep track of the number of symbols in the table

%}

%union {
    int intValue;
    double floatValue;
    char charValue;
    char* stringValue;
    char* idValue;
}

// Tokens with types
%token <intValue> INT
%token <floatValue> FLOAT
%token <charValue> CHAR
%token <stringValue> STRING
%token <charValue> BOOL
%token <stringValue> FUNCTION MAIN
%token <stringValue> ID

// Tokens sem types defined
%token INT_TYPE FLOAT_TYPE CHAR_TYPE STRING_TYPE BOOL_TYPE

// Operators
%left MUL DIV
%left ADD SUB 
%token MOD
%token SEMICOLON EQ COMMA COLON ASSIGN LSQBRACE RSQBRACE
%token LPAREN RPAREN LBRACE RBRACE
%token END

%token PRINT   
%type <floatValue> expression_print_numbers
%type <stringValue> expression_print_strings
%type <stringValue> expr_string_variable_lookup
%type <intValue> expr_int_variable_lookup
%type <floatValue> expr_float_variable_lookup
%type <floatValue> number_statements
%type <stringValue> string_statements
%type <charValue> expr_char_variable_lookup
%%

program: FUNCTION MAIN LPAREN RPAREN LBRACE block RBRACE  { printf("\nSuccessful execution\n"); }
    ;

block: 
    |  expressions_list 
    ;

expressions_list:
         var_declaration SEMICOLON
        | expressions_list expression_print SEMICOLON  
        | expressions_list var_declaration SEMICOLON 
        | expressions_list number_statements SEMICOLON 
        | expressions_list statements_list SEMICOLON 
        | expressions_list string_statements SEMICOLON 
        | expressions_list expression_print_numbers SEMICOLON
        | expressions_list expression_print_strings SEMICOLON
        | expressions_list END  { exit(0); }
    ;

number_statements: expr_int_variable_lookup { $$ = $1; printf("%d\n", $$); } 
    | expr_float_variable_lookup { $$ = $1; printf("%f\n", $$); }
    ;

string_statements: expr_string_variable_lookup { $$ = $1; }
    | expr_char_variable_lookup { $$ = $1; }

statements_list: PRINT LPAREN STRING RPAREN { printf("%s\n", $3); }
    | statements_list expression_print_numbers
    | statements_list expression_print_strings
;

expression_print: PRINT LPAREN ID RPAREN {
    int found = 0;
    for (int i = 0; i < symbol_count; ++i) {
        if (symbol_table[i].name != NULL && strcmp(symbol_table[i].name, $3) == 0) {
            found = 1;
            switch (symbol_table[i].type) {
                case INT_TYPE:
                    printf("%d\n", symbol_table[i].intValue);
                    break;
                case FLOAT_TYPE:
                    printf("%f\n", symbol_table[i].floatValue);
                    break;
                case CHAR_TYPE:
                    printf("%c\n", symbol_table[i].charValue);
                    break;
                case STRING_TYPE:
                    printf("%s\n", symbol_table[i].stringValue);
                    break;
            }
            break;
        }
    }
    if (!found) {
        fprintf(stderr, "Variable '%s' not found\n", $3);
        exit(EXIT_FAILURE);
    }
}
;

expression_print_numbers: PRINT LPAREN ID RPAREN {
    int found = 0;
    for (int i = 0; i < symbol_count; ++i) {
        if (symbol_table[i].name != NULL && strcmp(symbol_table[i].name, $3) == 0) {
            if (symbol_table[i].type == INT_TYPE) {
                printf("%d\n", symbol_table[i].intValue);
                found = 1;
                break;
            } else if (symbol_table[i].type == FLOAT_TYPE) {
                printf("%f\n", symbol_table[i].floatValue);
                found = 1;
                break;
            }
        }

    }
    if (!found) {
        fprintf(stderr, "Variable '%s' not found\n", $3);
        exit(EXIT_FAILURE);
    }
}
;

expression_print_strings: PRINT LPAREN ID RPAREN {
    int found = 0;
    for (int i = 0; i < symbol_count; ++i) {
        if (symbol_table[i].name != NULL && strcmp(symbol_table[i].name, $3) == 0) {
            if (symbol_table[i].type == STRING_TYPE) {
                printf("String variable '%s': %s\n", symbol_table[i].name, symbol_table[i].stringValue);
                found = 1;
                break;
            }
            else if (symbol_table[i].type == CHAR_TYPE) {
                printf("Char variable '%s': %c\n", symbol_table[i].name, symbol_table[i].charValue);
                found = 1;
                break;
            }
        }
    }
    if (!found) {
        fprintf(stderr, "Variable '%s' not found\n", $3);
        exit(EXIT_FAILURE);
    }
}
;

//Declaração de variaveis, associa o valor a variavel, e quanda-a na tabela de simbolos
//INT variable declaration
var_declaration: INT_TYPE ID ASSIGN INT { 
    struct SymbolTable symbol;
    symbol.name = strdup($2);
    symbol.intValue = $4;
    symbol.type = INT_TYPE; // Add this line
    symbol_table[symbol_count] = symbol;
    symbol_count++;
}
//FLOAT variable declaration
    | FLOAT_TYPE ID ASSIGN FLOAT { 
    struct SymbolTable symbol;
    symbol.name = strdup($2);
    symbol.floatValue = $4;
    symbol.type = FLOAT_TYPE; // Add this line
    symbol_table[symbol_count] = symbol;
    symbol_count++;
}
//char variable decalaration
    | CHAR_TYPE ID ASSIGN CHAR { 
    struct SymbolTable symbol;
    symbol.name = strdup($2);
    symbol.charValue = $4;
    symbol.type = CHAR_TYPE; // Add this line
    symbol_table[symbol_count] = symbol;
    symbol_count++;
}
//string variable declaration
    | STRING_TYPE ID ASSIGN STRING {
    struct SymbolTable symbol;
    symbol.name = strdup($2);
    symbol.stringValue = strdup($4);
    symbol.type = STRING_TYPE; // Add this line
    symbol_table[symbol_count] = symbol;
    symbol_count++;
    }
;

expr_int_variable_lookup: INT { $$ = $1; }

    | ID { // Variable lookup
        int found = 0;
        for (int i = 0; i < symbol_count; ++i) {
            if (symbol_table[i].name != NULL && strcmp(symbol_table[i].name, yytext) == 0) {
                $$ = symbol_table[i].intValue;
                found = 1;
                break;
            }
        }
        if (!found) {
            fprintf(stderr, "Variable '%s' not found\n", yytext);
            exit(EXIT_FAILURE);
        }
    }
    | CHAR { $$ = $1; }
    | expr_int_variable_lookup ADD expr_int_variable_lookup { $$ = $1 + $3; } 
    | expr_int_variable_lookup SUB expr_int_variable_lookup { $$ = $1 - $3; } 
    | expr_int_variable_lookup MUL expr_int_variable_lookup { $$ = $1 * $3; } 
    | expr_int_variable_lookup DIV expr_int_variable_lookup { if($3 != 0) $$ = $1 / $3; else yyerror("division by zero"); } 
    | expr_int_variable_lookup MOD expr_int_variable_lookup { $$ = $1 % $3; } 
    | LPAREN expr_int_variable_lookup RPAREN { $$ = $2; } 
    ;

expr_float_variable_lookup: FLOAT { $$ = $1; if($$ == INFINITY || $$ == -INFINITY ) yyerror("float overflow");}
    | ID { // Variable lookup
        int found = 0;
        for (int i = 0; i < symbol_count; ++i) {
            if (symbol_table[i].name != NULL && strcmp(symbol_table[i].name, yytext) == 0) {
                $$ = symbol_table[i].floatValue;
                found = 1;
                break;
            }
        }
        if (!found) {
            fprintf(stderr, "Variable '%s' not found\n", yytext);
            exit(EXIT_FAILURE);
        }
    }
    
    | CHAR { $$ = $1; }
    | expr_float_variable_lookup ADD expr_float_variable_lookup { $$ = $1 + $3; }
    | expr_float_variable_lookup SUB expr_float_variable_lookup { $$ = $1 - $3; } 
    | expr_float_variable_lookup MUL expr_float_variable_lookup { $$ = $1 * $3; } 
    | expr_float_variable_lookup DIV expr_float_variable_lookup { if($3 != 0) $$ = $1 / $3; else yyerror("division by zero"); } 
    | LPAREN expr_float_variable_lookup RPAREN { $$ = $2; } // Handle parentheses in floating-point numbers
    ;

expr_char_variable_lookup: CHAR { $$ = $1; }
    | ID {
        int found = 0;
        for (int i = 0; i < symbol_count; ++i) {
            if (symbol_table[i].name != NULL && strcmp(symbol_table[i].name, $1) == 0) {
                if (symbol_table[i].type == CHAR_TYPE) {
                    $$ = symbol_table[i].charValue;
                    found = 1;
                    break;
                } else {
                    fprintf(stderr, "Variable '%s' is not of type CHAR\n", $1);
                    exit(EXIT_FAILURE);
                }
            }
        }
        if (!found) {
            fprintf(stderr, "Variable '%s' not found\n", $1);
            exit(EXIT_FAILURE);
        }
    }
    | expr_char_variable_lookup ADD expr_char_variable_lookup { $$ = $1 + $3; } 
    | expr_char_variable_lookup SUB expr_char_variable_lookup { $$ = $1 - $3; } 
    | expr_char_variable_lookup MUL expr_char_variable_lookup { $$ = $1 * $3; } 
    | expr_char_variable_lookup DIV expr_char_variable_lookup { if($3 != 0) $$ = $1 / $3; else yyerror("division by zero"); } 
    | LPAREN expr_char_variable_lookup RPAREN { $$ = $2; } 
    ;

expr_string_variable_lookup: STRING {
    $$ = $1;
}
| ID {
    int found = 0;
    for (int i = 0; i < symbol_count; ++i) {
        if (symbol_table[i].name != NULL && strcmp(symbol_table[i].name, $1) == 0) {
            if (symbol_table[i].type == STRING_TYPE) {
                $$ = strdup(symbol_table[i].stringValue);
                found = 1;
                break;
            } else {
                fprintf(stderr, "Variable '%s' is not of type STRING\n", $1);
                exit(EXIT_FAILURE);
            }
        }
    }
    if (!found) {
        fprintf(stderr, "Variable '%s' not found\n", $1);
        exit(EXIT_FAILURE);
    }
}
| expr_string_variable_lookup ADD expr_string_variable_lookup { /* Handle concatenation */ }
| LPAREN expr_string_variable_lookup RPAREN { $$ = $2; }
;


%%

void yyerror(const char *msg) {
    fprintf(stderr, "Parser Error at line %d, near '%s' %s\n", yylineno, yytext, msg);
    exit(EXIT_FAILURE);
}

int main() {
    yyparse();
    return 0;
}