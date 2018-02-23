%{
#include "heading.h"
int yyerror (char* s);
int yylex (void);
%}

%union{
int val;
string* op_val;
}
%start	program

%token	FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA LPAREN RPAREN LSQUARE RSQUARE ASSIGN RETURN
%token <val> NUMBER
%token <op_val> IDENTIFIER
%left MULT DIV MOD ADD SUB 
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN

%%


program: 	functions { cout << "program -> functions" << endl;}
	 	;

functions:	functions function {cout << "functions -> function functions" << endl;}
		| {cout << "function -> epsilon" << endl;}
		;

function:	FUNCTION IDENTIFIER SEMICOLON BEGINPARAMS dec ENDPARAMS BEGINLOCALS dec ENDLOCALS BEGINBODY state2help1 ENDBODY {cout << "FUNCTION IDENT " <<*($2)<<" SEMICOLON BEGIN_PARAMS dec END_PARAMS BEGIN_LOCALS dec END_LOCALS BEGIN_BODY state2help1 END_BODY" << endl;}
		;  

dec:		declaration SEMICOLON dec {cout << "dec -> declaration SEMICOLON dec" << endl;}
		| {cout << "dec -> epsilon" << endl;}
		;

declaration:	dec1 COLON dec2 {cout << "dec1 COLON dec2" << endl;}
		;

dec1: 		IDENTIFIER COMMA dec1 {cout << "dec1 -> IDENTIFIER COMMA dec1" << endl;}
		| IDENTIFIER {cout << "dec1 ->IDENTIFIER" << endl;}
		;

dec2:		ARRAY LSQUARE NUMBER RSQUARE OF INTEGER {cout << "dec2 -> ARRAY LSQUARE NUMBER RSQUARE OF INTEGER" << endl;}
		| INTEGER {cout << "dec2 -> INTEGER" << endl;}
		;

statement:	statement1 {cout << "statement -> statement1" << endl;}
		| statement2 {cout << "statement -> statement2" << endl;}
		| statement3 {cout << "statement -> statement3" << endl;}
		| statement4 {cout << "statement -> statement4" << endl;}
		| statement5 {cout << "statement -> statement5" << endl;}
		| statement6 {cout << "statement -> statement6" << endl;}
		| statement7 {cout << "statement -> statement7" << endl;}
		| statement8 {cout << "statement -> statement8" << endl;}
		| statement9 {cout << "statement -> statement9" << endl;}
		;

statement1:	var ASSIGN expression {cout << "statement1 -> var ASSIGN expression" << endl;}
		;

statement2:	IF bool_exp THEN state2help1 state2help2 ENDIF {cout << "statement2 -> IF bool_exp state2help1 state2help2 ENDIF" << endl;}
		;

state2help1:	statement SEMICOLON state2help1 {cout << "state2help1 -> statement SEMICOLON state2help1" << endl;}
		| statement SEMICOLON {cout << "state2help1 -> statement SEMICOLON" << endl;}
		;

state2help2:	ELSE state2help1 {cout << "state2help2 -> ELSE state2help1" << endl;}
		| {cout << "state2help2 -> epsilon" << endl;}
		;

statement3:	WHILE bool_exp BEGINLOOP state2help1 ENDLOOP {cout << "statement3 -> WHILE bool_exp BEGINLOOP state2help1 ENDLOOOP" << endl;}
		;

statement4: 	DO BEGINLOOP state2help1 ENDLOOP WHILE bool_exp { cout << "statement4 -> DO BEGINLOOP state2help1 ENDLOOP WHILE bool_exp" << endl;}
		;

statement5: 	FOREACH IDENTIFIER IN IDENTIFIER BEGINLOOP state2help1 ENDLOOP {cout << "statement5 -> FOREACH IDENTIFIER IN IDENTIFIER BEGINLOOP state2help1 ENDLOOP" << endl;}
		;

statement6:	READ var state6help {cout << "statement6 -> READ var state6help" << endl;}
		;

state6help:	COMMA var state6help {cout << "state6help -> COMMA var state6help" << endl;}
		| {cout << "state6help -> epsilon" << endl;}
		;

