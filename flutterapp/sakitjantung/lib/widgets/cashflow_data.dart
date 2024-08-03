import 'package:flutter/material.dart';

class CashflowData extends StatefulWidget {
  const CashflowData({super.key});

  @override
  State<CashflowData> createState() => _CashflowDataState();
}

class _CashflowDataState extends State<CashflowData> {
  final List<CashflowItemData> cashflows = [
    CashflowItemData(Icons.work, 'Salary', 'Monthly - 1 Mar', 3000),
    CashflowItemData(Icons.attach_money, 'Freelance', 'Project - 15 Feb', 500),
    CashflowItemData(
        Icons.account_balance, 'Investments', 'Dividends - 28 Feb', 200),
    CashflowItemData(Icons.card_giftcard, 'Bonus', 'Performance - 5 Mar', 1000),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Cashflows',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Handle 'See all' action
              },
              child: Text('See all'),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 200, // Adjust this height as needed
          child: ListView.builder(
            itemCount: cashflows.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Opacity(
                  opacity: index < 3
                      ? 1.0
                      : 0.5, // Fade out items after the first three
                  child: CashflowItem(
                    icon: cashflows[index].icon,
                    name: cashflows[index].name,
                    description: cashflows[index].description,
                    amount: cashflows[index].amount,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CashflowItemData {
  final IconData icon;
  final String name;
  final String description;
  final int amount;

  CashflowItemData(this.icon, this.name, this.description, this.amount);
}

class CashflowItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final int amount;

  const CashflowItem({
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
          '+\$$amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
