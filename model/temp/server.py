from flask import Flask, jsonify, request
import joblib
import pickle

app = Flask(__name__)

# classes maps
transaction_or_not_classes = {
    0: "NOT TRANSACTION",
    1: "TRANSACTION"
}

money_in_out_classes = {
    0: "MONEY OUT",
    1: "MONEY IN"
}

transaction_category_classes = {
    0: "TRANSPORTATION",
    1: "ENTERTAIMENT",
    2: "UTILITIES",
    3: "FOOD AND BEVERAGE",
    4: "OTHERS"
}

# Load AI model (change hackattack_model to your folder name)
transaction_or_not_model = joblib.load('./hackattack_models/transaction_or_not.pkl')
with open('./hackattack_models/transaction_or_not_vectorizer.pkl', 'rb') as f:
    transaction_or_not_vectorizer = pickle.load(f)

money_in_out_model = joblib.load('./hackattack_models/money_in_out.pkl')
with open('./hackattack_models/money_in_out_vectorizer.pkl', 'rb') as f:
    money_in_out_vectorizer = pickle.load(f)

transaction_category_model = joblib.load('./hackattack_models/transaction_category.pkl')
with open('./hackattack_models/transaction_category_vectorizer.pkl', 'rb') as f:
    transaction_category_vectorizer = pickle.load(f)

# specify http endpoint
@app.route('/api/classify', methods=['POST'])
def classify_data():
    content = request.json
    input_data_ton = transaction_or_not_vectorizer.transform([content['data']])
    input_data_mio = money_in_out_vectorizer.transform([content['data']])
    input_data_tc = transaction_category_vectorizer.transform([content['data']])
    
    # Process the input data through your AI model
    prediction_ton = transaction_or_not_model.predict(input_data_ton)
    
    if (prediction_ton[0] == 0):
        response = {'prediction': [transaction_or_not_classes[prediction_ton[0]], -1]}
    else:
        prediction_mio = money_in_out_model.predict(input_data_mio)
        prediction_tc = transaction_category_model.predict(input_data_tc)
        response = {
            'prediction': [
                money_in_out_classes[prediction_mio[0]],
                transaction_category_classes[prediction_tc[0]]
            ]
        }

    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9000)
