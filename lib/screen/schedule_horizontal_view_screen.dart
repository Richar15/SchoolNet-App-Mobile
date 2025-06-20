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
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withAlpha(204), // 80% alpha
          border: Border.all(color: AppColors.white.withAlpha(77), width: 0.5), // 30% alpha
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
            color: AppColors.primaryPurple.withAlpha(204), // 80% alpha
            border: Border.all(color: AppColors.white.withAlpha(77), width: 0.5), // 30% alpha
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
            color: AppColors.secondaryPurple.withAlpha(153), // 60% alpha
            border: Border.all(color: AppColors.white.withAlpha(77), width: 0.5), // 30% alpha
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
              color: AppColors.white.withAlpha(51), // 20% alpha
              border: Border.all(color: AppColors.white.withAlpha(77), width: 0.5), // 30% alpha
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
                : Text('Libre', style: TextStyle(color: AppColors.white.withAlpha(170), fontSize: 12)), // 66% alpha
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
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
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
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  border: TableBorder.all(color: AppColors.white.withAlpha(128)), // 50% alpha
                  columnWidths: {
                    0: const IntrinsicColumnWidth(),
                    for (int i = 1; i <= daysInSchedule.length; i++)
                      i: const FixedColumnWidth(120.0),
                  },
                  children: tableRows,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
