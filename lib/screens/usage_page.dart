import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final String unit;

  Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isExpense = true,
    this.unit = "\$",
  });
}

class UsageData {
  final String userId;
  final String type;
  final String period;
  final double liters;
  final double weeklyLiters;
  final double billMonthly;
  final double goal;

  UsageData({
    required this.userId,
    required this.type,
    required this.period,
    required this.liters,
    required this.weeklyLiters,
    required this.billMonthly,
    required this.goal,
  });

  factory UsageData.fromMap(Map<String, dynamic> data) {
    return UsageData(
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      period: data['period'] ?? '',
      liters: (data['monthlyLiters'] ?? data['liters'] ?? 0).toDouble(),
      weeklyLiters: (data['weeklyLiters'] ?? 0).toDouble(),
      billMonthly: (data['billMonthly'] ?? 0).toDouble(),
      goal: (data['goal'] ?? 0).toDouble(),
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
              .orderBy("date", descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No usage data found"));
            }

            final docs = snapshot.data!.docs;
            final current = UsageData.fromMap(
              docs.first.data() as Map<String, dynamic>,
            );
            final previous = docs
                .skip(1)
                .map((d) => UsageData.fromMap(d.data() as Map<String, dynamic>))
                .toList();

            final transactions = [
              Transaction(
                title: "Bill",
                subtitle: "This month's water bill",
                amount: current.billMonthly,
                isExpense: true,
                unit: "₺",
              ),
              Transaction(
                title: "Usage",
                subtitle: isWeekly
                    ? "Weekly liters consumed"
                    : "Monthly liters consumed",
                amount: isWeekly ? current.weeklyLiters : current.liters,
                isExpense: true,
                unit: "L",
              ),
              Transaction(
                title: "Goal",
                subtitle: "Your saving target",
                amount: current.goal,
                isExpense: false,
                unit: "L",
              ),
            ];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UsageHeader(
                    isWeekly: isWeekly,
                    onToggle: (value) {
                      setState(() {
                        isWeekly = value;
                      });
                    },
                    usageData: current,
                  ),
                  const SizedBox(height: 16),
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
                                  data: _buildLineChartData(
                                    docs.take(3).toList(),
                                    isWeekly,
                                  ),
                                  labels: _buildLabels(docs.take(3).toList()),
                                  usageText: isWeekly
                                      ? "You used ${current.weeklyLiters} L this week."
                                      : "You used ${current.liters} L this month.",
                                  goalText: "GOAL: ${current.goal} L",
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 320,
                                child: SpendingBarChartCard(
                                  title: "Your spending",
                                  data: _buildBarChartData(
                                    docs.take(3).toList(),
                                  ),
                                  labels: _buildLabels(docs.take(3).toList()),
                                  spendingText:
                                      "You spent ₺${current.billMonthly} this month.",
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        TransactionHistorySection(transactions: transactions),
                        const SizedBox(height: 5),

                        if (previous.isNotEmpty)
                          PreviousUsageList(previousUsages: previous),
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

  List<FlSpot> _buildLineChartData(
    List<QueryDocumentSnapshot> docs,
    bool weekly,
  ) {
    final reversed = docs.reversed.toList();
    return List.generate(reversed.length, (i) {
      final data = UsageData.fromMap(
        reversed[i].data() as Map<String, dynamic>,
      );
      return FlSpot(i.toDouble(), weekly ? data.weeklyLiters : data.liters);
    });
  }

  List<BarChartGroupData> _buildBarChartData(List<QueryDocumentSnapshot> docs) {
    final reversed = docs.reversed.toList();
    return List.generate(reversed.length, (i) {
      final data = UsageData.fromMap(
        reversed[i].data() as Map<String, dynamic>,
      );
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: data.billMonthly, color: Colors.cyan, width: 12),
        ],
      );
    });
  }

