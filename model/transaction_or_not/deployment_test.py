#%%
# from sklearn.feature_extraction.text import TfidfVectorizer
# from sklearn.model_selection import train_test_split
# from sklearn.svm import SVC

import pandas as pd
import joblib
import pickle

### remove
# rawdata = pd.read_csv('transaction-notransaction.csv')
# rawdata = pd.read_csv('transaction-notransaction-2.csv')
rawdata = pd.read_csv('transaction-notransaction-3.csv')
rawdf = pd.DataFrame(rawdata)

text = rawdf.iloc[:, 0]
labels = rawdf.iloc[:, 1]
###

# load vectorizer and vector support machine
transaction_or_not_classes = {
    0: "NOT TRANSACTION",
    1: "TRANSACTION"
}
clf = joblib.load('transaction_or_not.pkl')

with open('transaction_or_not_vectorizer.pkl', 'rb') as f:
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
report = classification_report(y_pred, labels, target_names=[transaction_or_not_classes[0], transaction_or_not_classes[1]])

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
    return transaction_or_not_classes[prediction[0]]

# Example usecase
sample_text = "Transaction to Ali RM 2"
predicted_category = predict_category(sample_text)
print(f'The predicted category is: {predicted_category}')
#%%