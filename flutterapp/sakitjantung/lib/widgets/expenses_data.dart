import 'package:flutter/material.dart';

class ExpensesData extends StatefulWidget {
  const ExpensesData({super.key});

  @override
  State<ExpensesData> createState() => _ExpensesDataState();
}

class _ExpensesDataState extends State<ExpensesData> {
  final List<ExpenseItemData> expenses = [
    ExpenseItemData(
        Icons.sports_basketball, 'Dribbble', 'Subscribe - 24 Feb', -173),
    ExpenseItemData(Icons.extension, 'Figma', 'Subscribe - 21 Feb', -173),
    ExpenseItemData(Icons.fastfood, 'Food', 'Fee - 22 Feb', -173),
    ExpenseItemData(Icons.shopping_cart, 'Shopping', 'Groceries - 25 Feb', -89),
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
              'Top Expenses',
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
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Opacity(
                  opacity: index < 3
                      ? 1.0
                      : 0.5, // Fade out items after the first three
                  child: ExpenseItem(
                    icon: expenses[index].icon,
                    name: expenses[index].name,
                    description: expenses[index].description,
                    amount: expenses[index].amount,
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

class ExpenseItemData {
  final IconData icon;
  final String name;
  final String description;
  final int amount;

  ExpenseItemData(this.icon, this.name, this.description, this.amount);
}

class ExpenseItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final int amount;

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
          '\$$amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
