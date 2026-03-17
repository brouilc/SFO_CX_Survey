/*Date: 		27JAN2026*/
/*Analyst:		Beau Brouillette*/
/*Description:	The purpose of this script is complete an initial scan of survey response variables to each other.
				I'm interested in quickly getting a read on how correlated the responses to questions are because
					1: Tight correlation between overall satisfaction and an explanitory variable is a main goal
					2: If two survey questions are tightly correlated with each other, they're giving more-or-less
						the same information and we'd probably only want to use one of those.*/

/*Create a blank dataset to use at the beginning of the macro. 
	This will be used to overwrite the previous results table to ensure that we're not carrying down results to the next set.*/
data BLANK;
input ID;
cards;
;
run;

/*Begin defining macro SCAN_VARS, which will take 3 pieces of information as input*/
%macro SCAN_VARS(VAR1, VAR2, OUTSET);
/*Set the results set to BLANK to avoid carrying down previous variable's output in the even of an error*/
data RESULTS1;
	set BLANK;
run;
data RESULTS2;
	set BLANK;
run;
/*Use Output Delivery System (ODS) to save the inforamtion in the chi-square table to dataset WORK.RESULTS1 
	and crosstab information into dataset WORK.RESULTS2*/
ods output ChiSq=RESULTS1;
ods output CrossTabFreqs=RESULTS2;
/*Run proc freq with chi-squared option enabled to get information about the strenght of association between
	VAR1 and VAR2 that are specified in the calling of the macro*/
proc freq data = SFO_PRE_POST_SURVEY;
	where 	&VAR1. ^= '0 - Other/Unk/Missing'
		and &VAR2. ^= '0 - Other/Unk/Missing'; /*Exclude cases where there is a non-informative response in either variable*/
	tables &VAR1.*&VAR2. / chisq;
run;
/*Use PROC SQL to pull out the single row from the chi-squared results that corresponds to Cramer's V*/
proc sql;
	create table &OUTSET as	
		select "&VAR1" as VAR1,
			"&VAR2" as VAR2,
			/*Total number of variables used alongside min and max cell size (b/c chi-squared isn't reliable without a healthy number (~5+) in each cell)*/
			t1.TOTAL_SAMPLE_SIZE,
			t1.MIN_CELL_SIZE,
			t1.MAX_CELL_SIZE,
			/*Capture Cramer's V statistic, which is analagous to r-squared in the comparison of categorical variables*/
			t2.VALUE as CRAMERS_V,
			/*Capture key details about the Chi-Squared test, even though these should be considered preliminary due to small counts in most cases*/
			t3.VALUE as CHISQ,
			t3.DF as CHISQ_DF,
			t3.PROB as CHISQ_PROB

		from 
			(	select 'OVERALL' as LEVEL,
					MAX(case when _TYPE_ = '00' then FREQUENCY else . end) as TOTAL_SAMPLE_SIZE,
					MIN(case when _TYPE_ = '11' then FREQUENCY else . end) as MIN_CELL_SIZE,
					MAX(case when _TYPE_ = '11' then FREQUENCY else . end) as MAX_CELL_SIZE
				from RESULTS2
				group by 1
			) t1,
			(	select *
				from RESULTS1
				where Statistic = "Cramer's V"
			) t2,
			(	select *
				from RESULTS1
				where STATISTIC = 'Chi-Square'
			) t3;
quit;
/*End the macro definition for SCAN_VARS*/
%mend SCAN_VARS;


