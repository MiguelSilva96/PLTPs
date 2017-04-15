V=TPFlex

$V: $V.fl
	flex $V.fl
	gcc lex.yy.c -o $V