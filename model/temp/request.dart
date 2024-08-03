import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // classification test
  List<int> res1 = await classifyData(
      "Algorithm & Data Structure: Shashi Baka (OOP Lecturer) | Graphs.pptx");
  // List<int> res2 = await classifyData(
  //     "Ka-ching! Incoming money | Transaction to Hans, RM 10 with Touch n go");
  // List<int> res3 = await classifyData(
  //     "DuitNow Payment | You have paid RM6.00 to island one cafe and bakery.");
  // print("${res1} | ${res2} | ${res3}");
  print("${res1}");

  // // amount extraction test
  // List<double> amounts = extractAmounts(
  //     "Algorithm & Data Structure: Shashi Baka (OOP Lecturer) | Graphs.pptx");
  // amounts.addAll(extractAmounts(
  //     "Ka-ching! Incoming money | Transaction to Hans, RM 10 with Touch n go"));
  // amounts.addAll(extractAmounts(
  //     "DuitNow Payment | You have paid RM6.00 to island one cafe and bakery."));

  // for (var element in amounts) {
  //   print("${element}");
  // }
}

Future<List<int>> classifyData(String message) async {
  Map<String, int> responseType = {
    "NOT TRANSACTION": 0,
    "MONEY OUT": 1,
    "MONEY IN": 2
  };

  Map<String, int> transactionCategory = {
    "TRANSPORTATION": 0,
    "ENTERTAIMENT": 1,
    "UTILITIES": 2,
    "FOOD AND BEVERAGE": 3,
    "OTHERS": 4,
    "NOT TRANSACTION": 5,
  };

  List<String> resList = [];
  List<int> retList = [];

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
    resList.add(data['prediction'][0]);
    resList.add(data['prediction'][1]);
    // print('Prediction: ${data['prediction']}');
  } else {
    resList.add("ERROR");
    resList.add("ERROR");
    // print('Failed to load data');
  }

  if (resList[0] == "ERROR") {
    print("Something went wong");
    retList.add(-1);
  } else {
    if (responseType[resList[0]] == 0) {
      print("NOT TRANSACTION");
      retList.add(0);
    } else if (responseType[resList[0]] == 1) {
      print("MONEY OUT");
      retList.add(1);
    } else if (responseType[resList[0]] == 2) {
      print("MONEY IN");
      retList.add(2);
    } else {
      retList.add(-1);
    }
  }

  if (transactionCategory[resList[1]] == 5) {
    print("NOT TRANSACTION");
    retList.add(5);
  } else {
    if (transactionCategory[resList[1]] == 0) {
      print("TRANSPORTATION");
      retList.add(0);
    } else if (transactionCategory[resList[1]] == 1) {
      print("ENTERTAIMENT");
      retList.add(1);
    } else if (transactionCategory[resList[1]] == 2) {
      print("UTILITIES");
      retList.add(2);
    } else if (transactionCategory[resList[1]] == 3) {
      print("FOOD AND BEVERAGE");
      retList.add(3);
    } else if (transactionCategory[resList[1]] == 4) {
      print("OTHERS");
      retList.add(4);
    } else {
      print("Something went wong");
      retList.add(-1);
    }
  }

  return retList;
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
