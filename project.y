%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <map>
	#include <vector>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);
	extern int linenum;
	int tab_count = 1;
	int if_count = 0; 
	map<string,int> types; // 0 = string, 1 = int, 2 = float
	vector<string> strings;
	vector<string> ints;
	vector<string> floats;
	string cpp = "void main()\n{\n";
	string print;
	int tab_check = -2;
	int sum = 0;
	string invalid;
	int is_there_else = 0;
	int is_there_if = 0;
	int else_int;
	int tab_liner = 0;
	
%}

%union
{
	struct asdas{
		char * name;
		int type;
	};

	char * str;
	asdas var;
	
}
%token ADD SUB DIV MUL FUNC IF ELIF ELSE EQ NEQ LT LTE GT GTE EQUAL TAB QUOTE
%token <str> STRING INTEGER FLOAT
%type <var> var_def values declare
%type <str> operation compare


%%
program: statement_list { 
		if(ints.empty() != true){
			cpp += "\tint ";
			for(int i = 0; i < ints.size(); i++){
				cpp += ints.at(i) + ",";
			}
			cpp.pop_back();
			cpp += ";\n";
		}
		if(floats.empty() != true){
			cpp += "\tfloat ";
			for(int i = floats.size() - 1; i > -1; i--){
				cpp += floats.at(i) + ",";
			}
			cpp.pop_back();
			cpp += ";\n";
		}
		if(strings.empty() != true){
			cpp += "\tstring ";
			for(int i = strings.size() - 1; i > -1; i--){
				cpp += strings.at(i) + ",";
			}
			cpp.pop_back();
			cpp += ";\n";
		}
		cpp += "\n" + print + "}\n";
		if(!invalid.empty())	{ cout<<invalid;}
		else	{ cout<<cpp;}
 
	}

statement_list: statement | statement statement_list 

statement: decl_statement 
	| if_statement 
	| nested_statement { 

		tab_liner = 0;
		if(tab_check >= tab_count){ 
			string error = "tab inconsistency in line ";
			invalid += error + to_string(linenum) + "\n";
		}

		
		
		if(tab_check < if_count){
			int dif = if_count - tab_check;
			int counter = 0;
			
			while(counter < dif){
				string temp;
				if_count--;
				tab_count--;
				for(int i = 0; i < tab_count; i++){
					temp += "\t";
				}
				temp += "}\n";
				print += temp;
				
				counter++;
			}
		}

		if(if_count == else_int - 1)	{ is_there_else = 0; }
		if(if_count == 0)	{ is_there_if = 0; }
		sum = 0;
		tab_check = -1;
	}

if_statement: if_open	
	| else_open	
	| elif_open	

if_open: IF values compare values FUNC {
	tab_count += 1;
	if_count += 1;
	
	if(tab_liner == 1){
		string temp = "error in line " + to_string(linenum) + ": at least one line should be inside if/elif/else block\n";
		invalid += temp;
	}
	
	if(tab_check == -1 || tab_check == -2)	{ tab_liner = 1; }

	string temp;
	string temp2;
	is_there_if = 1;
	
	if(($2.type == 0 && $4.type != 0) || ($2.type != 0 && $4.type == 0)){
		string temp = "comparison type mismatch in line " + to_string(linenum) + "\n";
		invalid += temp;
	}
	
	for(int i = 0; i < tab_count - 1; i++){
		temp += "\t";
		temp2 += "\t";
	}
	temp += "if( " + string($2.name) + " " + string($3) + " " + string($4.name) + " )\n";
	temp2 += "{\n";
	print += temp + temp2;

	}

else_open: ELSE FUNC {
	tab_count += 1;
	if(tab_liner == 1){
		string temp = "error in line " + to_string(linenum) + ": at least one line should be inside if/elif/else block\n";
		invalid += temp;
	}	

	if(tab_check == -1 || tab_check == -2)	{ tab_liner = 1; }
	
	else_int = if_count;
	is_there_else = 1;
	string temp;
	string temp2;

	if(is_there_if == 0){
		string temp = "else without if in line " + to_string(linenum) + "\n";
		invalid += temp;
	}

	if_count++;

	for(int i = 0; i < tab_count - 1; i++){
		temp += "\t";
		temp2 += "\t";
	}
	temp += "else\n";
	temp2 += "{\n";
	print += temp + temp2;

	}	

elif_open: ELIF values compare values FUNC {
	tab_count += 1;
	if_count++;
	string temp;
	string temp2;
	
	if(tab_liner == 1){
		string temp = "error in line " + to_string(linenum) + ": at least one line should be inside if/elif/else block\n";
		invalid += temp;
	}
	
	if(tab_check == -1 || tab_check == -2)	{ tab_liner = 1; }

	if(($2.type == 0 && $4.type != 0) || ($2.type != 0 && $4.type == 0)){
		string temp = "comparison type mismatch in line " + to_string(linenum) + "\n";
		invalid += temp;
	}

	if(is_there_else == 1){
		string temp = "elif after else in line " + to_string(linenum) + "\n";
		invalid += temp;
		
	}
	

	for(int i = 0; i < tab_count - 1; i++){
		temp += "\t";
		temp2 += "\t";
	}
	temp += "else if( " + string($2.name) + " " + string($3) + " " + string($4.name) + " )\n";
	temp2 += "{\n";
	print += temp + temp2;

	}

nested_statement: TAB {sum++; tab_check = sum; }
	| TAB nested_statement	{sum++; tab_check = sum; }

