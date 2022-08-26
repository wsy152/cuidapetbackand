
import 'package:cuidapet_api/application/config/database_connection_configuration.dart';
import 'package:cuidapet_api/application/config/service_locator.dart';
import 'package:cuidapet_api/application/logger/mylogger.dart';
import 'package:cuidapet_api/application/routers/router_configure.dart';

import 'package:dotenv/dotenv.dart' show env,load;
import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';


import '../logger/i_mylogger.dart';

class ApplicationConfig {
 
  Future<void> loadConfigApplication(Router router)async{ 
    await _loadEnv();
    _loadDatabaseConfig();
    _configLogger();

    _loadDependencies();
    _loadRoutersConfigure(router);
  }

  Future<void>_loadEnv() async  => load();

  void _loadDatabaseConfig(){
    final databaseConfig = DatabaseConnectionConfiguration(
      host: env['DATABASE_HOST'] ?? env['database_host'] ?? '',
      user: env['DATABASE_USER'] ?? env['database_user']?? '',
      port: int.tryParse(env['DATABASE_PORT'] ?? env['database_port']!)?? 0,
      password: env['DATABASE_PASSWORD'] ?? env['database_password']!,
      database: env['DATABASE_NAME'] ?? env['database_name']!,
    );
    GetIt.I.registerSingleton(databaseConfig);
  }
  void _configLogger() => GetIt.I.registerLazySingleton<IMyLogger>(()=> MyLogger());
  
  void _loadDependencies() => configureDependencies();
  
  void _loadRoutersConfigure(Router router) => RouterConfigure(router).configure();






}

