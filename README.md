# Arrienda Seguro

Aplicación Flutter para administrar arriendos con roles de **Administrador**, **Arrendador** y **Arrendatario**.

## Características

- Dashboard con resumen de contratos, pagos pendientes y próximos vencimientos
- Gestión de contratos (activos, por vencer, finalizados)
- Detalle de contrato con cláusulas y documentos
- Registro de pagos con generación automática de recibos
- Calendario y recordatorios de pagos/vencimientos
- Notificaciones (pagos, vencimientos, recordatorios)
- Generación de contratos en 3 pasos
- Renovación de contratos
- Almacén de documentos (contratos y recibos mensuales)

## Usuarios demo

| Rol | Email | Contraseña |
|-----|-------|------------|
| Admin | admin@arriendaseguro.com | 123456 |
| Arrendador | juan.perez@email.com | 123456 |
| Arrendatario | maria.gonzalez@email.com | 123456 |

## Ejecutar

```bash
flutter pub get
flutter run
```

## Arquitectura (lista para Firebase)

```
lib/
├── core/di/service_locator.dart    # Inyección de dependencias
├── data/
│   ├── models/                     # Modelos con toMap/fromMap
│   ├── repositories/               # Interfaces abstractas
│   ├── repositories/mock/          # Implementaciones mock actuales
│   └── services/mock_data_service.dart
├── providers/                      # Estado con Provider
└── screens/                        # Pantallas de la UI
```

Para conectar Firebase, reemplazar en `service_locator.dart` las implementaciones `Mock*Repository` por `Firebase*Repository` que implementen las mismas interfaces.

## Dependencias

- `provider` - Gestión de estado
- `intl` - Formato de fechas y moneda
- `table_calendar` - Calendario
- `uuid` - IDs únicos para nuevos registros