/*Call macro SCAN_VARS iteratively to get strength of association between two variables*/
/*Interested in all of the Q2 variables against the main response variable Q3*/
%SCAN_VARS(Q2A_TX, Q3_TX, Q2A_RESP1);
%SCAN_VARS(Q2B_TX, Q3_TX, Q2B_RESP1);
%SCAN_VARS(Q2C_TX, Q3_TX, Q2C_RESP1);
%SCAN_VARS(Q2D_TX, Q3_TX, Q2D_RESP1);
%SCAN_VARS(Q2E_TX, Q3_TX, Q2E_RESP1);
%SCAN_VARS(Q2F_TX, Q3_TX, Q2F_RESP1);
%SCAN_VARS(Q2G_TX, Q3_TX, Q2G_RESP1);
%SCAN_VARS(Q2H_TX, Q3_TX, Q2H_RESP1);
%SCAN_VARS(Q2I_TX, Q3_TX, Q2I_RESP1);
%SCAN_VARS(Q2J_TX, Q3_TX, Q2J_RESP1);
%SCAN_VARS(Q2K_TX, Q3_TX, Q2K_RESP1);
%SCAN_VARS(Q2L_TX, Q3_TX, Q2L_RESP1);

/*Interested in how correlated Q2 variables are to each other...*/
%SCAN_VARS(Q2A_TX, Q2B_TX, Q2A_CORR1);
%SCAN_VARS(Q2A_TX, Q2C_TX, Q2A_CORR2);
%SCAN_VARS(Q2A_TX, Q2D_TX, Q2A_CORR3);
%SCAN_VARS(Q2A_TX, Q2E_TX, Q2A_CORR4);
%SCAN_VARS(Q2A_TX, Q2F_TX, Q2A_CORR5);
%SCAN_VARS(Q2A_TX, Q2G_TX, Q2A_CORR6);
%SCAN_VARS(Q2A_TX, Q2H_TX, Q2A_CORR7);
%SCAN_VARS(Q2A_TX, Q2I_TX, Q2A_CORR8);
%SCAN_VARS(Q2A_TX, Q2J_TX, Q2A_CORR9);
%SCAN_VARS(Q2A_TX, Q2K_TX, Q2A_CORR10);
%SCAN_VARS(Q2A_TX, Q2L_TX, Q2A_CORR11);

/*Note that we dont have to compare A to B again.
	Each variable down the list will have one fewer comparison needed, such that we won't have to compare Q2L to any of the other Q2 variables again*/
%SCAN_VARS(Q2B_TX, Q2C_TX, Q2B_CORR1);
%SCAN_VARS(Q2B_TX, Q2D_TX, Q2B_CORR2);
%SCAN_VARS(Q2B_TX, Q2E_TX, Q2B_CORR3);
%SCAN_VARS(Q2B_TX, Q2F_TX, Q2B_CORR4);
%SCAN_VARS(Q2B_TX, Q2G_TX, Q2B_CORR5);
%SCAN_VARS(Q2B_TX, Q2H_TX, Q2B_CORR6);
%SCAN_VARS(Q2B_TX, Q2I_TX, Q2B_CORR7);
%SCAN_VARS(Q2B_TX, Q2J_TX, Q2B_CORR8);
%SCAN_VARS(Q2B_TX, Q2K_TX, Q2B_CORR9);
%SCAN_VARS(Q2B_TX, Q2L_TX, Q2B_CORR10);

%SCAN_VARS(Q2C_TX, Q2D_TX, Q2C_CORR1);
%SCAN_VARS(Q2C_TX, Q2E_TX, Q2C_CORR2);
%SCAN_VARS(Q2C_TX, Q2F_TX, Q2C_CORR3);
%SCAN_VARS(Q2C_TX, Q2G_TX, Q2C_CORR4);
%SCAN_VARS(Q2C_TX, Q2H_TX, Q2C_CORR5);
%SCAN_VARS(Q2C_TX, Q2I_TX, Q2C_CORR6);
%SCAN_VARS(Q2C_TX, Q2J_TX, Q2C_CORR7);
%SCAN_VARS(Q2C_TX, Q2K_TX, Q2C_CORR8);
%SCAN_VARS(Q2C_TX, Q2L_TX, Q2C_CORR9);

