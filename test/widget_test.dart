import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:arrienda_seguro/core/di/service_locator.dart';
import 'package:arrienda_seguro/providers/app_providers.dart';
import 'package:arrienda_seguro/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    final locator = ServiceLocator.instance;

    await tester.pumpWidget(
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
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Arrienda Seguro'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
