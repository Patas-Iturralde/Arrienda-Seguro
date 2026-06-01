import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'routing/app_routes.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/contracts/contract_detail_screen.dart';
import 'screens/contracts/generate_contract_screen.dart';
import 'screens/contracts/renew_contract_screen.dart';
import 'screens/documents/documents_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/payments/payments_screen.dart';
import 'screens/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  final locator = ServiceLocator.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(locator.authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ContractProvider(locator.contractRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(locator.paymentRepository),
        ),
      ],
      child: const ArriendaSeguroApp(),
    ),
  );
}

class ArriendaSeguroApp extends StatelessWidget {
  const ArriendaSeguroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrienda Seguro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthWrapper(),
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.generateContract: (_) => const GenerateContractScreen(),
        AppRoutes.calendar: (_) => const CalendarScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.contractDetail:
            return MaterialPageRoute(
              builder: (_) => ContractDetailScreen(
                contractId: settings.arguments as String,
              ),
            );
          case AppRoutes.paymentRecord:
            return MaterialPageRoute(
              builder: (_) => PaymentRecordScreen(
                contractId: settings.arguments as String,
              ),
            );
          case AppRoutes.registerPayment:
            return MaterialPageRoute(
              builder: (_) => RegisterPaymentScreen(
                paymentId: settings.arguments as String,
              ),
            );
          case AppRoutes.renewContract:
            return MaterialPageRoute(
              builder: (_) => RenewContractScreen(
                contractId: settings.arguments as String,
              ),
            );
          case AppRoutes.documents:
            return MaterialPageRoute(
              builder: (_) => DocumentsScreen(
                contractId: settings.arguments as String?,
              ),
            );
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const MainShell());
          default:
            return null;
        }
      },
    );
  }
}
