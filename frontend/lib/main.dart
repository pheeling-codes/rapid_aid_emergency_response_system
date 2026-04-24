import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/theme.dart';
import 'core/routing/router_config.dart';
import 'core/network/network_client.dart';
import 'features/auth/data/token_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_bloc.dart';
import 'features/auth/logic/auth_event.dart';

final getIt = GetIt.instance;

Future<void> _initDependencies() async {
  // SharedPreferences (async init)
  final prefs = await SharedPreferences.getInstance();

  // Token Storage (encrypted + fast metadata)
  final tokenStorage = TokenStorage(
    secureStorage: const FlutterSecureStorage(),
    prefs: prefs,
  );
  getIt.registerSingleton<TokenStorage>(tokenStorage);

  // Network Client (Dio + AuthInterceptor)
  final networkClient = NetworkClient(tokenStorage: tokenStorage);
  getIt.registerSingleton<NetworkClient>(networkClient);

  // Auth Repository
  final authRepository = AuthRepository(
    dio: networkClient.dio,
    tokenStorage: tokenStorage,
  );
  getIt.registerSingleton<AuthRepository>(authRepository);

  // Wire session expiry callback → will be set after AuthBloc creation
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initDependencies();
  runApp(const RapidAidApp());
}

class RapidAidApp extends StatefulWidget {
  const RapidAidApp({super.key});

  @override
  State<RapidAidApp> createState() => _RapidAidAppState();
}

class _RapidAidAppState extends State<RapidAidApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: getIt<AuthRepository>());

    // Wire the interceptor's session expiry → AuthBloc logout
    getIt<NetworkClient>().authInterceptor.onSessionExpired = () {
      _authBloc.add(const AuthLogoutRequested());
    };

    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
      ],
      child: MaterialApp.router(
        title: 'Rapid Aid',
        theme: AppTheme.clinicalVanguardTheme,
        routerConfig: _appRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
