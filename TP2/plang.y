%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include <glib.h>
	#include <string.h>
	#include <ctype.h>

	#define MAXSTACK 512

	typedef struct variable {
			int stack;
			int size;
	} *Var;

	typedef struct stack {
		int blocks[MAXSTACK];
		int top;
	} *Stack;

	int pop(Stack);
	void push(int, Stack);
	void yyerror(char*);
	int yylex();
	Var addVar(Var, int, int);

	GHashTable* variaveis;
	Stack ifs;
	Stack whiles;
	FILE *fp;
	int sp = 0;
	int blocos = 0;


	Var temp;
	Var v = NULL;

%}
%token VAR V INTGR START PREAD PPRINT IF ELSE WHILE STRING

%union { char *s; int d; }
%type<d> INTGR
%type<s> V STRING

%%
Plang		: Init Body { fprintf(fp, "stop\n"); }
			;

Init		: VAR ':' Declare { fprintf(fp, "start\n"); }
			;

Declare		: Declare Variable
			| { 
				variaveis = g_hash_table_new(g_str_hash, g_str_equal);
				ifs = (Stack)malloc(sizeof(struct stack));
				ifs -> top = 0;
				whiles = (Stack)malloc(sizeof(struct stack));
				whiles -> top = 0;
			}
			;

Variable	: V ';' {
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

Body 		: START ':' Instructions ';'
			;

Instructions: Instructions Instruction
			| Instruction
			;

Instruction : Assignment
			| Read
			| Print
			| Condicional
			| Cyclic
			;

Assignment	: V '-' '>' Expression ';' {
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
					fprintf(fp, "		pushgp\n");
					fprintf(fp, "		pushi %d\n", temp->stack);
					fprintf(fp, "		padd\n");
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
					fprintf(fp, "		pushgp\n");
					fprintf(fp, "		pushi %d\n", temp->stack);
					fprintf(fp, "		padd\n");
				}
			} Expression '}' '[' {
				fprintf(fp, "		pushi %d\n", temp->size);
				fprintf(fp, "		mul\n");
			} Expression ']' '-' '>' {
				fprintf(fp, "		add\n");
			} Expression ';' {
				fprintf(fp, "		storen\n");
			}
			;

Read		: PREAD '(' V ')' ';' {
				temp = g_hash_table_lookup(variaveis,$3);
				if(temp == NULL) {
					yyerror("A variável não foi anteriormente declarada!");
				}
				else {
					fprintf(fp, "		read\n");
					fprintf(fp, "		atoi\n");
					fprintf(fp, "		storeg %d\n", temp->stack);
				}
			}
			| PREAD '(' V  {
				temp = g_hash_table_lookup(variaveis,$3);
				if(!temp) {
					yyerror("A variável não foi anteriormente declarada!");
				}
				else {
					fprintf(fp, "		pushgp\n");
					fprintf(fp, "		pushi %d\n", temp->stack);
					fprintf(fp, "		padd\n");
				}
			} '[' Expression ']' ')' ';' {
				fprintf(fp, "		read\n");
				fprintf(fp, "		atoi\n");
				fprintf(fp, "		storen\n");
			}
			| PREAD '(' V '{' {
				temp = g_hash_table_lookup(variaveis,$3);
				if(!temp) {
					yyerror("A variável não foi anteriormente declarada!");
				}
				else {
					fprintf(fp, "		pushgp\n");
					fprintf(fp, "		pushi %d\n", temp->stack);
					fprintf(fp, "		padd\n");
				}
			} Expression '}' '[' {
				fprintf(fp, "		pushi %d\n", temp->size);
				fprintf(fp, "		mul\n");
			} Expression ']' ')' ';' {
				fprintf(fp, "		add\n");
				fprintf(fp, "		read\n");
				fprintf(fp, "		atoi\n");
				fprintf(fp, "		storen\n");
			}
			;


Print		: PPRINT '(' Expression ')' ';' {
				fprintf(fp, "		writei\n");
			}
			| PPRINT '(' STRING ')' ';' {
				fprintf(fp, "		pushs %s\n", $3);
				fprintf(fp, "		writes\n");
			}
			;

Condicional	: IF '(' Accumulator ')' {
				blocos++;
				fprintf(fp, "		jz bloco%d\n", blocos);
				push(blocos, ifs);
			} '{' Instructions '}' Opelse
			;

Opelse		: ELSE {
				blocos++;
				fprintf(fp, "		jump bloco%d\n", blocos); 
				fprintf(fp, "bloco%d:\n", pop(ifs));
				push(blocos, ifs);
			} '{' Instructions '}' {
				fprintf(fp, "bloco%d:\n", pop(ifs));
			}
			| { 
				fprintf(fp, "bloco%d:\n", pop(ifs));
			}
			;

