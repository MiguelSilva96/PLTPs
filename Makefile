G=-lfl `pkg-config --cflags --libs glib-2.0`

normNomes: normNomes.fl
	flex normNomes.fl
	gcc lex.yy.c -o normNomes

convAcentos: convAcentos.fl
	flex convAcentos.fl
	gcc lex.yy.c -o convAcentos

exe1: exe1.fl
	flex exe1.fl
	gcc lex.yy.c $G -o exe1

genGraph: genGraph.fl 
	flex genGraph.fl
	gcc lex.yy.c -o genGraph

all: normNomes convAcentos exe1 genGraph

run:
	./convAcentos BibTEX/exemplo-utf8.bib
	./normNomes outAc.bib
	./genGraph out.bib
	dot -Tps Graph/graph.dot -o Graph/graph.ps


clean: 
	rm -f *.bib normNomes convAcentos genGraph exe1 lex.yy.c *.txt *.html
