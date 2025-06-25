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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Editar Profesor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(nameController, 'Nombre', Icons.person),
              const SizedBox(height: 12),
              _buildDialogTextField(lastNameController, 'Apellido', Icons.person_outline),
              const SizedBox(height: 12),
              _buildDialogTextField(phoneController, 'Teléfono', Icons.phone),
              const SizedBox(height: 12),
              _buildDialogTextField(addressController, 'Dirección', Icons.location_on),
              const SizedBox(height: 12),
              _buildDialogTextField(passwordController, 'Contraseña', Icons.lock, isPassword: true),
              const SizedBox(height: 12),
              _buildDialogTextField(areaController, 'Área de Experticia', Icons.school),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.darkText),
            ),
          ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profesor actualizado exitosamente'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.darkText.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: AppColors.primaryPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        filled: true,
        fillColor: AppColors.grey.withOpacity(0.1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Gestión de Profesores',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
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
                          Icons.school,
                          size: 40,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Buscar Profesores',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Encuentra y gestiona la información del personal docente',
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
          
          // Search Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.darkText),
                    decoration: InputDecoration(
                      labelText: 'Buscar por nombre, usuario, área, etc.',
                      labelStyle: TextStyle(color: AppColors.darkText.withOpacity(0.6)),
                      hintText: 'Ej. María García',
                      hintStyle: TextStyle(color: AppColors.darkText.withOpacity(0.4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryPurple),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.primaryPurple),
                              onPressed: () {
                                _searchController.clear();
                                _fetchAllTeachers();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _performSearch,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      _isLoading ? 'Buscando...' : 'Buscar Profesores',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          
          // Message Section
          if (_message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message.contains('No') || _message.contains('error') || _message.contains('Fallo')
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _message.contains('No') || _message.contains('error') || _message.contains('Fallo')
                        ? Colors.red.withOpacity(0.3)
                        : AppColors.primaryPurple.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message.contains('No') || _message.contains('error') || _message.contains('Fallo')
                        ? Colors.red
                        : AppColors.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          // Results Section
          Expanded(
            child: _searchResults.isEmpty && !_isLoading && _message.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 80,
                          color: AppColors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ingresa una palabra clave para\nempezar a buscar profesores',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.darkText.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final teacher = _searchResults[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.grey.withOpacity(0.3),
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
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryPurple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.school,
                                        color: AppColors.secondaryPurple,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${teacher.name} ${teacher.lastName}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentPurpleLight.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              teacher.areaOfExpertise,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primaryPurple,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(Icons.account_circle, 'Usuario', teacher.username),
                                _buildInfoRow(Icons.lock, 'Contraseña', teacher.password),
                                _buildInfoRow(Icons.email, 'Email', teacher.email),
                                _buildInfoRow(Icons.phone, 'Teléfono', teacher.phone),
                                _buildInfoRow(Icons.location_on, 'Dirección', teacher.address),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.amber),
                                        onPressed: () => _showEditTeacherDialog(teacher),
                                        tooltip: 'Editar profesor',
                                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primaryPurple.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
