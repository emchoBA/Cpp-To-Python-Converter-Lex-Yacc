%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);
%}
%token ADD SUB DIV MUL FUNC IF ELIF ELSE EQ NEQ LT LTE GT GTE IDENT EQUAL

%%
program: line_list

line_list: line | line line_list

line: if_line | var_line

if_line: IF IDENT operator IDENT FUNC

var_line: IDENT EQUAL var

var: IDENT | IDENT operator var | IDENT comparison var

statement: IF | ELIF | ELSE

operator: ADD | SUB | DIV | MUL

comparison: EQ | NEQ | LT | LTE | GT | GTE


%%
void yyerror(string s){
	cerr<<"Error at line: "<<linenum<<endl;

}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}