statement7:	WRITE var state6help {cout << "statement7 -> WRITE var state6help" << endl;}
		;

statement8:	CONTINUE {cout << "statement8 -> CONTINUE" << endl;}
		;

statement9:	RETURN expression {cout << "statement9 -> RETURN expression" << endl;}
		;

bool_exp:	relation_and_expr orHelper {cout << "bool_exp -> relation_and_expr orHelper" << endl;}

orHelper:	OR relation_and_expr orHelper {cout << "orHelper -> OR relation_and_exper orHelper" << endl;}
		| {cout << "orHelper -> epsilon" << endl;}
		;

relation_and_expr:	relationExprHelper {cout << "relation_and_expr -> relationExprHelper" << endl;}
			| NOT relationExprHelper {cout << "relation_and_expr -> NOT relationExprHelper" << endl;}
			;

relationExprHelper:	expression comp expression {cout << "relationExprHelper -> expression comp expression" << endl;}
			| TRUE {cout << "relationExprHelper -> TRUE" << endl;}
			| FALSE {cout << "relationExprHelper -> FALSE" << endl;}
			| LPAREN bool_exp RPAREN {cout << "relationExprHelper -> LPAREN bool_exp RPAREN" << endl;}
			;

comp:		EQ {cout << "comp -> EQ" << endl;}
		| NEQ {cout << "comp -> NEQ" << endl;}
		| LT {cout << "comp -> LT" << endl;}
		| GT {cout << "comp -> GT" << endl;}
		| LTE {cout << "comp -> LTE" << endl;}
		| GTE {cout << "comp -> GTE" << endl;}
		;

expression:	multiplicative_expr multExprHelper {cout << "expression -> multiplicative_expr multExprHelper" << endl;}
		;

multExprHelper:	ADD multiplicative_expr multExprHelper {cout << "ADD multiplicative_expr multExprHelper" << endl;}
		| SUB multiplicative_expr multExprHelper {cout << "SUB multiplicative_expr multExprHelper" << endl;}
		| {cout << "multExprHelper -> epsilon" << endl;}
		;

multiplicative_expr:	term termHelper {cout << "multiplicative_expr -> term termHelper" << endl;}
			;

termHelper:	MULT term termHelper {cout << "termHelper -> MULT term termHelper" << endl;}
		| DIV term termHelper {cout << "termHelper -> DIV term termHelper" << endl;}
		| MOD term termHelper {cout << "termHelper -> MOD term termHelper" << endl;}
		| {cout << "termHelper -> epsilon" << endl;}
		;

term:		identifierTerm {cout << "term -> idtentifierTerm" << endl;}
		| varTerm {cout << "term -> varTerm" << endl;}
		| SUB varTerm {cout << "term -> SUB varTerm" << endl;}
		;

identifierTerm: IDENTIFIER LPAREN identifierHelp RPAREN {cout << "IDENTIFIER " << *($1) << " LPAREN identifierHelp RPAREN" << endl;}
		;

identifierHelp: expression COMMA identifierHelp {cout << "identifierHelp -> expression COMMA identifierHelp" << endl;}
		| expression {cout << "identifierHelp -> expression" << endl;}

varTerm: 	var {cout << "varTerm -> var" << endl;}
		| NUMBER {cout << "varTerm -> NUMBER " << $1  << endl;}
		| LPAREN expression RPAREN {cout << "varTerm -> LPAREN expression RPAREN" << endl;}
		;

var:		IDENTIFIER {cout << "var -> IDENTIFIER " << *($1) << endl;}
		| IDENTIFIER LSQUARE expression RSQUARE {cout << "var -> IDENTIFIER " << *($1) << " LSQUARE expression RSQUARE" << endl;}
		;  
%%

int yyerror(string s)
{
  extern int row, column;
  extern char *yytext;		
  
  cerr << "Error at line "<<row<<", column "<<column<<"  Unexpected Symbol: \""<<yytext<<"\""<<endl;
  exit(1);
}
int yyerror(char *s)
{
  return yyerror(string(s));
}
