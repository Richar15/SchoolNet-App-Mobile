import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/professor_assignment_model.dart';
import '../model/student_for_grade_model.dart';
import '../model/grade_request_model.dart';
import '../model/grade_model.dart';
import '../service/grade_service.dart';

// ✅ Formateador personalizado para restringir valores entre 0.0 y 5.0
class GradeRangeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final value = double.tryParse(text);

    if (text.isEmpty || value == null) return newValue;
    if (value >= 0.0 && value <= 5.0) return newValue;

    return oldValue;
  }
}

class AssignGradesScreen extends StatefulWidget {
  final String token;
  const AssignGradesScreen({super.key, required this.token});

  @override
  State<AssignGradesScreen> createState() => _AssignGradesScreenState();
}

class _AssignGradesScreenState extends State<AssignGradesScreen> {
  final GradeService _gradeService = GradeService();
  List<ProfessorAssignment> _assignments = [];
  List<StudentForGrade> _students = [];
  List<GradeModel> _assignedGrades = [];
  ProfessorAssignment? _selectedAssignment;
  StudentForGrade? _selectedStudent;

  final _grade1Controller = TextEditingController();
  final _grade2Controller = TextEditingController();
  final _grade3Controller = TextEditingController();
  final _grade4Controller = TextEditingController();

  bool _isLoadingGrades = false;

  @override
  void initState() {
    super.initState();
    _loadAssignments().then((_) {
      _loadAllStudentsForAllAssignments().then((_) {
        _loadAssignedGrades();
      });
    });
  }

  Future<void> _loadAllStudentsForAllAssignments() async {
    List<StudentForGrade> allStudents = [];
    for (var assignment in _assignments) {
      try {
        final students = await _gradeService.getStudents(assignment.id, widget.token);
        allStudents.addAll(students);
      } catch (_) {}
    }
    final Map<int, StudentForGrade> uniqueStudents = {};
    for (var student in allStudents) {
      uniqueStudents[student.id] = student;
    }
    setState(() {
      _students = uniqueStudents.values.toList();
    });
  }

  Future<void> _loadAssignments() async {
    final assignments = await _gradeService.getAssignments(widget.token);
    setState(() => _assignments = assignments);
  }

  Future<void> _loadStudents(int assignmentId) async {
    final students = await _gradeService.getStudents(assignmentId, widget.token);
    setState(() => _students = students);
  }

  Future<void> _loadAssignedGrades() async {
    setState(() => _isLoadingGrades = true);
    try {
      final grades = await _gradeService.getGradesAssignedByProfessor(widget.token);
      setState(() {
        _assignedGrades = grades;
        _isLoadingGrades = false;
      });
    } catch (e) {
      setState(() => _isLoadingGrades = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar calificaciones: $e')),
      );
    }
  }

  String _getStudentName(int studentId) {
    final student = _students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => StudentForGrade(id: studentId, name: 'Estudiante ID: $studentId'),
    );
    return student.name;
  }

  String _getAssignmentInfo(int assignmentId) {
    final assignment = _assignments.firstWhere(
      (a) => a.id == assignmentId,
      orElse: () => ProfessorAssignment(id: assignmentId, subject: 'Materia', grade: 'N/A'),
    );
    return '${assignment.subject} - ${assignment.grade}°';
  }

  void _submitGrades() async {
    if (_selectedAssignment == null || _selectedStudent == null) return;

    List<TextEditingController> controllers = [
      _grade1Controller,
      _grade2Controller,
      _grade3Controller,
      _grade4Controller,
    ];

    for (var controller in controllers) {
      final value = double.tryParse(controller.text);
      if (value == null || value < 0.0 || value > 5.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las notas deben estar entre 0.0 y 5.0')),
        );
        return;
      }
    }

    final request = GradeRequest(
      studentId: _selectedStudent!.id,
      assignmentId: _selectedAssignment!.id,
      grade1: double.parse(_grade1Controller.text),
      grade2: double.parse(_grade2Controller.text),
      grade3: double.parse(_grade3Controller.text),
      grade4: double.parse(_grade4Controller.text),
    );

    await _gradeService.assignGrade(request, widget.token);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notas asignadas con éxito')),
    );

    _grade1Controller.clear();
    _grade2Controller.clear();
    _grade3Controller.clear();
    _grade4Controller.clear();
    _loadAssignedGrades();
  }

  double _calculateAverage(GradeModel grade) => grade.finalGrade;

  Color _getGradeColor(double average) {
    if (average >= 4.5) return Colors.green;
    if (average >= 3.5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildGradeItem(String label, double grade) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(grade.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  InputDecoration _gradeDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  TextField _gradeInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: _gradeDecoration(label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,1}(\.\d{0,2})?$')),
        GradeRangeInputFormatter(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Notas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAssignedGrades),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Asignar Nueva Calificación',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButton<ProfessorAssignment>(
                    value: _selectedAssignment,
                    hint: const Text('Selecciona una asignación'),
                    isExpanded: true,
                    items: _assignments.map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Text('${a.subject} - ${a.grade}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAssignment = value;
                        _selectedStudent = null;
                        _students = [];
                      });
                      if (value != null) _loadStudents(value.id);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<StudentForGrade>(
                    value: _selectedStudent,
                    hint: const Text('Selecciona un estudiante'),
                    isExpanded: true,
                    items: _students.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.name));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedStudent = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _gradeInput(_grade1Controller, 'Nota 1')),
                      const SizedBox(width: 8),
                      Expanded(child: _gradeInput(_grade2Controller, 'Nota 2')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _gradeInput(_grade3Controller, 'Nota 3')),
                      const SizedBox(width: 8),
                      Expanded(child: _gradeInput(_grade4Controller, 'Nota 4')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitGrades,
                      child: const Text('Asignar Notas'),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Calificaciones Asignadas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_isLoadingGrades)
                  const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _assignedGrades.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No hay calificaciones asignadas',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _assignedGrades.length,
                      itemBuilder: (context, index) {
                        final grade = _assignedGrades[index];
                        final average = _calculateAverage(grade);
                        final gradeColor = _getGradeColor(average);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_getStudentName(grade.studentId),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text(_getAssignmentInfo(grade.assignmentId),
                                              style: TextStyle(
                                                  color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: gradeColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Prom: ${grade.finalGrade.toStringAsFixed(1)}',
                                        style: TextStyle(
                                          color: gradeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: _buildGradeItem('N1', grade.grade1)),
                                    Expanded(child: _buildGradeItem('N2', grade.grade2)),
                                    Expanded(child: _buildGradeItem('N3', grade.grade3)),
                                    Expanded(child: _buildGradeItem('N4', grade.grade4)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _grade1Controller.dispose();
    _grade2Controller.dispose();
    _grade3Controller.dispose();
    _grade4Controller.dispose();
    super.dispose();
  }
}
