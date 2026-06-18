import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'package:universal_html/html.dart' as html;

import 'core/theme/theme.dart';
import 'core/routing/router_config.dart';
import 'core/network/network_client.dart';
import 'features/auth/data/token_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_bloc.dart';
import 'features/auth/logic/auth_event.dart';
import 'core/state/data_sync_bloc.dart';
import 'core/state/data_sync_event.dart';

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
  final baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://127.0.0.1:8000/api';
  final networkClient = NetworkClient(tokenStorage: tokenStorage, baseUrl: baseUrl);
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
  await dotenv.load(fileName: "rapid_aid.env");

  if (kIsWeb) {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey != null) {
      final script = html.ScriptElement()
        ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
        ..type = 'text/javascript';
      html.document.head?.append(script);
    }
  }

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
  late final DataSyncBloc _dataSyncBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: getIt<AuthRepository>());
    _dataSyncBloc = DataSyncBloc();

    // Wire the interceptor's session expiry → AuthBloc logout
    getIt<NetworkClient>().authInterceptor.onSessionExpired = () {
      _dataSyncBloc.add(DataSyncStopPolling());
      _authBloc.add(const AuthLogoutRequested());
    };

    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _dataSyncBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<DataSyncBloc>.value(value: _dataSyncBloc),
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
