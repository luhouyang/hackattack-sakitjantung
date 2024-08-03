#%%
# from sklearn.feature_extraction.text import TfidfVectorizer
# from sklearn.model_selection import train_test_split
# from sklearn.svm import SVC

import pandas as pd
import joblib
import pickle

### remove
rawdata = pd.read_csv('moneyin-moneyout.csv')
rawdf = pd.DataFrame(rawdata)

text = rawdf.iloc[:, 0]
labels = rawdf.iloc[:, 1]
###

# load vectorizer and vector support machine
money_in_out_classes = {
    0: "MONEY OUT",
    1: "MONEY IN"
}

clf = joblib.load('money_in_out.pkl')

with open('money_in_out_vectorizer.pkl', 'rb') as f:
    vectorizer = pickle.load(f)


### remove
vector_words = vectorizer.transform(text)
###

###
from sklearn.metrics import accuracy_score, classification_report

# Predict on the test set
y_pred = clf.predict(vector_words)

# Evaluate the performance
accuracy = accuracy_score(y_pred, labels)
report = classification_report(y_pred, labels, target_names=[money_in_out_classes[0], money_in_out_classes[1]])

print(f'Accuracy: {accuracy:.4f}')
print('Classification Report:')
print(report)
### remove


# predict one class
def predict_category(text):
    """
    Predict the category of a given text using the trained classifier.
    """
    text_vec = vectorizer.transform([text])
    prediction = clf.predict(text_vec)
    return money_in_out_classes[prediction[0]]

# Example usecase
sample_text = "DuitNow Transfer is successful! | You have successfully transferred RM 10.00 to MICHAEL TAN"
predicted_category = predict_category(sample_text)
print(f'The predicted category is: {predicted_category}')
#%%