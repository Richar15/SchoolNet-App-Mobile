import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/model/schedule_model.dart';
import 'package:school_net_mobil_app/screen/schedule_horizontal_view_screen.dart';
import 'package:school_net_mobil_app/service/schedule_service.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart';


class AllSchedulesScreen extends StatefulWidget {
  const AllSchedulesScreen({super.key});

  @override
  State<AllSchedulesScreen> createState() => _AllSchedulesScreenState();
}

class _AllSchedulesScreenState extends State<AllSchedulesScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  List<ScheduleEntity> _allSchedules = [];
  String? _selectedGradeForView; // Nuevo estado para el grado seleccionado en el dropdown
  String _message = '';
  bool _isLoading = false;

  final List<String> _grades = [
    'SEXTO',
    'SEPTIMO',
    'OCTAVO',
    'NOVENO',
    'DECIMO',
    'UNDECIMO'
  ];

  final List<String> _orderedDays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes'
  
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllSchedules(); 
  }

  Future<void> _fetchAllSchedules() async {
    setState(() {
      _isLoading = true;
      _message = '';
      _allSchedules = []; // Limpiar la lista antes de cargar
    });

    try {
      final schedules = await _scheduleService.getAllSchedules();
      setState(() {
        _allSchedules = schedules;
        if (schedules.isEmpty) {
          _message = 'No se encontraron horarios.';
        } else {
          _message = 'Horarios cargados exitosamente.';
        }
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

  // Nuevo método para obtener y ver un horario por grado
  Future<void> _fetchAndShowScheduleByGrade() async {
    if (_selectedGradeForView == null) {
      setState(() {
        _message = 'Por favor, selecciona un grado para ver su horario.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final schedule = await _scheduleService.getScheduleByGrade(_selectedGradeForView!);
      if (!mounted) return; // Asegurarse de que el widget sigue montado

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleHorizontalViewScreen(
            schedule: schedule,
            orderedDays: _orderedDays,
          ),
        ),
      );
      setState(() {
        _message = 'Horario de ${_selectedGradeForView!} cargado.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Todos los Horarios',
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
              // Dropdown para seleccionar grado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha(51), // 20% alpha
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.white.withAlpha(77), width: 1), // 30% alpha
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGradeForView,
                    hint: const Text('Selecciona un Grado', style: TextStyle(color: AppColors.white)),
                    dropdownColor: AppColors.primaryPurple,
                    style: const TextStyle(color: AppColors.white, fontSize: 16),
                    iconEnabledColor: AppColors.white,
                    isExpanded: true,
                    items: _grades.map((String grade) {
                      return DropdownMenuItem<String>(
                        value: grade,
                        child: Text(grade),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGradeForView = newValue;
                        _message = ''; // Limpiar mensaje al cambiar de grado
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Botón para ver horario por grado
              ElevatedButton.icon(
                onPressed: _isLoading || _selectedGradeForView == null ? null : _fetchAndShowScheduleByGrade,
                icon: _isLoading && _message.contains('cargado') ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                ) : const Icon(Icons.visibility),
                label: Text(
                  _isLoading && _message.contains('cargado') ? 'Cargando...' : 'Ver Horario por Grado',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurpleLight,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchAllSchedules,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _isLoading ? 'Cargando...' : 'Recargar Todos los Horarios',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryPurple, // Cambiado para diferenciar
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _message.contains('exitosamente') || _message.contains('encontraron')
                          ? AppColors.white
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPurpleLight),
                        ),
                      )
                    : _allSchedules.isEmpty && _message.contains('No se encontraron')
                        ? Center(
                            child: Text(
                              _message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.white, fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _allSchedules.length,
                            itemBuilder: (context, index) {
                              final schedule = _allSchedules[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                color: AppColors.primaryPurple, // Color sólido
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
                                        'Grado: ${schedule.grade}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'ID del Horario: ${schedule.id}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ScheduleHorizontalViewScreen(
                                                  schedule: schedule,
                                                  orderedDays: _orderedDays,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.accentPurpleLight,
                                            foregroundColor: AppColors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: const Text('Ver Detalles'),
                                        ),
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
