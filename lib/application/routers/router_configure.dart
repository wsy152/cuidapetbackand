
import 'package:cuidapet_api/application/routers/i_router_config.dart';
import 'package:cuidapet_api/modules/user/user_router.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterConfigure {
  final Router _router;
  RouterConfigure(this._router);

  final List<IRouterConfig> _routers = [
    UserRouter(),
  ];

  // ignore: avoid_function_literals_in_foreach_calls
  void configure() => _routers.forEach((r) => r.configure(_router));
}
