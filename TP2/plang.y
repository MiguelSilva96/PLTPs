%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include <glib.h>
	#include <string.h>
	#include <ctype.h>

	typedef struct variable {
			int stack;
			int size;
	} *Var;

	void yyerror(char*);
	int yylex();
	Var addVar(Var, int, int);

	GHashTable* variaveis;
	FILE *fp;
	int sp = 0;
	Var temp;
	Var v = NULL;

%}
%token VAR V INTGR START PREAD PPRINT IF ELSE WHILE STRING PREADM
%union { char *s; int d; }
%type<d> INTGR
%type<s> V STRING

%%
Plang           : Init Body
								;

Init            : VAR ':' Declare { fprintf(fp, "		start\n"); }
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
													v = addVar(v,sp,1);
													g_hash_table_insert(variaveis,$1,v);
													fprintf(fp, "		pushi 0\n");
													sp++;
												}
												}
								|  V '[' INTGR ']' ';'  {
										temp = g_hash_table_lookup(variaveis,$1);
										if(temp) {
											yyerror("Variável já declarada anteriormente!");
										}
										else {
											v = addVar(v,sp,$3);
											g_hash_table_insert(variaveis,$1,v);
											fprintf(fp, "		pushn %d\n", $3);
											sp += $3;
										}
								}
								|  V '{' INTGR '}' '[' INTGR ']' ';' {
										temp = g_hash_table_lookup(variaveis,$1);
										if(temp) {
											yyerror("Variável já declarada anteriormente!");
										}
										else {
											v = addVar(v,sp,$6);
											g_hash_table_insert(variaveis,$1,v);
											fprintf(fp, "		pushn %d\n", $3*$6);
											sp += $3*$6;
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
											fprintf(fp, "		storeg %d\n", temp->stack);
										}
								}
								| V  {
									 temp = g_hash_table_lookup(variaveis,$1);
									 if(!temp) {
										 yyerror("A variável não foi anteriormente declarada!");
									 }
									 else {
										 fprintf(fp, "		pushgp\n		pushi %d\n		padd\n", temp->stack);
									 }
								} '[' Expression ']' '-' '>' Expression ';' {
										fprintf(fp, "		storen\n");
								}
								|  V '{'  {
									 temp = g_hash_table_lookup(variaveis,$1);
									 if(!temp) {
										 yyerror("A variável não foi anteriormente declarada!");
									 }
									 else {
										 fprintf(fp, "		pushgp\n		pushi %d\n		padd\n", temp->stack);
									 }
								 } Expression '}' '[' {
											fprintf(fp, "		pushi %d\n		mul\n", temp->size);
									} Expression ']' '-' '>' {
										fprintf(fp, "		add\n");
									} Expression ';' {
										fprintf(fp, "		storen\n");
									}
								;

Read            : PREAD '(' V ')' ';' {
										temp = g_hash_table_lookup(variaveis,$3);
										if(temp == NULL) {
											yyerror("A variável não foi anteriormente declarada!");
										}
										else {
											fprintf(fp, "		read\n		atoi\n		storeg %d\n", temp->stack);
										}
								}
								| PREAD '(' V  {
									 temp = g_hash_table_lookup(variaveis,$3);
									 if(!temp) {
										 yyerror("A variável não foi anteriormente declarada!");
									 }
									 else {
										 fprintf(fp, "		pushgp\n		pushi %d\n		padd\n", temp->stack);
									 }
									 } '[' Expression ']' ')' ';' {
										fprintf(fp, "		read\n		atoi\n		storen\n");
									}
								| PREADM '(' V '[' {
										temp = g_hash_table_lookup(variaveis,$3);
										if(!temp) {
											yyerror("A variável não foi anteriormente declarada!");
										}
										else {
											fprintf(fp, "		pushgp\n		pushi %d\n		padd\n", temp->stack);
										}
										} Expression ']' '[' {
											fprintf(fp, "		pushi %d\n		mul\n", temp->size);
										} Expression ']' ')' ';' {
											fprintf(fp, "		read\n		atoi\n		storen\n");
										}
								;

Print           : PPRINT '(' Expression ')' ';' {
										fprintf(fp, "		writei\n");
								}
								| PPRINT '(' STRING ')' ';' {
										fprintf(fp, "		pushs %s\n", $3);
										fprintf(fp, "		writes\n");
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
									fprintf(fp, "		equal\n");
								}
								| Expression '!' '=' Expression
								| Expression '>' Expression {
									fprintf(fp, "		sup\n");
								}
								| Expression '<' Expression {
									fprintf(fp, "		inf\n");
								}
								| Expression '>' '=' Expression {
									fprintf(fp, "		supeql\n");
								}
								| Expression '<' '=' Expression {
									fprintf(fp, "		infeq\n");
								}
								;

Expression      : Expression '+' P {
									fprintf(fp, "		add\n");
								}
								| Expression '-' P {
									fprintf(fp, "		sub\n");
								}
								| P
								;

P               : P '*' Fat {
									fprintf(fp, "		mul\n");
								}
								| P '/' Fat {
									fprintf(fp, "		div\n");
								}
								| Fat
								;

Fat             : Es '^' Fat
								| Es
								;

Es              : '(' Expression ')'
								| INTGR {
									fprintf(fp, "		pushi %d\n", $1);
								}
								| V {
									temp = g_hash_table_lookup(variaveis,$1);
									if(!temp) {
										yyerror("A variável não foi anteriormente declarada!");
									}
									else {
										fprintf(fp, "		pushg %d\n", temp->stack);
									}
								}
								| V  {
									 temp = g_hash_table_lookup(variaveis,$1);
									 if(!temp) {
										 yyerror("A variável não foi anteriormente declarada!");
									 }
									 else {
										 fprintf(fp, "		pushgp\n		pushi %d\n		padd\n", temp->stack);
									 }
									} '[' Expression ']' {
										fprintf(fp, "		loadn\n");
									}
								| V '{'  {
									 temp = g_hash_table_lookup(variaveis,$1);
									 if(!temp) {
										 yyerror("A variável não foi anteriormente declarada!");
									 }
									 else {
										 fprintf(fp, "		pushgp\n		pushi %d\n		padd\n", temp->stack);
									 }
								 } Expression '}' '[' {
											fprintf(fp, "		pushi %d\n		mul\n", temp->size);
									} Expression ']' {
										fprintf(fp, "		add\n		load\n");
									}
								;

%%
#include "lex.yy.c"

void yyerror(char *s) {
	fprintf(stderr, "linha %d: [%s] - %s\n", yylineno, yytext, s);
}

Var addVar(Var v, int index, int size) {
	v = (Var) malloc(sizeof(struct variable));
	v->stack = index;
	v->size = size;
	return v;
}

int main(){
		fp = fopen("teste.vm", "w");
		yyparse();
		return 0;
}
