G=-lfl `pkg-config --cflags --libs glib-2.0`

normNomes: normNomes.fl
	flex normNomes.fl
	gcc lex.yy.c -o normNomes

convAcentos: convAcentos.fl
	flex convAcentos.fl
	gcc lex.yy.c -o convAcentos

procIngles: procIngles.fl
	flex procIngles.fl
	gcc lex.yy.c $G -o procIngles

genGraph: genGraph.fl 
	flex genGraph.fl
	gcc lex.yy.c -o genGraph

all: normNomes convAcentos procIngles genGraph

run:
	./convAcentos BibTEX/exemplo-utf8.bib
	./normNomes outAc.bib
	./genGraph out.bib
	dot -Tps Graph/graph.dot -o Graph/graph.ps


clean: 
	rm -f *.bib normNomes convAcentos genGraph procIngles lex.yy.c *.txt *.html
