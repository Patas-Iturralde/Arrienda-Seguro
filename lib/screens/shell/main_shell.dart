import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';
import '../contracts/contracts_screen.dart';
import '../payments/payments_screen.dart';
import '../profile/profile_screen.dart';
import '../properties/landlord_properties_screen.dart';
import '../properties/properties_browse_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  bool _hasFab(UserRole? role) =>
      role == UserRole.arrendador || role == UserRole.admin;

  void _onTap(int index, UserRole? role) {
    if (_hasFab(role) && index == 2) {
      if (role == UserRole.arrendador) {
        Navigator.pushNamed(context, AppRoutes.propertyForm);
      } else {
        Navigator.pushNamed(context, AppRoutes.generateContract);
      }
      return;
    }
    setState(() => _currentIndex = index);
  }

  int _bodyIndex(int navIndex, UserRole? role) {
    if (!_hasFab(role)) return navIndex;
    if (navIndex <= 1) return navIndex;
    if (navIndex == 2) return 0;
    return navIndex - 1;
  }

  List<Widget> _screens(UserRole? role) {
    final isLandlord = role == UserRole.arrendador;
    final mainScreen = isLandlord
        ? const LandlordPropertiesScreen()
        : const PropertiesBrowseScreen();

    if (role == UserRole.arrendatario) {
      return const [
        PropertiesBrowseScreen(),
        ContractsScreen(),
        PaymentsScreen(),
        ProfileScreen(),
      ];
    }

    return [
      mainScreen,
      const ContractsScreen(),
      const SizedBox.shrink(),
      const PaymentsScreen(),
      const ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> _navItems(UserRole? role) {
    final isLandlord = role == UserRole.arrendador;

    final exploreItem = BottomNavigationBarItem(
      icon: Icon(isLandlord ? Icons.apartment_outlined : Icons.search),
      activeIcon: Icon(isLandlord ? Icons.apartment : Icons.search),
      label: isLandlord ? 'Mis deptos' : 'Explorar',
    );

    const contractsItem = BottomNavigationBarItem(
      icon: Icon(Icons.description_outlined),
      activeIcon: Icon(Icons.description),
      label: 'Contratos',
    );

    const paymentsItem = BottomNavigationBarItem(
      icon: Icon(Icons.payments_outlined),
      activeIcon: Icon(Icons.payments),
      label: 'Pagos',
    );

    const profileItem = BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    );

    if (role == UserRole.arrendatario) {
      return [exploreItem, contractsItem, paymentsItem, profileItem];
    }

    return [
      exploreItem,
      contractsItem,
      BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLandlord ? Icons.add : Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
        label: '',
      ),
      paymentsItem,
      profileItem,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentUser?.role;
    final screens = _screens(role);
    final bodyIndex = _bodyIndex(_currentIndex, role).clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: bodyIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex.clamp(0, _navItems(role).length - 1),
          onTap: (index) => _onTap(index, role),
          type: BottomNavigationBarType.fixed,
          items: _navItems(role),
        ),
      ),
    );
  }
}
