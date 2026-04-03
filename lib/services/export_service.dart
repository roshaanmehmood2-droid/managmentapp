import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task_model.dart';

class ExportService {
  Future<void> exportToCSV(List<Task> tasks) async {
    List<List<dynamic>> rows = [];
    rows.add(["ID", "Title", "Description", "Due Date", "Is Completed", "Repeat"]);
    for (var task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description,
        task.dueDate.toIso8601String(),
        task.isCompleted,
        task.repeat,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/tasks.csv";
    final file = File(path);
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(path)], text: 'Exported Tasks CSV');
  }

  Future<void> exportToPDF(List<Task> tasks) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Text("Task List Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.SizedBox(height: 10),
            ...tasks.map((task) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("${task.title} (${task.isCompleted ? 'Completed' : 'Pending'})", 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(task.description),
                  pw.Text("Due Date: ${task.dueDate.toString()}"),
                  pw.Divider(thickness: 0.5),
                ],
              ),
            )),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'tasks.pdf');
  }

  Future<void> exportToEmail(List<Task> tasks) async {
    String emailBody = "Task Management Report\n\n";
    for (var task in tasks) {
      emailBody += "- ${task.title}: ${task.description} (Due: ${task.dueDate}, Completed: ${task.isCompleted})\n";
    }
    await Share.share(emailBody, subject: 'Task Management Application - Task Export');
  }
}
