import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/entities/noti_entity.dart';
import 'package:sakitjantung/usecase/chat_usecase.dart';
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
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final List<String> titles = ['Expense', 'Cashflow'];
  List<dynamic> transportationSum = [0, 0];
  List<dynamic> entertainmentSum = [0, 0];
  List<dynamic> utilitiesSum = [0, 0];
  List<dynamic> foodAndBeveragesSum = [0, 0];
  List<dynamic> othersSum = [0, 0];
  List<dynamic> cashflowSums = [0, 0];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<dynamic> calculateSubTotal(
      List<NotificationEventEntity> snapshot, int idx) {
    double sum = 0;
    int counter = 0;
    for (var e in snapshot) {
      if (e.transactionType == 1 && e.transactionCategory == idx) {
        sum += e.amount;
        counter++;
      }
    }
    return [sum, counter];
  }

  List<dynamic> calculateSubTotaltt(List<NotificationEventEntity> snapshot) {
    double incomeSum = 0;
    double expenseSum = 0;

    for (var e in snapshot) {
      if (e.transactionType == 1) {
        expenseSum += e.amount;
      } else if (e.transactionType == 2) {
        incomeSum += e.amount;
      }
    }
    return [incomeSum, expenseSum];
  }

  void updateChatUseCase(ChatUseCase chatUseCase) {
    chatUseCase.updateValues(
        transportationSum[0],
        entertainmentSum[0],
        utilitiesSum[0],
        foodAndBeveragesSum[0],
        othersSum[0],
        cashflowSums[0],
        cashflowSums[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Expense Page
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('events')
                        .orderBy('createAt')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else {
                        List<NotificationEventEntity> events = snapshot
                            .data!.docs
                            .map((doc) => NotificationEventEntity.fromMap(
                                doc.data() as Map<String, dynamic>))
                            .toList();

                        // Calculate subtotals for each category
                        transportationSum = calculateSubTotal(events, 0);
                        entertainmentSum = calculateSubTotal(events, 1);
                        utilitiesSum = calculateSubTotal(events, 2);
                        foodAndBeveragesSum = calculateSubTotal(events, 3);
                        othersSum = calculateSubTotal(events, 4);

                        return Column(
                          children: [
                            Expanded(
                              child: ExpensesPieChart(
                                numberOfCategories: 5,
                                amounts: [
                                  transportationSum[0],
                                  entertainmentSum[0],
                                  utilitiesSum[0],
                                  foodAndBeveragesSum[0],
                                  othersSum[0]
                                ],
                                names: const [
                                  'Transportation',
                                  'Entertainment',
                                  'Utilities',
                                  'Food & Beverages',
                                  'Others'
                                ],
                              ),
                            ),
                            ExpensesData(
                              transportationSum: transportationSum,
                              entertainmentSum: entertainmentSum,
                              utilitiesSum: utilitiesSum,
                              foodAndBeveragesSum: foodAndBeveragesSum,
                              othersSum: othersSum,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  // Cashflow Page
                  Consumer<ChatUseCase>(
                    builder: (context, chatUseCase, child) {
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('events')
                            .orderBy('createAt')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else {
                            List<NotificationEventEntity> events = snapshot
                                .data!.docs
                                .map((doc) => NotificationEventEntity.fromMap(
                                    doc.data() as Map<String, dynamic>))
                                .toList();

                            // Calculate cashflow sums (income and expenses)
                            cashflowSums = calculateSubTotaltt(events);

                            // Update chatUseCase after the build
                            // WidgetsBinding.instance.addPostFrameCallback((_) {
                            //   updateChatUseCase(chatUseCase);
                            // });

                            return Column(
                              children: [
                                Expanded(
                                  child: CashflowPieChart(
                                    amounts: [
                                      cashflowSums[0], // income
                                      cashflowSums[1], // expenses
                                    ],
                                    names: const ['Income', 'Expenses'],
                                  ),
                                ),
                                CashflowData(
                                  incomeSum: cashflowSums[0],
                                  expensesSum: cashflowSums[1],
                                ),
                                const SizedBox(height: 1),
                              ],
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
