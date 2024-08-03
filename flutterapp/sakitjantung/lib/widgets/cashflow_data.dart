import 'package:flutter/material.dart';

class CashflowData extends StatefulWidget {
  final double incomeSum;
  final double expensesSum;

  const CashflowData({
    super.key,
    required this.incomeSum,
    required this.expensesSum,
  });

  @override
  State<CashflowData> createState() => _CashflowDataState();
}

class _CashflowDataState extends State<CashflowData> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cashflows',
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
          child: ListView(
            children: [
              CashflowItem(
                icon: Icons.attach_money, // Icon for Total Income
                name: 'Total Income',
                description: 'Total Income for this period',
                amount: widget.incomeSum,
                color: Colors.green,
              ),
              const SizedBox(height: 10),
              CashflowItem(
                icon: Icons.money_off, // Icon for Total Expenses
                name: 'Total Expenses',
                description: 'Total Expenses for this period',
                amount: widget.expensesSum,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CashflowItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final double amount;
  final Color color;

  const CashflowItem({
    Key? key,
    required this.icon,
    required this.name,
    required this.description,
    required this.amount,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String displayAmount = color == Colors.red
        ? '- RM ${amount.toStringAsFixed(2)}'
        : 'RM ${amount.toStringAsFixed(2)}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                color.withOpacity(0.2), // Use color with opacity for background
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          displayAmount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
