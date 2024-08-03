import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlibabaServices {
  // classify message
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
}