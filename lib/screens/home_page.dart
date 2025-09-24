import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showAll = false;
  String _period = "Weekly";
  DateTime _selectedDate = DateTime.now();
  final _litersCtrl = TextEditingController();
  final _billCtrl = TextEditingController();


  Offset fabPosition = const Offset(300, 0);


  final List<Map<String, dynamic>> _transactions = const [
    {
      "title": "Bill",
      "subtitle": "Liters consumed - last week",
      "amount": "- \$5.99",
      "icon": Icons.receipt_long,
      "isExpense": true
    },
    {
      "title": "Usage",
      "subtitle": "Weekly liters consumed",
      "amount": "- 250 L",
      "icon": Icons.water_drop,
      "isExpense": true
    },
    {
      "title": "Usage",
      "subtitle": "Monthly liters consumed",
      "amount": "- 980 L",
      "icon": Icons.water_drop,
      "isExpense": true
    },
    {
      "title": "Goal",
      "subtitle": "Your saving target",
      "amount": "+ 1000 L",
      "icon": Icons.emoji_events,
      "isExpense": false
    },
    {
      "title": "Extra",
      "subtitle": "Old usage record",
      "amount": "- 150 L",
      "icon": Icons.water_drop,
      "isExpense": true
    },
  ];

  String getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7)
        .floor()
        .toString()
        .padLeft(2, '0');
  }

  Future<void> _saveUsage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final liters = double.tryParse(_litersCtrl.text) ?? 0;
    final bill = double.tryParse(_billCtrl.text) ?? 0;
    String docId;
    Map<String, dynamic> data = {
      "userId": user.uid,
      "date": Timestamp.fromDate(_selectedDate),
      "type": _period.toLowerCase(),
      "liters": liters,
    };

    if (_period == "Weekly") {
      final week = getWeekNumber(_selectedDate);
      docId = "${user.uid}_2025W$week";
      data["period"] = "2025W$week";
    } else {
      final month = _selectedDate.month.toString().padLeft(2, '0');
      docId = "${user.uid}_${_selectedDate.year}M$month";
      data["period"] = "${_selectedDate.year}M$month";
      data["billMonthly"] = bill;
    }

    await FirebaseFirestore.instance
        .collection("usages")
        .doc(docId)
        .set(data, SetOptions(merge: true));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Usage saved successfully!")),
    );
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

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        "Please enter the amount shown on your water meter.",
                        style: TextStyle(color: Color(0xFFF5FDE8), fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text("Weekly"),
                            selected: _period == "Weekly",
                            onSelected: (_) =>
                                setModalState(() => _period = "Weekly"),
                            selectedColor: const Color(0xFFEDC58F),
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text("Monthly"),
                            selected: _period == "Monthly",
                            onSelected: (_) =>
                                setModalState(() => _period = "Monthly"),
                            selectedColor: const Color(0xFFEDC58F),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Date Picker ---
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() => _selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Date",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.white30),
                            ),
                          ),
                          child: Text(
                            "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _litersCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Color(0xFFF5FDE8)),
                        decoration: InputDecoration(
                          labelText: "Consumption (liters)",
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_period == "Monthly")
                        TextField(
                          controller: _billCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFFF5FDE8)),
                          decoration: InputDecoration(
                            labelText: "Bill (₺)",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ),

                      const SizedBox(height: 18),

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
      },
    );
  }

  @override
  void dispose() {
    _litersCtrl.dispose();
    _billCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _showAll ? _transactions : _transactions.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD8C8C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8C8C2),
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/images/logo.png", width: 50, height: 50),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back,",
                    style: TextStyle(color: Colors.black54, fontSize: 14)),
                Text("Ankara, Bahçelievler",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ReservoirPieChart(city: "Ankara"),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Transaction History",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (_transactions.length > 4)
                    GestureDetector(
                      onTap: () => setState(() => _showAll = !_showAll),
                      child: Text(
                        _showAll ? "See Less" : "See All",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              ...visible.map((tx) {
                final isExpense = tx["isExpense"] as bool;
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
                      Row(children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(tx["icon"] as IconData,
                              color: Colors.black54),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx["title"] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF112250),
                                )),
                            Text(tx["subtitle"] as String,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black38)),
                          ],
                        ),
                      ]),
                      Text(
                        tx["amount"] as String,
                        style: TextStyle(
                          color: isExpense ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          Positioned(
            left: fabPosition.dx,
            top: fabPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final screenSize = MediaQuery.of(context).size;
                  const fabWidth = 110.0;
                  const fabHeight = 40.0;

                  double newX = fabPosition.dx + details.delta.dx;
                  double newY = fabPosition.dy + details.delta.dy;

                  if (newX < 0) newX = 0;
                  if (newY < 0) newY = 0;
                  if (newX > screenSize.width - fabWidth) {
                    newX = screenSize.width - fabWidth;
                  }
                  if (newY > screenSize.height - fabHeight - 100) {
                    newY = screenSize.height - fabHeight - 100;
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
    );
  }
}

class ReservoirPieChart extends StatefulWidget {
  final String city;
  const ReservoirPieChart({super.key, required this.city});

  @override
  State<ReservoirPieChart> createState() => _ReservoirPieChartState();
}

class _ReservoirPieChartState extends State<ReservoirPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reservoirs")
          .where("city", isEqualTo: widget.city)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildCard(const Center(child: CircularProgressIndicator()));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _buildCard(
              const Center(child: Text("No reservoir data found")));
        }

        final colors = [
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.green,
          Colors.pink,
          Colors.teal,
        ];

        return _buildCard(
          Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(docs.length, (i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final percent = (data["capacityPercent"] ?? 0).toDouble();
                      final isTouched = i == touchedIndex;
                      final radius = isTouched ? 65.0 : 55.0;
                      final fontSize = isTouched ? 22.0 : 14.0;

                      return PieChartSectionData(
                        color: colors[i % colors.length],
                        value: percent,
                        title: "${percent.toInt()}%",
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF5FDE8),
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

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FDE8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
