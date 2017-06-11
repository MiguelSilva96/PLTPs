%{
  #include <stdio.h>
  #include <math.h>
  int yyerror(char*);
  int yylex();
%}
%token VAR V INT BEGIN PREAD PPRINT STRING IF ELSE WHILE
%type<d> INT
%type<f> VAR BEGIN PREAD PPRINT STRING IF ELSE WHILE
%type<c> V

%%
Plang           : Init Body
                ;
Init            : VAR TP Declare
                ;
Declare         : Declare Variable
                | Variable
                ;
Variable        : V PV
                | V PA INT PF PV
                | V PA INT PF PA INT PF PV
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
Assignment      : V TO Expression PV
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

int yyerror(char *s){
    printf("erro: %s\n",s);
}

int main(){
    yyparse();
    return 0;
}
