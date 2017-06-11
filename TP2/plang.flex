%option noyywrap yylineno
%%
[0-9]+                        {
                              yylval.d = atoi(yytext);
                              return INT;
                              }
[\^+\-*/()=\n><;{}-\|&!]      {
                              return yytext[0];
                              }
VAR                           {
                              return VAR;
                              }
BEGIN                         {
                              return BEGIN;
                              }
Pread                         {
                              yylval.f = strdup(yytext);
                              return PREAD;
                              }
Pprint                        {
                              yylval.f = strdup(yytext);
                              return PPRINT;
                              }
if                            {
                              yylval.f = strdup(yytext);
                              return IF;
                              }
else                          {
                              yyval.f = strdup(yytext);
                              return ELSE;
                              }
while                         {
                              yyval.f = strdup(yytext);
                              return WHILE;
                              }
\"[^\"]*\"                    {
                              yyval.f = strdup(yytext);
                              return STRING;
                              }
[a-z]                         {
                              yylval.c = yytext[0];
                              return V;
                              }
[ \t]                          { }

%%
