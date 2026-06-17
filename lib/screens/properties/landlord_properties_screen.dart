import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../providers/property_provider.dart';
import '../../routing/app_routes.dart';
import '../../widgets/property_card.dart';

class LandlordPropertiesScreen extends StatefulWidget {
  const LandlordPropertiesScreen({super.key});

  @override
  State<LandlordPropertiesScreen> createState() =>
      _LandlordPropertiesScreenState();
}

class _LandlordPropertiesScreenState extends State<LandlordPropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final provider = context.read<PropertyProvider>();
    provider.watchByLandlord(user.id);
    provider.loadByLandlord(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final provider = context.watch<PropertyProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mis departamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Conversaciones',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chatList),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo departamento',
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.propertyForm);
              _load();
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadByLandlord(user.id),
              child: provider.properties.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.add_home_work_outlined,
                            size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Aún no tienes departamentos registrados',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Toca + para agregar uno',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.properties.length,
                      itemBuilder: (context, index) {
                        final property = provider.properties[index];
                        return Column(
                          children: [
                            PropertyCard(
                              property: property,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.propertyDetail,
                                arguments: property.id,
                              ),
                            ),
                            PropertyCardActions(
                              property: property,
                              showAvailabilityToggle: true,
                              onAvailabilityChanged: (value) async {
                                await provider.toggleAvailability(
                                  property.id,
                                  value,
                                );
                              },
                              onEditTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.propertyForm,
                                  arguments: property,
                                );
                                _load();
                              },
                              onViewTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.propertyDetail,
                                arguments: property.id,
                              ),
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.propertyForm);
          _load();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo departamento'),
      ),
    );
  }
}
