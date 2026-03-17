#Date:        20FEB2026
#Analyst:     Beau Brouillette
#Description: The purpose of this script is to complete a initial analysis of text from the SFO Customer Experience surveys

#1 - Import CSV files
#call the pandas library, which will import the csv files as data frames;
import pandas as pd
#MAY (Pre-Upgrade)
DF_MAY = pd.read_csv('data/SFO_Screening_Checkpoint_Satisfaction_May__2019.csv')


#To prepare for concatenation, add new column TIMEFRAME at the beginning of the DF_MAY dataset to denote this as "PRE"
DF_MAY.insert(0,'TIMEFRAME','PRE')

#To align with OCT dataset, rename Q3A_TEXT as Q3A_VERBATIM
DF_MAY.rename(columns={'Q3A_TEXT': 'Q3A_VERBATIM'}, inplace = True)

#Display the first 5 rows of the May dataset as a check.
print(DF_MAY.head())


#OCT (Post-Upgrade)
DF_OCT = pd.read_csv('data/SFO_Screening_Checkpoint_Satisfaction_October__2019.csv')

#To prepare for concatenation, add new column TIMEFRAME at the beginning of the DF_MAY dataset to denote this as "POST"
DF_OCT.insert(0,'TIMEFRAME','POST')

#Display the first 5 rows of the Oct dataset as a check.
print(DF_OCT.head())


#Concatenate the two datasets
DF_COMBINED = pd.concat([DF_MAY, DF_OCT], ignore_index = True)

#Create a new dataframe DF_COMMENTS that contains only records where the Q3A verbatim column is not null
DF_COMMENTS = DF_COMBINED[DF_COMBINED['Q3A_VERBATIM'].notna()] 


#Begin the implementation of LLM model using bertopic
from bertopic import BERTopic
from sentence_transformers import SentenceTransformer

# 1. Initialize the LLM "Brain"
embedding_model = SentenceTransformer("all-MiniLM-L6-v2")
topic_model = BERTopic(embedding_model=embedding_model, nr_topics=20)

# 2. Run the model on your original verbatim column
# BERTopic handles the 'fit' and 'transform' in one step
docs = DF_COMMENTS['Q3A_VERBATIM'].astype(str).tolist()
topics, probs = topic_model.fit_transform(docs)

# 3. Create DF_COMMENTS3
# We copy the original data so we don't modify the source DF_COMMENTS
DF_COMMENTS3 = DF_COMMENTS.copy()

# 4. Add the new LLM scores
DF_COMMENTS3['LLM_Topic'] = topics
DF_COMMENTS3['LLM_Probability'] = probs

# 5. Get Human-Readable Labels
# This adds a column showing the top 3 words for each topic
topic_labels = topic_model.generate_topic_labels(nr_words=3, separator=", ")
DF_COMMENTS3['Topic_Label'] = DF_COMMENTS3['LLM_Topic'].map(
    {i-1: label for i, label in enumerate(topic_labels)}
)

#Display the first 5 rows of the result dataset as a check
print(DF_COMMENTS3[['Q3A_VERBATIM', 'LLM_Topic', 'Topic_Label']].head())

#Summarize the number of times a topic appears, 
    #the subset of times that happen in the pre- dataset,
    #and the average overall satisfaction rating.
    #Because I'm most comfortable implemeting these types of summaries in SQL, use pandasql for this...
from pandasql import sqldf
query = """
select Topic_Label,
    count(Topic_Label) as RECORD_CT,
    SUM(case when TIMEFRAME = 'PRE' then 1 else 0 end) as PRE_CT,
    AVG(Q3) as AVG_Q3_RATING
from DF_COMMENTS3
where Q3 in (1,2,3,4,5)
group by Topic_Label 
"""

#run the pandaSQL statement and display results
TOPIC_SUMMARY_LLM = sqldf(query, locals())
print(TOPIC_SUMMARY_LLM)

#Interesting results that I'm calling out for deck.  
#11          3, shoes, dirty, floors         19       6       3.368421
#13       5, repack, repacking, area         19       9       3.842105
#Both of these are more common in the post- sample, indicating direction that they haven't improved
#Both are associated with relatively low overall satisfaction.
#Noting that there's some wobble from run to run, which seems like it's a known issue with these types of analyses.
