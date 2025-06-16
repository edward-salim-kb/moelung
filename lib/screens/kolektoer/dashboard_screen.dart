import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/tikoem_model.dart';
import 'package:moelung_new/services/tikoem_service.dart';
import 'package:moelung_new/models/enums/trash_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moelung_new/utils/app_colors.dart';

class KolektoerDashboardScreen extends StatefulWidget {
  final UserModel currentUser;

  const KolektoerDashboardScreen({super.key, required this.currentUser});

  @override
  State<KolektoerDashboardScreen> createState() => _KolektoerDashboardScreenState();
}

class _KolektoerDashboardScreenState extends State<KolektoerDashboardScreen> {
  List<Tikoem> _tikoems = [];
  Tikoem? _selectedTikoem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTikoemData();
  }

  Future<void> _fetchTikoemData() async {
    try {
      final tikoems = await fetchTikoems();
      setState(() {
        _tikoems = tikoems;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error, e.g., show a snackbar
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load Tikoem data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 5,
      user: widget.currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Kolektoer Dashboard'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Kolektoer ${widget.currentUser.name}!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'This dashboard provides all features for Kolektoer, Pengepoel, and Stakeholder/Supervisor roles.',
                    style: TextStyle(fontSize: 16, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 30),

                  // Tikoem Filter
                  _isLoading
                      ? const SizedBox.shrink()
                      : DropdownButtonFormField<Tikoem?>(
                          decoration: InputDecoration(
                            labelText: 'Select Tikoem',
                            labelStyle: const TextStyle(color: AppColors.dark),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: AppColors.accent, width: 2.0),
                            ),
                          ),
                          value: _selectedTikoem,
                          items: [
                            const DropdownMenuItem<Tikoem?>(
                              value: null,
                              child: Text('All Tikoems', style: TextStyle(color: AppColors.dark)),
                            ),
                            ..._tikoems.map((tikoem) => DropdownMenuItem<Tikoem>(
                                  value: tikoem,
                                  child: Text(tikoem.name, style: const TextStyle(color: AppColors.dark)),
                                )),
                          ],
                          onChanged: (Tikoem? newValue) {
                            setState(() {
                              _selectedTikoem = newValue;
                            });
                          },
                          dropdownColor: AppColors.background,
                        ),
                  const SizedBox(height: 30),

                  // Tikoem Statistics Section
                  const Text(
                    'Tikoem Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _tikoems.isEmpty
                          ? const Center(child: Text('No Tikoem data available.', style: TextStyle(color: AppColors.secondary)))
                          : _selectedTikoem != null
                              ? _buildTikoemCard(_selectedTikoem!)
                              : _buildAggregateTikoemStatistics(),
                  const SizedBox(height: 30),

                  // Total Trash Weight Comparison Bar Chart
                  const Text(
                    'Total Trash Weight Comparison',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _tikoems.isEmpty
                          ? const Center(child: Text('No Tikoem data for comparison.', style: TextStyle(color: AppColors.secondary)))
                          : SizedBox(
                              height: 250, // Height for the bar chart
                              child: BarChart(
                                BarChartData(
                                  barGroups: _buildBarChartGroups(_tikoems),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: AppColors.dark, width: 1),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            space: 4,
                                            child: Text(_tikoems[value.toInt()].name, style: const TextStyle(fontSize: 10, color: AppColors.dark)),
                                          );
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text('${value.toInt()}kg', style: const TextStyle(fontSize: 10, color: AppColors.dark));
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: const FlGridData(show: false),
                                ),
                              ),
                            ),
                  const SizedBox(height: 30),

                  // Existing Kolektoer Features
                  const Text(
                    'Kolektoer Operations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigating to Pickup Service (Dummy action)')),
                        );
                      },
                      icon: const Icon(Icons.delivery_dining, color: Colors.white),
                      label: const Text('Pickup Service', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigating to Automatic Daily Reports (Dummy action)')),
                        );
                      },
                      icon: const Icon(Icons.auto_stories, color: Colors.white),
                      label: const Text('Automatic Daily Reports', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigating to Escalation Reporting (Dummy action)')),
                        );
                      },
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: const Text('Escalation Reporting', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: AppColors.secondary, // Earthy brown for warning
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  

                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

  Widget _buildTikoemCard(Tikoem tikoem) {
    return Card(
      color: Colors.white, // White card background for clean look
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tikoem.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
            ),
            const SizedBox(height: 8),
            Text('Total Trash Weight: ${tikoem.totalTrashWeight.toStringAsFixed(2)} kg', style: const TextStyle(color: AppColors.dark)),
            Text('Capacity: ${tikoem.capacity.toStringAsFixed(2)} kg', style: const TextStyle(color: AppColors.dark)),
            const SizedBox(height: 16),
            Card(
              color: AppColors.primary.withOpacity(0.1),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Pickup:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        Text(
                          tikoem.nextPickupDate?.toLocal().toString().split(' ')[0] ?? 'N/A',
                          style: const TextStyle(fontSize: 16, color: AppColors.dark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Last Emptied: ${tikoem.lastEmptiedDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}', style: const TextStyle(color: AppColors.dark)),
            const SizedBox(height: 16),
            const Text('Trash Breakdown:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
            const SizedBox(height: 8),
            ...tikoem.trashBreakdown.entries.map((entry) => Text(
                  '  - ${entry.key.label}: ${entry.value.toStringAsFixed(2)} kg',
                  style: const TextStyle(color: AppColors.secondary),
                )),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Height for the pie chart
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(tikoem.trashBreakdown),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregateTikoemStatistics() {
    double totalWeightAllTikoems = 0;
    Map<TrashType, double> aggregateTrashBreakdown = {};

    for (var tikoem in _tikoems) {
      totalWeightAllTikoems += tikoem.totalTrashWeight;
      tikoem.trashBreakdown.forEach((type, weight) {
        aggregateTrashBreakdown.update(type, (value) => value + weight, ifAbsent: () => weight);
      });
    }

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aggregate Tikoem Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Trash Weight Across All Tikoems: ${totalWeightAllTikoems.toStringAsFixed(2)} kg',
              style: const TextStyle(fontSize: 16, color: AppColors.dark),
            ),
            const SizedBox(height: 16),
            const Text('Overall Trash Breakdown:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
            const SizedBox(height: 8),
            ...aggregateTrashBreakdown.entries.map((entry) => Text(
                  '  - ${entry.key.label}: ${entry.value.toStringAsFixed(2)} kg',
                  style: const TextStyle(color: AppColors.secondary),
                )),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Height for the pie chart
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(aggregateTrashBreakdown),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

List<BarChartGroupData> _buildBarChartGroups(List<Tikoem> tikoems) {
  return tikoems.asMap().entries.map((entry) {
    final index = entry.key;
    final tikoem = entry.value;
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: tikoem.totalTrashWeight,
          color: AppColors.primary, // Use primary green for bars
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();
}

List<PieChartSectionData> _buildPieChartSections(Map<TrashType, double> trashBreakdown) {
  final List<Color> pieColors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.secondary,
    AppColors.infoBlue,
    Colors.amber, // Additional color if needed
    Colors.deepOrange, // Additional color if needed
  ];
  int colorIndex = 0;

  return trashBreakdown.entries.map((entry) {
    final isTouched = false; // For now, no touch interaction
    final double fontSize = isTouched ? 18 : 14;
    final double radius = isTouched ? 60 : 50;
    final color = pieColors[colorIndex % pieColors.length];
    colorIndex++;

    return PieChartSectionData(
      color: color,
      value: entry.value,
      title: '${entry.key.label}\n${entry.value.toStringAsFixed(1)}kg',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xffffffff),
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
  }).toList();
}
}
