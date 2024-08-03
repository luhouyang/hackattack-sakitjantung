# Sakit Jantung

---

**Hack Attack 2024**

## About

* Flutter code base is in `flutterapp/sakitjantung`

* Classifier model data & training info is in `model`

## Alibaba Cloud ECS & Classifier Configurations

1. Create ECS instance (Ubuntu 22.0.4, 2 cores, 4GB ram)

1. Configure

```
sudo apt-get update

python3 -m venv hackattack
source hackattack/bin/activate

pip install pandas
pip install -U scikit-learn
pip install Flask
```

1. Create folder in root `models`

1. Upload `.pkl` files into the folder

1. Run `nano transaction_classifier.py`

1. Paste code into file

```python
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
```

1. Run script with `python3 transaction_classifier.py`

1. In Flutter app, make http call

```dart
// invoke function
int res1 = await classifyData("YOUR MESSAGE");
```

```dart
// http function
Future<int> classifyData(String message) async {
    Map<String, int> responseClasses = {
        "NOT TRANSACTION": 0,
        "MONEY OUT": 1,
        "MONEY IN": 2
    };

    List<String> resList = [];

    final url = Uri.parse('http://47.250.87.162:9000/api/classify');
    final response = await http.post(
        url,
        headers: {
            'Content-Type': 'application/json',
        },
        body: json.encode({'data': message}),
    );

    if (response.statusCode == 200) {
        final data = json.decode(response.body);
        resList.add(data['prediction']);
    } else {
        resList.add("ERROR");
    }

    if (resList[0] == "ERROR") {
        debugPrint("Something went wong");
    return -1;
    } else {
        if (responseClasses[resList[0]] == 0) {
            debugPrint("NOT A TRANSACTION");
            return 0;
        } else if (responseClasses[resList[0]] == 1) {
            debugPrint("MONEY OUT");
            return 1;
        } else if (responseClasses[resList[0]] == 2) {
            debugPrint("MONEY IN");
            return 2;
        }
    }

debugPrint("Something went wong");
return -1;
}
```