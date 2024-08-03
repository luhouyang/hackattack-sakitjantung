import 'package:flutter/material.dart';
import 'package:sakitjantung/widgets/cashflow_data.dart';
import 'package:sakitjantung/widgets/piechart_cashflow.dart';
import 'package:sakitjantung/widgets/piechart_expenses.dart';
import 'package:sakitjantung/widgets/expenses_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int touchedIndex = -1;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  List<String> titles = ['Expense', 'Cashflow']; // Updated title here

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: SegmentedButton(
              segments: titles,
              selectedIndex: _currentPage,
              onSegmentTapped: (index) {
                setState(() {
                  _currentPage = index;
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                Column(
                  children: [
                    Expanded(
                        child: ExpensesPieChart(
                            numberOfCategories: 5,
                            amounts: [500, 750, 100, 300, 400],
                            names: ['A', 'B', 'C', 'D', 'E'])),
                    SizedBox(height: 10),
                    ExpensesData(),
                  ],
                ),
                Column(
                  children: [
                    Expanded(
                        child: CashflowPieChart(
                            numberOfCategories: 5,
                            amounts: [200, 400, 150, 600, 700],
                            names: ['A', 'B', 'C', 'D', 'E'])),
                    CashflowData(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SegmentedButton extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final Function(int) onSegmentTapped;

  const SegmentedButton({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 146, 146, 146),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(segments.length, (index) {
          bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSegmentTapped(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 223, 225, 226)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                segments[index],
                style: TextStyle(
                  color:
                      isSelected ? Colors.black : Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
