import 'package:eazyexpense/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Import the 'dart:math' library for generating random colors.

enum ChartType { LineChart, BarChart, SplineChart, DonutChart }

class LineChartScreen extends StatefulWidget {
  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  List<User> userList = [];

  DateTime selectedStartDate = DateTime.now().subtract(Duration(days: 7));
  DateTime selectedEndDate = DateTime.now();

  DateTime minDate = DateTime.now().subtract(Duration(days: 30));
  DateTime maxDate = DateTime.now().add(Duration(days: 1));

  Map<DateTime, double> incomeData = {};
  Map<DateTime, double> expenseData = {};

  ChartType selectedChartType = ChartType.LineChart;

  @override
  void initState() {
    super.initState();
    userCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        userList = data;
      });
      updateChartData();
    }).toList();
  }

  void updateChartData() {
    incomeData.clear();
    expenseData.clear();

    for (final user in userList) {
      final date = user.date;
      final totalAmount = user.totalAmount;

      if (user.isIncome) {
        incomeData[date] = (incomeData[date] ?? 0) + totalAmount;
      } else {
        expenseData[date] = (expenseData[date] ?? 0) + totalAmount;
      }
    }
  }

  void updateChartDateRange(DateTime startDate, DateTime endDate) {
    setState(() {
      selectedStartDate = startDate;
      selectedEndDate = endDate;
      updateChartData();
    });
  }

  void changeChartType(ChartType type) {
    setState(() {
      selectedChartType = type;
    });
  }

  Widget buildChart() {
    switch (selectedChartType) {
      case ChartType.LineChart:
        return buildLineChart();
      case ChartType.BarChart:
        return buildBarChart();
      case ChartType.SplineChart:
        return buildSplineChart();
      case ChartType.DonutChart:
        return buildDonutChart();
      default:
        return Container();
    }
  }

  Widget buildLineChart() {
    final List<ChartData> incomeChartData = incomeData.entries
        .where((entry) =>
            entry.key.isAfter(selectedStartDate) &&
            entry.key.isBefore(selectedEndDate))
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    final List<ChartData> expenseChartData = expenseData.entries
        .where((entry) =>
            entry.key.isAfter(selectedStartDate) &&
            entry.key.isBefore(selectedEndDate))
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Date'),
        dateFormat: DateFormat.yMd(),
        intervalType: DateTimeIntervalType.days,
        minimum: selectedStartDate,
        maximum: selectedEndDate,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Amount'),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        alignment: ChartAlignment.center,
      ),
      series: <ChartSeries>[
        LineSeries<ChartData, DateTime>(
          name: 'Income',
          dataSource: incomeChartData,
          xValueMapper: (ChartData sales, _) => sales.date,
          yValueMapper: (ChartData sales, _) => sales.amount,
          isVisibleInLegend: true,
        ),
        LineSeries<ChartData, DateTime>(
          name: 'Expense',
          dataSource: expenseChartData,
          xValueMapper: (sales, _) => sales.date,
          yValueMapper: (sales, _) => sales.amount,
          isVisibleInLegend: true,
        ),
      ],
    );
  }

  Widget buildBarChart() {
    final List<ChartData> incomeChartData = incomeData.entries
        .where((entry) =>
            entry.key.isAfter(selectedStartDate) &&
            entry.key.isBefore(selectedEndDate))
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    final List<ChartData> expenseChartData = expenseData.entries
        .where((entry) =>
            entry.key.isAfter(selectedStartDate) &&
            entry.key.isBefore(selectedEndDate))
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    // Sort both income and expense data
    incomeChartData.sort((a, b) => a.amount.compareTo(b.amount));
    expenseChartData.sort((a, b) => a.amount.compareTo(b.amount));

    // Compare the total income and total expense
    double totalIncome =
        incomeChartData.fold(0, (sum, data) => sum + data.amount);
    double totalExpense =
        expenseChartData.fold(0, (sum, data) => sum + data.amount);

    // Determine the order based on the comparison
    bool showIncomeFirst = totalIncome >= totalExpense;

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Date'),
        dateFormat: DateFormat.yMd(),
        intervalType: DateTimeIntervalType.days,
        minimum: selectedStartDate,
        maximum: selectedEndDate,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Amount'),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        alignment: ChartAlignment.center,
      ),
      series: <ChartSeries>[
        StackedColumnSeries<ChartData, DateTime>(
          name: showIncomeFirst ? 'Expenses' : 'Income',
          dataSource: showIncomeFirst ? expenseChartData : incomeChartData,
          xValueMapper: (ChartData sales, _) => sales.date,
          yValueMapper: (ChartData sales, _) => sales.amount,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        StackedColumnSeries<ChartData, DateTime>(
          name: showIncomeFirst ? 'Income' : 'Expenses',
          dataSource: showIncomeFirst ? incomeChartData : expenseChartData,
          xValueMapper: (ChartData sales, _) => sales.date,
          yValueMapper: (ChartData sales, _) => sales.amount,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
      ],
    );
  }

  Widget buildDonutChart() {
    // Fetch expenses from Firestore within the selected date range
    final List<User> filteredExpenses = userList.where((user) {
      return user.date.isAfter(selectedStartDate) &&
          user.date.isBefore(selectedEndDate) &&
          !(user.isIncome ?? false); // Exclude income
    }).toList();

    // Calculate the total expense for each category or name
    final Map<String, double> totalExpenseByName = {};

    // Generate random colors for each name
    final Map<String, Color> nameColors = {};

    for (final user in filteredExpenses) {
      final name = user.name ?? 'Unknown';
      final totalAmount = user.totalAmount ?? 0.0;

      totalExpenseByName[name] =
          (totalExpenseByName[name] ?? 0.0) + totalAmount;

      // Assign a random color for each name
      if (!nameColors.containsKey(name)) {
        nameColors[name] = Color.fromRGBO(
            Random().nextInt(256),
            Random().nextInt(256),
            Random().nextInt(256),
            1.0); // Generate a random color with full opacity
      }
    }

    // Calculate the total expense for all names
    final totalExpense = totalExpenseByName.values.fold(0.0, (a, b) => a + b);

    // Calculate the percentage for each entry
    final List<MapEntry<String, double>> totalExpenseData =
        totalExpenseByName.entries.map((entry) {
      final name = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalExpense) * 100;

      return MapEntry(name, percentage);
    }).toList();

    return SfCircularChart(
      palette: <Color>[
        ...nameColors.values.toList()
      ], // Assign the custom colors
      series: <CircularSeries>[
        DoughnutSeries<MapEntry<String, double>, String>(
          dataSource: totalExpenseData,
          xValueMapper: (MapEntry<String, double> data, _) => data.key,
          yValueMapper: (MapEntry<String, double> data, _) => data.value,
          dataLabelMapper: (MapEntry<String, double> data, _) =>
              '${data.key}\n${data.value.toStringAsFixed(2)}%',
          startAngle: 90,
          endAngle: 90,
          enableTooltip: true,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
          ),
        ),
      ],
    );
  }

  Widget buildSplineChart() {
    final List<ChartData> incomeChartData = incomeData.entries
        .where((entry) =>
            entry.key.isAfter(selectedStartDate) &&
            entry.key.isBefore(selectedEndDate))
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    final List<ChartData> expenseChartData = expenseData.entries
        .where((entry) =>
            entry.key.isAfter(selectedStartDate) &&
            entry.key.isBefore(selectedEndDate))
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Date'),
        dateFormat: DateFormat.yMd(),
        intervalType: DateTimeIntervalType.days,
        minimum: selectedStartDate,
        maximum: selectedEndDate,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Amount'),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        alignment: ChartAlignment.center,
      ),
      series: <ChartSeries>[
        SplineSeries<ChartData, DateTime>(
          name: 'Income',
          dataSource: incomeChartData,
          xValueMapper: (ChartData sales, _) => sales.date,
          yValueMapper: (ChartData sales, _) => sales.amount,
          isVisibleInLegend: true,
        ),
        SplineSeries<ChartData, DateTime>(
          name: 'Expense',
          dataSource: expenseChartData,
          xValueMapper: (sales, _) => sales.date,
          yValueMapper: (sales, _) => sales.amount,
          isVisibleInLegend: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SfDateRangePicker(
              view: DateRangePickerView.month,
              minDate: minDate,
              maxDate: maxDate,
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                updateChartDateRange(
                  args.value?.startDate ?? selectedStartDate,
                  args.value?.endDate ?? selectedEndDate,
                );
              },
            ),
            SizedBox(height: 10),
            DropdownButton<ChartType?>(
              value: selectedChartType,
              onChanged: (ChartType? type) {
                if (type != null) {
                  changeChartType(type);
                }
              },
              items: ChartType.values.map((type) {
                String typeText = '';
                switch (type) {
                  case ChartType.LineChart:
                    typeText = 'Line Chart';
                    break;
                  case ChartType.BarChart:
                    typeText = 'Bar Chart';
                    break;
                  case ChartType.SplineChart:
                    typeText = 'Spline Chart';
                    break;
                  case ChartType.DonutChart:
                    typeText = 'Donut Chart';
                    break;
                }
                return DropdownMenuItem<ChartType?>(
                  value: type,
                  child: Text(typeText),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Expanded(child: buildChart()),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final double amount;

  ChartData(this.date, this.amount);
}
