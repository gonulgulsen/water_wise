import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../utils/snackbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _weeklyCtrl = TextEditingController();
  final _billCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  bool _showBillField = false;
  DateTime _selectedDate = DateTime.now();
  Offset? fabPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (fabPosition == null) {
      final screen = MediaQuery.of(context).size;
      const fabW = 110.0;
      const fabH = 40.0;
      fabPosition = Offset(screen.width - fabW - 16, 16);
    }
  }

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = _selectedDate.toString().split(" ")[0];
  }

  @override
  void dispose() {
    _weeklyCtrl.dispose();
    _billCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  String _monthKey(DateTime d) =>
      "${d.year}M${d.month.toString().padLeft(2, '0')}";

  String _weekKey(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    final firstMonday = DateTime(
      d.year,
      1,
      1,
    ).subtract(Duration(days: DateTime(d.year, 1, 1).weekday - 1));
    final weekNumber =
        ((monday.difference(firstMonday).inDays) / 7).floor() + 1;
    return "${d.year}W${weekNumber.toString().padLeft(2, '0')}";
  }

  Future<void> _saveUsage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        showErrorMessage(context, "User not logged in.");
      });
      return;
    }

    final now = _selectedDate;
    final monthKey = _monthKey(now);
    final weekKey = _weekKey(now);

    final weeklyLiters = double.tryParse(_weeklyCtrl.text.trim());
    final bill = double.tryParse(_billCtrl.text.trim());

    if ((weeklyLiters == null || weeklyLiters <= 0) &&
        (!_showBillField || bill == null || bill <= 0)) {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        showErrorMessage(context, "Please enter at least one value.");
      });
      return;
    }

    final usageRef = FirebaseFirestore.instance.collection("usages");

    if (weeklyLiters != null && weeklyLiters > 0) {
      final existingWeek = await usageRef
          .where("userId", isEqualTo: user.uid)
          .where("type", isEqualTo: "week")
          .where("weekKey", isEqualTo: weekKey)
          .get();

      if (existingWeek.docs.isNotEmpty) {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200), () {
          showErrorMessage(
            context,
            "⚠️ A record already exists for this week.",
          );
        });
        return;
      }
    }

    if (_showBillField && bill != null && bill > 0) {
      final existingBill = await usageRef
          .where("userId", isEqualTo: user.uid)
          .where("type", isEqualTo: "bill")
          .where("monthKey", isEqualTo: monthKey)
          .get();

      if (existingBill.docs.isNotEmpty) {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200), () {
          showErrorMessage(
            context,
            "⚠️ You already added a bill for this month.",
          );
        });
        return;
      }
    }

    final batch = FirebaseFirestore.instance.batch();

    if (weeklyLiters != null && weeklyLiters > 0) {
      final weekDoc = usageRef.doc();
      batch.set(weekDoc, {
        "userId": user.uid,
        "type": "week",
        "date": Timestamp.fromDate(now),
        "weekKey": weekKey,
        "monthKey": monthKey,
        "weeklyLiters": weeklyLiters,
      });
    }

    if (_showBillField && bill != null && bill > 0) {
      final billDoc = usageRef.doc();
      batch.set(billDoc, {
        "userId": user.uid,
        "type": "bill",
        "date": Timestamp.fromDate(now),
        "monthKey": monthKey,
        "billMonthly": bill,
      });
    }

    await batch.commit();

    if (mounted) {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        showSuccessMessage(context, "Usage saved successfully ✅");
      });

      _weeklyCtrl.clear();
      _billCtrl.clear();
      setState(() => _showBillField = false);
    }
  }

  void _openUsageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF112250),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FDE8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Text(
                    "Enter your weekly usage",
                    style: TextStyle(color: Color(0xFFF5FDE8), fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _dateCtrl,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _dateCtrl.text = _selectedDate.toString().split(
                            " ",
                          )[0];
                        });
                      }
                    },
                    style: const TextStyle(color: Color(0xFFF5FDE8)),
                    decoration: _input("Select Date"),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _weeklyCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFF5FDE8)),
                    decoration: _input("Weekly Consumption (liters)"),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.amber,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            _showBillField = !_showBillField;
                          });
                          Navigator.pop(ctx);
                          Future.delayed(const Duration(milliseconds: 200), () {
                            _openUsageSheet();
                          });
                        },
                      ),
                      const Text(
                        "Add Monthly Bill",
                        style: TextStyle(color: Color(0xFFF5FDE8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_showBillField)
                    Column(
                      children: [
                        TextField(
                          controller: _billCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFFF5FDE8)),
                          decoration: _input("Monthly Bill (₺)"),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDC58F),
                        foregroundColor: const Color(0xFF112255),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveUsage,
                      child: const Text("SUBMIT"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8C8C2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Image.asset("assets/images/logo.png", width: 70, height: 70),
                  const SizedBox(width: 8),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Text(
                          "Loading...",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        );
                      }
                      if (!snap.data!.exists) {
                        return const Text(
                          "No profile",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        );
                      }
                      final data = snap.data!.data() as Map<String, dynamic>;
                      final city = (data["city"] ?? "-").toString();
                      final district = (data["district"] ?? "-").toString();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back,",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "$city, $district",
                            style: const TextStyle(
                              color: Color(0xFF112250),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ReservoirPieChart(city: "Ankara"),
                      const SizedBox(height: 20),

                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("goal")
                            .doc("ankara")
                            .snapshots(),
                        builder: (context, goalSnap) {
                          if (!goalSnap.hasData || !goalSnap.data!.exists) {
                            return const Text("No goal data");
                          }
                          final goalData =
                          goalSnap.data!.data() as Map<String, dynamic>;
                          final goalMonthly = (goalData["goalMonthly"] ?? 0)
                              .toDouble();
                          final goalWeekly = (goalData["goalWeekly"] ?? 0)
                              .toDouble();

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("usages")
                                .where(
                              "userId",
                              isEqualTo:
                              FirebaseAuth.instance.currentUser?.uid,
                            )
                                .where("type", isEqualTo: "week")
                                .where(
                              "monthKey",
                              isEqualTo: _monthKey(DateTime.now()),
                            )
                                .snapshots(),
                            builder: (context, usageSnap) {
                              if (!usageSnap.hasData) {
                                return const CircularProgressIndicator();
                              }
                              final docs = usageSnap.data!.docs;
                              final weeklyUsages = docs
                                  .map(
                                    (d) =>
                                    ((d.data()
                                    as Map<
                                        String,
                                        dynamic
                                    >)["weeklyLiters"] ??
                                        0)
                                        .toDouble(),
                              )
                                  .toList()
                                  .cast<double>();

                              final totalLiters = weeklyUsages.fold(
                                0.0,
                                    (sum, v) => sum + v,
                              );

                              return Column(
                                children: [
                                  GoalProgressCard(
                                    liters: totalLiters,
                                    goalMonthly: goalMonthly,
                                    goalWeekly: goalWeekly,
                                    weeklyUsages: weeklyUsages,
                                  ),
                                  const SizedBox(height: 12),

                                  if (weeklyUsages.isNotEmpty && weeklyUsages.last > goalWeekly)
                                    const StatusCard(
                                      message: "⚠️ You exceeded your weekly limit.",
                                      color: Colors.orange,
                                      icon: Icons.warning,
                                    ),

                                  const SizedBox(height: 12),
                                  if (totalLiters >= goalMonthly)
                                    const StatusCard(
                                      message:
                                      "❌ Sorry, you consumed more water than allowed this month.",
                                      color: Colors.red,
                                      icon: Icons.close,
                                    )
                                  else if (totalLiters >= goalMonthly / 2)
                                    const StatusCard(
                                      message:
                                      "⚠️ Oops! You already consumed half of your monthly goal.",
                                      color: Colors.orange,
                                      icon: Icons.warning,
                                    )
                                  else
                                    const StatusCard(
                                      message:
                                      "👏 Good progress! You are still below half of your monthly goal.",
                                      color: Colors.green,
                                      icon: Icons.thumb_up,
                                    ),

                                  const SizedBox(height: 12),

                                  if (docs.length >= 2)
                                    ComparisonCard(
                                      current: (docs[0].data()
                                      as Map<String, dynamic>)["weeklyLiters"]
                                          ?.toDouble() ??
                                          0.0,
                                      previous: (docs[1].data()
                                      as Map<String, dynamic>)["weeklyLiters"]
                                          ?.toDouble() ??
                                          0.0,
                                      goalMonthly: goalMonthly,
                                    ),
                                ],
                              );

                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      const DailyTipCard(),
                      const SizedBox(height: 20),
                    ],
                  ),

                  if (fabPosition != null)
                    Positioned(
                      left: fabPosition!.dx,
                      top: fabPosition!.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            final screen = MediaQuery.of(context).size;
                            const fabW = 110.0;
                            const fabH = 40.0;
                            double newX = fabPosition!.dx + details.delta.dx;
                            double newY = fabPosition!.dy + details.delta.dy;
                            if (newX < 0) newX = 0;
                            if (newY < 0) newY = 0;
                            if (newX > screen.width - fabW) {
                              newX = screen.width - fabW;
                            }
                            if (newY > screen.height - fabH - 100) {
                              newY = screen.height - fabH - 100;
                            }
                            fabPosition = Offset(newX, newY);
                          });
                        },
                        child: FloatingActionButton.extended(
                          backgroundColor: const Color(0xFFC30B0E),
                          foregroundColor: const Color(0xFFD8CBC2),
                          onPressed: _openUsageSheet,
                          icon: const Icon(Icons.add),
                          label: const Text(
                            "Usage",
                            style: TextStyle(
                              color: Color(0xFFD8CBC2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const StatusCard({
    super.key,
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FDE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComparisonCard extends StatelessWidget {
  final double current;
  final double previous;
  final double goalMonthly;

  const ComparisonCard({
    super.key,
    required this.current,
    required this.previous,
    required this.goalMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final diff = current - previous;
    final percent = previous > 0 ? (diff / previous * 100) : 0.0;

    String message;
    Color color;

    if (current > previous) {
      message =
      "Oops! You used ${percent.toStringAsFixed(1)}% more water than last week.";
      color = Colors.red;
    } else if (current < previous) {
      message =
      "Great! You used ${percent.abs().toStringAsFixed(1)}% less water than last week.";
      color = Colors.green;
    } else {
      message = "No change compared to last week.";
      color = Colors.blueGrey;
    }

    if (current + previous < goalMonthly / 2 && current > 0 && previous > 0) {
      message =
      "👏 Good progress! You are still below half of your monthly goal.";
      color = Colors.teal;
    }

    final ratio = previous > 0 ? (current / previous).clamp(0.0, 2.0) : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FDE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                current > previous
                    ? Icons.arrow_upward
                    : current < previous
                    ? Icons.arrow_downward
                    : Icons.remove,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ratio > 1 ? 1 : ratio,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 6),
          Text(
            "Current: ${current.toStringAsFixed(0)} L | Previous: ${previous.toStringAsFixed(0)} L",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class GoalProgressCard extends StatelessWidget {
  final double liters;
  final double goalMonthly;
  final double goalWeekly;
  final List<double> weeklyUsages;

  const GoalProgressCard({
    super.key,
    required this.liters,
    required this.goalMonthly,
    required this.goalWeekly,
    required this.weeklyUsages,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goalMonthly > 0
        ? (liters / goalMonthly).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FDE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Goal Progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF112250),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: liters > goalMonthly ? Colors.red : const Color(0xFF04bfda),
            minHeight: 12,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 12),

          if (weeklyUsages.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Records",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF112250),
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(weeklyUsages.length, (i) {
                  final value = weeklyUsages[i];
                  final exceeded = value > goalWeekly;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: exceeded
                          ? Colors.red.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          exceeded ? Icons.warning : Icons.water_drop,
                          color: exceeded ? Colors.red : Colors.blue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Week ${i + 1}: ${value.toStringAsFixed(0)} L",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: exceeded ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}

class DailyTipCard extends StatefulWidget {
  const DailyTipCard({super.key});

  @override
  State<DailyTipCard> createState() => _DailyTipCardState();
}

class _DailyTipCardState extends State<DailyTipCard> {
  late String selectedTip;

  final List<String> tips = const [
    "💧 Turn off the tap while brushing your teeth to save 20 L a day.",
    "🚿 Take a 5-minute shower instead of 10 — save up to 50 L.",
    "🪣 Use a bucket instead of a hose when washing your car.",
    "🌱 Water plants in the early morning to reduce evaporation.",
    "🛠️ Fix leaking taps — one drip per second wastes 11,000 L per year.",
  ];

  @override
  void initState() {
    super.initState();
    _pickRandomTip();
  }

  void _pickRandomTip() {
    final random = Random();
    setState(() {
      selectedTip = tips[random.nextInt(tips.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FDE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              selectedTip,
              style: const TextStyle(fontSize: 14, color: Color(0xFF112250)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blueGrey),
            tooltip: "Get another tip",
            onPressed: _pickRandomTip,
          ),
        ],
      ),
    );
  }
}

class ReservoirPieChart extends StatelessWidget {
  final String city;

  const ReservoirPieChart({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reservoirs")
          .where("city", isEqualTo: city)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text("No reservoir data found");
        }

        final colors = [
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.green,
          Colors.pink,
          Colors.teal,
        ];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FDE8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(docs.length, (i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final percent = (data["capacityPercent"] ?? 0).toDouble();

                      return PieChartSectionData(
                        color: colors[i % colors.length],
                        value: percent,
                        title: "${percent.toInt()}%",
                        radius: 55,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5FDE8),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(docs.length, (i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final damName = data["damName"] ?? "Reservoir";
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(damName, style: const TextStyle(fontSize: 13)),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
