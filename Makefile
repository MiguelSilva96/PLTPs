V=TPFlex

tpflex: $V.fl
	flex $V.fl
	gcc lex.yy.c -o $V