decl_statement: STRING EQUAL declare	{ 

		types[$1] = $3.type; 
		int inVec = 0;
		
		
		if(tab_check == -2 && if_count != 0)	{
			string error = "error in line " + to_string(linenum) + ": at least one line should be inside if/elif/else block\n";
			invalid += error;
		}




		if(tab_count == 1)	{ is_there_if = 0;}
		if(tab_check == -1 && if_count == 1 && tab_count == 2 ){
			
		if(tab_liner == 1)	{
			string temp = "error in line " + to_string(linenum) + ": at least one line should be inside if/elif/else block\n";
			invalid += temp;
		}
		if($3.type == 0){
			for(int i = 0; i < tab_count; i++){
				print += "\t";
			}
			string temp;
			print += string($1)+ "_str" + " = \"" + string($3.name) + "\";\n";
			temp = string($1) + "_str";
			
			tab_count--;
			if_count--;
			print += "\t}\n";

			for(int i = 0; i < strings.size(); i++){
				if(strings.at(i) == temp){
					inVec = 1;
					break;	
				}
			}
			if(inVec == 0){
				strings.push_back(temp); 
			}
			
		}
		if($3.type == 1){
			for(int i = 0; i < tab_count; i++){
				print += "\t";
			}
			string temp;
			print += string($1)+ "_int" + " = " + string($3.name) + ";\n"; 
			temp = string($1) + "_int";
			
			tab_count--;
			if_count--;
			print += "\t}\n";
	
			for(int i = 0; i < ints.size(); i++){
				if(ints.at(i) == temp){
					inVec = 1;
					break;	
				}
			}
			if(inVec == 0){
				ints.push_back(temp); 
			}
			 
		}
		if($3.type == 2){
			for(int i = 0; i < tab_count; i++){
				print += "\t";
			}
			string temp;
			print += string($1)+ "_flt" + " = " + string($3.name) + ";\n"; 
			temp = string($1) + "_flt";

			tab_count--;
			if_count--;
			print += "\t}\n";

			for(int i = 0; i < floats.size(); i++){
				if(floats.at(i) == temp){
					inVec = 1;
					break;	
				}
			}
			if(inVec == 0){
				floats.push_back(temp); 
			}
			 
		}
		
		}
		

		
		else{
		if($3.type == 0){
			for(int i = 0; i < tab_count; i++){
				print += "\t";
			}
			string temp;
			print += string($1)+ "_str" + " = \"" + string($3.name) + "\";\n";
			temp = string($1) + "_str";
			
			for(int i = 0; i < strings.size(); i++){
				if(strings.at(i) == temp){
					inVec = 1;
					break;	
				}
			}
			if(inVec == 0){
				strings.push_back(temp); 
			}
			
		}
		if($3.type == 1){
			for(int i = 0; i < tab_count; i++){
				print += "\t";
			}
			string temp;
			print += string($1)+ "_int" + " = " + string($3.name) + ";\n"; 
			temp = string($1) + "_int";
	
			for(int i = 0; i < ints.size(); i++){
				if(ints.at(i) == temp){
					inVec = 1;
					break;	
				}
			}
			if(inVec == 0){
				ints.push_back(temp); 
			}
			 
		}
		if($3.type == 2){
			for(int i = 0; i < tab_count; i++){
				print += "\t";
			}
			string temp;
			print += string($1)+ "_flt" + " = " + string($3.name) + ";\n"; 
			temp = string($1) + "_flt";

			for(int i = 0; i < floats.size(); i++){
				if(floats.at(i) == temp){
					inVec = 1;
					break;	
				}
			}
			if(inVec == 0){
				floats.push_back(temp); 
			}
			 
		}
		}
		if(if_count == else_int - 1)	{ is_there_else = 0; }
		
	}

declare: QUOTE var_def QUOTE	{ $$.type = 0; $$.name = $2.name;  }
	| var_def	{ $$.type = $1.type; $$.name = $1.name; }

var_def: values { $$.name = $1.name; $$.type = $1.type; }
	| values operation var_def 
		{ if($1.type == $3.type)
			{ 
				$$.type = $1.type; 
				string temp = string($1.name) + " " + $2 + " " + string($3.name);
				$$.name = strdup(temp.c_str());
			}
		else if($1.type != 0 && $3.type != 0)
			{
				$$.type = 2; 
				string temp = string($1.name) + " " + $2 + " " + string($3.name);
				$$.name = strdup(temp.c_str());
			}
		else {
			string temp = "type mismatch in line " + to_string(linenum) + "\n";
			invalid += temp;
		}
		}

values: STRING	{ if(types[string($1)] != NULL){ 
			$$.type = types[string($1)];
			if(types[string($1)] == 1){
				string temp = string($1) + "_int";
				$$.name = strdup(temp.c_str());
			}
			if(types[string($1)] == 2){
				string temp = string($1) + "_flt";
				$$.name = strdup(temp.c_str());
			}	
		}
			else{ $$.type = 0;
			$$.name = strdup(string($1).c_str());  } 
		}
	| INTEGER	{ $$.name = strdup(string($1).c_str()); $$.type = 1; }
	| FLOAT	{ $$.name = strdup(string($1).c_str()); $$.type = 2; }

operation: MUL	{ $$ = strdup(string("*").c_str()); }
	| ADD	{ $$ = strdup(string("+").c_str()); }
	| SUB	{ $$ = strdup(string("-").c_str()); }
	| DIV	{ $$ = strdup(string("/").c_str()); }

compare: EQ	{ $$ = strdup(string("=").c_str()); }
	| NEQ	{ $$ = strdup(string("!=").c_str()); }
	| LT	{ $$ = strdup(string("<").c_str()); }
	| LTE	{ $$ = strdup(string("<=").c_str()); }
	| GT	{ $$ = strdup(string(">").c_str()); }
	| GTE	{ $$ = strdup(string(">=").c_str()); }

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
