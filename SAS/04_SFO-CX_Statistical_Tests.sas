/*Date: 		16FEB2026*/
/*Analyst:		Beau Brouillette*/
/*Description:	The purpose of this script is to compile an overall satisfaction summary for the SFO Customer Experience project.

				Net Promoter Score is not appropriate for a summary of Question 3 because it does not read "How likely are you to recommend..."
				Therefore, we're going to present mean score of the responses that are informative (i.e. 1 - 5).
				
				After calculating mean score, there will be some quality assurance to ensure that this calculation is correct.
				
				Will also do a t-test of mean score to determine whether the observed difference is statistically significant, which is a 
				different test than the chi-square in script 01A.  That test asked whether the distribution of scores between pre and post
				test was the same.*/
				
/*Compiling the top-line MEAN_SCORE summary*/
proc sql;
	create table MEAN_SCORE_SUMMARY as
		select *,
			/*Calculate mean score as (5*Q3_5_EXCL_CT+4*Q3_4_SAT_CT+...+1*Q3_1_POOR_CT) / Q3_RESPONSE_CT*/
				(	5*Q3_5_EXCL_CT 	+
					4*Q3_4_SAT_CT 	+ 
					3*Q3_3_NEUT_CT 	+ 
					2*Q3_2_UNSAT_CT +
					1*Q3_1_POOR_CT
				) / Q3_RESPONSE_CT as Q3_MEAN_SCORE_V1 format = 4.2
		from 
			(	select TIMEFRAME,
					count(TIMEFRAME) as TOTAL_RESPONSE_CT,
					sum(case when Q3_TX ^= '0 - Other/Unk/Missing' 		then 1 else 0 end) as Q3_RESPONSE_CT,
					sum(case when Q3_TX  = '0 - Other/Unk/Missing'		then 1 else 0 end) as Q3_0_OTHR_CT,
					sum(case when Q3_TX  = '1 - Poor'					then 1 else 0 end) as Q3_1_POOR_CT,
					sum(case when Q3_TX  = '2 - Unsatisfactory'			then 1 else 0 end) as Q3_2_UNSAT_CT,
					sum(case when Q3_TX  = '3 - Neutral'				then 1 else 0 end) as Q3_3_NEUT_CT,
					sum(case when Q3_TX  = '4 - Satisfactory'			then 1 else 0 end) as Q3_4_SAT_CT,
					sum(case when Q3_TX  = '5 - Excellent'				then 1 else 0 end) as Q3_5_EXCL_CT,
					
					/*For use in testing, calculate total of raw Q3 and alternate calculation of Mean score when value is 1-5...*/
					sum(case when Q3 in (1,2,3,4,5)						then Q3 else 0 end) as Q3_SUM,
					mean(case when Q3 in (1,2,3,4,5)					then Q3 else . end) as Q3_MEAN_SCORE_V2 format = 4.2,
					
					/*After testing confirming the logic for Q3_MEAN_SCORE_V2 worked well, applying this to 4 key drivers*/
					mean(case when Q2D in (1,2,3,4,5)					then Q2D else . end) 	as Q2D_MEAN_SCORE_V2 format = 4.2,
					mean(case when Q2F in (1,2,3,4,5)					then Q2F else . end) 	as Q2F_MEAN_SCORE_V2 format = 4.2,
					mean(case when Q2K in (1,2,3,4,5)					then Q2K else . end) 	as Q2K_MEAN_SCORE_V2 format = 4.2,
					mean(case when Q2C in (1,2,3,4,5)					then Q2C else . end) 	as Q2C_MEAN_SCORE_V2 format = 4.2
				from SFO_PRE_POST_SURVEY
				group by TIMEFRAME					
			);
quit;

/*Testing: Create a dataset that does a series of checks that the information in MEAN_SCORE_SUMMARY is logical / meets expectations*/
/*Note that these tests use ROUND to account for small differences (e.g. 1^e-26) that occasionally throw false positives in testing 
	and would be negligible in the top line reporting.*/
proc sql;
	create table TEST_MEAN_SCORE_SUMMARY as	
		select 
			/*MS_TEST1: Check that TOTAL_RESPONSE_CT meets expectations (PRE = 403 and POST = 546) based on import summaries*/
				case	when TIMEFRAME = 'PRE' 	and TOTAL_RESPONSE_CT = 403 	then '1 - PRE CT = 403'
						when TIMEFRAME = 'POST' and TOTAL_RESPONSE_CT = 546 	then '2 - POST CT = 546'
						else '9 - Other' end as MS_TEST1_RESULT,
			/*MS_TEST2: Check that TOTAL_RESPONSE_CT = Q3_0_OTHR_CT + Q3_RESPONSE_CT.  In other words, we're excluding "0 - Other/Unk/Missing"*/
				case	when round(TOTAL_RESPONSE_CT, 0.01) = round((Q3_0_OTHR_CT + Q3_RESPONSE_CT),0.01) 	then '1 - TOTAL_RESPONSE_CT = Q3_0_OTHR_CT + Q3_RESPONSE_CT'
						else '9 - Other' end as MS_TEST2_RESULT,
			/*MS_TEST3: Compare two versions of Q3_MEAN_SCORE compiled with different calculations to ensure alignment.*/
				case	when round(Q3_MEAN_SCORE_V1,0.01) = round(Q3_MEAN_SCORE_V2,0.01) then '1 - Q3_MEAN_SCORE_V1 = Q3_MEAN_SCORE_V2'
						else '9 - Other' end as MS_TEST3_RESULT
		from MEAN_SCORE_SUMMARY;
