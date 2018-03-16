%{
#include "heading.h"

//global
int yyerror (char* s);
int yylex (void);
int tmpcount = 0;
int lblcount = 0;
int paramVal = 0;
ofstream out_stream;

const char* tok[] = {"chicken","function","beginparams","endparams","beginlocals","endlocals","beginbody","integer","array",
						"of","if","then","endif","else","while","do","foreach","in","beginloop","endloop","continue",
						"read","write","true","false","semicolon","colon","comma","lparen","rparen","lsquare","rsquare",
						"assign","return"};
						
vector<string> tokens(tok, tok + 33); 

bool param_open = false;
bool error = false;

stringstream ss;

// structures
vector <string> param_vector;
vector <string> function_vector;
vector <string> identifier_vector;
vector <string> identifier_type_vector;
vector <string> operands;
vector <string> statement_vector;

vector <vector <string> > if_label_vector;
vector <vector <string> > loop_label_vector;
vector <vector <string> > for_loop_label_vector;

stack <string> param_stack;
stack <string> read_stack;


//functions
string genTmpVar();
string genLblVar();
bool unDeclaredVariable(string);
bool wasDeclared(string);
bool mainExists(vector<string>);
bool arrSizeZero(int);
bool functionNotDeclared(string);
bool usingReservedKeyword(string, vector<string>);
bool isArrayUsedAsNotArray(string);
bool isNotArrayUsedAsArray(string);
bool usedContinueOutsideOfLoop(vector <vector <string> >);

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


program: 	functions
			{
				out_stream.close();
				if(!mainExists(function_vector)) {
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();
            	}
			}
	 	;	

functions:	functions function
		|
		;

function_help: FUNCTION IDENTIFIER
		{
			// out_stream.open("test1.mil", fstream::app);
			if(!out_stream.is_open()) {
				if(!error)
				{
					out_stream.open("test1.mil");
				}
			}
			
			function_vector.push_back(*($2));
			cout << "func " << *($2) << endl;
			out_stream << "func " << *($2) << endl;
		}
		
beginparam: BEGINPARAMS
			{ param_open = true;}
			;

endparam:	ENDPARAMS
			{ param_open = false;}
			;

function:	function_help SEMICOLON beginparam dec endparam BEGINLOCALS dec ENDLOCALS BEGINBODY state2help1 ENDBODY
			{
				// 	int num_param = 0;
				// 	for(int i=0; i < identifier_vector.size(); i++)
				// 	{
				// 		// identifier_type_vector.at(i) = INTEGER if int or N from [N] if array
				// 		if(identifier_type_vector.at(i) == "INTEGER"){
				// 			cout<<". " << identifier_vector.at(i) << endl;
				// 			out_stream<<". " << identifier_vector.at(i) << endl;
				// 		}
				// 		else{	// would be an array
				// 			cout <<".[] "<< identifier_vector.at(i)<< ", " << identifier_type_vector.at(i) <<endl;
				// 			out_stream <<".[] "<< identifier_vector.at(i)<< ", " << identifier_type_vector.at(i) <<endl;
				// 		}
				// 	}
				// 	identifier_vector.clear();
				// 	identifier_type_vector.clear();
				// 	while(!param_vector.empty())
				// 	{
				// 		string paramVecFront = param_vector.front();
				// 		cout << "= " << paramVecFront<< ", $" << num_param << endl;
				// 		out_stream<< "= " << paramVecFront<< ", $" << num_param << endl;
				// 		param_vector.erase(param_vector.begin());
				// 		num_param++;
				// 	} 
				// for(int i=0;i<statement_vector.size();i++)
				// {
    //             	cout<<statement_vector.at(i)<<endl;
				// }
	            cout << "endfunc" << endl;
	            out_stream << "endfunc" << endl;
				identifier_vector.clear();
            	identifier_type_vector.clear();	            
	            statement_vector.clear();
	            param_vector.clear();
				if(error) {
            	out_stream.open("test1.mil", ofstream::trunc);
            	out_stream.close();
            	}
			}
		;  

dec:		declaration SEMICOLON dec
		|
		;

declaration:	dec1 COLON dec2 
				{
					int num_param = 0;
					for(int i=0; i < identifier_vector.size(); i++)
					{
						// identifier_type_vector.at(i) = INTEGER if int or N from [N] if array
						if(identifier_type_vector.at(i) == "INTEGER"){
							cout<<". " << identifier_vector.at(i) << endl;
							out_stream<<". " << identifier_vector.at(i) << endl;
						}
						else{	// would be an array
							cout <<".[] "<< identifier_vector.at(i)<< ", " << identifier_type_vector.at(i) <<endl;
							out_stream <<".[] "<< identifier_vector.at(i)<< ", " << identifier_type_vector.at(i) <<endl;
						}
					}
					while(!param_vector.empty())
					{
						string paramVecFront = param_vector.front();
						cout << "= " << paramVecFront<< ", $" << num_param << endl;
						out_stream<< "= " << paramVecFront<< ", $" << num_param << endl;
						param_vector.erase(param_vector.begin());
						num_param++;
					}					
				}
		;

dec1: 	IDENTIFIER COMMA dec1 
			{
				string temp = "_"+ *($1);
				if(wasDeclared(temp))
				{
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();					
				}
				// ~~~~~~~~~ CHECK DIS ~~~~~~~~~~ //
				if(usingReservedKeyword(*($1), tokens)){
					error = true;
					out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();	
				}
				string int_type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(int_type);
			}
		| IDENTIFIER 
			{
				string temp = "_" + *($1);
				if(wasDeclared(temp))
				{
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();						
				}
				if(usingReservedKeyword(*($1), tokens)){
					error = true;
					out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();	
				}
				identifier_vector.push_back(temp);
				if(param_open){
					param_vector.push_back(temp);
				}
			}
		;

dec2:	ARRAY LSQUARE NUMBER RSQUARE OF INTEGER 
			{
				stringstream num;
				num << $3;
				int temps = ($3);
				if(arrSizeZero(temps)){
					error = true;
				}
				string tempSpace = num.str();
				identifier_type_vector.push_back(num.str());
			}
		| INTEGER
			{
				string int_type = "INTEGER";
				identifier_type_vector.push_back(int_type);
			}
		;

statement:	statement1
		| statement2
		| statement3
		| statement4
		| statement5
		| statement6
		| statement7
		| statement8
		| statement9
		;

statement1:	IDENTIFIER ASSIGN expression 
			{
				string temp = "_" + *($1);
				string identifier_statement = "= " + temp + ", " + operands.at(operands.size() - 1);
				if(isArrayUsedAsNotArray(temp))
				{
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();					
				}
				if(unDeclaredVariable(temp))
				{
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();					
				}
				statement_vector.push_back(identifier_statement);
				cout << identifier_statement << endl;
				out_stream << identifier_statement << endl;
				operands.pop_back();
			}
		|	IDENTIFIER LSQUARE expression RSQUARE ASSIGN expression 
			{
				string array_name = "_" + *($1);
				string array_source = operands.at(operands.size() - 1);
				operands.pop_back();
				string array_index = operands.at(operands.size() - 1);
				operands.pop_back();
				if(isNotArrayUsedAsArray(array_name))
				{
					error = true;
					out_stream.open("test1.mil", ofstream::trunc);
					out_stream.close();
				}
				string array_statement = "[]= " + array_name + ", " + array_index + ", " + array_source;
				statement_vector.push_back(array_statement);
				cout << array_statement << endl;
				out_stream << array_statement << endl;
			}
		;

statement2:	if_statement state2help1 ENDIF 
			{
				string if_end = ": " + if_label_vector.back().at(1);
				statement_vector.push_back(if_end);
				cout << if_end << endl;
				out_stream << if_end << endl;
				if_label_vector.pop_back(); // End of if statements
			}
		|	else_if_statement state2help1 ENDIF
			{
				string if_end = ": " + if_label_vector.back().at(2);
				statement_vector.push_back(if_end);
				cout << if_end << endl;
				out_stream << if_end << endl;
				if_label_vector.pop_back();
			}
		;

state2help1:	statement SEMICOLON state2help1
		| statement SEMICOLON
		;
		
else_if_statement:	if_statement state2help1 ELSE
					{
						string end_if_statement = ":= " + if_label_vector.back().at(2);
						statement_vector.push_back(end_if_statement);
						cout << end_if_statement << endl;
						out_stream << end_if_statement << endl;
						
						string else_if_declare_statement = ": " + if_label_vector.back().at(1);
						statement_vector.push_back(else_if_declare_statement);
						cout << else_if_declare_statement << endl;
						out_stream << else_if_declare_statement << endl;
					}
		;

if_statement:	IF bool_exp THEN
				{
					string temp = genLblVar();
					temp = temp;
					string if_true = "if_condition_true_" + temp;
		            string if_false = "if_condition_false_" + temp;
		            string end_if = "end_if_"  + temp;
		            
		            vector<string> label_statements;
		            label_statements.push_back(if_true);
		            label_statements.push_back(if_false);
		            label_statements.push_back(end_if);
		            if_label_vector.push_back(label_statements);
		            
		            string if_true_statement = "?:= " + if_true + ", " + operands.at(operands.size() - 1);
		            statement_vector.push_back(if_true_statement); // adds if_true label to statement vector
		            cout << if_true_statement << endl;
		            out_stream << if_true_statement << endl;
		            operands.pop_back();
		            
		            string if_false_statement = ":= " + if_false;
		            statement_vector.push_back(if_false_statement); // adds if_false label to statement vector
		            cout << if_false_statement << endl;
		            out_stream << if_false_statement << endl;
		            
		            string if_declare_statement = ": " + if_true;
		            statement_vector.push_back(if_declare_statement);// adds if_declare statment to statement vector
		            cout << if_declare_statement << endl;
		            out_stream << if_declare_statement << endl;
		            
		            // does declare > false > true in order so it prints out this way.
				}
		;

statement3:	while_start state2help1 ENDLOOP 
			{
				string while_loop_label = ":= " + loop_label_vector.back().at(0);
				string while_loop_end = ": " + loop_label_vector.back().at(2);
				statement_vector.push_back(while_loop_label);
				cout << while_loop_label << endl;
				out_stream << while_loop_label << endl;
				statement_vector.push_back(while_loop_end);
				cout << while_loop_end << endl;
				out_stream << while_loop_end << endl;
				loop_label_vector.pop_back();
			}
		;

while_start: while_statement bool_exp BEGINLOOP
			{
				string while_in = "?:= " + loop_label_vector.back().at(1) + ", " +  operands.at(operands.size() - 1);
				operands.pop_back();
				string while_end = ":= " + loop_label_vector.back().at(2);
				string while_start = ": " + loop_label_vector.back().at(1);
	
				statement_vector.push_back(while_in);
				statement_vector.push_back(while_end);
				statement_vector.push_back(while_start);
				cout << while_in << endl;
				out_stream << while_in << endl;
				cout << while_end << endl;
				out_stream << while_end << endl;
				cout << while_start << endl;
				out_stream << while_start << endl;
			}	
		;


while_statement: WHILE
				{
					string temp = genLblVar();
		            string while_loop = "while_loop" + temp;
		            string cond_true = "conditional_true" + temp;
		            string cond_false = "conditional_false" + temp; 
		            
		            vector<string> while_statements;
		            while_statements.push_back(while_loop);
		            while_statements.push_back(cond_true);
		            while_statements.push_back(cond_false);
		            
		            
		            loop_label_vector.push_back(while_statements);
		            string while_declare = ": " + while_loop;
		            statement_vector.push_back(while_declare);
		            cout << while_declare << endl;
		            out_stream << while_declare << endl;
				}
		;

statement4: do_check WHILE bool_exp 
			{
				string do_while_done = "?:= " + loop_label_vector.back().at(0) + ", " + operands.at(operands.size() - 1);
				cout << do_while_done << endl;
				out_stream << do_while_done << endl;
				statement_vector.push_back(do_while_done);
				operands.pop_back();
				loop_label_vector.pop_back();
			}
		;
		
		
do_check:	do_while state2help1 ENDLOOP
			{
				string do_while_cond_check = ": " + loop_label_vector.back().at(1); 
				statement_vector.push_back(do_while_cond_check);
				cout << do_while_cond_check << endl;
				out_stream << do_while_cond_check << endl;
				// makes the continue check declare
			}
	;


do_while:	DO BEGINLOOP
			{
				string temp = genLblVar();
				string do_while = "do_while" + temp;
				string do_while_check = "do_while_check" + temp;
				
				vector<string> do_while_statements;
				do_while_statements.push_back(do_while);
				do_while_statements.push_back(do_while_check);
				
				loop_label_vector.push_back(do_while_statements);
				
				string do_while_declare = ": " + do_while;
				statement_vector.push_back(do_while_declare);
				cout << do_while_declare << endl;
				out_stream << do_while_declare << endl;
			}
	;

statement5: foreachstart state2help1 ENDLOOP
			{
				string foreach_loop_label = ":= " + for_loop_label_vector.back().at(0);
				string foreach_loop_end = ": " + for_loop_label_vector.back().at(2);
				
				statement_vector.push_back(foreach_loop_label);
				cout << foreach_loop_label << endl;
				out_stream << foreach_loop_label << endl;
				statement_vector.push_back(foreach_loop_end);
				cout << foreach_loop_end << endl;
				out_stream << foreach_loop_end << endl;
			}
		;

// ~~~~~~~~~~~~ NOT DONE ~~~~~~~~~~~~~~~~ //
foreachstart: foreachstatement forexpr BEGINLOOP //IDENTIFIER IN IDENTIFIER BEGINLOOP
			{
				string foreach_in = "?:= " + for_loop_label_vector.back().at(1) + ", " +  operands.at(operands.size() - 1);
				operands.pop_back();
				string foreach_end = ":= " + for_loop_label_vector.back().at(2);
				string foreach_start = ": " + for_loop_label_vector.back().at(1);
	
				statement_vector.push_back(foreach_in);
				statement_vector.push_back(foreach_end);
				statement_vector.push_back(foreach_start);
				cout << foreach_in << endl;
				out_stream << foreach_in << endl;
				cout << foreach_end << endl;
				out_stream << foreach_end << endl;
				cout << foreach_start << endl;
				out_stream << foreach_start << endl;
			}
		;
		
foreachstatement: FOREACH
			{
				string temp = genLblVar();
				temp = temp;
	            string foreach_loop = "foreach_loop" + temp;
	            string cond_true = "conditional_true" + temp;
	            string cond_false = "conditional_false" + temp; 
	            
	            vector<string> foreach_statements;
	            foreach_statements.push_back(foreach_loop);
	            foreach_statements.push_back(cond_true);
	            foreach_statements.push_back(cond_false);
	            
	            
	            for_loop_label_vector.push_back(foreach_statements);
	            string foreach_declare = ": " + foreach_loop;
	            statement_vector.push_back(foreach_declare);
	            cout << foreach_declare << endl;
	            out_stream << foreach_declare << endl;
			}
		;

forexpr: IDENTIFIER IN IDENTIFIER
		
statement6:	READ IDENTIFIER read_variables 
			{
				string temp = "_" + *($2);
				string temp_statement = ".< " + temp;
				if(unDeclaredVariable(temp))
				{
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();						
				}
				read_stack.push(temp_statement);
				while(read_stack.size() != 0)
				{
					statement_vector.push_back(read_stack.top());
					cout << read_stack.top() << endl;
					out_stream << read_stack.top() << endl;
					read_stack.pop();
				}
			}
		|	READ IDENTIFIER LSQUARE expression RSQUARE read_variables
			{
				string temp = genTmpVar();
				string temp_statement = ".< " + temp;
				string temp_array_statement = "[]= _" + *($2) + ", " + operands.at(operands.size() - 1) + ", " + temp; 
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back("INTEGER");
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				read_stack.push(temp_statement);
				read_stack.push(temp_array_statement);
				operands.pop_back();
				while(read_stack.size() != 0)
				{
					statement_vector.push_back(read_stack.top());
					cout << read_stack.top() << endl;
					out_stream << read_stack.top() << endl;
					read_stack.pop();
				}
			}
		;

read_variables:	COMMA IDENTIFIER read_variables
			{
				string temp = "_" + *($2);
				string read_statement = ".< " + temp;
				if(unDeclaredVariable(temp))
				{
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();						
				}
				read_stack.push(read_statement);
			}
		|	COMMA IDENTIFIER LSQUARE expression RSQUARE read_variables
			{
				string generated_temp = genTmpVar();
				identifier_vector.push_back(generated_temp);
				identifier_type_vector.push_back("INTEGER");
				cout << ". " << generated_temp << endl;
				out_stream << ". " << generated_temp << endl;
				string temp_statement = ".< " + generated_temp;
				string temp_array_statement = "[]= " + *($2) + ", " + operands.at(operands.size() - 1) + ", " + generated_temp;
				read_stack.push(temp_statement);
				read_stack.push(temp_array_statement);
				operands.pop_back();
			}
		| 
		;
		
state6help: COMMA varTerm state6help
		|
		;

statement7:	WRITE varTerm state6help  // probably use var is okay, but varterm is recommended
			{
				while(operands.size() != 0) 
				{
					string start = operands.at(0);
					string write_statement = ".> " + start;
					statement_vector.push_back(write_statement);
					cout << write_statement << endl;
					out_stream << write_statement << endl;
					operands.erase(operands.begin());
				}
				operands.clear();
			}
		;

statement8:	CONTINUE 
			{
				if(usedContinueOutsideOfLoop(loop_label_vector))
				{
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();					
				}
				if(loop_label_vector.size() != 0) 
				{
					if(loop_label_vector.back().at(0) == "d")
					{
						string continue_statement = ":= " + loop_label_vector.back().at(0);
						statement_vector.push_back(continue_statement);
						cout << continue_statement << endl;
						out_stream << continue_statement << endl;
					}
					else
					{
						string not_continue_statement = ":= " + loop_label_vector.back().at(1);
						statement_vector.push_back(not_continue_statement);
						cout << not_continue_statement << endl;
						out_stream << not_continue_statement << endl;
					}
				}
			}
		;

statement9:	RETURN expression 
			{
				string return_statement = "ret " + operands.at(operands.size() - 1);
				statement_vector.push_back(return_statement);
				cout << return_statement << endl;
				out_stream << return_statement << endl;
				operands.pop_back();
			}
		;

bool_exp: relationHelp
		| bool_exp OR relationHelp
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				string push_item = "|| " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);
			}

