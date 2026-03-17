# SFO_CX_Survey
Code files to implement public portfolio project that analyzes customer survey responses about San Francisco International Airport (SFO) security screening. 

The City and County of San Francisco has made some customer survey information publicly available.
  These surveys capture customer satisfaction survey responses before and after an update to the TSA
  screening area at one of the SFO terminals in 2019. 
				
Details on the source of this data are provided below:
  SFO May URL: https://data.sfgov.org/Transportation/SFO-Screening-Checkpoint-Satisfaction-May-2019/jt6x-6hpy/about_data
  SFO Oct URL: https://data.sfgov.org/Transportation/SFO-Screening-Checkpoint-Satisfaction-October-2019/xyey-v962/about_data


## Tech Stack
- Web-Based SAS Studio (https://welcome.oda.sas.com)
- Anaconda (https://www.anaconda.com/download)

## Features
- Import and formatting of survey results in SAS
- Definition and use of custom SAS macro to evaluate changes between pre- and post- samples, collinearity between Likert questions, and contribution of Likert questions to overall satisfaction
- Implementation of finalized tests of statistical significance of changes between the two survey timepoints; preparation of summary information for presentation
- Implementation of LLM analysis in Python to identify topics in freeform text.  Evaluation of frequency of topics in pre- and post- sample to look for impacts of TSA updates.

## Contact
Beau Brouillette - [LinkedIn](https://www.linkedin.com/in/beau-brouillette) - brouillette.beau@gmail.com
