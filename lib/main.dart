import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'data/models/contract_generation_args.dart';
import 'data/models/property.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart';
import 'providers/property_provider.dart';
import 'routing/app_routes.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/contracts/contract_detail_screen.dart';
import 'screens/contracts/generate_contract_screen.dart';
import 'screens/contracts/renew_contract_screen.dart';
import 'screens/documents/documents_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/payments/landlord_payment_review_screen.dart';
import 'screens/payments/payments_screen.dart';
import 'screens/payments/tenant_register_payment_screen.dart';
import 'screens/properties/landlord_rental_requests_screen.dart';
import 'screens/properties/properties_browse_screen.dart';
import 'screens/properties/property_detail_screen.dart';
import 'screens/properties/property_form_screen.dart';
import 'screens/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!DefaultFirebaseOptions.currentPlatform.projectId.startsWith('YOUR_')) {
      firebaseEnabled = true;
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      }
    }
  } catch (e) {
    debugPrint('Firebase no configurado, usando datos mock: $e');
  }

  final locator = ServiceLocator.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(locator.authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ContractProvider(
            locator.contractRepository,
            locator.paymentRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(locator.paymentRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PropertyProvider(locator.propertyRepository),
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
        AppRoutes.calendar: (_) => const CalendarScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.propertyForm: (_) => const PropertyFormScreen(),
        AppRoutes.chatList: (_) => const ChatListScreen(),
        AppRoutes.properties: (_) => const PropertiesBrowseScreen(),
        AppRoutes.rentalRequests: (_) => const LandlordRentalRequestsScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.generateContract:
            return MaterialPageRoute(
              builder: (_) => GenerateContractScreen(
                args: settings.arguments as ContractGenerationArgs?,
              ),
            );
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
          case AppRoutes.tenantRegisterPayment:
            return MaterialPageRoute(
              builder: (_) => const TenantRegisterPaymentScreen(),
            );
          case AppRoutes.landlordPaymentReview:
            return MaterialPageRoute(
              builder: (_) => LandlordPaymentReviewScreen(
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
          case AppRoutes.propertyDetail:
            return MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(
                propertyId: settings.arguments as String,
              ),
            );
          case AppRoutes.propertyForm:
            return MaterialPageRoute(
              builder: (_) => PropertyFormScreen(
                property: settings.arguments as Property?,
              ),
            );
          case AppRoutes.chat:
            return MaterialPageRoute(
              builder: (_) => ChatScreen(
                roomId: settings.arguments as String,
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
