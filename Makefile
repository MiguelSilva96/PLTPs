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

all: normNomes convAcentos exe1

run:
	./convAcentos BibTEX/exemplo-utf8.bib
	./normNomes outAc.bib

clean: 
	rm -f out.bib outAc.bib normNomes convAcentos exe1 lex.yy.c lista.txt contracoes.txt