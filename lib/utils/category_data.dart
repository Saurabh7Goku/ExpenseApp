import 'package:eazyexpense/utils/user.dart';
import 'package:flutter/material.dart';

class ModifiedDetailsPage extends StatelessWidget {
  final List<User> userList;

  ModifiedDetailsPage({required this.userList});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> totalIncomeMap = {};
    final Map<String, double> totalExpenseMap = {};

    for (final user in userList) {
      final name = user.name.toLowerCase();
      final isIncome = user.isIncome;

      if (isIncome) {
        totalIncomeMap[name] = (totalIncomeMap[name] ?? 0) + user.amount;
      } else {
        totalExpenseMap[name] = (totalExpenseMap[name] ?? 0) + user.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Modified Details Page',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(
              label: Text('Name'),
            ),
            DataColumn(
              label: Text('Income'),
            ),
            DataColumn(
              label: Text('Expense'),
            ),
            DataColumn(
              label: Text('Total'),
            ),
          ],
          rows: totalIncomeMap.keys.map((name) {
            final totalIncome = totalIncomeMap[name] ?? 0;
            final totalExpense = totalExpenseMap[name] ?? 0;
            final total = totalIncome - totalExpense;

            return DataRow(
              cells: [
                DataCell(Text(name)),
                DataCell(Text(totalIncome.toStringAsFixed(1))),
                DataCell(Text(totalExpense.toStringAsFixed(1))),
                DataCell(Text(total.toStringAsFixed(1))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
