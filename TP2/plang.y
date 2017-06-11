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

	GHashTable* variaveis = g_hash_table_new(g_str_hash, g_str_equal);
	FILE *fp;
	int sp = 0;
	int pc = 0;


	Var temp = (Var)malloc(sizeof(struct variavel));
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
								| Variable
								;

Variable        : V ';' {
										temp = g_hash_table_lookup(variaveis,$1);
										if(temp == NULL) {
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
										if(temp == NULL) {
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
										if(temp == NULL) {
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

Assignment      : V '=' Expression ';' {
										temp = g_hash_table_lookup(variaveis,$1);
										if(temp == NULL) {
											yyerror("A variável não foi anteriormente declarada!");
										}
										else {
											fprintf(fp, "storeg %d\n", temp->stack);
											pc++;
										}
								}
								| V '(' Expression ')' '=' Expression ';'
								| V '(' Expression ')' '(' Expression ')' '=' Expression ';'
								;
Read            : PREAD '(' V ')' ';'
								;
Print           : PPRINT '(' Expression ')' ';'
								| PPRINT '(' STRING ')' ';'
								;
Condicional     : IF '(' Accumulator ')' '{' Instructions '}' ELSE '{' Instructions '}'
								| IF '(' Accumulator ')' '{' Instructions '}'
								;
Cyclic          : WHILE '(' Accumulator ')' '{' Instructions '}'
								;
Accumulator     : Comparator "||" Accumulator
								| Comparator "&&" Accumulator
								| Comparator
								;
Comparator      : Expression
								| Expression "==" Expression
								| Expression "!=" Expression
								| Expression ">" Expression
								| Expression "<" Expression
								| Expression ">=" Expression
								| Expression "<=" Expression
								;
Expression      : Expression '+' P
								| Expression '-' P
								| P
								;
P               : P '*' Fat
								| P '/' Fat
								| Fat
								;
Fat             : Es '^' Fat
								| Es
								;
Es              : '(' Expression ')'
								| INTGR
								| V
								;
%%
#include "lex.yy.c"

void yyerror(char *s) {
	fprintf(stderr, "linha %d: [%s] - %s\n", yylineno, yytext, s);
}

Var addVar(Var v, int index, int type, int size) {
	v = (Var) malloc(sizeof(struct variavel));
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