relationHelp: relationexpr
			| relationHelp AND relationexpr
				{
					string temp = genTmpVar();
					string type = "INTEGER";
					identifier_vector.push_back(temp);
					identifier_type_vector.push_back(type);
					
					cout << ". " << temp << endl;
					out_stream << ". " << temp << endl;
					
					string operand1 = operands.at(operands.size()-1);
					string operand2 = operands.at(operands.size()-2);
					
					
					string push_item = "&& " + temp + ", " + operand2 + ", " + operand1;
					
					statement_vector.push_back(push_item);
					cout << push_item << endl;
					out_stream << push_item << endl;
					
					operands.pop_back();
					operands.pop_back();
					
					operands.push_back(temp);	
				}



// bool_exp:	relation_and_expr orHelper {}

// orHelper:	OR relation_and_expr orHelper 
// 			{
// 				string temp = genTmpVar();
// 				string type = "INTEGER";
// 				identifier_vector.push_back(temp);
// 				identifier_type_vector.push_back(type);
// 				cout << ". " << temp << endl;
// 				out_stream << ". " << temp << endl;
				
// 				string operand1 = operands.at(operands.size()-1);
// 				string operand2 = operands.at(operands.size()-2);
				
// 				string push_item = "|| " + temp + ", " + operand2 + ", " + operand1;
				
