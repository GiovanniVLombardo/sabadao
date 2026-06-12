import 'package:flutter/material.dart';
import 'package:sabadao/models/attendance_result.dart';
import 'package:sabadao/models/match.dart';
import 'package:sabadao/services/attendance_service.dart';



class AttendanceController extends ValueNotifier<List<Match>> {
  final AttendanceService _attendanceService;

  AttendanceController({AttendanceService? attendanceService})
      : _attendanceService = attendanceService ?? AttendanceService(),
        super([]);


  Future<AttendanceResult> getAttendances(String matchId) async {
    return _attendanceService.getAttendances(matchId);
  }

  Future<void> setAttendance({
    required String matchId,
    required String playerId,
    required bool isConfirmed,
  }) async {
    await _attendanceService.insertAttendance(
      matchId: matchId,
      playerId: playerId,
      isConfirmed: isConfirmed,
    );
  }

  Future<void> removeAttendance({
    required String matchId,
    required String playerId,
  }) async {
    await _attendanceService.deleteAttendance(
      matchId: matchId,
      playerId: playerId,
    );
  }

  Future<void> addGuest({
    required String matchId,
    required String name,
    required String position
  }) async {
    await _attendanceService.addGuest(
      matchId: matchId,
      name: name,
      position: position
    );
  }
}