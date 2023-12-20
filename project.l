
%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #include <iostream>
  using namespace std;
  extern int yylval;
%}
%%
"+"	{ return ADD; }
"-"	{ return SUB; }
"/"	{ return DIV; }
"*"	{ return MUL; }
"If"	{ return IF; }
"if"	{ return IF; }
"elif"	{ return ELIF; }
"else"	{ return ELSE; }
":"	{ return FUNC; }
"=="	{ return EQ; }
"!="	{ return NEQ; }
"<"	{ return LT; }
"<="	{ return LTE; }
">"	{ return GT; }
">="	{ return GTE; }
"="	{ return EQUAL; }
[a-zA-Z]*[0-9]*	{ return IDENT; }
\n	
[ \t]+
%%
