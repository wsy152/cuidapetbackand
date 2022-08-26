
import 'package:cuidapet_api/application/helpers/request_mappting.dart';

class LoginViewModel extends RequestMapping {
  late String login;
  late String password;
  late String avatar;
  late String socialType;
  late String socialkey;
  late bool socialLogin;
  late bool supplierUser;

  LoginViewModel(super.dataRequest);
  @override
  void map() {
    login = data['login'];
    password = data['password'];
    avatar = data['avatar'];
    socialType = data['social_type'];
    socialkey = data['social_key'];
    socialLogin = data['social_login'];
    supplierUser = data['supplier_user'];
  }
}