%SCAN_VARS(Q2D_TX, Q2E_TX, Q2D_CORR1);
%SCAN_VARS(Q2D_TX, Q2F_TX, Q2D_CORR2);
%SCAN_VARS(Q2D_TX, Q2G_TX, Q2D_CORR3);
%SCAN_VARS(Q2D_TX, Q2H_TX, Q2D_CORR4);
%SCAN_VARS(Q2D_TX, Q2I_TX, Q2D_CORR5);
%SCAN_VARS(Q2D_TX, Q2J_TX, Q2D_CORR6);
%SCAN_VARS(Q2D_TX, Q2K_TX, Q2D_CORR7);
%SCAN_VARS(Q2D_TX, Q2L_TX, Q2D_CORR8);

%SCAN_VARS(Q2E_TX, Q2F_TX, Q2E_CORR1);
%SCAN_VARS(Q2E_TX, Q2G_TX, Q2E_CORR2);
%SCAN_VARS(Q2E_TX, Q2H_TX, Q2E_CORR3);
%SCAN_VARS(Q2E_TX, Q2I_TX, Q2E_CORR4);
%SCAN_VARS(Q2E_TX, Q2J_TX, Q2E_CORR5);
%SCAN_VARS(Q2E_TX, Q2K_TX, Q2E_CORR6);
%SCAN_VARS(Q2E_TX, Q2L_TX, Q2E_CORR7);

%SCAN_VARS(Q2F_TX, Q2G_TX, Q2F_CORR1);
%SCAN_VARS(Q2F_TX, Q2H_TX, Q2F_CORR2);
%SCAN_VARS(Q2F_TX, Q2I_TX, Q2F_CORR3);
%SCAN_VARS(Q2F_TX, Q2J_TX, Q2F_CORR4);
%SCAN_VARS(Q2F_TX, Q2K_TX, Q2F_CORR5);
%SCAN_VARS(Q2F_TX, Q2L_TX, Q2F_CORR6);

%SCAN_VARS(Q2G_TX, Q2H_TX, Q2G_CORR1);
%SCAN_VARS(Q2G_TX, Q2I_TX, Q2G_CORR2);
%SCAN_VARS(Q2G_TX, Q2J_TX, Q2G_CORR3);
%SCAN_VARS(Q2G_TX, Q2K_TX, Q2G_CORR4);
%SCAN_VARS(Q2G_TX, Q2L_TX, Q2G_CORR5);

%SCAN_VARS(Q2H_TX, Q2I_TX, Q2H_CORR1);
%SCAN_VARS(Q2H_TX, Q2J_TX, Q2H_CORR2);
%SCAN_VARS(Q2H_TX, Q2K_TX, Q2H_CORR3);
%SCAN_VARS(Q2H_TX, Q2L_TX, Q2H_CORR4);

%SCAN_VARS(Q2I_TX, Q2J_TX, Q2I_CORR1);
%SCAN_VARS(Q2I_TX, Q2K_TX, Q2I_CORR2);
%SCAN_VARS(Q2I_TX, Q2L_TX, Q2I_CORR3);

%SCAN_VARS(Q2J_TX, Q2K_TX, Q2J_CORR1);
%SCAN_VARS(Q2J_TX, Q2L_TX, Q2J_CORR2);

%SCAN_VARS(Q2K_TX, Q2L_TX, Q2K_CORR1);

/*Finally, let's look at how variables differ between pre- and post- intervention surveys...*/
%SCAN_VARS(Q2A_TX, 	TIMEFRAME, Q2A_TIME);
%SCAN_VARS(Q2B_TX, 	TIMEFRAME, Q2B_TIME);
%SCAN_VARS(Q2C_TX, 	TIMEFRAME, Q2C_TIME);
%SCAN_VARS(Q2D_TX, 	TIMEFRAME, Q2D_TIME);
%SCAN_VARS(Q2E_TX, 	TIMEFRAME, Q2E_TIME);
%SCAN_VARS(Q2F_TX, 	TIMEFRAME, Q2F_TIME);
%SCAN_VARS(Q2G_TX, 	TIMEFRAME, Q2G_TIME);
%SCAN_VARS(Q2H_TX, 	TIMEFRAME, Q2H_TIME);
%SCAN_VARS(Q2I_TX, 	TIMEFRAME, Q2I_TIME);
%SCAN_VARS(Q2J_TX, 	TIMEFRAME, Q2J_TIME);
%SCAN_VARS(Q2K_TX, 	TIMEFRAME, Q2K_TIME);
%SCAN_VARS(Q2L_TX, 	TIMEFRAME, Q2L_TIME);
%SCAN_VARS(Q3_TX, 	TIMEFRAME, Q3_TIME);

