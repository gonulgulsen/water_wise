import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


// Transaction modeli
class Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final String unit; // $, L gibi birim

  Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isExpense = true,
    this.unit = "\$", // varsayılan para
  });
}

// UsageData Model
class UsageData {
  final String userId;
  final int goal;
  final int weeklyLiters;
  final int monthlyLiters;
  final int billMonthly;
  final String week;

  UsageData({
    required this.userId,
    required this.goal,
    required this.weeklyLiters,
    required this.monthlyLiters,
    required this.billMonthly,
    required this.week,
  });

  factory UsageData.fromMap(Map<String, dynamic> data) {
    return UsageData(
      userId: data['userId'] ?? '',
      goal: data['goal'] ?? 0,
      weeklyLiters: data['weeklyLiters'] ?? 0,
      monthlyLiters: data['monthlyLiters'] ?? 0,
      billMonthly: int.tryParse(data['billMonthly'].toString()) ?? 0,
      week: data['week'] ?? '',
    );
  }
}

class UsagePage extends StatefulWidget {
  const UsagePage({super.key});

  @override
  State<UsagePage> createState() => _UsagePageState();
}

class _UsagePageState extends State<UsagePage> {
  bool isWeekly = true;

  final weeklyLineData = const [
    FlSpot(0, 50),
    FlSpot(1, 120),
    FlSpot(2, 90),
    FlSpot(3, 150),
    FlSpot(4, 500),
    FlSpot(5, 140),
    FlSpot(6, 140),
  ];
  final monthlyLineData = const [
    FlSpot(0, 600),
    FlSpot(1, 1200),
    FlSpot(2, 1800),
    FlSpot(3, 1500),
  ];
  final lineLabelsWeekly = const ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final lineLabelsMonthly = const ["W1", "W2", "W3", "W4"];

  final weeklyBarData = [
    BarChartGroupData(x: 0, barRods: [
      BarChartRodData(toY: 50, color: Colors.cyan, width: 8),
      BarChartRodData(toY: 40, color: Colors.orange, width: 8),
    ]),
  ];
  final monthlyBarData = [
    BarChartGroupData(x: 0, barRods: [
      BarChartRodData(toY: 150, color: Colors.cyan, width: 8),
      BarChartRodData(toY: 100, color: Colors.orange, width: 8),
    ]),
  ];
  final barLabelsWeekly = const ["Sun", "Mon"];
  final barLabelsMonthly = const ["Jan", "Feb"];

