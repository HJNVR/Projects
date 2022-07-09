import json
import pandas as pd

size = 1000000
review_json_path='yelp/yelp_academic_dataset_review.json'
review = pd.read_json(review_json_path, lines=True,chunksize=size)
chunk_list = []
for chunk_review in review:
     chunk_list.append(chunk_review)

df = pd.concat(chunk_list, ignore_index=True, join='outer', axis=0)
df.to_csv('yelp/review.csv', index=False)

business_json_path='yelp/yelp_academic_dataset_business.json'
business = pd.read_json(business_json_path, lines=True)
business.to_csv('yelp/review.csv', index=False)

print("end")