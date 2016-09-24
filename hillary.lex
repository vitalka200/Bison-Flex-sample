%{
	#include <string.h>
	#include "hillary.tab.h"
	extern int atoi(const char*);
	
	
%}
%option noyywrap

%%
(S|s)tate {return STATE;}
(C|c)ounty {return COUNTY;}
(E|e)lectors {return ELECTORS;}
(C|c)ancelled {return CANCELLED;}
(D|d)emocrats {return DEMOCRATS;}
(R|r)epublicans {return REPUBLICANS;}
(W|w)in {return WIN;}
[;:()DR!] {return yytext[0];}

((G|g)ary)([[:space:]]+Johnson)? {return GARY;}
((J|j)ill)([[:space:]]+Stein)? {return JILL;}
((H|h)illary)([[:space:]]+Clinton)? {return HILLARY;}
((D|d)onald)([[:space:]]+Trump)? {return DONALD;}

[0-9]+ { yylval.ival = atoi(yytext);return NUM;}
[a-zA-Z]+ {;return NAME;}
[\n\t ]+ /*skip*/
%%