import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user_role.dart';
import '../../providers/app_providers.dart';
import '../../routing/app_routes.dart';
import '../chat/chat_list_screen.dart';
import '../contracts/contracts_screen.dart';
import '../home/home_screen.dart';
import '../payments/payments_screen.dart';
import '../profile/profile_screen.dart';
import '../properties/landlord_properties_screen.dart';

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

  void _onFabTap(UserRole? role) {
    switch (role) {
      case UserRole.arrendador:
        Navigator.pushNamed(context, AppRoutes.propertyForm);
      case UserRole.arrendatario:
        Navigator.pushNamed(context, AppRoutes.properties);
      case UserRole.admin:
        Navigator.pushNamed(context, AppRoutes.generateContract);
      default:
        break;
    }
  }

  void _onTap(int index, UserRole? role) {
    if (index == 2) {
      _onFabTap(role);
      return;
    }
    setState(() => _currentIndex = index);
    _reloadTabData(index);
  }

  void _reloadTabData(int index) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final isTenant = user.role == UserRole.arrendatario;
    final paymentsIndex = isTenant ? 4 : 3;

    if (index == 0 || index == 1 || index == paymentsIndex) {
      context.read<ContractProvider>().loadContracts(user);
    }
    if (index == 0 || index == paymentsIndex) {
      context.read<PaymentProvider>().loadDashboardData(user);
    }
  }

  List<Widget> _screens(UserRole? role) {
    if (role == UserRole.arrendatario) {
      return const [
        HomeScreen(),
        ContractsScreen(),
        SizedBox.shrink(),
        ChatListScreen(),
        PaymentsScreen(),
        ProfileScreen(),
      ];
    }

    final mainScreen = role == UserRole.arrendador
        ? const LandlordPropertiesScreen()
        : const HomeScreen();

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
    final isTenant = role == UserRole.arrendatario;

    final firstItem = isTenant || role == UserRole.admin
        ? const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          )
        : BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            activeIcon: const Icon(Icons.apartment),
            label: isLandlord ? 'Mis inmuebles' : 'Inicio',
          );

    const contractsItem = BottomNavigationBarItem(
      icon: Icon(Icons.description_outlined),
      activeIcon: Icon(Icons.description),
      label: 'Contratos',
    );

    final fabItem = BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isTenant ? Icons.search : Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      label: '',
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

    if (isTenant) {
      const chatsItem = BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: 'Chats',
      );
      return [
        firstItem,
        contractsItem,
        fabItem,
        chatsItem,
        paymentsItem,
        profileItem,
      ];
    }

    return [firstItem, contractsItem, fabItem, paymentsItem, profileItem];
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentUser?.role;
    final screens = _screens(role);
    final navItems = _navItems(role);
    final screenIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: screenIndex,
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
          currentIndex: _currentIndex.clamp(0, navItems.length - 1),
          onTap: (index) => _onTap(index, role),
          type: BottomNavigationBarType.fixed,
          items: navItems,
        ),
      ),
    );
  }
}
