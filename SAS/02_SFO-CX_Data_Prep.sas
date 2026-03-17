/*Date: 		17JAN2026*/
/*Analyst:		Beau Brouillette*/
/*Description:	The purpose of this script is to format the raw data from the import (00A-SFO_MAIN_IMPORT.sas) so that MAY and OCT responses
				are combined into a single dataset and the encoding of variables is human-readable (rather than numeric codes).
				Suffix _TX will be used to denote transformed/translated varaibles.
				_TX versions of variables will be encoded based on detail from data dictionary (codelist PDF) that accompanies these datasets.
				A review of the PDFs shows consistent encoding of variables between the MAY and OCT datasets.
				
				The final portion of this script will complete some quality assurance to ensure that the expected number of records is found in the dataset
				and that the data from the raw import variables is consistently translated into human-readable format and that translation matches
				expectations for that variable.

				The City and County of San Francisco has made some customer survey information publically available.
				These surveys capture customer satisfaction survey responses before and after an update to the TSA
				screening area at one of the San Francisco International Airport (SFO) terminals in 2019. 
				
				Details on the source of this data are provided below:
					SFO May URL: https://data.sfgov.org/Transportation/SFO-Screening-Checkpoint-Satisfaction-May-2019/jt6x-6hpy/about_data
					SFO Oct URL: https://data.sfgov.org/Transportation/SFO-Screening-Checkpoint-Satisfaction-October-2019/xyey-v962/about_data*/
					