Cyclic		: WHILE {
				blocos++;
				fprintf(fp, "bloco%d:\n", blocos);
				push(blocos, whiles);
			} '(' Accumulator ')' {
				blocos++;
				fprintf(fp, "		jz bloco%d\n", blocos);
				push(blocos, ifs);
			} '{' Instructions '}' {
				fprintf(fp, "		jump bloco%d\n", pop(whiles));
				fprintf(fp, "bloco%d:\n", pop(ifs));
			}
			;

Accumulator	: Comparator '|' '|' Accumulator
			| Comparator '&' '&' Accumulator
			| Comparator
			;

Comparator	: Expression
			| Expression '=' '=' Expression {
				fprintf(fp, "		equal\n");
			}
			| Expression '!' '=' Expression {
				fprintf(fp, "		equal\n");
				fprintf(fp, "		not\n");
			}
			| Expression '>' Expression {
				fprintf(fp, "		sup\n");
			}
			| Expression '<' Expression {
				fprintf(fp, "		inf\n");
			}
			| Expression '>' '=' Expression {
				fprintf(fp, "		supeq\n");
			}
			| Expression '<' '=' Expression {
				fprintf(fp, "		infeq\n");
			}
			;

Expression	: Expression '+' P {
				fprintf(fp, "		add\n");
			}
			| Expression '-' P {
				fprintf(fp, "		sub\n");
			}
			| P
			;

P			: P '*' Fat {
				fprintf(fp, "		mul\n");
			}
			| P '/' Fat {
				fprintf(fp, "		div\n");
			}
			| P '%' Fat {
				fprintf(fp, "		mod\n");
			}
			| Fat
			;

Fat			: Es '^' Fat
			| Es
			;

Es			: '(' Expression ')'
			| INTGR {
				fprintf(fp, "		pushi %d\n", $1);
			}
			| '-' INTGR {
				fprintf(fp, "		pushi -%d\n", $2);
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
			| '-' V {
				temp = g_hash_table_lookup(variaveis,$2);
				if(!temp) {
					yyerror("A variável não foi anteriormente declarada!");
				}
				else {
					fprintf(fp, "		pushi -1\n");
					fprintf(fp, "		pushg %d\n", temp->stack);
					fprintf(fp, "		mul\n");
				}
			}
			| V  {
				temp = g_hash_table_lookup(variaveis,$1);
				if(!temp) {
					yyerror("A variável não foi anteriormente declarada!");
				}
				else {
					fprintf(fp, "		pushgp\n");
					fprintf(fp, "		pushi %d\n", temp->stack);
					fprintf(fp, "		padd\n");
				}
			} '[' Expression ']' {
				fprintf(fp, "		loadn\n");
			}
			| '-' V  {
				temp = g_hash_table_lookup(variaveis,$2);
				if(!temp) {
					yyerror("A variável não foi anteriormente declarada!");
				}
				else {
					fprintf(fp, "		pushgp\n");
					fprintf(fp, "		pushi %d\n", temp->stack);
					fprintf(fp, "		padd\n");
				}
			} '[' Expression ']' {
				fprintf(fp, "		loadn\n");
				fprintf(fp, "		pushi -1\n");
				fprintf(fp, "		mul\n");
			}
			| V '{'  {
				temp = g_hash_table_lookup(variaveis,$1);
				if(!temp) {
					yyerror("A variável não foi anteriormente declarada!");
				}
				else {
					fprintf(fp, "		pushgp\n");
					fprintf(fp, "		pushi %d\n", temp->stack);
					fprintf(fp, "		padd\n");
				}
			} Expression '}' '[' {
				fprintf(fp, "		pushi %d\n", temp->size);
				fprintf(fp, "		mul\n");
			} Expression ']' {
				fprintf(fp, "		add\n");
				fprintf(fp, "		loadn\n");
			}
			| '-' V '{'  {
				temp = g_hash_table_lookup(variaveis,$2);
				if(!temp) {
					yyerror("A variável não foi anteriormente declarada!");
				}
				else {
					fprintf(fp, "		pushgp\n");
					fprintf(fp, "		pushi %d\n", temp->stack);
					fprintf(fp, "		padd\n");
				}
			} Expression '}' '[' {
				fprintf(fp, "		pushi %d\n", temp->size);
				fprintf(fp, "		mul\n");
			} Expression ']' {
				fprintf(fp, "		add\n");
				fprintf(fp, "		loadn\n");
				fprintf(fp, "		pushi -1\n");
				fprintf(fp, "		mul\n");
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

void push(int i, Stack s) {
	(s -> blocks)[s -> top] = i;
	(s -> top)++;
}

int pop(Stack s) {
	(s -> top)--;
	int res = (s -> blocks)[s -> top];
	return res; 
}

int main(int argc, char **argv){
	if(argc > 1) {
		yyin = fopen(argv[1], "r");
		if(argc > 2)
			fp = fopen(argv[2], "w");
	}
	else
		fp = fopen("out.vm", "w");
	yyparse();
	return 0;
}