  List<String> _buildLabels(List<QueryDocumentSnapshot> docs) {
    final reversed = docs.reversed.toList();
    return List.generate(reversed.length, (i) {
      final data = UsageData.fromMap(
        reversed[i].data() as Map<String, dynamic>,
      );
      return data.period;
    });
  }
}

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
                      color: isWeekly
                          ? const Color(0xFF04bfda)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Weekly",
                      style: TextStyle(
                        color: isWeekly
                            ? const Color(0xFF112250)
                            : const Color(0xFF04bfda),
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
                      color: !isWeekly
                          ? const Color(0xFF04bfda)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Monthly",
                      style: TextStyle(
                        color: !isWeekly
                            ? const Color(0xFF112250)
                            : const Color(0xFF04bfda),
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
              : "You used ${usageData.liters} L this month.",
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

  String _formatPeriod(String period) {
    if (period.contains("W")) {
      final week = int.tryParse(period.substring(5)) ?? 0;
      return "W$week";
    } else if (period.contains("M")) {
      final year = int.tryParse(period.substring(0, 4)) ?? DateTime.now().year;
      final month = int.tryParse(period.substring(5)) ?? 1;
      return DateFormat.MMM().format(DateTime(year, month));
    }
    return period;
  }

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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3c5070),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.water_drop, color: Color(0xFF04bfda), size: 20),
              const SizedBox(width: 6),
              Text(
                usageText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            goalText,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
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
                          final raw = labels[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _formatPeriod(raw),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
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

  String formatPeriod(String period) {
    if (period.contains("W")) {
      final week = int.tryParse(period.substring(5)) ?? 0;
      return "W$week";
    } else if (period.contains("M")) {
      final year = int.tryParse(period.substring(0, 4)) ?? DateTime.now().year;
      final month = int.tryParse(period.substring(5)) ?? 1;
      return DateFormat.MMM().format(DateTime(year, month));
    }
    return period;
  }

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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3c5070),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.green, size: 20),
              const SizedBox(width: 6),
              Text(
                spendingText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Compared to last 3 records",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 1),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < labels.length) {
                          final label = formatPeriod(labels[value.toInt()]);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
    final visibleTransactions = showAll
        ? widget.transactions
        : [widget.transactions.first];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Transaction History",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF112250),
              ),
            ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                color: const Color(0xFFF5FDE8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(iconData, color: iconColor),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF112250),
                            ),
                          ),
                          Text(
                            tx.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    "${tx.isExpense ? "-" : "+"} ${tx.amount.toStringAsFixed(0)} ${tx.unit}",
                    style: TextStyle(
                      color: tx.isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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

class PreviousUsageList extends StatefulWidget {
  final List<UsageData> previousUsages;

  const PreviousUsageList({super.key, required this.previousUsages});

  @override
  State<PreviousUsageList> createState() => _PreviousUsageListState();
}

class _PreviousUsageListState extends State<PreviousUsageList> {
  bool show = false;

  String formatPeriod(String period) {
    try {
      if (period.contains("M")) {
        final year = period.split("M")[0];
        final month = int.parse(period.split("M")[1]);
        final monthName = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ][month - 1];
        return "$monthName $year";
      } else if (period.contains("W")) {
        final year = period.split("W")[0];
        final week = period.split("W")[1];
        return "Week $week, $year";
      }
    } catch (e) {
      return period;
    }
    return period;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Previous Records",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF112250),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => show = !show),
              child: Text(
                show ? "See Less" : "See All",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (show)
          SizedBox(
            height: 170,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: widget.previousUsages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final usage = widget.previousUsages[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black12, width: 0.6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dönem
                          Text(
                            formatPeriod(usage.period),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF112250),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(
                            height: 14,
                            thickness: 1,
                            color: Colors.black12,
                          ),

                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue.withOpacity(0.15),
                                child: const Icon(
                                  Icons.water_drop,
                                  size: 16,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${usage.liters} L",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.green.withOpacity(0.15),
                                child: const Icon(
                                  Icons.attach_money,
                                  size: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "₺${usage.billMonthly}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.orange.withOpacity(
                                  0.15,
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  size: 16,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${usage.goal} L",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orangeAccent,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
