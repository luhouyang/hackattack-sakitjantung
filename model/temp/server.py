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

# Load AI model (change hackattack_model to your folder name)
transaction_or_not_model = joblib.load('./hackattack_models/transaction_or_not.pkl')
with open('./hackattack_models/transaction_or_not_vectorizer.pkl', 'rb') as f:
    transaction_or_not_vectorizer = pickle.load(f)

money_in_out_model = joblib.load('./hackattack_models/money_in_out.pkl')
with open('./hackattack_models/money_in_out_vectorizer.pkl', 'rb') as f:
    money_in_out_vectorizer = pickle.load(f)

# specify http endpoint
@app.route('/api/classify', methods=['POST'])
def classify_data():
    content = request.json
    input_data_ton = transaction_or_not_vectorizer.transform([content['data']])
    input_data_mio = money_in_out_vectorizer.transform([content['data']])
    
    # Process the input data through your AI model
    prediction_ton = transaction_or_not_model.predict(input_data_ton)
    
    if (prediction_ton[0] == 0):
        response = {'prediction': transaction_or_not_classes[prediction_ton[0]]}
    else:
        prediction_mio = money_in_out_model.predict(input_data_mio)
        response = {'prediction': money_in_out_classes[prediction_mio[0]]}

    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9000)
