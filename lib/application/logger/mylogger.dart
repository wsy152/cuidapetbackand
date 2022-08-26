import 'package:logger/logger.dart';

import 'i_mylogger.dart';

class MyLogger implements IMyLogger {

  final _logger = Logger();

  @override
  void debug(message, [error, StackTrace? stackTrace]) => _logger.d(message,error,stackTrace);

  @override
  void error(message, [error, StackTrace? stackTrace]) => _logger.e(message,error,stackTrace);

  @override
  void info(message, [error, StackTrace? stackTrace]) => _logger.i(message,error,stackTrace);

  @override
  void warning(message, [error, StackTrace? stackTrace]) => _logger.w(message,error,stackTrace);

}