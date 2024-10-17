// lib/pages/home.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:midtest/pages/employee.dart';
import 'package:midtest/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream<QuerySnapshot>? employeeStream;

  // Các TextEditingController cho việc chỉnh sửa
  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // Phương thức để lấy dữ liệu từ Firestore
  void getOnTheLoad() {
    employeeStream = DatabaseMethods().getEmployeeDetails();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  // Widget để hiển thị tất cả chi tiết sản phẩm
  Widget allEmployeeDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: employeeStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hiển thị loading indicator khi đang tải dữ liệu
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Hiển thị thông báo nếu không có dữ liệu
          return Center(child: Text("Không tìm thấy sản phẩm."));
        }

        // Hiển thị danh sách sản phẩm
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            return Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Tên Sản Phẩm: " + (ds["Name"] ?? "N/A"),
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Chuyển đổi Price thành String
                              nameController.text = ds["Name"] ?? "";
                              typeController.text = ds["Type"] ?? "";
                              priceController.text =
                                  ds["Price"]?.toString() ?? "";
                              EditEmployeeDetails(ds["Id"]);
                            },
                            child: Icon(Icons.edit, color: Colors.orange),
                          ),
                          SizedBox(width: 10.0),
                          GestureDetector(
                            onTap: () async {
                              await DatabaseMethods()
                                  .deleteEmployeeDetails(ds["Id"]);
                              Fluttertoast.showToast(
                                msg: "Đã xóa sản phẩm",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.orange,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "Loại Sản Phẩm: " + (ds["Type"] ?? "N/A"),
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "Giá Sản Phẩm: " + (ds["Price"]?.toString() ?? "N/A"),
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Chuyển đến màn hình thêm sản phẩm và đợi kết quả
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Employee(),
            ),
          );
          // Tải lại dữ liệu sau khi thêm sản phẩm
          getOnTheLoad();
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Flutter",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Firebase",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Fluttertoast.showToast(
                msg: "Đã đăng xuất",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child: Column(
          children: [
            Expanded(child: allEmployeeDetails()),
          ],
        ),
      ),
    );
  }

  // Phương thức để hiển thị dialog chỉnh sửa
  Future EditEmployeeDetails(String id) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.cancel),
                      ),
                      SizedBox(width: 60.0),
                      Text(
                        "Chỉnh Sửa",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        " Chi Tiết",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Tên Sản Phẩm",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Loại Sản Phẩm",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: typeController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Giá",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number, // Chỉ cho nhập số
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          // Kiểm tra và chuyển đổi Price thành int
                          int? price = int.tryParse(priceController.text);
                          if (price == null) {
                            Fluttertoast.showToast(
                              msg: "Vui lòng nhập giá hợp lệ",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            return;
                          }

                          Map<String, dynamic> updateInfo = {
                            "Name": nameController.text,
                            "Type": typeController.text,
                            "Id": id,
                            "Price": price, // Lưu dưới dạng int
                          };
                          await DatabaseMethods()
                              .updateEmployeeDetails(id, updateInfo)
                              .then((value) {
                            Fluttertoast.showToast(
                              msg: "Đã cập nhật thành công",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            Navigator.pop(context);
                            // Xóa dữ liệu controller sau khi cập nhật
                            nameController.clear();
                            typeController.clear();
                            priceController.clear();
                          }).catchError((error) {
                            Fluttertoast.showToast(
                              msg: "Lỗi khi cập nhật sản phẩm: $error",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          });
                        },
                        child: Text("Cập Nhật",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold))),
                  )
                ],
              ),
            ),
          ));
}
