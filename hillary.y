%code requires{
	#include <stdio.h>
	#include <malloc.h>
	extern yylex(void);
	void yyerror (const char* s);
	
	typedef struct counter{
		long democrats;
		long republicans;
	}counter;
	
	/* we need YYSTYPE to be struct and not union,
	   because we using ival and electors(counter) in the same time
	*/
	typedef struct {
		int ival;
		counter electors;
	} YYSTYPE;
	
	extern YYSTYPE yylval;
}

%token STATE NAME ELECTORS 
%token <ival>NUM
%token DEMOCRATS REPUBLICANS WIN COUNTY HILLARY DONALD GARY JILL CANCELLED

%type <electors> statelist state 
%type <electors>countylist county winner
%error-verbose

%%
input: statelist {	if ($1.democrats > $1.republicans && $1.democrats >= 270)
						fprintf(stdout, "Hillary Clinton Win!\n");
					else if ($1.democrats < $1.republicans && $1.republicans >= 270)
						fprintf(stdout, "Donald Trump Win!\n");
					else fprintf(stdout, "No Winner!\n");
					if (isVerbose() == 1) 
					{
						fprintf(stdout, "Donald Trump has %d electors!\n", $1.republicans);
						fprintf(stdout, "Hillary Clinton has %d electors!\n", $1.democrats);
					}
				};
				
name: NAME | name NAME; /* Fix the proble with long names*/

statelist: /* empty */ {$$.democrats = 0; $$.republicans = 0;};

statelist: statelist state {
							$$.democrats += $2.democrats;
							$$.republicans += $2.republicans;
							};

state: STATE ':' name ';' ELECTORS ':' NUM ';' countylist { 
															if ($9.democrats > $9.republicans) {$$.democrats += $7 ;}
															else if ($9.democrats < $9.republicans) {$$.republicans += $7 ;}
															} |
															
       STATE ':' name ';' ELECTORS ':' NUM ';' winner { 
														if ($9.democrats == 1) {$$.democrats += $7;}
														else if ($9.republicans == 1) {$$.republicans += $7;}
														} |
														
       STATE ':' name ';' ELECTORS ':' NUM ';' CANCELLED {$$.democrats += 0 ; $$.republicans += 0 ;};

winner:  DEMOCRATS WIN '!'   {$$.democrats = 1;   $$.republicans = -1;} | 
         REPUBLICANS WIN '!' {$$.republicans = 1; $$.democrats = -1;};

countylist: /* empty */       {$$.democrats = 0; $$.republicans = 0;};

countylist: countylist county {
								$$.democrats += $2.democrats;
								$$.republicans += $2.republicans;
								};


county: COUNTY ':' name ';' HILLARY ':' NUM  DONALD ':' NUM optional_third_party {
																					$$.democrats += $7; 
																					$$.republicans += $10;
																					} |
																					
        COUNTY ':' name ';' NUM '(' 'D' ')' NUM '(' 'R' ')' {$$.republicans += $5; $$.democrats += $9; } ;

optional_third_party : GARY ':' NUM  |   JILL ':' NUM  |  /* empty */ ;
%%
int verbose_selected = 0;
main(int argc, char **argv)
{
	extern FILE *yyin;
	if (argc > 2 && strcmp(argv[2], "-v") == 0) {verbose_selected = 1; yyin = fopen(argv[1], "r");}
	else if (argc > 2 && strcmp(argv[1], "-v") == 0) {verbose_selected = 1; yyin = fopen(argv[2], "r");}
	else {yyin = fopen(argv[1], "r");}
	yyparse();
	fclose(yyin);
	return 0;
}

void yyerror(const char *s)
{
	fprintf(stderr, "%s\n", s);
}

int isVerbose() { return verbose_selected;}