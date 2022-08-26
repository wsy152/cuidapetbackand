import 'dart:io';

import 'package:cuidapet_api/application/config/application_config.dart';
import 'package:cuidapet_api/application/middlewares/cors/cors_middlewares.dart';
import 'package:cuidapet_api/application/middlewares/default_content_type/default_content_type.dart';
import 'package:cuidapet_api/application/middlewares/security/security_middleware.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart'  as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  final router = Router();

  final appConfig = ApplicationConfig();
  await appConfig.loadConfigApplication(router);

  final getIt = GetIt.I;

  // Configure a pipeline that logs requests.
  final handler = shelf.Pipeline()
  .addMiddleware(CorsMiddlewares().handler)
  .addMiddleware(DefaultContentType().handler)
  .addMiddleware(shelf.logRequests())
  .addMiddleware(SecurityMiddleware(getIt.get()).handler)
  .addHandler(router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8484');
  final server = await io.serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}


