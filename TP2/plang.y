%{
  #include <stdio.h>
  #include <math.h>
  #include <glib.h>
  #include <string.h>
  #include <ctype.h>
  void yyerror(char*);
  int yylex();
%}
%token VAR V INT BEGIN PREAD PPRINT STRING IF ELSE WHILE
%type<d> INT
%type<f> VAR BEGIN PREAD PPRINT STRING IF ELSE WHILE
%type<c> V

  GHashTable* variaveis = g_hash_table_new(g_str_hash, g_str_equal);
  FILE *f;
  int sp = 0;
  int pc = 0;

  typedef struct variable {
  	 int stack;
     int type;
   } Var;
   typedef struct variavel *Var;

   Var addVar(Var v, int index, int type, int size) {
		      v = (Var) malloc(sizeof(struct variable));
		      v->index = index;
          v->type = type;
          v->size = size
          return v;
	  }
    Var temp = (Var) malloc(sizeof(struct variable));
    Var v = null;
}

%%
Plang           : Init Body
                ;
Init            : VAR TP Declare                                                               {
                                                                                              fprintf(f, "start\n");
                                                                                              }
                ;
Declare         : Declare Variable
                | Variable
                ;
Variable        : V PV                                                                        {
                                                                                              temp = g_hash_table_lookup(variaveis,$1);
                                                                                              if(temp == NULL) {
                                                                                                yyerror("Variável já declarada anteriorment!");
                                                                                              }
                                                                                              else {
                                                                                                v = addVar(v,sp,0,1);
                                                                                                g_hash_table_insert(variaveis,$1,v);
                                                                                                fprintf(fp, "pushi 0\n");
                                                                                                sp++;
                                                                                                pc++;
                                                                                              }
                                                                                              }
                | V PA INT PF PV                                                              {
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
                | V PA INT PF PA INT PF PV                                                    {
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
Body            : BEGIN TP Instructions PV
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
Assignment      : V TO Expression PV                                                          {
                                                                                              temp = g_hash_table_lookup(variaveis,$1);
                                                                                              if(temp == NULL) {
                                                                                                yyerror("A variável não foi anteriormente declarada!");
                                                                                              }
                                                                                              else {
                                                                                                fprintf(fp, "storeg %d\n", temp->index);
                                                                                                pc++;
                                                                                              }
                                                                                              }
                | V PA Expression PF TO Expression PV
                | V PA Expression PF PA Expression PF TO Expression PV
                ;
Read            : PREAD PA V PF PV
                ;
Print           : PPRINT PA Expression PF PV
                | PPRINT PA STRING PF PV
                ;
Condicional     : IF PA Accumulator PF BA Instructions BF ELSE BA Instructions BF
                | IF PA Accumulator PF BA Instructions BF
                ;
Cyclic          : WHILE PA Accumulator PF BA Instructions BF
                ;
Accumulator     : Accumulator OR Comparator
                | Accumulator AND Comparator
                | Comparator
                ;
Comparator      : Expression
                | PA Expression PF
                | Expression EQUALS Expression
                | Expression DIFF Expression
                | Expression GR Expression
                | Expression LESS Expression
                | Expression GREQUALS Expression
                | Expression LEQUALS Expression
                ;
Expression      : Expression PLUS P
                | Expression MINUS P
                | P
                ;
P               : P MULT F
                | p DIV Fat
                | Fat
                ;
Fat             : Es EXP Fat
                | Es
                ;
Es              : PA Expression PF
                | INT
                | V
                ;
%%
#include "lex.yy.c"

void yyerror(char *s) {
  fprintf(stderr, "linha %d: [%s] - %s\n", yylineno, yytext, s);
}

int main(){
    f = open("teste.vm", "w");
    yyparse();
    return 0;
}
