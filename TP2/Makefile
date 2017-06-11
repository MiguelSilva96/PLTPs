plang:
	flex plang.flex
	yacc plang.y
	cc `pkg-config --cflags --libs glib-2.0` y.tab.c -o plang

clean: 
	rm plang y.tab.c lex.yy.c
