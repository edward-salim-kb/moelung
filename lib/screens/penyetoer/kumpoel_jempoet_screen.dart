import 'package:flutter/material.dart';
import 'package:moelung_new/models/enums/service_type.dart';
import 'package:moelung_new/models/index.dart';
import 'package:moelung_new/models/user_model.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/tikoem_map.dart';
import '../../widgets/penyetoer/jempoet_drawer.dart';
import '../../widgets/penyetoer/kumpoel_drawer.dart';

class KumpoelJempoetScreen extends StatefulWidget {
  const KumpoelJempoetScreen({super.key, required this.currentUser});

  final UserModel currentUser;

  @override
  State<KumpoelJempoetScreen> createState() => _KumpoelJempoetScreenState();
}

class _KumpoelJempoetScreenState extends State<KumpoelJempoetScreen> {
  ServiceType? _selectedType;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _showModeSelection);
  }

  void _showModeSelection() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose your mode',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _optionTile(
                  ServiceType.kumpoel,
                  'Kumpoel',
                  Icons.local_shipping,
                ),
                const SizedBox(height: 12),
                _optionTile(ServiceType.jempoet, 'Jempoet', Icons.cyclone),
              ],
            ),
          ),
    );
  }

  Widget _optionTile(ServiceType type, String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
        setState(() => _selectedType = type);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 2,
      user: widget.currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Peta Kumpoel / Jempoet'),
          Expanded(
            child: Stack(
              children: [
                const TikoemMap(),
                if (_selectedType != null)
                  if (_selectedType == ServiceType.kumpoel)
                    const KumpoelDrawer()
                  else
                    JempoetDrawer(currentUser: widget.currentUser),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