quit;

proc freq data = TEST_MEAN_SCORE_SUMMARY;
	title 'MS_TEST1: Check that TOTAL_RESPONSE_CT meets expectations (PRE = 403 and POST = 546) based on import summaries';
	title2 'Expect MS_TEST1_RESULT to be scenario 1 or 2 (i.e. no 9)';
	tables MS_TEST1_RESULT / missing;
run; title ''; title2'';
proc freq data = TEST_MEAN_SCORE_SUMMARY;
	title 'MS_TEST2: Check that TOTAL_RESPONSE_CT = Q3_0_OTHR_CT + Q3_RESPONSE_CT.  In other words, we are excluding "0 - Other/Unk/Missing"';
	title2 'Expect MS_TEST2_RESULT to be scenario 1 (i.e. no 9)';
	tables MS_TEST2_RESULT / missing;
run; title ''; title2'';
proc freq data = TEST_MEAN_SCORE_SUMMARY;
	title 'MS_TEST3: Compare two versions of Q3_MEAN_SCORE compiled with different calculations to ensure alignment.';
	title2 'Expect MS_TEST3_RESULT to be scenario 1 (i.e. no 9)';
	tables MS_TEST3_RESULT / missing;
run; title ''; title2'';
/*All tests are passed*/

/*Display results*/
proc print data = MEAN_SCORE_SUMMARY noobs;
run;


/*Run a statisical test to compare the mean between timeframe.
	GLM is general linear model that will determine whether the average value of Q3 is different between PRE and POST timeframe*/
proc glm data = SFO_PRE_POST_SURVEY;
	class TIMEFRAME; /*Set TIMEFRAME as a classification (i.e. not continuous) predictor of Q3*/
	where Q3_TX ^= '0 - Other/Unk/Missing'; /*Exclude from the analysis any cases where Q3 is not 1-5 Likert response*/
	model Q3 = TIMEFRAME / solution; /*Using the numeric Q3 variable, see if there is a difference by class variable timeframe.  Solution option requests detail on means*/
run;
/*The observed difference is statistically significant.  The box plot calls out a limitation here, which is that we/re not looking at a true 
	continuous variable that has a errors that are normally distributed.*/
	
/*Let's see if we would get a different answer with the more correct ordinal logisitc regress*/
proc logistic data = SFO_PRE_POST_SURVEY;
	class TIMEFRAME; /*Set TIMEFRAME as a classification (i.e. not continuous) predictor of Q3*/
	where Q3_TX ^= '0 - Other/Unk/Missing'; /*Exclude from the analysis any cases where Q3 is not 1-5 Likert response*/
	model Q3 = TIMEFRAME; /*Using the numeric Q3 variable, see if there is a difference by class variable timeframe.  Solution option requests detail on means*/
	effectplot / polybar;
run;
/*No.  With this test, which is the most appropriate so far, we still see that there's a significant difference between the two timeframes.
	The effect shows that the POST scores are improved relative to the PRE-intervention scores.*/
	
/*Repeating this statistical test with the top 4 drivers...*/
proc logistic data = SFO_PRE_POST_SURVEY;
	class TIMEFRAME;
	where Q2D_TX ^= '0 - Other/Unk/Missing';
	model Q2D = TIMEFRAME;
	effectplot / polybar;
run; /*Borderline statistical significance.*/
proc logistic data = SFO_PRE_POST_SURVEY;
	class TIMEFRAME;
	where Q2F_TX ^= '0 - Other/Unk/Missing';
	model Q2F = TIMEFRAME;
	effectplot / polybar;
run; /*Not sigificant*/
proc logistic data = SFO_PRE_POST_SURVEY;
	class TIMEFRAME;
	where Q2K_TX ^= '0 - Other/Unk/Missing';
	model Q2K = TIMEFRAME;
	effectplot / polybar;
run; /*Not sigificant*/
proc logistic data = SFO_PRE_POST_SURVEY;
	class TIMEFRAME;
	where Q2C_TX ^= '0 - Other/Unk/Missing';
	model Q2C = TIMEFRAME;
	effectplot / polybar;
run; /*Significant*/
