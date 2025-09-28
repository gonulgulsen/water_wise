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

  UsageData({
    required this.userId,
    required this.type,
    required this.period,
    required this.liters,
    required this.weeklyLiters,
    required this.billMonthly,
  });

  factory UsageData.fromMap(Map<String, dynamic> data) {
    return UsageData(
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      period: data['weekKey'] ?? data['monthKey'] ?? '',
      liters: (data['liters'] ?? 0).toDouble(),
      weeklyLiters: (data['weeklyLiters'] ?? 0).toDouble(),
      billMonthly: (data['billMonthly'] ?? 0).toDouble(),
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

  String _currentWeekKey(DateTime d) {
    final firstDayOfYear = DateTime(d.year, 1, 1);
    final days = d.difference(firstDayOfYear).inDays;
    final weekNumber = (days ~/ 7) + 1;
    return "${d.year}W${weekNumber.toString().padLeft(2, "0")}";
  }

  String _currentMonthKey(DateTime d) {
    return "${d.year}M${d.month.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8CBC2),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("goal")
              .doc("ankara")
              .snapshots(),
          builder: (context, goalSnap) {
            if (!goalSnap.hasData || !goalSnap.data!.exists) {
              return const Center(child: CircularProgressIndicator());
            }

            final goalData = goalSnap.data!.data() as Map<String, dynamic>;
            final goalWeekly = (goalData["goalWeekly"] ?? 0).toDouble();
            final goalMonthly = (goalData["goalMonthly"] ?? 0).toDouble();

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("usages")
                  .where("userId", isEqualTo: currentUserId)
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No usage data found"));
                }

                final docs = snapshot.data!.docs;
                final usages = docs
                    .map(
                      (d) =>
                          UsageData.fromMap(d.data() as Map<String, dynamic>),
                    )
                    .toList();

                final now = DateTime.now();
                final weekKey = _currentWeekKey(now);
                final monthKey = _currentMonthKey(now);

                final weeklyLiters = usages
                    .where((u) => u.type == "week" && u.period == weekKey)
                    .fold(0.0, (sum, u) => sum + u.weeklyLiters);

                final monthlyLiters = usages
                    .where((u) => u.type == "week")
                    .where((u) {
                      final year = int.parse(u.period.substring(0, 4));
                      final weekNum = int.parse(u.period.substring(5));
                      final date = DateTime(
                        year,
                      ).add(Duration(days: (weekNum - 1) * 7));
                      final monthKeyOfWeek =
                          "${date.year}M${date.month.toString().padLeft(2, '0')}";
                      return monthKeyOfWeek == monthKey;
                    })
                    .fold(0.0, (sum, u) => sum + u.weeklyLiters);

                final currentUsage = isWeekly ? weeklyLiters : monthlyLiters;
                final currentGoal = isWeekly ? goalWeekly : goalMonthly;

                final transactions = [
                  if (usages.any(
                    (u) => u.type == "bill" && u.period == monthKey,
                  ))
                    Transaction(
                      title: "Bill",
                      subtitle: "This month's water bill",
                      amount: usages
                          .firstWhere(
                            (u) => u.type == "bill" && u.period == monthKey,
                          )
                          .billMonthly,
                      isExpense: true,
                      unit: "₺",
                    ),
                  Transaction(
                    title: "Usage",
                    subtitle: isWeekly
                        ? "Weekly liters consumed"
                        : "Monthly liters consumed",
                    amount: currentUsage,
                    isExpense: true,
                    unit: "L",
                  ),
                  Transaction(
                    title: "Goal",
                    subtitle: "Your saving target",
                    amount: currentGoal,
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
                        onToggle: (value) => setState(() => isWeekly = value),
                        usageValue: currentUsage,
                        goalValue: currentGoal,
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
                                        usages,
                                        isWeekly,
                                      ),
                                      labels: _buildLabels(usages),
                                      usageText: isWeekly
                                          ? "You used $weeklyLiters L this week."
                                          : "You used $monthlyLiters L this month.",
                                      goalText: "GOAL: $currentGoal L",
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 320,
                                    child: SpendingBarChartCard(
                                      title: "Your spending",
                                      data: _buildBarChartData(usages),
                                      labels: _buildLabels(usages),
                                      spendingText:
                                          usages.any(
                                            (u) =>
                                                u.type == "bill" &&
                                                u.period == monthKey,
                                          )
                                          ? "You spent ₺${usages.firstWhere((u) => u.type == "bill" && u.period == monthKey).billMonthly}"
                                          : "No bill yet",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            TransactionHistorySection(
                              transactions: transactions,
                            ),
                            const SizedBox(height: 5),

                            PreviousUsageList(previousUsages: usages),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<FlSpot> _buildLineChartData(List<UsageData> usages, bool weekly) {
    if (weekly) {
      final weeklyUsages = usages.where((u) => u.type == "week").toList();
      return List.generate(weeklyUsages.length, (i) {
        final data = weeklyUsages[i];
        return FlSpot(i.toDouble(), data.weeklyLiters);
      });
    } else {
      final Map<String, double> monthlyTotals = {};
      for (var u in usages.where((u) => u.type == "week")) {
        final year = int.parse(u.period.substring(0, 4));
        final weekNum = int.parse(u.period.substring(5));
        final date = DateTime(year).add(Duration(days: (weekNum - 1) * 7));
        final monthKey =
            "${date.year}M${date.month.toString().padLeft(2, '0')}";
        monthlyTotals[monthKey] =
            (monthlyTotals[monthKey] ?? 0) + u.weeklyLiters;
      }

      final entries = monthlyTotals.entries.toList();
      return List.generate(entries.length, (i) {
        return FlSpot(i.toDouble(), entries[i].value);
      });
    }
  }

  List<BarChartGroupData> _buildBarChartData(List<UsageData> usages) {
    final reversed = usages.reversed.toList();
    return List.generate(reversed.length, (i) {
      final data = reversed[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: data.billMonthly, color: Colors.cyan, width: 12),
        ],
      );
    });
  }

  List<String> _buildLabels(List<UsageData> usages) {
    final reversed = usages.reversed.toList();
    return reversed.map((u) => u.period).toList();
  }
}

class UsageHeader extends StatelessWidget {
  final bool isWeekly;
  final ValueChanged<bool> onToggle;
  final double usageValue;
  final double goalValue;

  const UsageHeader({
    super.key,
    required this.isWeekly,
    required this.onToggle,
    required this.usageValue,
    required this.goalValue,
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
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2A3D5F),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: isWeekly
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2 - 32,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04BFDA),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isWeekly ? "Weekly" : "Monthly",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF112250),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onToggle(true),
                      child: Center(
                        child: Text(
                          "Weekly",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isWeekly
                                ? Colors.transparent
                                : const Color(0xFF04BFDA),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onToggle(false),
                      child: Center(
                        child: Text(
                          "Monthly",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !isWeekly
                                ? Colors.transparent
                                : const Color(0xFF04BFDA),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isWeekly
              ? "You used $usageValue L this week."
              : "You used $usageValue L this month.",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF112250),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "GOAL : $goalValue L",
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
      final week = int.tryParse(period.split("W")[1]) ?? 0;
      return "W$week";
    } else if (period.contains("M")) {
      final year = int.tryParse(period.split("M")[0]) ?? DateTime.now().year;
      final month = int.tryParse(period.split("M")[1]) ?? 1;
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
      final week = int.tryParse(period.split("W")[1]) ?? 0;
      return "W$week";
    } else if (period.contains("M")) {
      final year = int.tryParse(period.split("M")[0]) ?? DateTime.now().year;
      final month = int.tryParse(period.split("M")[1]) ?? 1;
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
            "Compared to last records",
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
    final weeks = widget.previousUsages.where((u) => u.type == "week").toList();
    final bills = widget.previousUsages.where((u) => u.type == "bill").toList();
    final Map<String, double> monthlyTotals = {};
    for (var w in weeks) {
      final year = int.parse(w.period.substring(0, 4));
      final weekNum = int.parse(w.period.substring(5));
      final date = DateTime(year).add(Duration(days: (weekNum - 1) * 7));
      final monthKey = "${date.year}M${date.month.toString().padLeft(2, '0')}";

      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + w.weeklyLiters;
    }

    final weeklyCards = weeks.map(
      (usage) => {
        "period": usage.period,
        "widget": _buildCard(
          title: formatPeriod(usage.period),
          usage: usage.weeklyLiters,
          bill: 0,
        ),
      },
    );

    final monthlyCards = monthlyTotals.entries.map((entry) {
      final monthKey = entry.key;
      final totalUsage = entry.value;

      final billForMonth = bills.firstWhere(
        (b) => b.period == monthKey,
        orElse: () => UsageData(
          userId: "",
          type: "bill",
          period: monthKey,
          liters: 0,
          weeklyLiters: 0,
          billMonthly: 0,
        ),
      );

      return {
        "period": monthKey,
        "widget": _buildCard(
          title: formatPeriod(monthKey),
          usage: totalUsage,
          bill: billForMonth.billMonthly,
        ),
      };
    });

    final allCards = [...weeklyCards, ...monthlyCards];

    allCards.sort((a, b) {
      final pa = a["period"] as String;
      final pb = b["period"] as String;
      return pb.compareTo(pa);
    });

    final visibleCards = show ? allCards : allCards.take(2).toList();

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
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: visibleCards.map((c) => c["widget"] as Widget).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required double usage,
    required double bill,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF112250),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 14, thickness: 1, color: Colors.black12),
          Row(
            children: [
              const Icon(Icons.water_drop, size: 16, color: Colors.blueAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Usage: ${usage.toStringAsFixed(0)} L",
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
          if (bill > 0)
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "₺${bill.toStringAsFixed(0)}",
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
        ],
      ),
    );
  }
}
