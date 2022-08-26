import 'dart:convert';

import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logger/i_mylogger.dart';
import 'package:cuidapet_api/application/middlewares/middlewares.dart';
import 'package:cuidapet_api/application/middlewares/security/security_skip.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

class SecurityMiddleware extends Middlewares {
  final IMyLogger log;
  final skypUrl = <SecuritySkip>[
    SecuritySkip(url: '/auth/register', method: 'POST'),
    SecuritySkip(url: '/auth/', method: 'POST')
  ];

  SecurityMiddleware(this.log);

  @override
  Future<Response> execute(Request request) async {
    try {
      if (skypUrl.contains(
          SecuritySkip(url: '/${request.url.path}', method: request.method))) {
        return innerHandler(request);
      }
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || authHeader.isEmpty) {
         throw JwtException.invalidToken;
      }

      final authHeaderContent = authHeader.split('');
      if (authHeaderContent[0] != 'Bearer') {
         throw JwtException.invalidToken;
      }

      final authorizationToken = authHeaderContent[1];

      var claims = JwtHelper.getClaims(authorizationToken);

      if (request.url.path != 'auth/refresh') {
        claims.validate();
      }

      final claimsMap = claims.toJson();

      final userId = claimsMap['sub'];
      final supplierId = claimsMap['supplier'];

      if (userId != null) {
        throw JwtException.invalidToken;
      }
      final securityHeadeaders = {
        'user': userId,
        'access_token': authorizationToken,
        'supplier': supplierId,
      };
      return innerHandler(request.change(headers: securityHeadeaders));
    } on JwtException catch (e, s) {
      log.error('Erro ao validar token jwt', e, s);
      return Response.forbidden(jsonEncode({}));
    } catch (e, s) {
      log.error('Internal server error', e, s);
      return Response.forbidden(jsonEncode({}));
    }
  }
}
