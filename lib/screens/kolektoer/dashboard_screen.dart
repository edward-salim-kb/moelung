import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/tikoem_model.dart';
import 'package:moelung_new/services/tikoem_service.dart';
import 'package:moelung_new/models/enums/trash_type.dart';
import 'dart:math'; // Import for math operations like pi
import 'package:fl_chart/fl_chart.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/config/app_routes.dart';
// Import NotificationScreen

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
        SnackBar(
          content: Text('Failed to load Tikoem data: $e'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
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
          PageHeader(
            title: 'Dasbor Kolektoer',
            showBackButton: false,
            onNotificationPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.notifications,
                arguments: widget.currentUser,
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, Kolektoer ${widget.currentUser.name}!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Dasbor ini menyediakan semua fitur untuk peran Kolektoer, Pengepoel, dan Pemangku Kepentingan/Supervisor.',
                    style: TextStyle(fontSize: 16, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 30),

                  // KPI Cards Section
                  const Text(
                    'Ringkasan Kinerja Anda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final itemWidth = (screenWidth - 16 * 3) / 2; // screenWidth - (spacing * (crossAxisCount + 1)) / crossAxisCount
                      final itemHeight = 100.0; // Approximate desired height for the card content
                      final childAspectRatio = itemWidth / itemHeight;

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _buildKpiCard(
                            title: 'Jemput Hari Ini',
                            value: '12', // Dummy value
                            icon: Icons.motorcycle,
                            color: AppColors.primary,
                          ),
                          _buildKpiCard(
                            title: 'Berat Terkumpul',
                            value: '150 kg', // Dummy value
                            icon: Icons.scale,
                            color: AppColors.accent,
                          ),
                          _buildKpiCard(
                            title: 'Poin Didapat',
                            value: '500', // Dummy value
                            icon: Icons.star,
                            color: AppColors.infoBlue,
                          ),
                          _buildKpiCard(
                            title: 'Rating Rata-rata',
                            value: '4.8', // Dummy value
                            icon: Icons.star_half,
                            color: AppColors.secondary,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Tikoem Filter
                  _isLoading
                      ? const SizedBox.shrink()
                      : DropdownButtonFormField<Tikoem?>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Tikoem',
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
                              child: Text('Semua Tikoem', style: TextStyle(color: AppColors.dark)),
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
                    'Statistik Tikoem',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _tikoems.isEmpty
                          ? const Center(child: Text('Tidak ada data Tikoem tersedia.', style: TextStyle(color: AppColors.secondary)))
                          : _selectedTikoem != null
                              ? _buildTikoemCard(_selectedTikoem!)
                              : _buildAggregateTikoemStatistics(),
                  const SizedBox(height: 30),

                  // Total Trash Weight Comparison Bar Chart
                  const Text(
                    'Perbandingan Total Berat Sampah',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _tikoems.isEmpty
                          ? const Center(child: Text('Tidak ada data Tikoem untuk perbandingan.', style: TextStyle(color: AppColors.secondary)))
                          : SizedBox(
                              height: 250, // Height for the bar chart
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: _tikoems.length * 60.0, // Adjust width based on number of bars
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
                                                child: Transform.rotate(
                                                  angle: -pi / 4, // Rotate by -45 degrees
                                                  child: Text(
                                                    _tikoems[value.toInt()].name,
                                                    style: const TextStyle(fontSize: 10, color: AppColors.dark),
                                                    textAlign: TextAlign.right, // Align text to the right after rotation
                                                  ),
                                                ),
                                              );
                                            },
                                            reservedSize: 70, // Increased reserved size to accommodate tilted text
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
                              ),
                            ),
                  const SizedBox(height: 30),

                  // Existing Kolektoer Features
                  const Text(
                    'Operasi Kolektoer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Menuju Pelaporan Eskalasi (Aksi dummy)'),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                          ),
                        );
                      },
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: const Text('Pelaporan Eskalasi', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: AppColors.secondary, // Earthy brown for warning
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Add a buffer at the bottom to prevent overflow
                  const SizedBox(height: 150), // Even further increased buffer
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: color,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: FittedBox( // Added FittedBox here
          fit: BoxFit.scaleDown,
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 32, color: Colors.white), // Slightly smaller icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            Text('Total Berat Sampah: ${tikoem.totalTrashWeight.toStringAsFixed(2)} kg', style: const TextStyle(color: AppColors.dark)),
            Text('Kapasitas: ${tikoem.capacity.toStringAsFixed(2)} kg', style: const TextStyle(color: AppColors.dark)),
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
                          'Jadwal Jemput Berikutnya:',
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
            Text('Terakhir Dikosongkan: ${tikoem.lastEmptiedDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}', style: const TextStyle(color: AppColors.dark)),
            const SizedBox(height: 16),
            const Text('Rincian Sampah:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
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
              'Statistik Agregat Tikoem',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Berat Sampah di Semua Tikoem: ${totalWeightAllTikoems.toStringAsFixed(2)} kg',
              style: const TextStyle(fontSize: 16, color: AppColors.dark),
            ),
            const SizedBox(height: 16),
            const Text('Rincian Sampah Keseluruhan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
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
