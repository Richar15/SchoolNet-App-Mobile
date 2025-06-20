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
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar el horario para el grado $_selectedGrade?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
          title: const Text('Confirmar Eliminación Global'),
          content: const Text('¡ADVERTENCIA! ¿Estás seguro de que quieres eliminar TODOS los horarios? Esta acción es irreversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar TODO', style: TextStyle(color: Colors.red)),
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
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.8),
          border: Border.all(color: AppColors.white.withOpacity(0.3), width: 0.5),
        ),
        child: const Text('Hora', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
      )
    ];
    for (String day in daysInSchedule) {
      headerCells.add(
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.8),
            border: Border.all(color: AppColors.white.withOpacity(0.3), width: 0.5),
          ),
          child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        ),
      );
    }
    tableRows.add(TableRow(children: headerCells));

    // Filas de datos (Horarios por día)
    for (String timeRange in uniqueTimeRanges) {
      List<Widget> rowCells = [
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.fromRGBO(
              AppColors.secondaryPurple.red,
              AppColors.secondaryPurple.green, 
              AppColors.secondaryPurple.blue,
              0.6
            ),
            border: Border.all(color: AppColors.white.withOpacity(0.3), width: 0.5),
          ),
          child: Text(timeRange, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
              color: AppColors.whiteTransparent,
              border: Border.all(color: AppColors.white.withOpacity(0.3), width: 0.5),
            ),
            child: sessionForSlot != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sessionForSlot.subject != null && sessionForSlot.subject!.isNotEmpty
                            ? sessionForSlot.subject!
                            : 'RECREO',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentPurpleLight, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        sessionForSlot.teacher,
                        style: const TextStyle(fontSize: 12, color: AppColors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        sessionForSlot.classroom,
                        style: const TextStyle(fontSize: 12, color: AppColors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : const Text('Libre', style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
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
              // Selector de Grado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.whiteTransparent,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.white.withAlpha(77), width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGrade,
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
                        _selectedGrade = newValue;
                        _message = ''; // Limpiar mensaje al cambiar de grado
                        _currentSchedule = null; // Limpiar horario al cambiar de grado
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botones de acción (Cargar y Crear)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _fetchSchedule,
                      icon: _isLoading && _message.contains('Cargando') ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      ) : const Icon(Icons.search),
                      label: Text(
                        _isLoading && _message.contains('Cargando') ? 'Cargando...' : 'Cargar Horario',
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
                  ),
                  const SizedBox(width: 10), // Espacio entre botones
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createSchedule,
                      icon: _isLoading && _message.contains('creando') ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      ) : const Icon(Icons.add),
                      label: Text(
                        _isLoading && _message.contains('creando') ? 'Creando...' : 'Crear Horario',
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
                  ),
                ],
              ),
              const SizedBox(height: 10), // Espacio entre filas de botones

              // Botones de acción (Eliminar)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _deleteScheduleByGrade,
                      icon: _isLoading && _message.contains('eliminando') && _message.contains('grado') ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      ) : const Icon(Icons.delete_forever),
                      label: Text(
                        _isLoading && _message.contains('eliminando') && _message.contains('grado') ? 'Eliminando...' : 'Eliminar por Grado',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Color para eliminar
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _deleteAllSchedules,
                      icon: _isLoading && _message.contains('eliminando') && _message.contains('todos') ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      ) : const Icon(Icons.clear_all),
                      label: Text(
                        _isLoading && _message.contains('eliminando') && _message.contains('todos') ? 'Eliminando Todo...' : 'Eliminar Todo',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800], // Color más oscuro para eliminar todo
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
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
                      color: _message.contains('exitosamente') ? AppColors.white : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Visualización del Horario en Tabla
              Expanded(
                child: _currentSchedule == null && !_isLoading
                    ? Center(
                        child: Text(
                          _selectedGrade == null ? 'Selecciona un grado para ver o crear su horario.' : 'No hay horario cargado para este grado. Puedes crearlo o eliminarlo.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.white, fontSize: 18),
                        ),
                      )
                    : _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPurpleLight),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal, // Permite desplazamiento horizontal
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical, // Permite desplazamiento vertical
                              child: Table(
                                border: TableBorder.all(color: AppColors.white.withOpacity(0.5)),
                                columnWidths: {
                                  0: const IntrinsicColumnWidth(), // Columna de la hora
                                  for (int i = 1; i <= daysInSchedule.length; i++)
                                    i: const FixedColumnWidth(120.0), // Ancho fijo para las columnas de días
                                },
                                children: tableRows,
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
