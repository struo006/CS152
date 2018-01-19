%{
#include<unistd.h>
int lineNum = 1, currPost = 0;
%}
COMMENT [##].*
DIGIT [0-9]
WRONG [0-9_][a-zA-Z0-9_]+
WRONG2 [a-zA-Z0-9]*[_]
IDENTIFIER [a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]*
%%
{COMMENT}	;
function	printf("FUNCTION\n"); currPost += yyleng;
beginparams	printf("BEGIN_PARAMS\n"); currPost += yyleng;
endparams	printf("END_PARAMS\n");currPost += yyleng;
beginlocals	printf("BEGIN_LOCALS\n");currPost += yyleng;
endlocals	printf("END_LOCALS\n"); currPost += yyleng;
beginbody	printf("BEGIN_BODY\n"); currPost += yyleng;
endbody		printf("END_BODY\n"); currPost += yyleng;
integer		printf("INTEGER\n"); currPost += yyleng;
array		printf("ARRAY\n"); currPost += yyleng;
of		printf("OF\n"); currPost += yyleng;
if		printf("IF\n"); currPost += yyleng;
then		printf("THEN\n"); currPost += yyleng;
endif		printf("ENDIF\n"); currPost += yyleng;
else		printf("ELSE\n"); currPost += yyleng;
while		printf("WHILE\n"); currPost += yyleng;
do		printf("DO\n"); currPost += yyleng;
foreach		printf("FOREACH\n"); currPost += yyleng;
in		printf("IN\n"); currPost += yyleng;
beginloop	printf("BEGINLOOP\n"); currPost += yyleng;
endloop		printf("ENDLOOP\n"); currPost += yyleng;
continue	printf("CONTINUE\n"); currPost += yyleng;
read		printf("READ\n"); currPost += yyleng;
write		printf("WRITE\n"); currPost += yyleng;
and		printf("AND\n"); currPost += yyleng;
or		printf("OR\n"); currPost += yyleng;
not		printf("NOT\n"); currPost += yyleng;
true		printf("TRUE\n"); currPost += yyleng;
false		printf("FALSE\n"); currPost += yyleng;
return		printf("RETURN\n"); currPost += yyleng;
"-"		printf("SUB\n"); currPost += yyleng;
"+"		printf("ADD\n"); currPost += yyleng;
"*" 		printf("MULT\n"); currPost += yyleng;
"/"		printf("DIV\n"); currPost += yyleng;
"%"		printf("MOD\n"); currPost += yyleng;
"=="		printf("EQ\n"); currPost += yyleng;
"<>"		printf("NEQ\n"); currPost += yyleng;
"<" 		printf("LT\n"); currPost += yyleng;
">"		printf("GT\n"); currPost += yyleng;
"<="		printf("LTE\n"); currPost += yyleng;
">="		printf("GTE\n"); currPost += yyleng;

{DIGIT}+ 	printf("NUMBER %s\n", yytext); currPost += yyleng;
{WRONG}		currPost += yyleng; printf("invalid identifier should not start with a number or underscore line:%d position:%d\n",lineNum, currPost); exit(0);
{WRONG2}	currPost += yyleng; printf("invalid identifier should not end with underscore line:%d position:%d\n",lineNum, currPost); exit(0);
{IDENTIFIER}	printf("IDENT %s\n", yytext); currPost += yyleng;


";"		printf("SEMICOLON\n"); currPost += yyleng;
":"		printf("COLON\n"); currPost += yyleng;
","		printf("COMMA\n"); currPost += yyleng;
"("		printf("L_PAREN\n"); currPost += yyleng;
")"		printf("R_PAREN\n"); currPost += yyleng;
"["		printf("L_SQUARE_BRACKET\n"); currPost += yyleng;
"]"		printf("R_SQUARE_BRACKET\n"); currPost += yyleng;
":="		printf("ASSIGN\n"); currPost += yyleng;
[ \t]+	;
[\n]		++lineNum; currPost = 1;
.		exit(0);

%%

int main(int argc, char** argv) {
	++argv, --argc;
	if(argc > 0 ) 
		yyin = fopen(argv[0],"r");
	else
		yyin = stdin;
	yylex();
}
