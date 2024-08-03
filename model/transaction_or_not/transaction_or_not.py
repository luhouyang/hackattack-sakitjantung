#%%
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC

from IPython.display import display

import pandas as pd


transaction_or_not_feature_map = {
    0: "NOT TRANSACTION",
    1: "TRANSACTION"
}


# rawdata = pd.read_csv('testdata.csv')
rawdata = pd.read_csv('transaction-notransaction.csv')
rawdf = pd.DataFrame(rawdata)

text = rawdf.iloc[:, 0]
labels = rawdf.iloc[:, 1]

display(rawdf.head())

vectorizer = TfidfVectorizer(stop_words='english', max_df=0.7)
vector_words = vectorizer.fit_transform(text)

# print(vectorizer.get_feature_names_out())

# X_train, X_test, y_train, y_test = train_test_split(vector_words, labels, test_size=0.2)

clf = SVC(kernel='linear')
clf.fit(vector_words, labels)
# clf.fit(X_train, y_train)


from sklearn.metrics import accuracy_score, classification_report

# Predict on the test set
y_pred = clf.predict(vector_words)
# y_pred = clf.predict(X_test)

# Evaluate the performance
accuracy = accuracy_score(y_pred, labels)
report = classification_report(y_pred, labels, target_names=[transaction_or_not_feature_map[0], transaction_or_not_feature_map[1]])

# accuracy = accuracy_score(y_pred, y_test)
# report = classification_report(y_pred, y_test, target_names=[transaction_or_not_feature_map[0], transaction_or_not_feature_map[1]])

print(f'Accuracy: {accuracy:.4f}')
print('Classification Report:')
print(report)


def predict_category(text):
    """
    Predict the category of a given text using the trained classifier.
    """
    text_vec = vectorizer.transform([text])
    prediction = clf.predict(text_vec)
    return transaction_or_not_feature_map[prediction[0]]

# Example usage
sample_text = "Not NASA announced the discovery of new exoplanets. There are chickens on there"
predicted_category = predict_category(sample_text)
print(f'The predicted category is: {predicted_category}')


import joblib
import pickle

joblib.dump(clf, 'transaction_or_not.pkl')

with open('transaction_or_not_vectorizer.pkl', 'wb') as f:
    pickle.dump(vectorizer, f)

#%%