// 				statement_vector.push_back(push_item);
// 				cout << push_item << endl;
// 				out_stream << push_item << endl;
				
// 				operands.pop_back();
// 				operands.pop_back();
				
// 				operands.push_back(temp);
// 			}
// 		| 
// 			{}
// 		;

// relation_and_expr: relationexpr andHelper {};

// andHelper: 	AND relationexpr andHelper
// 			{
// 				string temp = genTmpVar();
// 				string type = "INTEGER";
// 				identifier_vector.push_back(temp);
// 				identifier_type_vector.push_back(type);
				
// 				cout << ". " << temp << endl;
// 				out_stream << ". " << temp << endl;
				
// 				string operand1 = operands.at(operands.size()-1);
// 				string operand2 = operands.at(operands.size()-2);
				
				
// 				string push_item = "&& " + temp + ", " + operand2 + ", " + operand1;
				
// 				statement_vector.push_back(push_item);
// 				cout << push_item << endl;
// 				out_stream << push_item << endl;
				
// 				operands.pop_back();
// 				operands.pop_back();
				
// 				operands.push_back(temp);	
// 			}
// 		| 
// 			{};


relationexpr:	relationExprHelper
			| NOT relationExprHelper 
			{
				string temp = genTmpVar();
				temp = temp;
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back("INTEGER");
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				string operand1 = operands.back();
				operands.pop_back();
				string not_statement = "! " + temp + ", " + operand1;
				statement_vector.push_back(not_statement);
				cout << not_statement << endl;
				out_stream << not_statement << endl;
				
				operands.push_back(temp);
			}
			;

