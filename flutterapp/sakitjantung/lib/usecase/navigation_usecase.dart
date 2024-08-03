import 'package:flutter/material.dart';

class NavigationUseCase extends ChangeNotifier {
  int bottomNavigationIdx = 0;
  int touchedIdx = -1;

  void changeIdx(int idx) {
    bottomNavigationIdx = idx;
    notifyListeners();
  }

  void changePieIndex(int idx) {
    touchedIdx = idx;
    notifyListeners();
  }
}
