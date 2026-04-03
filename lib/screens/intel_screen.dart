import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/export_service.dart';

class IntelScreen extends StatelessWidget {
  const IntelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final exportService = ExportService();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          _buildGridBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  const Text('SYSTEM_CONFIGURATION',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  const Text('SECURE_NODE: CONFIGURATION_INTERFACE_V2.0.4',
                      style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 40),

                  _buildSectionHeader('VISUAL_PROTOCOL', Icons.palette_outlined),
                  Row(
                    children: [
                      _buildProtocolToggle('OBSIDIAN_CORE', Icons.nightlight_round, taskProvider.isDarkMode, () {
                        if (!taskProvider.isDarkMode) taskProvider.toggleTheme();
                      }),
                      const SizedBox(width: 12),
                      _buildProtocolToggle('LIGHT_EMITTING', Icons.wb_sunny_outlined, !taskProvider.isDarkMode, () {
                        if (taskProvider.isDarkMode) taskProvider.toggleTheme();
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader('SIGNAL_RELAY', Icons.sensors),
                  _buildSwitchTile('PUSH_NOTIFICATIONS', 'REAL-TIME DATA UPDATES', true),
                  _buildSwitchTile('CRITICAL_ALERTS', 'EMERGENCY SYSTEM BYPASS', false),
                  const SizedBox(height: 30),

                  _buildSectionHeader('DATA_EXFILTRATION', Icons.file_upload_outlined),
                  const Text('SNAPSHOT_VERSION: 10.42.0', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  _buildExportButton('EXPORT_CSV', 'RAW DATA ARCHIVE', Icons.table_chart_outlined, () {
                    exportService.exportToCSV(taskProvider.tasks);
                  }),
                  const SizedBox(height: 12),
                  _buildExportButton('EXPORT_PDF', 'VISUAL REPORTING LOG', Icons.picture_as_pdf_outlined, () {
                    exportService.exportToPDF(taskProvider.tasks);
                  }),
                  const SizedBox(height: 16),
                  _buildNotice('NOTICE: All exported data is encrypted with AES-256 standards. Ensure destination nodes are verified before initializing transfer.'),
                  const SizedBox(height: 30),

                  _buildSectionHeader('LOCALE_ID', Icons.language),
                  _buildLocaleDropdown(),
                  const SizedBox(height: 30),

                  _buildSectionHeader('SYSTEM_STATUS', Icons.memory),
                  _buildStatusCard(),
                  const SizedBox(height: 40),

                  _buildWipeButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.developer_board, color: Color(0xFF00E5FF), size: 20),
            SizedBox(width: 12),
            Text('CORE_TASK', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Icon(icon, color: Colors.purpleAccent, size: 18),
        ],
      ),
    );
  }

  Widget _buildProtocolToggle(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            border: Border.all(color: isActive ? const Color(0xFF00E5FF) : const Color(0xFF1A1A1A)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? const Color(0xFF00E5FF) : Colors.white, size: 20),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(color: isActive ? const Color(0xFF00E5FF) : Colors.grey, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 0.5)),
            ],
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: const Color(0xFF00E5FF),
            activeTrackColor: const Color(0xFF00E5FF).withOpacity(0.3),
            inactiveTrackColor: const Color(0xFF1A1A1A),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF121212),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 1)),
              ],
            ),
            Icon(icon, color: Colors.white24, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNotice(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Icon(Icons.circle, color: Color(0xFF00E5FF), size: 10),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 9, height: 1.5, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  Widget _buildLocaleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFF121212),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'en',
          dropdownColor: const Color(0xFF121212),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('ENGLISH_GLOBAL [EN-US]')),
          ],
          onChanged: (v) {},
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(left: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
            ),
            child: const Text('V2.4', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BUILD_HASH: 0X00F7FF', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('ALL MODULES NOMINAL.', style: TextStyle(color: Colors.grey, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWipeButton() {
    return Center(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: const Text('WIPE_LOCAL_STORAGE', style: TextStyle(color: Colors.redAccent, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(painter: GridPainter(), child: Container());
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03)..strokeWidth = 1;
    const step = 30.0;
    for (double i = 0; i < size.width; i += step) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += step) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
