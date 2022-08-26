import 'package:cuidapet_api/application/entitties/user_model.dart';

abstract class IUserRepository {  
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> loginWithEmailPassoword(String email, String password, bool supplierUser);
  Future<UserModel> loginWithSocial(String email,String socialKey, socitalType);
}