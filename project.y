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
%token ADD SUB DIV MUL IF ELIF ELSE EQ NEQ LT LTE GT GTE VAR

%%
program: statement_list


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