relationExprHelper:	comp // normally [expression comp expression]
			| TRUE 
				{
					string temp = genTmpVar();
					string type = "INTEGER";
					identifier_vector.push_back(temp);
					identifier_type_vector.push_back(type);
					cout << ". " << temp << endl;
					out_stream << ". " << temp << endl;
					string push_item = "= " + temp + ", 1";
					
					statement_vector.push_back(push_item);
					cout << push_item << endl;
					out_stream << push_item << endl;
					operands.push_back(temp);
				}
			| FALSE 
				{
					string temp = genTmpVar();
					string type = "INTEGER";
					identifier_vector.push_back(temp);
					identifier_type_vector.push_back(type);
					cout << ". " << temp << endl;
					out_stream << ". " << temp << endl;
					
					string push_item = "= " + temp + ", 0";
					
					statement_vector.push_back(push_item);
					cout << push_item << endl;
					out_stream << push_item << endl;
					
					operands.push_back(temp);
				}
			| LPAREN bool_exp RPAREN 
			;

comp:	expression EQ expression 
		{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "== " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);			
		}
		| expression NEQ expression 
		{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "!= " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);			
		}
		| expression LT expression 
		{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "< " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);			
		}
		| expression GT expression 
		{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "> "  + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);			
		}
		| expression LTE expression 
		{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "<= " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);			
		}
		| expression GTE expression 
		{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = ">= " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);			
		}
		;


