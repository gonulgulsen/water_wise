import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  static const double _iconTileWidth = 80;
  static const double _iconTileHeight = 130;
  static const double _imageSize = 56;

  String selectedCategory = "Indoor";
  String selectedTab = "today";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8C8C2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back,",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black26,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tanya Myroniuk",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF112250),
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/avatar.jpg"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _buildCategoryToggle(),

              const SizedBox(height: 16),

              SizedBox(
                height: _iconTileHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: selectedCategory == "Indoor"
                      ? [
                    _buildTaskIcon("assets/images/dishwasher-icon.png",
                        "Full Dishwasher"),
                    _buildTaskIcon(
                        "assets/images/shower-icon.png", "Short Shower"),
                    _buildTaskIcon("assets/images/laundry2-icon.png",
                        "Full Laundry"),
                    _buildTaskIcon(
                        "assets/images/reuse-icon.png", "Reuse Water"),
                  ]
                      : [
                    _buildTaskIcon(
                        "assets/images/cloud-icon.png", "Rain Harvest"),
                    _buildTaskIcon("assets/images/garden-watering-icon.png",
                        "Night Watering"),
                    _buildTaskIcon(
                        "assets/images/drop-icon.png", "Drip Irrigation"),
                    _buildTaskIcon(
                        "assets/images/plants-icon.png", "Drought Plants"),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _openShowAllSheet(context, selectedCategory),
                      child: const Text(
                        "Show All",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "My Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF112250),
                  ),
                ),
              ),

              // Tabs
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTab("Today"),
                    const SizedBox(width: 20),
                    _buildTab("Upcoming"),
                    const SizedBox(width: 20),
                    _buildTab("Completed"),
                  ],
                ),
              ),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("tasks")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data["category"] == selectedCategory &&
                        (data["status"] ?? "")
                            .toString()
                            .toLowerCase() ==
                            selectedTab.toLowerCase();
                  }).toList();

                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text("No tasks found")),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data() as Map<String, dynamic>;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.greenAccent),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["title"] ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                data["description"] ?? "",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${data["date"] ?? ""} ${data["time"] ?? ""}",
                                    style:
                                    const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Yeni Toggle builder
  Widget _buildCategoryToggle() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF112250),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: selectedCategory == "Indoor"
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 24,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFF04BFDA),
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: Text(
                selectedCategory,
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
                  onTap: () => setState(() => selectedCategory = "Indoor"),
                  child: Center(
                    child: Text(
                      "Indoor",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedCategory == "Indoor"
                            ? Colors.transparent
                            : const Color(0xFF04BFDA),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedCategory = "Outdoor"),
                  child: Center(
                    child: Text(
                      "Outdoor",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedCategory == "Outdoor"
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
    );
  }

  // Tab builder
  Widget _buildTab(String text) {
    return GestureDetector(
      onTap: () => setState(() => selectedTab = text.toLowerCase()),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selectedTab == text.toLowerCase()
              ? const Color(0xFF112250)
              : Colors.grey,
        ),
      ),
    );
  }

  // Icon tile
  Widget _buildTaskIcon(String assetPath, String title) {
    return Container(
      width: _iconTileWidth + 20,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _imageSize + 32,
            height: _imageSize + 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF112250),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ Show All Sheet ve task seçenekleri kodların aynı (hiç değiştirmedim)
  void _openShowAllSheet(BuildContext context, String category) {
    final items = _taskOptions(category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A3D5F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final height = MediaQuery.of(context).size.height * 0.8;
        return SizedBox(
          height: height,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (_, i) => _sheetCard(items[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetCard(_TaskOption item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F9EA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(item.iconPath, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF112250),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
              height: 1,
              color: const Color(0xFF112250).withOpacity(0.25)),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(
              color: Color(0xFF112250),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  List<_TaskOption> _taskOptions(String category) {
    if (category == "Indoor") {
      return [
        _TaskOption(
          iconPath: "assets/images/dishwasher-icon.png",
          title: "Full Dishwasher",
          description: "Run dishwasher only when full to save water.",
        ),
        _TaskOption(
          iconPath: "assets/images/shower-icon.png",
          title: "Short Shower",
          description: "Take shorter showers to reduce daily water usage.",
        ),
        _TaskOption(
          iconPath: "assets/images/laundry2-icon.png",
          title: "Full Laundry",
          description: "Wash full loads to minimize water and energy.",
        ),
        _TaskOption(
          iconPath: "assets/images/reuse-icon.png",
          title: "Reuse Water",
          description: "Reuse vegetable washing water for plant irrigation.",
        ),
      ];
    } else {
      return [
        _TaskOption(
          iconPath: "assets/images/cloud-icon.png",
          title: "Rain Harvest",
          description: "Rainwater harvesting and use.",
        ),
        _TaskOption(
          iconPath: "assets/images/garden-watering-icon.png",
          title: "Night Watering",
          description:
          "Night watering helps save water during hot summer months.",
        ),
        _TaskOption(
          iconPath: "assets/images/drop-icon.png",
          title: "Drip Irrigation",
          description: "Efficient irrigation with minimal evaporation.",
        ),
        _TaskOption(
          iconPath: "assets/images/plants-icon.png",
          title: "Drought Plants",
          description: "Use drought-resistant plants to reduce watering.",
        ),
      ];
    }
  }
}

class _TaskOption {
  final String iconPath;
  final String title;
  final String description;
  _TaskOption({
    required this.iconPath,
    required this.title,
    required this.description,
  });
}
