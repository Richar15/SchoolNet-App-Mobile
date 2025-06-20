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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    print('StudentSearchScreen: Iniciando búsqueda para palabra clave: "$keyword"'); // DEBUG
    if (keyword.isEmpty) {
      setState(() {
        _message = 'Por favor, ingresa una palabra clave para buscar.';
        _searchResults = [];
        _isLoading = false; // Asegurarse de que isLoading sea false
      });
      print('StudentSearchScreen: Palabra clave vacía.'); // DEBUG
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _searchResults = [];
    });
    print('StudentSearchScreen: Estado de carga activado.'); // DEBUG

    try {
      final students = await _studentService.searchStudentsByKeyword(keyword);
      if (!mounted) {
        print('StudentSearchScreen: Widget desmontado, no se actualiza el estado.'); // DEBUG
        return;
      }

      setState(() {
        _searchResults = students;
        if (students.isEmpty) {
          _message = 'No se encontraron estudiantes para la palabra clave "$keyword".';
        } else {
          _message = 'Resultados de búsqueda para "$keyword".';
        }
      });
      print('StudentSearchScreen: Búsqueda exitosa. Resultados: ${_searchResults.length}'); // DEBUG
    } on AuthException catch (e) {
      setState(() {
        _message = e.message;
      });
      print('StudentSearchScreen: AuthException capturada en UI: ${e.message}'); // DEBUG
    } catch (e) {
      setState(() {
        _message = 'Ocurrió un error inesperado: ${e.toString()}';
      });
      print('StudentSearchScreen: Error inesperado en UI: ${e.toString()}'); // DEBUG
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('StudentSearchScreen: Estado de carga desactivado.'); // DEBUG
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Buscar Estudiantes',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo de búsqueda
              TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  labelText: 'Buscar por nombre, usuario, etc.',
                  hintText: 'Ej. Juan Pérez',
                  labelStyle: const TextStyle(color: AppColors.white),
                  hintStyle: const TextStyle(color: Color(0xB3FFFFFF)),
                  filled: true,
                  fillColor: AppColors.whiteTransparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.accentPurpleLight, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.white),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.white),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _message = '';
                            });
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _performSearch(), // Permite buscar al presionar Enter
              ),
              const SizedBox(height: 20),

              // Botón de búsqueda
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
              const SizedBox(height: 20),

              // Mensaje de estado
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _message.contains('No se encontraron') || _message.contains('error') || _message.contains('Fallo')
                          ? Colors.redAccent
                          : AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Lista de resultados
              Expanded(
                child: _searchResults.isEmpty && !_isLoading && _message.isEmpty
                    ? Center(
                        child: Text(
                          'Ingresa una palabra clave para empezar a buscar estudiantes.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.white, fontSize: 18),
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
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Usuario: ${student.username}',
                                    style: const TextStyle(fontSize: 16, color: AppColors.white),
                                  ),
                                  Text(
                                    'Grado: ${student.grade}',
                                    style: const TextStyle(fontSize: 16, color: AppColors.white),
                                  ),
                                  Text(
                                    'Email: ${student.email}',
                                    style: const TextStyle(fontSize: 16, color: AppColors.white),
                                  ),
                                  Text(
                                    'Teléfono: ${student.phone}',
                                    style: const TextStyle(fontSize: 16, color: AppColors.white),
                                  ),
                                  Text(
                                    'Dirección: ${student.address}',
                                    style: const TextStyle(fontSize: 16, color: AppColors.white),
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