expression:	multiplicative_expr multExprHelper
		;

multExprHelper:	ADD multiplicative_expr multExprHelper 
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "+ " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);
			}
		| SUB multiplicative_expr multExprHelper 
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "- " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);
			}
		| 
		;

multiplicative_expr:	term termHelper 
			;

termHelper:	MULT term termHelper
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "* " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);
			}
		| DIV term termHelper
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				string push_item = "/ " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);
			}
		| MOD term termHelper
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				
				string operand1 = operands.at(operands.size()-1);
				string operand2 = operands.at(operands.size()-2);
				
				
				string push_item = "% " + temp + ", " + operand2 + ", " + operand1;
				
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
				
				operands.pop_back();
				operands.pop_back();
				
				operands.push_back(temp);
			}
		| 
		;

term:	identifierTerm 
			{
				// ?????????????? think its done
			}
		| varTerm 
			{
				// empty
			}
		| SUB varTerm
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				string operand1 = operands.at(operands.size()-1);
				
				string push_item = "- " + temp + ", 0, " + operand1; 
				cout << push_item << endl;
				out_stream << push_item << endl;
				statement_vector.push_back(push_item);
				operands.pop_back();
				operands.push_back(temp);
			}
		;

identifierTerm: IDENTIFIER LPAREN identifierHelp RPAREN 
				{
					string temp = genTmpVar(); // makes temp variable
					identifier_vector.push_back(temp); // this line and line below adds to table to output later
					identifier_type_vector.push_back("INTEGER");
					cout << ". " << temp << endl;
					out_stream << ". " << temp << endl;
					
					while(!param_stack.empty()) 
					{
						string temp = "param " + param_stack.top();
						statement_vector.push_back(temp);
						cout << temp << endl;
						param_stack.pop();
					}
					if(functionNotDeclared(*($1))) {
						error = true;
		            	out_stream.open("test1.mil", ofstream::trunc);
		            	out_stream.close();						
					}
					string identifier_statement = "call " + *($1) + ", " + temp;
					statement_vector.push_back(identifier_statement); // adds for statement
					cout << identifier_statement << endl;
					out_stream << identifier_statement << endl;
					operands.push_back(temp); // pushes the temp variable number into operands for going into param stack
				}
		;

