import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/model/student_model.dart';
import 'package:school_net_mobil_app/service/student_service.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart';

class StudentSearchScreen extends StatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  State<StudentSearchScreen> createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StudentService _studentService = StudentService();
  List<StudentDto> _searchResults = [];
  String _message = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllStudents() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final students = await _studentService.getAllStudents();
      setState(() {
        _searchResults = students;
        _message = students.isEmpty ? 'No hay estudiantes registrados.' : '';
      });
    } catch (e) {
      setState(() {
        _message = e is AuthException ? e.message : 'Error al obtener estudiantes.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _message = 'Por favor, ingresa una palabra clave para buscar.';
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _searchResults = [];
    });

    try {
      final students = await _studentService.searchStudentsByKeyword(keyword);
      if (!mounted) return;

      setState(() {
        _searchResults = students;
        _message = students.isEmpty
            ? 'No se encontraron estudiantes para la palabra clave "$keyword".'
            : 'Resultados de búsqueda para "$keyword".';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = e.message;
      });
    } catch (e) {
      setState(() {
        _message = 'Ocurrió un error inesperado: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStudent(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este estudiante?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _studentService.deleteStudent(id);
        _fetchAllStudents();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estudiante eliminado')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  void _showEditStudentDialog(StudentDto student) {
    final nameController = TextEditingController(text: student.name);
    final lastNameController = TextEditingController(text: student.lastName);
    final phoneController = TextEditingController(text: student.phone);
    final addressController = TextEditingController(text: student.address);
    final passwordController = TextEditingController(text: student.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Estudiante'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Apellido')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Dirección')),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final updated = StudentRequestDTO(
                name: nameController.text,
                lastName: lastNameController.text,
                username: student.username,
                email: student.email,
                phone: phoneController.text,
                address: addressController.text,
                grade: student.grade,
                password: passwordController.text,
              );

              final studentId = student.id;
              if (studentId == null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error: El estudiante no tiene un ID válido.')),
                );
                return;
              }

              try {
                await _studentService.updateStudent(studentId, updated);
                Navigator.pop(context);
                _fetchAllStudents();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estudiante actualizado')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al actualizar: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Estudiantes',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryPurple,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  labelText: 'Buscar por nombre, usuario, etc.',
                  labelStyle: const TextStyle(color: AppColors.white),
                  hintText: 'Ej. Juan Pérez',
                  hintStyle: const TextStyle(color: Color(0xB3FFFFFF)),
                  filled: true,
                  fillColor: AppColors.whiteTransparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.white),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.white),
                          onPressed: () {
                            _searchController.clear();
                            _fetchAllStudents();
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _performSearch(),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPurpleLight),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search),
                      label: const Text(
                        'Buscar Estudiantes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurpleLight,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
              const SizedBox(height: 10),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _message.contains('No') || _message.contains('error') || _message.contains('Fallo')
                          ? Colors.redAccent
                          : AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: _searchResults.isEmpty && !_isLoading && _message.isEmpty
                    ? const Center(
                        child: Text(
                          'Ingresa una palabra clave para empezar a buscar estudiantes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final student = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            color: AppColors.primaryPurple,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${student.name} ${student.lastName}',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Usuario: ${student.username}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Contraseña: ${student.password}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Grado: ${student.grade}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Email: ${student.email}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Teléfono: ${student.phone}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Dirección: ${student.address}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.amber),
                                        onPressed: () => _showEditStudentDialog(student),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () => _deleteStudent(student.id!),
                                      ),
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
      ),
    );
  }
}