  String get currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8CBC2),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("usages")
              .where("userId", isEqualTo: currentUserId)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No usage data found"));
            }

            final doc = snapshot.data!.docs.first;
            final usageData = UsageData.fromMap(doc.data() as Map<String, dynamic>);


            final transactions = [
              Transaction(
                title: "Bill",
                subtitle: "This month's water bill",
                amount: usageData.billMonthly.toDouble(),
                isExpense: true,
                unit: "\$",
              ),
              Transaction(
                title: "Usage",
                subtitle: "Weekly liters consumed",
                amount: usageData.weeklyLiters.toDouble(),
                isExpense: true,
                unit: "L",
              ),
              Transaction(
                title: "Usage",
                subtitle: "Monthly liters consumed",
                amount: usageData.monthlyLiters.toDouble(),
                isExpense: true,
                unit: "L",
              ),
              Transaction(
                title: "Goal",
                subtitle: "Your saving target",
                amount: usageData.goal.toDouble(),
                isExpense: false,
                unit: "L",
              ),
            ];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  UsageHeader(
                    isWeekly: isWeekly,
                    onToggle: (value) {
                      setState(() {
                        isWeekly = value;
                      });
                    },
                    usageData: usageData,
                  ),
                  const SizedBox(height: 16),

                  // Grafik kartları
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 250,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: 320,
                                child: CustomLineChartCard(
                                  title: "Water Usage",
                                  data: isWeekly ? weeklyLineData : monthlyLineData,
                                  labels: isWeekly ? lineLabelsWeekly : lineLabelsMonthly,
                                  usageText: isWeekly
                                      ? "You used ${usageData.weeklyLiters} L this week."
                                      : "You used ${usageData.monthlyLiters} L this month.",
                                  goalText: "GOAL: ${usageData.goal} L",
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 320,
                                child: SpendingBarChartCard(
                                  title: "Your spending",
                                  data: isWeekly ? weeklyBarData : monthlyBarData,
                                  labels: isWeekly ? barLabelsWeekly : barLabelsMonthly,
                                  spendingText:
                                  "You spent \$${usageData.billMonthly} this month.",
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Transaction History Section
                        TransactionHistorySection(transactions: transactions),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Header
class UsageHeader extends StatelessWidget {
  final bool isWeekly;
  final ValueChanged<bool> onToggle;
  final UsageData usageData;

  const UsageHeader({
    super.key,
    required this.isWeekly,
    required this.onToggle,
    required this.usageData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset("assets/images/logo.png", width: 70, height: 70),
            const SizedBox(width: 8),
            const Text(
              "Your Water Usage",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF112250),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Toggle
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A3D5F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isWeekly ? const Color(0xFF04bfda) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Weekly",
                      style: TextStyle(
                        color: isWeekly ? const Color(0xFF112250) : const Color(0xFF04bfda),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isWeekly ? const Color(0xFF04bfda) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Monthly",
                      style: TextStyle(
                        color: !isWeekly ? const Color(0xFF112250) : const Color(0xFF04bfda),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isWeekly
              ? "You used ${usageData.weeklyLiters} L this week."
              : "You used ${usageData.monthlyLiters} L this month.",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF112250),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "GOAL : ${usageData.goal} L",
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }
}

// Line Chart Card
class CustomLineChartCard extends StatelessWidget {
  final String title;
  final List<FlSpot> data;
  final List<String> labels;
  final String usageText;
  final String goalText;

  const CustomLineChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.labels,
    required this.usageText,
    required this.goalText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf5fde8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3c5070))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.water_drop, color: Color(0xFF04bfda), size: 20),
              const SizedBox(width: 6),
              Text(usageText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D1B4C))),
            ],
          ),
          const SizedBox(height: 4),
          Text(goalText, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 1),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < labels.length) {
                          return Text(labels[value.toInt()],
                              style: const TextStyle(fontSize: 12));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: const Color(0xFF04bfda),
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bar Chart Card
class SpendingBarChartCard extends StatelessWidget {
  final String title;
  final List<BarChartGroupData> data;
  final List<String> labels;
  final String spendingText;

  const SpendingBarChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.labels,
    required this.spendingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf5fde8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3c5070))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.green, size: 20),
              const SizedBox(width: 6),
              Text(spendingText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Compared to last period",
              style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 1),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < labels.length) {
                          return Text(labels[value.toInt()],
                              style: const TextStyle(fontSize: 12));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Transaction History Section
class TransactionHistorySection extends StatefulWidget {
  final List<Transaction> transactions;
  const TransactionHistorySection({super.key, required this.transactions});

  @override
  State<TransactionHistorySection> createState() =>
      _TransactionHistorySectionState();
}

class _TransactionHistorySectionState extends State<TransactionHistorySection> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    // Eğer showAll false ise sadece Bill görünsün
    final visibleTransactions =
    showAll ? widget.transactions : [widget.transactions.first];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Transaction History",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF112250))),
            GestureDetector(
              onTap: () {
                setState(() {
                  showAll = !showAll;
                });
              },
              child: Text(
                showAll ? "See Less" : "See All",
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Transactions list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleTransactions.length,
          itemBuilder: (context, index) {
            final tx = visibleTransactions[index];

            IconData iconData;
            Color iconColor;
            if (tx.title == "Bill") {
              iconData = Icons.attach_money;
              iconColor = Colors.green;
            } else if (tx.title.contains("Usage")) {
              iconData = Icons.water_drop;
              iconColor = Colors.blue;
            } else if (tx.title == "Goal") {
              iconData = Icons.emoji_events;
              iconColor = Colors.orange;
            } else {
              iconData = Icons.receipt_long;
              iconColor = Colors.grey;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(iconData, color: iconColor),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF112250))),
                          Text(tx.subtitle,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black38)),
                        ]),
                  ]),
                  Text(
                    "${tx.isExpense ? "-" : "+"} ${tx.amount.toStringAsFixed(0)} ${tx.unit}",
                    style: TextStyle(
                        color: tx.isExpense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
