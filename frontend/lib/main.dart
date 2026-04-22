import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/theme.dart';
import 'core/routing/router_config.dart';
import 'features/auth/logic/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RapidAidApp());
}

class RapidAidApp extends StatelessWidget {
  const RapidAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
      ],
      child: MaterialApp.router(
        title: 'Rapid Aid',
        theme: AppTheme.clinicalVanguardTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
