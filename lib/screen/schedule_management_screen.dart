import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/model/schedule_model.dart';
import 'package:school_net_mobil_app/service/schedule_service.dart';
import 'package:school_net_mobil_app/exceptions/auth_exception.dart';
import 'package:collection/collection.dart'; // Para firstWhereOrNull

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  ScheduleEntity? _currentSchedule;
  String? _selectedGrade;
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

  // Definir el orden de los días de la semana
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
    // Opcional: cargar un horario por defecto al iniciar
    // _selectedGrade = _grades.first;
    // _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    if (_selectedGrade == null) {
      setState(() {
        _message = 'Por favor, selecciona un grado.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _currentSchedule = null;
    });

    try {
      final schedule = await _scheduleService.getScheduleByGrade(_selectedGrade!);
      setState(() {
        _currentSchedule = schedule;
        _message = 'Horario cargado exitosamente para el grado $_selectedGrade.';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = e.message;
        _currentSchedule = null; // Limpiar horario si hay error
      });
    } catch (e) {
      setState(() {
        _message = 'Ocurrió un error inesperado: ${e.toString()}';
        _currentSchedule = null; // Limpiar horario si hay error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createSchedule() async {
    if (_selectedGrade == null) {
      setState(() {
        _message = 'Por favor, selecciona un grado para crear el horario.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final newSchedule = await _scheduleService.createSchedule(_selectedGrade!);
      setState(() {
        _message = 'Horario creado exitosamente para el grado ${newSchedule.grade} (ID: ${newSchedule.id}).';
        _currentSchedule = newSchedule; // Mostrar el horario recién creado
      });
    } on AuthException catch (e) {
      setState(() {
        _message = e.message;
      });
    } catch (e) {
      setState(() {
        _message = 'Ocurrió un error inesperado al crear el horario: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteScheduleByGrade() async {
    if (_selectedGrade == null) {
      setState(() {
        _message = 'Por favor, selecciona un grado para eliminar su horario.';
      });
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar el horario para el grado $_selectedGrade?',
            style: const TextStyle(color: AppColors.darkText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.darkText),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        await _scheduleService.deleteSchedulesByGrade(_selectedGrade!);
        setState(() {
          _message = 'Horario eliminado exitosamente para el grado $_selectedGrade.';
          _currentSchedule = null; // Limpiar el horario mostrado
        });
      } on AuthException catch (e) {
        setState(() {
          _message = e.message;
        });
      } catch (e) {
        setState(() {
          _message = 'Ocurrió un error inesperado al eliminar el horario: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAllSchedules() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirmar Eliminación Global',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          content: const Text(
            '¡ADVERTENCIA! ¿Estás seguro de que quieres eliminar TODOS los horarios? Esta acción es irreversible.',
            style: TextStyle(color: AppColors.darkText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.darkText),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar TODO'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        await _scheduleService.deleteAllSchedules();
        setState(() {
          _message = 'Todos los horarios han sido eliminados exitosamente.';
          _currentSchedule = null; // Limpiar el horario mostrado
          _selectedGrade = null; // Resetear el grado seleccionado
        });
      } on AuthException catch (e) {
        setState(() {
          _message = e.message;
        });
      } catch (e) {
        setState(() {
          _message = 'Ocurrió un error inesperado al eliminar todos los horarios: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Función para agrupar sesiones por día y obtener rangos de tiempo únicos
  Map<String, List<Session>> _groupSessionsByDay(List<Session> sessions) {
    final Map<String, List<Session>> grouped = {};
    for (var session in sessions) {
      if (!grouped.containsKey(session.day)) {
        grouped[session.day] = [];
      }
      grouped[session.day]!.add(session);
    }
    // Ordenar las sesiones dentro de cada día por hora de inicio
    grouped.forEach((day, sessionList) {
      sessionList.sort((a, b) => a.start.compareTo(b.start));
    });
    return grouped;
  }

  List<String> _getUniqueTimeRanges(List<Session> sessions) {
    Set<String> timeRanges = {};
    for (var session in sessions) {
      timeRanges.add('${session.start}-${session.end}');
    }
    List<String> sortedTimeRanges = timeRanges.toList();
    // Ordenar los rangos de tiempo por la hora de inicio
    sortedTimeRanges.sort((a, b) {
      String timeA = a.split('-')[0];
      String timeB = b.split('-')[0];
      return timeA.compareTo(timeB);
    });
    return sortedTimeRanges;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Session>> groupedSessions = _currentSchedule != null
        ? _groupSessionsByDay(_currentSchedule!.sessions)
        : {};

    final List<String> uniqueTimeRanges = _currentSchedule != null
        ? _getUniqueTimeRanges(_currentSchedule!.sessions)
        : [];

    // Filtrar y ordenar los días que realmente tienen sesiones
    final List<String> daysInSchedule = groupedSessions.keys.toList();
    daysInSchedule.sort((a, b) => _orderedDays.indexOf(a).compareTo(_orderedDays.indexOf(b)));

    // Construir las filas de la tabla
    List<TableRow> tableRows = [];

    // Fila de encabezado (Hora y Días de la semana)
    List<Widget> headerCells = [
      Container(
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          border: Border.all(color: AppColors.grey.withOpacity(0.3), width: 1),
        ),
        child: const Text(
          'Hora',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            fontSize: 14,
          ),
        ),
      )
    ];
    for (String day in daysInSchedule) {
      headerCells.add(
        Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            border: Border.all(color: AppColors.grey.withOpacity(0.3), width: 1),
          ),
          child: Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    tableRows.add(TableRow(children: headerCells));

    // Filas de datos (Horarios por día)
    for (String timeRange in uniqueTimeRanges) {
      List<Widget> rowCells = [
        Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.secondaryPurple.withOpacity(0.9),
            border: Border.all(color: AppColors.grey.withOpacity(0.3), width: 1),
          ),
          child: Text(
            timeRange,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        )
      ];
      String startTime = timeRange.split('-')[0];
      String endTime = timeRange.split('-')[1];

      for (String day in daysInSchedule) {
        Session? sessionForSlot;
        if (groupedSessions.containsKey(day)) {
          sessionForSlot = groupedSessions[day]!.firstWhereOrNull(
            (session) => session.start == startTime && session.end == endTime,
          );
        }

        rowCells.add(
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.grey.withOpacity(0.3), width: 1),
            ),
            child: sessionForSlot != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: sessionForSlot.subject != null && sessionForSlot.subject!.isNotEmpty
                              ? AppColors.primaryPurple.withOpacity(0.1)
                              : AppColors.accentPurpleLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sessionForSlot.subject != null && sessionForSlot.subject!.isNotEmpty
                              ? sessionForSlot.subject!
                              : 'RECREO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sessionForSlot.subject != null && sessionForSlot.subject!.isNotEmpty
                                ? AppColors.primaryPurple
                                : AppColors.accentPurpleLight,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 12,
                            color: AppColors.darkText.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sessionForSlot.teacher,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.darkText.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.room,
                            size: 12,
                            color: AppColors.darkText.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sessionForSlot.classroom,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.darkText.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'Libre',
                      style: TextStyle(
                        color: AppColors.darkText.withOpacity(0.4),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          ),
        );
      }
      tableRows.add(TableRow(children: rowCells));
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Gestión de Horarios',
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
                          Icons.schedule,
                          size: 40,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gestión de Horarios',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crea, consulta y administra los horarios académicos',
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
                  // Grade Selector
                  const Text(
                    'Seleccionar Grado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGrade,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Selecciona un Grado',
                            style: TextStyle(color: AppColors.darkText),
                          ),
                        ),
                        dropdownColor: AppColors.white,
                        style: const TextStyle(color: AppColors.darkText, fontSize: 16),
                        iconEnabledColor: AppColors.primaryPurple,
                        isExpanded: true,
                        items: _grades.map((String grade) {
                          return DropdownMenuItem<String>(
                            value: grade,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.class_,
                                      size: 16,
                                      color: AppColors.primaryPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(grade),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGrade = newValue;
                            _message = ''; // Limpiar mensaje al cambiar de grado
                            _currentSchedule = null; // Limpiar horario al cambiar de grado
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  const Text(
                    'Acciones Disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // First row of buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _fetchSchedule,
                          icon: _isLoading && _message.contains('Cargando') 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                ) 
                              : const Icon(Icons.search),
                          label: Text(
                            _isLoading && _message.contains('Cargando') 
                                ? 'Cargando...' 
                                : 'Cargar Horario',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createSchedule,
                          icon: _isLoading && _message.contains('creando') 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                ) 
                              : const Icon(Icons.add),
                          label: Text(
                            _isLoading && _message.contains('creando') 
                                ? 'Creando...' 
                                : 'Crear Horario',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryPurple,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _deleteScheduleByGrade,
                          icon: _isLoading && _message.contains('eliminando') && _message.contains('grado') 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                ) 
                              : const Icon(Icons.delete_forever),
                          label: Text(
                            _isLoading && _message.contains('eliminando') && _message.contains('grado') 
                                ? 'Eliminando...' 
                                : 'Eliminar por Grado',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _deleteAllSchedules,
                          icon: _isLoading && _message.contains('eliminando') && _message.contains('todos') 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                ) 
                              : const Icon(Icons.clear_all),
                          label: Text(
                            _isLoading && _message.contains('eliminando') && _message.contains('todos') 
                                ? 'Eliminando Todo...' 
                                : 'Eliminar Todo',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Message Section
                  if (_message.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: _message.contains('exitosamente')
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _message.contains('exitosamente')
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _message.contains('exitosamente')
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: _message.contains('exitosamente')
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _message,
                              style: TextStyle(
                                color: _message.contains('exitosamente')
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (_currentSchedule != null) ...[
                    const Text(
                      'Horario Actual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Table(
                              border: TableBorder.all(
                                color: AppColors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                              columnWidths: {
                                0: const IntrinsicColumnWidth(),
                                for (int i = 1; i <= daysInSchedule.length; i++)
                                  i: const FixedColumnWidth(140.0),
                              },
                              children: tableRows,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else if (!_isLoading) ...[
                    Container(
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
                            Icons.calendar_month,
                            size: 60,
                            color: AppColors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedGrade == null 
                                ? 'Selecciona un grado para ver o crear su horario'
                                : 'No hay horario cargado para este grado',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.darkText.withOpacity(0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_selectedGrade != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Puedes crearlo o cargarlo usando los botones de arriba',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.darkText.withOpacity(0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  
                  if (_isLoading)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      child: const Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Procesando...',
                            style: TextStyle(
                              color: AppColors.darkText,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
