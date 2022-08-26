// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/application/entitties/user_model.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/logger/i_mylogger.dart';
import 'package:cuidapet_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/user/view_models/user_save.input_model.dart';
import 'package:injectable/injectable.dart';

import './i_user_service.dart';


@LazySingleton(as: IUserService)
class UserService implements IUserService {
  IUserRepository userRepository;
  IMyLogger log;

  UserService({
    required this.userRepository,
    required this.log,
  });
  @override
  Future<UserModel> createUser(UserSaveInputModel user) {
    
    final userEntity = UserModel(
      email: user.email,
      password: user.password,
      registerType: 'APP',
      supplierId: user.supplierId
    );

   return userRepository.createUser(userEntity);
  }
  
  @override
  Future<UserModel> loginWithEmailPassoword(
          String email, String password, bool supplierUser) =>
      userRepository.loginWithEmailPassoword(email, password, supplierUser);

  @override
  Future<UserModel> loginByEmailsocialKey(
      String email, String avatar, String socitalType, String socialKey) async {
    try {
      return await userRepository.loginWithSocial(
          email, socialKey, socitalType);
    } on UserNotfoundException catch (e) {
      log.error('Usuário não encontrado, criando um usuário', e);
      final user = UserModel(
          email: email,
          imageAvatar: avatar,
          registerType: socitalType,
          socialKey: socialKey,
          password: DateTime.now().toString());      
      return await userRepository.createUser(user);
    }
  }
  

  

}
