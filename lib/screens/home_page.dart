import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final _litersCtrl = TextEditingController();
  final _weeklyCtrl = TextEditingController();
  final _billCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  Offset? fabPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (fabPosition == null) {
      final screen = MediaQuery.of(context).size;
      const fabW = 110.0;
      const fabH = 40.0;
      fabPosition = Offset(
          screen.width - fabW - 16,
          16,
      );
    }
  }

  Future<void> _saveUsage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final monthlyLiters = double.tryParse(_litersCtrl.text) ?? 0;
    final weeklyLiters = double.tryParse(_weeklyCtrl.text) ?? 0;
    final bill = double.tryParse(_billCtrl.text) ?? 0;
    final goal = double.tryParse(_goalCtrl.text) ?? 0;

    final month = _selectedDate.month.toString().padLeft(2, '0');
    final docId = "${user.uid}_${DateTime.now().millisecondsSinceEpoch}";

    final data = {
      "userId": user.uid,
      "date": Timestamp.fromDate(_selectedDate),
      "monthlyLiters": monthlyLiters,
      "weeklyLiters": weeklyLiters,
      "billMonthly": bill,
      "goal": goal,
      "period": "${_selectedDate.year}M$month",
      "type": "monthly",
    };

    await FirebaseFirestore.instance
        .collection("usages")
        .doc(docId)
        .set(data, SetOptions(merge: true));

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Usage saved successfully!")));

    // formu temizle
    _litersCtrl.clear();
    _weeklyCtrl.clear();
    _billCtrl.clear();
    _goalCtrl.clear();
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
                    "Please enter your usage",
                    style: TextStyle(color: Color(0xFFF5FDE8), fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Monthly Consumption
                  TextField(
                    controller: _litersCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFF5FDE8)),
                    decoration: _input("Monthly Consumption (liters)"),
                  ),
                  const SizedBox(height: 16),

                  // Weekly Consumption
                  TextField(
                    controller: _weeklyCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFF5FDE8)),
                    decoration: _input("Weekly Consumption (liters)"),
                  ),
                  const SizedBox(height: 16),

                  // Bill
                  TextField(
                    controller: _billCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFF5FDE8)),
                    decoration: _input("Bill (₺)"),
                  ),
                  const SizedBox(height: 16),

                  // Goal
                  TextField(
                    controller: _goalCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFF5FDE8)),
                    decoration: _input("Goal (liters)"),
                  ),
                  const SizedBox(height: 18),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDC58F),
                        foregroundColor: const Color(0xFFD8CBC2),
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
  void dispose() {
    _litersCtrl.dispose();
    _weeklyCtrl.dispose();
    _billCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
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
                      final city =
                          toBeginningOfSentenceCase(
                            (data["city"] ?? "-").toString(),
                            'tr_TR',
                          ) ??
                          '-';
                      final district =
                          toBeginningOfSentenceCase(
                            (data["district"] ?? "-").toString(),
                            'tr_TR',
                          ) ??
                          '-';

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

                      // Goal Progress
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("usages")
                            .where(
                              "userId",
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                            )
                            .orderBy("date", descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return const Text("No usage data found");
                          }
                          final doc =
                              snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>;
                          final liters = (doc["monthlyLiters"] ?? 0).toDouble();
                          final goal = (doc["goal"] ?? 0).toDouble();
                          return GoalProgressCard(liters: liters, goal: goal);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Comparison
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("usages")
                            .where(
                              "userId",
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                            )
                            .orderBy("date", descending: true)
                            .limit(2)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          if (snapshot.data!.docs.length < 2) {
                            return const Text("Not enough data for comparison");
                          }
                          final docs = snapshot.data!.docs;
                          final current =
                              docs[0].data() as Map<String, dynamic>;
                          final previous =
                              docs[1].data() as Map<String, dynamic>;

                          final cur = (current["monthlyLiters"] ?? 0)
                              .toDouble();
                          final prev = (previous["monthlyLiters"] ?? 0)
                              .toDouble();

                          final diff = cur - prev;
                          final percent = prev > 0 ? (diff / prev * 100) : 0.0;

                          return ComparisonCard(
                            current: cur,
                            previous: prev,
                            percentChange: percent.toStringAsFixed(1),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      const DailyTipCard(),
                      const SizedBox(height: 20),
                    ],
                  ),

                  // FAB (taşınabilir)
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
                          if (newX > screen.width - fabW)
                            newX = screen.width - fabW;
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

// Comparison Card
class ComparisonCard extends StatelessWidget {
  final double current;
  final double previous;
  final String percentChange;

  const ComparisonCard({
    super.key,
    required this.current,
    required this.previous,
    required this.percentChange,
  });

  @override
  Widget build(BuildContext context) {
    final changeValue = double.tryParse(percentChange) ?? 0.0;
    final isDecrease = changeValue < 0;
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
                isDecrease ? Icons.arrow_downward : Icons.arrow_upward,
                color: isDecrease ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isDecrease
                      ? "Great! You used ${percentChange.replaceAll('-', '')}% less water than last time."
                      : "Oops! You used $percentChange% more water than last time.",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF112250),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ratio > 1 ? 1 : ratio,
            backgroundColor: Colors.grey[300],
            color: isDecrease ? Colors.green : Colors.red,
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

// Goal Progress Card
class GoalProgressCard extends StatelessWidget {
  final double liters;
  final double goal;

  const GoalProgressCard({super.key, required this.liters, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (liters / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = goal - liters;

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
            color: const Color(0xFF04bfda),
            minHeight: 12,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Text(
            remaining > 0
                ? "You need ${remaining.toStringAsFixed(0)} L more to reach your goal."
                : "🎉 Goal reached! Great job!",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// Daily Tip Card
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

// Reservoir Pie Chart
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
