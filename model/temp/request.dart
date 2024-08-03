import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // classification test
  // int res1 = await classifyData(
  //     "Algorithm & Data Structure: Shashi Baka (OOP Lecturer) | Graphs.pptx");
  // int res2 = await classifyData(
  //     "Ka-ching! Incoming money | Transaction to Hans, RM 10 with Touch n go");
  // int res3 = await classifyData(
  //     "DuitNow Payment | You have paid RM6.00 to island one cafe and bakery.");
  // print("${res1} | ${res2} | ${res3}");

  // amount extraction test
  List<double> amounts = extractAmounts(
      "Algorithm & Data Structure: Shashi Baka (OOP Lecturer) | Graphs.pptx");
  amounts.addAll(extractAmounts(
      "Ka-ching! Incoming money | Transaction to Hans, RM 10 with Touch n go"));
  amounts.addAll(extractAmounts(
      "DuitNow Payment | You have paid RM6.00 to island one cafe and bakery."));

  for (var element in amounts) {
    print("${element}");
  }
}

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
    // print('Prediction: ${data['prediction']}');
  } else {
    resList.add("ERROR");
    // print('Failed to load data');
  }

  if (resList[0] == "ERROR") {
    print("Something went wong");
    return -1;
  } else {
    if (responseClasses[resList[0]] == 0) {
      print("NOT A TRANSACTION");
      return 0;
    } else if (responseClasses[resList[0]] == 1) {
      print("MONEY OUT");
      return 1;
    } else if (responseClasses[resList[0]] == 2) {
      print("MONEY IN");
      return 2;
    }
  }

  print("Something went wong");
  return -1;
}

// converts amounts
List<double> extractAmounts(String message) {
  // Regular expression to match amounts with "RM" in various formats
  final RegExp regExp = RegExp(r'RM\s?(\d+(?:\.\d+)?)', caseSensitive: false);
  List<double> amounts = [];

  // Find all matches in the message
  Iterable<RegExpMatch> matches = regExp.allMatches(message);

  // Convert matches to double and add to the list
  for (var match in matches) {
    String? amountStr = match.group(1);
    if (amountStr != null) {
      amounts.add(double.parse(amountStr));
    }
  }

  return amounts;
}
