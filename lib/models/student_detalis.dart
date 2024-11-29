import 'package:school_management/models/category.dart';

class StudentDetalis {
  const StudentDetalis({
    required this.id,
    required this.name,
    required this.studentid,
    required this.subject,
    required this.address,
    required this.phoneNumber,
    required this.feePaid,
  });
  final String id;
  final String name;
  final int studentid;
  final Category subject;
  final String address;
  final int phoneNumber;
  final double feePaid;
}
