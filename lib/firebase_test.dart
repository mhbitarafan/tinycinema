import 'package:dio/dio.dart';
class User {
  late String name;
  User.fromJson(dynamic json) {
    name = json['name'];
  }
}
void main() async {
  var fbClient = Dio(BaseOptions(
    baseUrl:
        "https://tinycinema-app-default-rtdb.europe-west1.firebasedatabase.app",
    queryParameters: {"auth": "pNiOI1MlM0A63loxX2SsVB9rWutd4hJreYHyW6Vv"},
  ));
  fbClient.post("/favorites.json", data: 
    {"name": "ali16"}
  );
  // final res = await fbClient.get("/users.json");
  // var user = User.fromJson(res.data[0]);
  // print(user.name);
}
