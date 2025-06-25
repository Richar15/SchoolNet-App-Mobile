import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
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
        SnackBar(
          content: Text('Error al cargar calificaciones: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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
    if (_selectedAssignment == null || _selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona una asignación y un estudiante'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

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
          SnackBar(
            content: const Text('Las notas deben estar entre 0.0 y 5.0'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
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

    try {
      await _gradeService.assignGrade(request, widget.token);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notas asignadas con éxito'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      _grade1Controller.clear();
      _grade2Controller.clear();
      _grade3Controller.clear();
      _grade4Controller.clear();
      setState(() {
        _selectedStudent = null;
        _selectedAssignment = null;
      });
      _loadAssignedGrades();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al asignar notas: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  double _calculateAverage(GradeModel grade) => grade.finalGrade;

  Color _getGradeColor(double average) {
    if (average >= 4.5) return Colors.green;
    if (average >= 3.5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildGradeItem(String label, double grade) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkText.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            grade.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeInput(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.darkText.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: AppColors.primaryPurple, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,1}(\.\d{0,2})?$')),
          GradeRangeInputFormatter(),
        ],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) itemText,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryPurple, size: 20),
                const SizedBox(width: 12),
                Text(
                  hint,
                  style: TextStyle(color: AppColors.darkText.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          isExpanded: true,
          dropdownColor: AppColors.white,
          style: const TextStyle(color: AppColors.darkText, fontSize: 16),
          iconEnabledColor: AppColors.primaryPurple,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(itemText(item)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Asignar Calificaciones',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.whiteTransparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.white),
              onPressed: _loadAssignedGrades,
              tooltip: 'Actualizar calificaciones',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            color: AppColors.primaryPurple,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.grade,
                          size: 40,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gestión de Calificaciones',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Asigna y consulta las calificaciones de tus estudiantes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Curva decorativa
                Container(
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add_task,
                                color: AppColors.primaryPurple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Nueva Calificación',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Dropdowns
                        _buildDropdown<ProfessorAssignment>(
                          value: _selectedAssignment,
                          hint: 'Selecciona una asignación',
                          items: _assignments,
                          itemText: (a) => '${a.subject} - ${a.grade}°',
                          onChanged: (value) {
                            setState(() {
                              _selectedAssignment = value;
                              _selectedStudent = null;
                              _students = [];
                            });
                            if (value != null) _loadStudents(value.id);
                          },
                          icon: Icons.subject,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildDropdown<StudentForGrade>(
                          value: _selectedStudent,
                          hint: 'Selecciona un estudiante',
                          items: _students,
                          itemText: (s) => s.name,
                          onChanged: (value) => setState(() => _selectedStudent = value),
                          icon: Icons.person,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Calificaciones (0.0 - 5.0)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Grade Inputs
                        Row(
                          children: [
                            Expanded(child: _buildGradeInput(_grade1Controller, 'Nota 1', Icons.looks_one)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildGradeInput(_grade2Controller, 'Nota 2', Icons.looks_two)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildGradeInput(_grade3Controller, 'Nota 3', Icons.looks_3)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildGradeInput(_grade4Controller, 'Nota 4', Icons.looks_4)),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submitGrades,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'Asignar Calificaciones',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Assigned Grades Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in,
                          color: AppColors.secondaryPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Calificaciones Asignadas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoadingGrades)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _assignedGrades.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 60,
                                color: AppColors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay calificaciones asignadas',
                                style: TextStyle(
                                  color: AppColors.darkText.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Las calificaciones que asignes aparecerán aquí',
                                style: TextStyle(
                                  color: AppColors.darkText.withOpacity(0.4),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _assignedGrades.length,
                          itemBuilder: (context, index) {
                            final grade = _assignedGrades[index];
                            final average = _calculateAverage(grade);
                            final gradeColor = _getGradeColor(average);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppColors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: gradeColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            color: gradeColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getStudentName(grade.studentId),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColors.darkText,
                                                ),
                                              ),
                                              Text(
                                                _getAssignmentInfo(grade.assignmentId),
                                                style: TextStyle(
                                                  color: AppColors.darkText.withOpacity(0.6),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: gradeColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Promedio: ${grade.finalGrade.toStringAsFixed(1)}',
                                            style: TextStyle(
                                              color: gradeColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(child: _buildGradeItem('Nota 1', grade.grade1)),
                                        const SizedBox(width: 8),
                                        Expanded(child: _buildGradeItem('Nota 2', grade.grade2)),
                                        const SizedBox(width: 8),
                                        Expanded(child: _buildGradeItem('Nota 3', grade.grade3)),
                                        const SizedBox(width: 8),
                                        Expanded(child: _buildGradeItem('Nota 4', grade.grade4)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
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
