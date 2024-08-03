import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlibabaServices {
  // classify message
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
    // debugPrint('Prediction: ${data['prediction']}');
  } else {
    resList.add("ERROR");
    resList.add("ERROR");
    // debugPrint('Failed to load data');
  }
 
  if (resList[0] == "ERROR") {
    debugPrint("Something went wong");
    retList.add(-1);
  } else {
    if (responseType[resList[0]] == 0) {
      debugPrint("NOT TRANSACTION");
      retList.add(0);
    } else if (responseType[resList[0]] == 1) {
      debugPrint("MONEY OUT");
      retList.add(1);
    } else if (responseType[resList[0]] == 2) {
      debugPrint("MONEY IN");
      retList.add(2);
    } else {
      retList.add(-1);
    }
  }

  if (transactionCategory[resList[1]] == 5) {
    debugPrint("NOT TRANSACTION");
    retList.add(5);
  } else {
    if (transactionCategory[resList[1]] == 0) {
      debugPrint("TRANSPORTATION");
      retList.add(0);
    } else if (transactionCategory[resList[1]] == 1) {
      debugPrint("ENTERTAIMENT");
      retList.add(1);
    } else if (transactionCategory[resList[1]] == 2) {
      debugPrint("UTILITIES");
      retList.add(2);
    } else if (transactionCategory[resList[1]] == 3) {
      debugPrint("FOOD AND BEVERAGE");
      retList.add(3);
    } else if (transactionCategory[resList[1]] == 4) {
      debugPrint("OTHERS");
      retList.add(4);
    } else {
      debugPrint("Something went wong");
      retList.add(-1);
    }
  }

  return retList;
}
}