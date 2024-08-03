import 'package:flutter/material.dart';

class ExpensesData extends StatefulWidget {
  final List<dynamic> transportationSum;
  final List<dynamic> entertainmentSum;
  final List<dynamic> utilitiesSum;
  final List<dynamic> foodAndBeveragesSum;
  final List<dynamic> othersSum;

  const ExpensesData({
    super.key,
    required this.transportationSum,
    required this.entertainmentSum,
    required this.utilitiesSum,
    required this.foodAndBeveragesSum,
    required this.othersSum,
  });

  @override
  State<ExpensesData> createState() => _ExpensesDataState();
}

class _ExpensesDataState extends State<ExpensesData> {
  late final List<ExpenseItemData> expenses;

  @override
  void initState() {
    super.initState();
    expenses = [
      ExpenseItemData(
          Icons.car_crash_rounded,
          'Transportation',
          'Transaction: ${widget.transportationSum[1]}',
          widget.transportationSum[0]),
      ExpenseItemData(
          Icons.movie,
          'Entertainment',
          'Transaction: ${widget.entertainmentSum[1]}',
          widget.entertainmentSum[0]),
      ExpenseItemData(Icons.water, 'Utilities',
          'Transaction: ${widget.utilitiesSum[1]}', widget.utilitiesSum[0]),
      ExpenseItemData(
          Icons.food_bank,
          'Food & Beverages',
          'Transaction: ${widget.foodAndBeveragesSum[1]}',
          widget.foodAndBeveragesSum[0]),
      ExpenseItemData(Icons.abc, 'Other', 'Transaction: ${widget.othersSum[1]}',
          widget.othersSum[0]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expenses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200, // Adjust this height as needed
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ExpenseItem(
                  icon: expenses[index].icon,
                  name: expenses[index].name,
                  description: expenses[index].description,
                  amount: expenses[index].amount,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ExpenseItemData {
  final IconData icon;
  final String name;
  final String description;
  final double amount;

  ExpenseItemData(this.icon, this.name, this.description, this.amount);
}

class ExpenseItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final double amount;

  const ExpenseItem({
    Key? key,
    required this.icon,
    required this.name,
    required this.description,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          '- RM ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
