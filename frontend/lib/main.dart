import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'core/routing/router_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RapidAidApp());
}

class RapidAidApp extends StatelessWidget {
  const RapidAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rapid Aid',
      theme: AppTheme.clinicalVanguardTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
