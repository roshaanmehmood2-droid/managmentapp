import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dueDate;
  late String _priority;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _priority = widget.task?.priority ?? 'BETA';
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final task = Task(
        id: widget.task?.id,
        title: _title,
        description: _description,
        dueDate: _dueDate,
        priority: _priority,
        subtasks: widget.task?.subtasks ?? [],
        isCompleted: widget.task?.isCompleted ?? false,
      );

      if (widget.task == null) {
        taskProvider.addTask(task);
      } else {
        taskProvider.updateTask(task);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          _buildGridBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 30),
                    const Text('MANUAL_ENTRY_V2.0',
                        style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    const Text('TASK_EDITOR',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 40),
                    
                    _buildSectionLabel('SYSTEM_TITLE'),
                    TextFormField(
                      initialValue: _title,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Enter operational objective...'),
                      validator: (value) => value!.isEmpty ? 'FIELD_REQUIRED' : null,
                      onSaved: (value) => _title = value ?? '',
                    ),
                    const SizedBox(height: 30),

                    _buildSectionLabel('DATA_DESCRIPTION'),
                    TextFormField(
                      initialValue: _description,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Define parameters and expected outcomes...'),
                      onSaved: (value) => _description = value ?? '',
                    ),
                    const SizedBox(height: 30),

                    _buildSectionLabel('EXECUTION_DATE_AND_TIME'),
                    _buildDateTimePicker(),
                    const SizedBox(height: 30),

                    _buildSectionLabel('URGENCY_LEVEL'),
                    _buildUrgencySelector(),
                    const SizedBox(height: 50),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildGradientButton('SAVE_CHANGES', _saveTask),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: _buildOutlineButton('CANCEL', () => Navigator.pop(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
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
        const CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildDateTimePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF00E5FF),
                  onPrimary: Colors.black,
                  surface: Color(0xFF121212),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_dueDate),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF00E5FF),
                    onPrimary: Colors.black,
                    surface: Color(0xFF121212),
                    onSurface: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (time != null) {
            setState(() {
              _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF1A1A1A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MM/dd/yyyy  |  HH:mm').format(_dueDate), 
                 style: const TextStyle(color: Colors.white, fontSize: 16)),
            const Icon(Icons.access_time_outlined, color: Color(0xFF00E5FF), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencySelector() {
    return Row(
      children: [
        _urgencyItem('LOW', 'GAMMA'),
        const SizedBox(width: 8),
        _urgencyItem('MED', 'BETA'),
        const SizedBox(width: 8),
        _urgencyItem('HIGH', 'ALPHA'),
      ],
    );
  }

  Widget _urgencyItem(String label, String value) {
    bool isSelected = _priority == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x1A00E5FF) : const Color(0xFF121212),
            border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00E5FF) : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onPressed) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF00B2FF)],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildOutlineButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF1A1A1A)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
