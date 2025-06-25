import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/model/teacher_model.dart';
import 'package:school_net_mobil_app/service/teacher_service.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart';

class TeacherSearchScreen extends StatefulWidget {
  const TeacherSearchScreen({super.key});

  @override
  State<TeacherSearchScreen> createState() => _TeacherSearchScreenState();
}

class _TeacherSearchScreenState extends State<TeacherSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TeacherService _teacherService = TeacherService();
  List<TeacherDto> _searchResults = [];
  String _message = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllTeachers() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final teachers = await _teacherService.getAllTeachers();
      setState(() {
        _searchResults = teachers;
        _message = teachers.isEmpty ? 'No hay profesores registrados.' : '';
      });
    } catch (e) {
      setState(() {
        _message = e is AuthException ? e.message : 'Error al obtener profesores.';
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
      final teachers = await _teacherService.searchTeachersByKeyword(keyword);
      if (!mounted) return;
      setState(() {
        _searchResults = teachers;
        _message = teachers.isEmpty
            ? 'No se encontraron profesores para la palabra clave "$keyword".'
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

  void _showEditTeacherDialog(TeacherDto teacher) {
    final nameController = TextEditingController(text: teacher.name);
    final lastNameController = TextEditingController(text: teacher.lastName);
    final phoneController = TextEditingController(text: teacher.phone);
    final addressController = TextEditingController(text: teacher.address);
    final passwordController = TextEditingController(text: teacher.password);
    final areaController = TextEditingController(text: teacher.areaOfExpertise);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Profesor'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Apellido')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Dirección')),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña')),
              TextField(controller: areaController, decoration: const InputDecoration(labelText: 'Área de experticia')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final updated = TeacherRequestDTO(
                name: nameController.text,
                lastName: lastNameController.text,
                username: teacher.username,
                email: teacher.email,
                phone: phoneController.text,
                address: addressController.text,
                password: passwordController.text,
                areaOfExpertise: areaController.text,
              );
              try {
                await _teacherService.updateTeacher(teacher.id!, updated);
                Navigator.pop(context);
                _fetchAllTeachers();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profesor actualizado')));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
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
        title: const Text('Profesores', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
                  hintText: 'Ej. María García',
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
                            _fetchAllTeachers();
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
                      label: const Text('Buscar Profesores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurpleLight,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
                      color: _message.contains('No') || _message.contains('error') ? Colors.redAccent : AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: _searchResults.isEmpty && !_isLoading && _message.isEmpty
                    ? const Center(
                        child: Text(
                          'Ingresa una palabra clave para empezar a buscar profesores.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final teacher = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            color: AppColors.primaryPurple,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${teacher.name} ${teacher.lastName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white)),
                                  const SizedBox(height: 8),
                                  Text('Usuario: ${teacher.username}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Área: ${teacher.areaOfExpertise}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Email: ${teacher.email}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Teléfono: ${teacher.phone}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Dirección: ${teacher.address}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  Text('Contraseña: ${teacher.password}', style: const TextStyle(fontSize: 16, color: AppColors.white)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.amber),
                                        onPressed: () => _showEditTeacherDialog(teacher),
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
