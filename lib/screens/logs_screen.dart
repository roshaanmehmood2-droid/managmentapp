import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completedTasks = taskProvider.completedTasks;

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
                  const Text('SYSTEM STATUS: INTEGRITY NOMINAL',
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('ARCHIVE',
                      style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${completedTasks.length.toString().padLeft(1, '0')} ',
                          style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: 'TOTAL TASKS DEPLOYED &\nCOMPLETED',
                          style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.5, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildWipeButton(),
                  const SizedBox(height: 30),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completedTasks.length,
                    itemBuilder: (context, index) {
                      return _buildArchiveCard(completedTasks[index]);
                    },
                  ),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text('END OF ARCHIVE REACHED.\nSYNCING WITH TEMPORAL NODE...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 4, height: 2)),
                  ),
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
        Icon(Icons.search, color: Color(0xFF00E5FF), size: 20),
      ],
    );
  }

  Widget _buildWipeButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(left: BorderSide(color: Colors.redAccent, width: 4)),
      ),
      child: ListTile(
        leading: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20),
        title: const Text('WIPE ARCHIVE',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        onTap: () {},
      ),
    );
  }

  Widget _buildArchiveCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF121212),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#00-${task.id ?? '00'}', style: const TextStyle(color: Colors.white10, fontSize: 8)),
                  const SizedBox(height: 4),
                  Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF00E5FF), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          const Text('DATE FINALIZED', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(DateFormat('MMM dd, yyyy').format(task.dueDate).toUpperCase(),
              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      painter: GridPainter(),
      child: Container(),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 30.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
