import 'package:flutter/material.dart';
import 'package:school_net_mobil_app/constants/app_colors.dart';
import 'package:school_net_mobil_app/model/schedule_model.dart';
import 'package:collection/collection.dart'; // Para firstWhereOrNull

class ScheduleHorizontalViewScreen extends StatelessWidget {
  final ScheduleEntity schedule;
  final List<String> orderedDays;

  const ScheduleHorizontalViewScreen({
    super.key,
    required this.schedule,
    required this.orderedDays,
  });

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
    final Map<String, List<Session>> groupedSessions = _groupSessionsByDay(schedule.sessions);
    final List<String> uniqueTimeRanges = _getUniqueTimeRanges(schedule.sessions);

    final List<String> daysInSchedule = groupedSessions.keys.toList();
    daysInSchedule.sort((a, b) => orderedDays.indexOf(a).compareTo(orderedDays.indexOf(b)));

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
        title: Text(
          'Horario de ${schedule.grade}',
          style: const TextStyle(
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
                          Icons.calendar_view_week,
                          size: 40,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Horario ${schedule.grade}°',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Consulta el horario semanal de clases',
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
          
          // Schedule Table
          Expanded(
            child: Container(
              color: AppColors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    margin: const EdgeInsets.all(24),
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
            ),
          ),
        ],
      ),
    );
  }
}
