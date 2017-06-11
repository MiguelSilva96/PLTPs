%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include <glib.h>
	#include <string.h>
	#include <ctype.h>

	typedef struct variable {
			int stack;
			int type;
			int size;
	} *Var;

	void yyerror(char*);
	int yylex();
	Var addVar(Var, int, int, int);

	GHashTable* variaveis;
	FILE *fp;
	int sp = 0;
	int pc = 0;


	Var temp;
	Var v = NULL;

%}
%token VAR V INTGR START PREAD PPRINT IF ELSE WHILE STRING
%union { char *s; int d; }
%type<d> INTGR
%type<s> V STRING

%%
Plang           : Init Body
								;

Init            : VAR ':' Declare { fprintf(fp, "start\n"); }
								;

Declare         : Declare Variable
								| { variaveis = g_hash_table_new(g_str_hash, g_str_equal); }
								;

Variable        : V ';' {
										temp = g_hash_table_lookup(variaveis,$1);
										if(temp) {
											yyerror("Variável já declarada anteriormente!");
										}
										else {
											v = addVar(v,sp,0,1);
											g_hash_table_insert(variaveis,$1,v);
											fprintf(fp, "pushi 0\n");
											sp++;
											pc++;
										}
								}
								| V '(' INTGR ')' ';'  {
										temp = g_hash_table_lookup(variaveis,$1);
										if(temp) {
											yyerror("Variável já declarada anteriormente!");
										}
										else {
											v = addVar(v,sp,1,$3);
											g_hash_table_insert(variaveis,$1,v);
											fprintf(fp, "pushn %d\n", $3);
											sp += $3;
											pc++;
										}
								}
								| V '(' INTGR ')' '(' INTGR ')' ';' {
										temp = g_hash_table_lookup(variaveis,$1);
										if(temp) {
											yyerror("Variável já declarada anteriormente!");
										}
										else {
											v = addVar(v,sp,1,$3*$6);
											g_hash_table_insert(variaveis,$1,v);
											fprintf(fp, "pushn %d\n", $3*$6);
											sp += $3*$6;
											pc++;
										}
								}
								;

Body            : START ':' Instructions ';'
								;

Instructions    : Instructions Instruction
								| Instruction
								;

Instruction     : Assignment
								| Read
								| Print
								| Condicional
								| Cyclic
								;

Assignment      : V '-' '>' Expression ';' {
										temp = g_hash_table_lookup(variaveis,$1);
										if(!temp) {
											yyerror("A variável não foi anteriormente declarada!");
										}
										else {
											fprintf(fp, "storeg %d\n", temp->stack);
											pc++;
										}
								}
								| V '(' Expression ')' '-' '>' Expression ';'
								| V '(' Expression ')' '(' Expression ')' '-' '>' Expression ';'
								;
Read            : PREAD '(' V ')' ';' {
										temp = g_hash_table_lookup(variaveis,$3);
										if(temp == NULL) {
											yyerror("A variável não foi anteriormente declarada!");
										}
										else {
											fprintf(fp, "read\natoi\nstoreg %d\n", temp->stack);
											pc += 3;
										}
								}
								;
Print           : PPRINT '(' Expression ')' ';' {
										fprintf(fp, "writei\n");
										pc++;
								}
								| PPRINT '(' STRING ')' ';' {
										fprintf(fp, "pushs %s\n", $3);
										fprintf(fp, "writes\n");
										pc +=2;
								}
								;
Condicional     : IF '(' Accumulator ')' '{' Instructions '}' ELSE '{' Instructions '}'
								| IF '(' Accumulator ')' '{' Instructions '}'
								;
Cyclic          : WHILE '(' Accumulator ')' '{' Instructions '}'
								;
Accumulator     : Comparator '|' '|' Accumulator
								| Comparator '&' '&' Accumulator
								| Comparator
								;
Comparator      : Expression
								| Expression '=' '=' Expression {
									fprintf(fp, "equal\n");
									pc++;
								}
								| Expression '!' '=' Expression
								| Expression '>' Expression {
									fprintf(fp, "sup\n");
									pc++;
								}
								| Expression '<' Expression {
									fprintf(fp, "inf\n");
									pc++;
								}
								| Expression '>' '=' Expression {
									fprintf(fp, "supeql\n");
									pc++;
								}
								| Expression '<' '=' Expression {
									fprintf(fp, "infeq\n");
									pc++;
								}
								;
Expression      : Expression '+' P {
									fprintf(fp, "add\n");
									pc++;
								}
								| Expression '-' P {
									fprintf(fp, "sub\n");
									pc++;
								}
								| P
								;
P               : P '*' Fat {
									fprintf(fp, "mul\n");
									pc++;
								}
								| P '/' Fat {
									fprintf(fp, "div\n");
									pc++;
								}
								| Fat
								;
Fat             : Es '^' Fat
								| Es
								;
Es              : '(' Expression ')'
								| INTGR {
									fprintf(fp, "pushi %d\n", $1);
									pc++;
								}
								| V {
									temp = g_hash_table_lookup(variaveis,$1);
									if(!temp) {
										yyerror("A variável não foi anteriormente declarada!");
									}
									else {
										fprintf(fp, "pushg %d\n", temp->stack);
										pc++;
									}
								}
								;
%%
#include "lex.yy.c"

void yyerror(char *s) {
	fprintf(stderr, "linha %d: [%s] - %s\n", yylineno, yytext, s);
}

Var addVar(Var v, int index, int type, int size) {
	v = (Var) malloc(sizeof(struct variable));
	v->stack = index;
	v->type = type;
	v->size = size;
	return v;
}

int main(){
		fp = fopen("teste.vm", "w");
		yyparse();
		return 0;
}
