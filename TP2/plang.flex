%option noyywrap yylineno


%%
-?[0-9]+        {
							yylval.d = atoi(yytext);
							return INTGR;
							}
[\^+\-*/\[\]=><;,():{}\|&!]		{
							return yytext[0];
							}
VAR                         {
							return VAR;
							}
START                       {
							return START;
							}
Pread                       {
							return PREAD;
							}
Pprint                      {
							return PPRINT;
							}
if                          {
							return IF;
							}
else                        {
							return ELSE;
							}
while                       {
							return WHILE;
							}
[a-z]+                      {
							yylval.s = strdup(yytext);
							return V;
							}
\"[^\n]*\"		{
							yylval.s = strdup(yytext);
							return STRING;
							}
[ \t\n]                     { }

.|\n 						{ yyerror("Caracter desconhecido"); }

%%
