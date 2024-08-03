import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  classifyData("Ka-ching! Incoming money | aelbgla rg gg hehe boi Transaction to Hans, RM 10 with Touch n go");
}

Future<List<String>> classifyData(String message) async {
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
    print('Prediction: ${data['prediction']}');
  } else {
    print('Failed to load data');
  }

  return resList;
}
