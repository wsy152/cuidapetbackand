// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/entitties/user_model.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/helpers/cripty_helper.dart';
import 'package:cuidapet_api/application/logger/i_mylogger.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './i_user_repository.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  final IDatabaseConnection connection;
  final IMyLogger log;

  UserRepository({
    required this.connection,
    required this.log,
  });
  @override
  Future<UserModel> createUser(UserModel user) async {
     MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final query = ''' 

        insert usuario(email, tipo_cadastro, img_avatar, senha, fornecedor_id, social_id)
        values(?,?,?,?,?,?)
    
    ''';
      final result = await conn.query(query, [
        user.email,
        user.registerType,
        user.imageAvatar,
        CriptyHelper.generateSha256Hash(user.password ?? ''),
        user.supplierId,
        user.socialKey
      ]);

      final userId = result.insertId;
      return user.copyWith(id: userId, password: null);
    } on MySqlException catch (e, s) {
      if (e.message.contains('usuario.email_UNIQUE')) {
        log.error('Usuario ja cadastrado na base de dados', e, s);

        throw UserExistsException();
      }
      log.error('Erro ao criar usuario', e, s);
      throw DatabaseException(message: 'Erro ao criar usuario', exception: e);
    } finally {
      await conn?.close();
    }
   
  }
  
  @override
  Future<UserModel> loginWithEmailPassoword(String email, String password, bool supplierUser) async{

    MySqlConnection? conn;

    try {
       conn = await connection.openConnection();
      var query1 = ''' 

      select * 
      from usuario
      where
        email = ? and
        senha = ?
      ''';

      if(supplierUser){
        query1 += 'and fornecedor_id is not null';
      } else{
        query1 += 'and fornecedor_id is null';
      }
      final result = await conn.query(query1, [
        email,
        CriptyHelper.generateSha256Hash(password),
      ]);

      if(result.isEmpty){
        log.error('usuario ou senha invalidos');
        throw UserNotfoundException(message: 'usuario ou senha invalidos!!!');
      }else{
        final userSqlData = result.first;
        return UserModel(
          id: userSqlData['id'] as int,
          email: userSqlData['email'],
          registerType: userSqlData['tipo_cadastro'],
          iosToken: (userSqlData['io_token'] as Blob?)?.toString(),
          androidToken: (userSqlData['android_token'] as Blob?)?.toString(),
          refreshToken: (userSqlData['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (userSqlData['img_avatar'] as Blob?)?.toString(),
          supplierId: userSqlData['fornecedor_id']

        );
      }
    }on MySqlException catch(e,s) {
      log.error('Erro ao realizar login',e,s);
      throw DatabaseException(message: 'Erro ao realizar login',exception: e);
     
      
    }finally{
       await conn?.close();
    }
  }
  
  @override
  Future<UserModel> loginByEmailSocialKey(String email, String socialKey, socitalType) async{
    MySqlConnection? conn;

  try {    
    conn= await connection.openConnection();
    final  result = await conn.query('select * from usuario where email = ?',[email]);
    if(result.isEmpty){
      throw UserNotfoundException(message: 'Usuário não encontrado');
    }else{
      final dataMysql = result.first;
      if (dataMysql['social_id'] == null || dataMysql['social_id'] != socialKey) {
          await conn.query('''update usuario 
                              set social_id = ?, 
                              tipo_cadastro = ? 
                            where id = ?''',
              [socialKey, socitalType, dataMysql['id']]);
        }
        return UserModel(
          id: dataMysql['id'] as int,
          email: dataMysql['email'],
          registerType: dataMysql['tipo_cadastro'],
          iosToken: (dataMysql['io_token'] as Blob?)?.toString(),
          androidToken: (dataMysql['android_token'] as Blob?)?.toString(),
          refreshToken: (dataMysql['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (dataMysql['img_avatar'] as Blob?)?.toString(),
            supplierId: dataMysql['fornecedor_id']);
      }
      
    } finally {
      await conn?.close();
    }

  }
  
  @override
  Future<void> updateUserDeviceTokenAndRefreshToken(UserModel user)async {
   
    MySqlConnection? conn;
    try{  

      conn = await connection.openConnection();  

      final setParams = {};

      if(user.iosToken != null){
        setParams.putIfAbsent('ios_token', () => user.iosToken);

      }else{
         setParams.putIfAbsent('android_token', () => user.androidToken);

      }
      
    } finally {
      await conn?.close();
      
    }

   
  }


  

 
}