identifierHelp: expression COMMA identifierHelp 
			{
				param_stack.push(operands.at(operands.size() - 1));
				operands.pop_back();
			}
		| expression 
			{
				param_stack.push(operands.at(operands.size() - 1));
				operands.pop_back();
			}

varTerm: 	var 
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				string operand1 = operands.at(operands.size()-1);
				operands.pop_back();
				
				if(operand1.at(0) == '['){	//we know its an array
					string push_item = "=[] " + temp + ", " + operand1.substr(2);
					// CHECK THIS 
					statement_vector.push_back(push_item);
					cout << push_item << endl;
					out_stream << push_item << endl;
				}
				else {	// has to be an integer
					string push_item = "= " + temp + ", " + operand1;
					statement_vector.push_back(push_item);
					cout << push_item << endl;
					out_stream << push_item << endl;
				}
				operands.push_back(temp);
			}
		| NUMBER
			{
				string temp = genTmpVar();
				string type = "INTEGER";
				identifier_vector.push_back(temp);
				identifier_type_vector.push_back(type);
				cout << ". " << temp << endl;
				out_stream << ". " << temp << endl;
				operands.push_back(temp);
				
				stringstream num;
				num << $1;
				string push_item = "= " + temp + ", " + num.str();
				statement_vector.push_back(push_item);
				cout << push_item << endl;
				out_stream << push_item << endl;
			}
		| LPAREN expression RPAREN
			{
				while(param_stack.size() != 0)
                {
                	string temp = param_stack.top();
                	param_stack.pop();
                	string push_item = "param " + temp;
                    statement_vector.push_back(push_item);
                    cout << push_item << endl;
                    out_stream << push_item << endl;
                }
			}
		;