proc sql;
	create table SFO_PRE_POST_SURVEY as
		select TIMEFRAME, 	/*User-defined variable TIMEFRAME with levels PRE = May 2019 pre-intervention responses, POST = October 2019 post-intervention responses*/
			
			/*ID variables from input files*/
			RESPNUM, 		/*Respondent Number – automatically generated during data entry*/
			CCGID,			/*CCG ID assigned durng batching*/
			RUNID,			/*Run on which survey was collected*/
			AREA,			/*[Not defined in codelist data dictionary. Retaining, but appears to be all 'D', so uninformative]
		
			/*Day and Date detail from raw import*/
			DAY,
			DATE format = date9., /*Need to specify DATE9 (ddMONyyyy) format because this did not come through in the import process*/
			
			/*METH: Method of collection*/
			METH,			/*Method of collection*/
			/*Use case logic to encode description from data dictionary*/
			case	when METH = 1 			then '1 - At Gate'
					when METH = 2 			then '2 - Mail-in'
					else '0 - Other/Unk/Missing' end 	as METH_TX,
					
			/*Q1: Did you go through security (e.g. security checkpoint) to enter this terminal today?*/
			Q1,
			case	when Q1 = 1				then '1 - Yes'
					when Q1 = 2 			then '2 - No'
					else '0 - Other/Unk/Missing' end 	as Q1_TX,
					
			/*Q2:How would you rate your SFO security checkpoint experience on each of the following:*/
				/*Data dictionary shows this encoding of Q2 and Q3 variables:
					5 Excellent
					4 
					3
					2
					1 Poor
					6 Don't know
					0 Blank*/
				/*As a first pass, I will create the TX version with 6/0/[null] combined into [null].  
					I will also populate descriptors for levels 2-4, though it looks like these were not present on the survey and are imputed for convenience*/
			/*Q2A: Courtesy of checkpoint entry staff*/
			Q2A,
			case	when Q2A = 5			then '5 - Excellent'
					when Q2A = 4			then '4 - Satisfactory'
					when Q2A = 3			then '3 - Neutral'
					when Q2A = 2			then '2 - Unsatisfactory'
					when Q2A = 1			then '1 - Poor'
					when Q2A in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2A_TX,
			/*Q2B: Courtesy of ID check podium staff*/
			Q2B,
			case	when Q2B = 5			then '5 - Excellent'
					when Q2B = 4			then '4 - Satisfactory'
					when Q2B = 3			then '3 - Neutral'
					when Q2B = 2			then '2 - Unsatisfactory'
					when Q2B = 1			then '1 - Poor'
					when Q2B in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2B_TX,
			/*Q2C: Courtesy and helpfulness of checkpoint screening staff*/
			Q2C,
			case	when Q2C = 5			then '5 - Excellent'
					when Q2C = 4			then '4 - Satisfactory'
					when Q2C = 3			then '3 - Neutral'
					when Q2C = 2			then '2 - Unsatisfactory'
					when Q2C = 1			then '1 - Poor'
					when Q2C in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2C_TX,
			/*Q2D: Efficiency of screening staff*/
			Q2D,
			case	when Q2D = 5			then '5 - Excellent'
					when Q2D = 4			then '4 - Satisfactory'
					when Q2D = 3			then '3 - Neutral'
					when Q2D = 2			then '2 - Unsatisfactory'
					when Q2D = 1			then '1 - Poor'
					when Q2D in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2D_TX,
			/*Q2E: Signage to checkpoint*/
			Q2E,
			case	when Q2E = 5			then '5 - Excellent'
					when Q2E = 4			then '4 - Satisfactory'
					when Q2E = 3			then '3 - Neutral'
					when Q2E = 2			then '2 - Unsatisfactory'
					when Q2E = 1			then '1 - Poor'
					when Q2E in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2E_TX,
			/*Q2F: Checkpoint organization*/
			Q2F,
			case	when Q2F = 5			then '5 - Excellent'
					when Q2F = 4			then '4 - Satisfactory'
					when Q2F = 3			then '3 - Neutral'
					when Q2F = 2			then '2 - Unsatisfactory'
					when Q2F = 1			then '1 - Poor'
					when Q2F in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2F_TX,
			/*Q2G: Waiting time in security line*/
			Q2G,
			case	when Q2G = 5			then '5 - Excellent'
					when Q2G = 4			then '4 - Satisfactory'
					when Q2G = 3			then '3 - Neutral'
					when Q2G = 2			then '2 - Unsatisfactory'
					when Q2G = 1			then '1 - Poor'
					when Q2G in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2G_TX,
			/*Q2H: Noise level*/
			Q2H,
			case	when Q2H = 5			then '5 - Excellent'
					when Q2H = 4			then '4 - Satisfactory'
					when Q2H = 3			then '3 - Neutral'
					when Q2H = 2			then '2 - Unsatisfactory'
					when Q2H = 1			then '1 - Poor'
					when Q2H in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2H_TX,
			/*Q2I: Music selection and volume*/
			Q2I,
			case	when Q2I = 5			then '5 - Excellent'
					when Q2I = 4			then '4 - Satisfactory'
					when Q2I = 3			then '3 - Neutral'
					when Q2I = 2			then '2 - Unsatisfactory'
					when Q2I = 1			then '1 - Poor'
					when Q2I in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2I_TX,
			/*Q2J: Space allotted for you to prepare to go through screening (where luggage is placed on conveyor, etc.)*/
			Q2J,
			case	when Q2J = 5			then '5 - Excellent'
					when Q2J = 4			then '4 - Satisfactory'
					when Q2J = 3			then '3 - Neutral'
					when Q2J = 2			then '2 - Unsatisfactory'
					when Q2J = 1			then '1 - Poor'
					when Q2J in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2J_TX,
			/*Q2K: Cleanliness of checkpoint area*/
			Q2K,
			case	when Q2K = 5			then '5 - Excellent'
					when Q2K = 4			then '4 - Satisfactory'
					when Q2K = 3			then '3 - Neutral'
					when Q2K = 2			then '2 - Unsatisfactory'
					when Q2K = 1			then '1 - Poor'
					when Q2K in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2K_TX,
			/*Q2L: Repacking area (once you’ve passed through security)*/
			Q2L,
			case	when Q2L = 5			then '5 - Excellent'
					when Q2L = 4			then '4 - Satisfactory'
					when Q2L = 3			then '3 - Neutral'
					when Q2L = 2			then '2 - Unsatisfactory'
					when Q2L = 1			then '1 - Poor'
					when Q2L in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q2L_TX,			

			/*Q3: Overall rating of security checkpoint*/
			Q3,
			case	when Q3 = 5				then '5 - Excellent'
					when Q3 = 4				then '4 - Satisfactory'
					when Q3 = 3				then '3 - Neutral'
					when Q3 = 2				then '2 - Unsatisfactory'
					when Q3 = 1				then '1 - Poor'
					when Q3 in (0,6)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q3_TX,	
					
			/*Q4: (Q4_1 to Q4_3) Which of the following lines/areas did you use to enter the security checkpoint today?*/
				/*Data dictionary shows this encoding of the Q4 variables:
					1 General/main security line
					2 PreCheck (or Pre ü)
					3 Premium
					4 CLEAR
					5 Other (specify)
					6 Don’t know
					7 Blank
					8 Disabled/special assistance (added by respondents)*/
				/*It's rare to have anything populated in Q4_2 or Q4_3.  These appear to indicate modifiers of the process, e.g. special assitance in general line*/
				/*As a first pass, let's collapse the multiple lines into a single response and also the Other/Unknown/Blank into a single line*/
			Q4_1,
			Q4_2,
			Q4_3,
			case	/*To start, we're going to scan the responses for the spillover variables to see if there's a substantive response
						that would indicate screening in multiple lines / processes.*/
					when Q4_1 not in (., 6, 7) and 			/*Null, Don't Know (6), and Blank(7) are not counted as substantive responses*/
							(		(Q4_2 not in (., 6, 7)) 	
								or 	(Q4_3 not in (., 6, 7))		
							)				then '9 - Multiple'
					when Q4_1 = 1			then '1 - General/Main'
					when Q4_1 = 2			then '2 - PreCheck'
					when Q4_1 = 3			then '3 - Premium'
					when Q4_1 = 4			then '4 - CLEAR'
					when Q4_1 = 8			then '8 - Special Assitance'
					when Q4_1 in (5,6,7)	then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q4_TX,


			/*Q5: How safe did you feel going through the security checkpoint at SFO today?*/
				/*Data dictionary shows this encoding of the Q5 variable:
					5 Very safe
					4
					3 Neutral
					2
					1 Not safe at all
					6 Don't know
					0 Blank*/
				/*As a first pass, I will create the TX version with 6/0/[null] combined into [null].
					I will also populate descriptors for levels 2 and 4, though it looks like these were not present on the survey and are imputed for convenience*/ 
			Q5,
			case	when Q5 = 5				then '5 - Very safe'
					when Q5 = 4				then '4 - Safe'
					when Q5 = 3				then '3 - Neutral'
					when Q5 = 2				then '2 - Not safe'
					when Q5 = 1				then '1 - Not safe at all'
					when Q5 in (6,0)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q5_TX,
			
			/*Q6: What is the primary purpose of your trip?*/
				/*Data dictonary shows this encoding of the Q6 variable:
					1 Business
					2 Personal
					3 Other (specify)
					0 Blank*/
				/*As a first pass, I will create the TX version with 6/0/[null] combined into [null].*/
			Q6,
			case	when Q6 = 1				then '1 - Business'
					when Q6 = 2				then '2 - Personal'
					when Q6 in (3,0)		then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q6_TX,
			
			/*Q7: About how many times have you flown out of SFO in the past 12 months?*/
				/*Data dictonary shows this encoding of the Q7 variable:
					1 1
					2 2
					3 3 to 4
					4 5 to 10
					5 11 to 20
					6 More than 20
					0 Blank*/
			Q7,
			case	when Q7 = 1				then '1 - 1'
					when Q7 = 2				then '2 - 2'
					when Q7 = 3				then '3 - 3 to 4'
					when Q7 = 4				then '4 - 5 to 10'
					when Q7 = 5				then '5 - 11 to 20'
					when Q7 = 6				then '5 - More than 20'
					when Q7 = 0				then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q7_TX,
			
			/*Q8: Do you live in...*/
				/*Data dictonary shows this encoding of the Q8 variable:
					1 The 9-county Bay Area
					2 Northern California outside the Bay Area
					3 Somewhere else in the United States
					4 Another country (outside of the U.S.)
					0 Blank*/
			Q8,
			case	when Q8 = 1				then '1 - The 9-county Bay Area'
					when Q8 = 2				then '2 - Northern California outside the Bay Area'
					when Q8 = 3				then '3 - Somewhere else in the United States'
					when Q8 = 4				then '4 - Another country (outside of the U.S.)'
					when Q8 = 0				then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q8_TX,
					
			/*Q9: Age*/
				/*Data dictonary shows this encoding of the Q9 variable:
					1 Under 18 [12]
					2 18-34 [26]
					3 35-44 [39.5]
					4 45-64 [54.5]
					5 65 and over [72]
					0 Blank*/
			Q9, 
			case	when Q9 = 1				then '1 - Under 18'
					when Q9 = 2				then '2 - 18-34'
					when Q9 = 3				then '3 - 35-44'
					when Q9 = 4				then '4 - 45-64'
					when Q9 = 5				then '5 - 65 and over'
					when Q9 = 0				then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q9_TX,
			/*Q10: Gender*/
				/*Data dictionary shows this encoding of the Q10 variable:
					1 Male
					2 Female
					3 Other (specify)
					0 Blank */
				/*As a first pass, I will create the TX version with 3/0/null combined into Ohter/Unknown/Missing*/
			Q10,
			case	when Q10 = 1			then '1 - Male'
					when Q10 = 2			then '2 - Female'
					when Q10 in  (3,0,.)	then '0 - Other/Unk/Missing'
					else '0 - Other/Unk/Missing' end as Q10_TX,
					
			/*LANG: Language of questionaire*/
			/*Data dictionary shows this encoding of the LANG variable:
				1 English
				2 Spanish
				3 Chinese*/
			LANG,
			case	when LANG = 1 			then '1 - English'
					when LANG = 2 			then '2 - Spanish'
					when LANG = 3 			then '3 - Chinese'
					else '0 - Other/Unk/Missing' end as LANG_TX,
			/*Q3A1, Q3A2, Q3A3: Textual Commnents (encoded)*/
			/*Data dictionary shows this encoding of Q3A Text variables (A1 to A3):
					1  GENERAL POSITIVE COMMENT
					2  POSITIVE COMMENT - STAFF
					3  POSITIVE COMMENT - SPEED/ORGANIZATION
					4  NEED BETTER ORGANIZATION
					5  CRAMPED/CROWDED - NEED MORE SPACE
					6  NEGATIVE COMMENT - STAFF
					7  UNCLEAR/CONFUSING INSTRUCTIONS/SIGNAGE/FELT RUSHED/INSUFFICIENT INSTRUCTIONS
					8  PROCESS TOOK TOO LONG/LINES TOO LONG/SPECIFIC SERVICES, ADDTL CHECKING TOOK LONGER THAN SHOULD HAVE
					9  AREA WAS DIRTY/CARPET WAS FILTHY CONSIDERING SHOES WERE OFF
					10 DOGS - POSITIVE COMMENT
					11 DOGS - NEGATIVE COMMENT
					12 NEED THE AREA TO BE QUIETER/TOO NOISY/DIDN'T NOTICE MUSIC
					13 BAD BEHAVIOR BY PASSENGERS (E.G. LINE CUTS) NOT ADDRESSED
					14 GENERAL NEGATIVE COMMENT
					15 COULD NOT FIND CORRECT LINE/WAS UNSURE WHICH LINE WAS WHICH
					16 OK/NOT GREAT; GENERAL NEUTRAL COMMENT
					17 NOT ENOUGH STAFF/NOT ENOUGH STAFF AT RIGHT LOCATIONS/LINES
					0  NO COMMENT PROVIDED */
			/*Note that we're also observing values of 18 and 20 that are not defined in the data dictionary
				Reviewing 20, this appears to be a positive comment about pre-check.
				18 looks like it's a negative comment about lack of containers to hold belongings*/
			Q3A1,
			Q3A2, 
			Q3A3
			/*For now, I am going to not encode these.  A better way to deck these up for analysis would be to
				create indicators based on the presence of comment types.
				Considering using Python to complete text analysis portion of project, as needed*/
		from
			/*The subquery below stacks the raw output from MAY (pre-intervention) and OCT (post-intervention) responses.
				I define the TIMEFRAME based on the raw data source - either the MAY or OCT dataset.
				Because the variable order and formats are consistent between the two datasets, I can use a union all to concatenate the two.*/
			(	select  'PRE' as TIMEFRAME,
					*
				from RAW_MAY_DAT
				
				union all
				
				select  'POST' as TIMEFRAME,
					*
				from RAW_OCT_DAT
		);
