import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_api/application/entitties/user_model.dart';
import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logger/i_mylogger.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_api/modules/user/view_models/login_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_save.input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'auth_controller.g.dart';

@Injectable()
class AuthController {
  IUserService userService;
  IMyLogger log;
  AuthController({required this.userService,required this.log});

  @Route.post('/')
  Future<Response> login(Request request) async {
    try {
      final loginViewModel = LoginViewModel(await request.readAsString());

      UserModel user;

      if (!loginViewModel.socialLogin) {
        user = await userService.loginWithEmailPassoword(
            loginViewModel.login, loginViewModel.password, loginViewModel.supplierUser);
      } else {
        user = await userService.loginByEmailsocialKey(
          loginViewModel.login,
          loginViewModel.avatar,
          loginViewModel.socialType,
          loginViewModel.socialkey,
        );
      }
      return Response.ok(jsonEncode(
          {'access_token': JwtHelper.generateJWT(user.id!, user.supplierId)}));
    } on UserNotfoundException {
      return Response.forbidden(jsonEncode({'message':'Usuario ou senha invalidos'}));
    }catch(e,s) {
      log.error('Erro ao fazer o login',e,s);
      return Response.internalServerError(body: jsonEncode({'message':'Erro ao realizar login'}));
    }
  }

   @Route.post('/register')
   Future<Response> saveuser(Request request) async { 

    try {
      final userModel = UserSaveInputModel(await request.readAsString());
      await userService.createUser(userModel);
      return Response.ok(jsonEncode({'message': 'Cadastro realizado com sucesso'}));
    } on UserExistsException {
      return Response(400, body: ({'messge':'Usuario ja cadastrado na base de dados'}));
    } catch (e){
      log.error('Erro ao cadastrar usu[ario',e);
      return Response.internalServerError();

    }
  }

   Router get router => _$AuthControllerRouter(this);
}