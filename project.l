
%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #include <iostream>
  using namespace std;
  int linenum=1;
%}

DIGIT [0-9]
INTEGER [-]*{DIGIT}+
FLOAT [-]*{DIGIT}+"."{DIGIT}+

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
["]	{ return QUOTE; }
[\t]	{ return TAB; }
{INTEGER}	{ yylval.str = strdup(yytext);	return INTEGER; }
{FLOAT}	{ yylval.str = strdup(yytext);	return FLOAT; }
[a-zA-Z]+	{ yylval.str = strdup(yytext);	return STRING; }
\n	{linenum++; }
.

%%
