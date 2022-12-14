import 'package:cuidapet_api/application/entitties/user_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_save.input_model.dart';

abstract class IUserService {
  Future<UserModel> createUser(UserSaveInputModel user);
  Future<UserModel> loginWithEmailPassoword(String email, String password, bool supplierUser);
  Future<UserModel> loginWithSocial(String email,String avatar,String socitalType, String socialKey);
  Future<String> confirmLogin(UserConfirmInputModel imputModel);
}