/*Concatenate the results datasets*/
data RESULTS_STACK;
	format VAR1 VAR2 $20.;
	set Q2A_RESP1 Q2B_RESP1 Q2C_RESP1 Q2D_RESP1 Q2E_RESP1 Q2F_RESP1 Q2G_RESP1 Q2H_RESP1 Q2I_RESP1 Q2J_RESP1 Q2K_RESP1 Q2L_RESP1
		Q2A_CORR1 Q2A_CORR2 Q2A_CORR3 Q2A_CORR4 Q2A_CORR5 Q2A_CORR6 Q2A_CORR7 Q2A_CORR8 Q2A_CORR9 Q2A_CORR10 Q2A_CORR11
		Q2B_CORR1 Q2B_CORR2 Q2B_CORR3 Q2B_CORR4 Q2B_CORR5 Q2B_CORR6 Q2B_CORR7 Q2B_CORR8 Q2B_CORR9 Q2B_CORR10
		Q2C_CORR1 Q2C_CORR2 Q2C_CORR3 Q2C_CORR4 Q2C_CORR5 Q2C_CORR6 Q2C_CORR7 Q2C_CORR8 Q2C_CORR9
		Q2D_CORR1 Q2D_CORR2 Q2D_CORR3 Q2D_CORR4 Q2D_CORR5 Q2D_CORR6 Q2D_CORR7 Q2D_CORR8 
		Q2E_CORR1 Q2E_CORR2 Q2E_CORR3 Q2E_CORR4 Q2E_CORR5 Q2E_CORR6 Q2E_CORR7
		Q2F_CORR1 Q2F_CORR2 Q2F_CORR3 Q2F_CORR4 Q2F_CORR5 Q2F_CORR6
		Q2G_CORR1 Q2G_CORR2 Q2G_CORR3 Q2G_CORR4 Q2G_CORR5
		Q2H_CORR1 Q2H_CORR2 Q2H_CORR3 Q2H_CORR4
		Q2I_CORR1 Q2I_CORR2 Q2I_CORR3
		Q2J_CORR1 Q2J_CORR2
		Q2K_CORR1 
		Q2A_TIME Q2B_TIME Q2C_TIME Q2D_TIME Q2E_TIME Q2F_TIME Q2G_TIME Q2H_TIME Q2I_TIME Q2J_TIME Q2K_TIME Q2L_TIME Q3_TIME
	;
run;


proc print data = RESULTS_STACK noobs;
run;


/*Let's look closer at the direction of changes pre- and post- for likert variables that were significantly different by timeframe...*/
proc freq data = SFO_PRE_POST_SURVEY;
	where 	Q2A_TX ^= '0 - Other/Unk/Missing'; 
	tables 	TIMEFRAME*Q2A_TX;
run;
proc freq data = SFO_PRE_POST_SURVEY;
	where 	Q2C_TX ^= '0 - Other/Unk/Missing'; 
	tables 	TIMEFRAME*Q2C_TX;
run;
proc freq data = SFO_PRE_POST_SURVEY;
	where 	Q2D_TX ^= '0 - Other/Unk/Missing'; 
	tables 	TIMEFRAME*Q2D_TX;
run;
proc freq data = SFO_PRE_POST_SURVEY;
	where 	Q2F_TX ^= '0 - Other/Unk/Missing'; 
	tables 	TIMEFRAME*Q2F_TX;
run;
proc freq data = SFO_PRE_POST_SURVEY;
	where 	Q3_TX ^= '0 - Other/Unk/Missing'; 
	tables 	TIMEFRAME*Q3_TX;
run;