var:		IDENTIFIER 
			{
				string temp = "_" + *($1);
				if(unDeclaredVariable(temp))
				{
					error = true;
	            	out_stream.open("test1.mil", ofstream::trunc);
	            	out_stream.close();						
				}
				operands.push_back(temp);
			}
		|	IDENTIFIER LSQUARE expression RSQUARE 
			{
				string operandLatest = operands.at(operands.size() - 1);
				string temp = "_" + *($1);
				operands.pop_back();
				string operandStatement = "[]" + temp + "," + operandLatest;
				operands.push_back(operandStatement);
			}
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

// define functions here
string genTmpVar(){
	ss.str("");
	ss.clear();
	ss << tmpcount;
	string temp = "_tmp_"+ ss.str();
	++tmpcount;
	return temp;
}

string genLblVar(){
	
	ss.str("");
	ss.clear();
	ss << lblcount;
	string temp = "_lbl_"+ ss.str();
	++lblcount;
	return temp;
}

bool unDeclaredVariable(string var)
{
	extern int row;
	bool undeclared = true;
	for(unsigned int i = 0; i < identifier_vector.size(); ++i)
	{
		cout << identifier_vector.at(i) << " ";
		if(identifier_vector.at(i) == var)
		{
			undeclared = false;
		}
	}
	if(undeclared)
	{
		cerr << "Semantic error: undeclared variable \"" << var << "\" on line " << row << endl;
		return true;
	}
	return false;
}

