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

flexToDot1: flexToDot1.fl
		flex flexToDot1.fl
		gcc lex.yy.c -o flexToDot1

flexToDot2: flexToDot2.fl
		flex flexToDot2.fl
		gcc lex.yy.c -o flexToDot2

flexToDot1: flexToDot3.fl
		flex flexToDot3.fl
		gcc lex.yy.c -o flexToDot3


all: normNomes convAcentos exe1

run:
	./convAcentos BibTEX/exemplo-utf8.bib
	./normNomes outAc.bib
	./flexToDot1 out.bib
	./flexToDot2 out2.bib
	./flexToDot3 out3.bib
	dot -Tps graph.dot -o graph.ps

clean: 
	rm -f out.bib outAc.bib normNomes convAcentos exe1 lex.yy.c lista.txt contracoes.txt