quit;


/*******************************/
/*Quality Assurance of Encoding*/
/*******************************/
proc freq data = SFO_PRE_POST_SURVEY;
	title 'QA of Encoding';
	title2 'For each raw variable, expect encoded value to align with raw value';
	tables METH*METH_TX / list missing;
	tables Q1*Q1_TX / list missing;
	tables Q2A*Q2A_TX/ list missing;
	tables Q2B*Q2B_TX/ list missing;
	tables Q2C*Q2C_TX/ list missing;
	tables Q2D*Q2D_TX/ list missing;
	tables Q2E*Q2E_TX/ list missing;
	tables Q2F*Q2F_TX/ list missing;
	tables Q2G*Q2G_TX/ list missing;
	tables Q2H*Q2H_TX/ list missing;
	tables Q2I*Q2I_TX/ list missing;
	tables Q2J*Q2J_TX/ list missing;
	tables Q2K*Q2K_TX/ list missing;
	tables Q2L*Q2L_TX/ list missing;
	tables Q3*Q3_TX/ list missing;
	tables Q4_1*Q4_2*Q4_3*Q4_TX/ list missing;
	tables Q5*Q5_TX/ list missing;
	tables Q6*Q6_TX/ list missing;
	tables Q7*Q7_TX/ list missing;
	tables Q8*Q8_TX/ list missing;
	tables Q9*Q9_TX/ list missing;
	tables Q10*Q10_TX/ list missing;
	tables LANG*LANG_TX/ list missing;
run; title''; title2'';
/*Pass - Encoding aligns with expectations based on all variables*/

/*******************************/
/*Check of Survey Counts********/
/*******************************/
proc freq data = SFO_PRE_POST_SURVEY;
	title 'Check of Survey Counts';
	title2 'Expect 403 PRE and 546 POST';
	tables TIMEFRAME / list missing;
run; title ''; title2'';
/*Pass - Counts match expectations based on review of raw files*/
