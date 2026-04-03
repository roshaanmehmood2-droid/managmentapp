import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';
import 'logs_screen.dart';
import 'intel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const Center(child: Text('SQUAD_INTERFACE_V1.0', style: TextStyle(color: Colors.white24))),
    const TaskListBody(),
    const LogsScreen(),
    const IntelScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1A1A1A), width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0A0A),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'SQUAD'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'TASKS'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'LOGS'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), label: 'INTEL'),
        ],
      ),
    );
  }
}

class TaskListBody extends StatelessWidget {
  const TaskListBody({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final today = DateFormat('yyyy.MM.dd').format(DateTime.now());
    final activeTasks = taskProvider.activeTasks;

    return Stack(
      children: [
        _buildGridBackground(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Text('SYSTEM_CHRONO: $today',
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, letterSpacing: 2)),
                const SizedBox(height: 10),
                const Text('ACTIVE_PROTOCOLS',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                Container(margin: const EdgeInsets.only(top: 8), height: 4, width: 60, color: const Color(0xFF00E5FF)),
                const SizedBox(height: 30),
                _buildActiveOps(taskProvider, context),
                const SizedBox(height: 20),
                activeTasks.isEmpty 
                  ? const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Center(child: Text('NO_ACTIVE_OPERATIONS', style: TextStyle(color: Colors.white24, letterSpacing: 2))),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeTasks.length,
                      itemBuilder: (context, index) => _buildTaskCard(activeTasks[index], taskProvider, context),
                    ),
                const SizedBox(height: 30),
                _buildLoadDistribution(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.developer_board, color: Color(0xFF00E5FF), size: 20),
            SizedBox(width: 12),
            Text('CORE_TASK', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.search, color: Color(0xFF00E5FF), size: 20), onPressed: () {}),
            const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveOps(TaskProvider taskProvider, BuildContext context) {
    final totalActive = taskProvider.activeTasks.length;
    final totalCompleted = taskProvider.completedTasks.length;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ACTIVE OPERATIONS', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: '${totalActive.toString().padLeft(2, '0')} ',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  TextSpan(text: '/ ${(totalActive + totalCompleted).toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskDetailScreen())),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('ADD TASK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task, TaskProvider provider, BuildContext context) {
    Color priorityColor = task.priority == 'ALPHA' ? Colors.redAccent : (task.priority == 'GAMMA' ? Colors.purpleAccent : const Color(0xFF00E5FF));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF121212), border: Border(left: BorderSide(color: priorityColor, width: 4))),
      child: ListTile(
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: task.isCompleted,
            onChanged: (val) => provider.toggleTaskCompletion(task),
            activeColor: const Color(0xFF00E5FF),
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.grey, width: 2),
          ),
        ),
        title: Text(task.title.toUpperCase(),
            style: TextStyle(
                color: task.isCompleted ? Colors.grey : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Text('PRIORITY_${task.priority}', style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              const Icon(Icons.access_time, color: Colors.grey, size: 12),
              const SizedBox(width: 4),
              Text('DEADLINE: ${DateFormat('HH:mm').format(task.dueDate)}Z', style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
        trailing: const Icon(Icons.more_vert, color: Colors.grey),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task))),
      ),
    );
  }

  Widget _buildLoadDistribution() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF121212), border: const Border(left: BorderSide(color: Color(0xFF00E5FF), width: 2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LOAD_DISTRIBUTION', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(height: 100, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(9, (index) => _buildBar([0.4, 0.7, 0.9, 0.3, 1.0, 0.5, 0.8, 0.4, 0.9][index])))),
          const SizedBox(height: 10),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('SYSTEM_NODE_01', style: TextStyle(color: Colors.grey, fontSize: 8)), Text('SYSTEM_NODE_99', style: TextStyle(color: Colors.grey, fontSize: 8))])
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor) => Container(width: 25, height: 100 * heightFactor, color: const Color(0xFF263238));

  Widget _buildGridBackground() => CustomPaint(painter: GridPainter(), child: Container());
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
