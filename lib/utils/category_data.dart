import 'package:eazyexpense/utils/user.dart';
import 'package:flutter/material.dart';

class ModifiedDetailsPage extends StatelessWidget {
  final List<User> userList;

  ModifiedDetailsPage({required this.userList});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> totalIncomeMap = {};
    final Map<String, double> totalExpenseMap = {};

    final Set<String> uniqueNames = Set<String>();

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
          columnSpacing: MediaQuery.of(context).size.width * 0.1,
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
          rows: userList.where((user) {
            final name = user.name.toLowerCase();

            // Check if the name is unique, if so, add it to the set
            if (!uniqueNames.contains(name)) {
              uniqueNames.add(name);
              return true;
            }
            return false;
          }).map((user) {
            final name = user.name.toLowerCase();
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
