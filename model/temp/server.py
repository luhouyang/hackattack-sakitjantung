from flask import Flask, jsonify, request
import joblib

app = Flask(__name__)

# Load your AI model (example using joblib for scikit-learn model)
model = joblib.load('path_to_your_model.pkl')

@app.route('/api/classify', methods=['POST'])
def classify_data():
    content = request.json
    input_data = content['data']
    
    # Process the input data through your AI model
    prediction = model.predict([input_data])
    
    response = {'prediction': prediction[0]}
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9000)