bool wasDeclared(string var)
{
	extern int row;
	for(unsigned int i = 0; i < identifier_vector.size(); ++i) {
		if(identifier_vector.at(i) == var) {
			cerr << "Semantic error: symbol \"" << var << "\" has already been declared on line" << row  << endl;
			return true;
		}
	} 
	return false;
}

bool mainExists(vector<string> v){
	for(unsigned int i = 0; i < function_vector.size(); ++i){
		if(function_vector.at(i) == "main"){
			return true;
		}
	}
	cerr << "Semantic error: did not define main function" << endl;
	return false;
}

bool arrSizeZero(int i){
	if(i <= 0){
		cerr << "Semantic error: declared array of size <= 0" << endl;
		return true;
	}
	return false;
}

bool functionNotDeclared(string var)
{
	extern int row;
	for(unsigned int i  = 0; i < function_vector.size(); ++i)
	{
		if(function_vector.at(i) == var)
		{
			return false;
		}
	}
	cerr << "Semantic error: function \"" << var << "\" was not declared on line " << row << endl;
	return true;
}

bool usingReservedKeyword(string s, vector<string> v){
	extern int row;
	for(unsigned int i = 0; i < v.size(); ++i){
		if(s == v.at(i)){
			cerr << "Semantic error: using reserved keyword for variable on line" << row << endl;
			return true;
		}
	}
	return false;
}

bool isArrayUsedAsNotArray(string var)
{
	extern int row;
	for(unsigned int i = 0; i < identifier_type_vector.size(); ++i)
	{
		if(identifier_vector.at(i) == var)
		{
			if(identifier_type_vector.at(i) != "INTEGER")
			{
				cerr << "Semantic error: using an array without specifiying index on line " << row << endl;
				return true;
			}
		}
	}
	return false;
}

bool isNotArrayUsedAsArray(string var)
{
	extern int row;
	for(unsigned int i = 0; i < identifier_type_vector.size(); ++i)
	{
		if(identifier_vector.at(i) == var)
		{
			if(identifier_type_vector.at(i) == "INTEGER")
			{
				cerr << "Semantic error: specifying an index on an integer on line " << row << endl;
				return true;
			}
		}
	}
	return false;
}

bool usedContinueOutsideOfLoop(vector<vector <string> > label_loop)
{
	extern int row;
	if(label_loop.size() == 0)
	{
		cerr << "Semantic error: used continue outside of loop on line " << row << endl;
		return true;
	}
	return false;
}