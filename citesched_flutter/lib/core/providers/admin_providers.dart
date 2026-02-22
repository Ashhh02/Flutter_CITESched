import 'package:citesched_client/citesched_client.dart';
import 'package:citesched_flutter/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final facultyListProvider = FutureProvider<List<Faculty>>((ref) async {
  return await client.admin.getAllFaculty();
});

final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  return await client.admin.getAllSubjects();
});

final roomListProvider = FutureProvider<List<Room>>((ref) async {
  return await client.admin.getAllRooms();
});

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  return await client.admin.getAllRooms();
});

final timeslotsProvider = FutureProvider<List<Timeslot>>((ref) async {
  return await client.admin.getAllTimeslots();
});

final schedulesProvider = FutureProvider<List<Schedule>>((ref) async {
  return await client.admin.getAllSchedules();
});
