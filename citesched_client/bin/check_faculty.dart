import 'package:citesched_client/citesched_client.dart';

void main() async {
  var client = Client('http://localhost:8083/');
  client.connectivityMonitor = null;

  try {
    var facultyList = await client.admin.getAllFaculty();
    for (var f in facultyList) {
      print('Faculty: ${f.name} (ID: ${f.id}) - maxLoad: ${f.maxLoad}');
    }

    var schedules = await client.admin.getAllSchedules();
    print('Total schedules: ${schedules.length}');
  } catch (e) {
    print('Error: $e');
  }
}
