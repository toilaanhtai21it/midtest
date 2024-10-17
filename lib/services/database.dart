// lib/services/database.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Phương thức để thêm chi tiết sản phẩm
  Future<void> addEmployeeDetails(
      Map<String, dynamic> employeeInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Employee")
        .doc(id)
        .set(employeeInfoMap);
  }

  // Phương thức để lấy chi tiết sản phẩm dưới dạng Stream
  Stream<QuerySnapshot> getEmployeeDetails() {
    return FirebaseFirestore.instance.collection("Employee").snapshots();
  }

  // Phương thức để cập nhật chi tiết sản phẩm
  Future<void> updateEmployeeDetails(
      String id, Map<String, dynamic> updateInfo) async {
    return await FirebaseFirestore.instance
        .collection("Employee")
        .doc(id)
        .update(updateInfo);
  }

  // Phương thức để xóa chi tiết sản phẩm
  Future<void> deleteEmployeeDetails(String id) async {
    return await FirebaseFirestore.instance
        .collection("Employee")
        .doc(id)
        .delete();
  }
}
