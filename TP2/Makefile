plang:
	flex plang.flex
	yacc plang.y
	cc y.tab.c `pkg-config --cflags --libs glib-2.0` -o plang

clean: 
	rm plang y.tab.c lex.yy.c
