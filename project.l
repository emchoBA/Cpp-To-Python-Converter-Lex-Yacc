
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
"=="	{ return EQ; }
"!="	{ return NEQ; }
"<"	{ return LT; }
"<="	{ return LTE; }
">"	{ return GT; }
">="	{ return GTE;}
[a-zA-Z]*[0-9]*	{ return VAR; }
\n	
[ \t]+
%%
