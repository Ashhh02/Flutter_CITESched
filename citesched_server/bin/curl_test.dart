import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var response = await http.post(
    Uri.parse('http://localhost:8083/admin/testMaxLoadValidation'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'facultyId': 2, 'units': -1.0}),
  );
  print('Response status: \${response.statusCode}');
  print('Response body: \${response.body}');
}
