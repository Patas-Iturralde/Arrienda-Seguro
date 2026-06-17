import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/app_document.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/contract.dart';
import '../models/contract_status.dart';
import '../models/payment.dart';
import '../models/payment_status.dart';
import '../models/property.dart';
import '../models/reminder.dart';
import '../models/user_role.dart';

/// Datos mock centralizados. Reemplazar por Firestore cuando se conecte Firebase.
class MockDataService {
  MockDataService._();
  static final instance = MockDataService._();

  final users = <AppUser>[
    const AppUser(
      id: 'admin-1',
      nombre: 'Carlos',
      apellido: 'Administrador',
      email: 'admin@arriendaseguro.com',
      telefono: '+57 300 111 0001',
      cedula: '1000000001',
      role: UserRole.admin,
    ),
    const AppUser(
      id: 'arrendador-1',
      nombre: 'Juan',
      apellido: 'Pérez',
      email: 'juan.perez@email.com',
      telefono: '+57 300 222 0002',
      cedula: '1234567890',
      role: UserRole.arrendador,
    ),
    const AppUser(
      id: 'arrendatario-1',
      nombre: 'María',
      apellido: 'González',
      email: 'maria.gonzalez@email.com',
      telefono: '+57 300 333 0003',
      cedula: '9876543210',
      role: UserRole.arrendatario,
    ),
    const AppUser(
      id: 'arrendatario-2',
      nombre: 'Pedro',
      apellido: 'Ramírez',
      email: 'pedro.ramirez@email.com',
      telefono: '+57 300 444 0004',
      cedula: '5555555555',
      role: UserRole.arrendatario,
    ),
  ];

  final properties = <Property>[
    Property(
      id: 'prop-1',
      nombre: 'Apartamento moderno en Chapinero',
      descripcion:
          'Amplio apartamento de 85 m² con excelente iluminación, cocina integral y balcón. Ideal para parejas o profesionales.',
      direccion: 'Calle 45 #12-34',
      ciudad: 'Bogotá',
      valor: 1250000,
      arrendadorId: 'arrendador-1',
      arrendadorNombre: 'Juan Pérez',
      tipo: 'Apartamento',
      fotos: const [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      ],
      servicios: const [
        'WiFi incluido',
        'Parqueadero',
        'Portería 24h',
        'Zona de lavandería',
      ],
      disponible: true,
      createdAt: DateTime(2024, 1, 10),
      updatedAt: DateTime.now(),
    ),
    Property(
      id: 'prop-2',
      nombre: 'Casa El Poblado con jardín',
      descripcion:
          'Casa de 3 habitaciones en zona residencial, con jardín privado y cocina abierta. Perfecta para familias.',
      direccion: 'Carrera 15 #78-90',
      ciudad: 'Medellín',
      valor: 2800000,
      arrendadorId: 'arrendador-1',
      arrendadorNombre: 'Juan Pérez',
      tipo: 'Casa',
      fotos: const [
        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
      ],
      servicios: const [
        'WiFi incluido',
        'Jardín privado',
        'Mascotas permitidas',
        'Cocina equipada',
      ],
      disponible: true,
      createdAt: DateTime(2024, 3, 5),
      updatedAt: DateTime.now(),
    ),
    Property(
      id: 'prop-3',
      nombre: 'Local comercial Av. 68',
      descripcion:
          'Local en primer piso con vitrina amplia, baño privado y acceso directo desde la avenida principal.',
      direccion: 'Av. 68 #25-10',
      ciudad: 'Bogotá',
      valor: 3500000,
      arrendadorId: 'arrendador-1',
      arrendadorNombre: 'Juan Pérez',
      tipo: 'Local comercial',
      fotos: const [
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
      ],
      servicios: const [
        'Baño privado',
        'Vitrina amplia',
        'Acceso directo',
      ],
      disponible: false,
      createdAt: DateTime(2023, 8, 20),
      updatedAt: DateTime.now(),
    ),
    Property(
      id: 'prop-4',
      nombre: 'Estudio céntrico en Quito',
      descripcion:
          'Estudio completamente amoblado cerca del centro histórico. Servicios incluidos y contrato flexible.',
      direccion: 'Av. Amazonas N24-03',
      ciudad: 'Quito',
      valor: 450,
      arrendadorId: 'arrendador-1',
      arrendadorNombre: 'Juan Pérez',
      tipo: 'Estudio',
      fotos: const [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
      ],
      servicios: const [
        'Amoblado',
        'Servicios incluidos',
        'Cancelación flexible',
      ],
      disponible: true,
      createdAt: DateTime(2024, 6, 1),
      updatedAt: DateTime.now(),
    ),
  ];

  final chatRooms = <ChatRoom>[];
  final chatMessages = <String, List<ChatMessage>>{};

  late final List<Contract> contracts = [
    Contract(
      id: 'contract-1',
      propertyId: 'prop-1',
      arrendadorId: 'arrendador-1',
      arrendatarioId: 'arrendatario-1',
      propertyName: 'Apartamento 201',
      arrendadorName: 'Juan Pérez',
      arrendatarioName: 'María González',
      direccion: 'Calle 45 #12-34, Bogotá',
      canonMensual: 1250000,
      deposito: 2500000,
      fechaInicio: DateTime(2023, 6, 1),
      fechaFin: DateTime(2025, 7, 31),
      status: ContractStatus.activo,
      diaPago: 5,
      clausulas: _defaultClauses,
    ),
    Contract(
      id: 'contract-2',
      propertyId: 'prop-2',
      arrendadorId: 'arrendador-1',
      arrendatarioId: 'arrendatario-2',
      propertyName: 'Casa El Poblado',
      arrendadorName: 'Juan Pérez',
      arrendatarioName: 'Pedro Ramírez',
      direccion: 'Carrera 15 #78-90, Medellín',
      canonMensual: 2800000,
      deposito: 5600000,
      fechaInicio: DateTime(2024, 1, 15),
      fechaFin: DateTime(2025, 6, 30),
      status: ContractStatus.porVencer,
      diaPago: 15,
      clausulas: _defaultClauses,
    ),
    Contract(
      id: 'contract-3',
      propertyId: 'prop-3',
      arrendadorId: 'arrendador-1',
      arrendatarioId: 'arrendatario-1',
      propertyName: 'Local Comercial 5',
      arrendadorName: 'Juan Pérez',
      arrendatarioName: 'María González',
      direccion: 'Av. 68 #25-10, Bogotá',
      canonMensual: 3500000,
      deposito: 7000000,
      fechaInicio: DateTime(2022, 3, 1),
      fechaFin: DateTime(2024, 2, 28),
      status: ContractStatus.finalizado,
      diaPago: 1,
      clausulas: _defaultClauses,
    ),
  ];

  late final List<Payment> payments = _generatePayments();
  late final List<AppDocument> documents = _generateDocuments();
  late final List<AppNotification> notifications = _generateNotifications();
  late final List<Reminder> reminders = _generateReminders();

  static const _defaultClauses = [
    ContractClause(
      titulo: 'Objeto del contrato',
      contenido:
          'El ARRENDADOR cede en arrendamiento al ARRENDATARIO el inmueble descrito, para uso exclusivo de vivienda/comercio según corresponda.',
    ),
    ContractClause(
      titulo: 'Canon de arrendamiento',
      contenido:
          'El canon mensual será pagado dentro de los primeros cinco (5) días de cada mes. El incumplimiento generará intereses de mora.',
    ),
    ContractClause(
      titulo: 'Depósito en garantía',
      contenido:
          'El ARRENDATARIO entrega un depósito equivalente a dos (2) meses de canon, reembolsable al finalizar el contrato sin perjuicios.',
    ),
    ContractClause(
      titulo: 'Duración',
      contenido:
          'El presente contrato tendrá la duración estipulada en las fechas de inicio y fin, prorrogable de común acuerdo entre las partes.',
    ),
    ContractClause(
      titulo: 'Obligaciones del arrendatario',
      contenido:
          'Mantener el inmueble en buen estado, pagar servicios públicos y no subarrendar sin autorización escrita del ARRENDADOR.',
    ),
  ];

  List<Payment> _generatePayments() {
    final now = DateTime.now();
    final list = <Payment>[];

    for (final contract in contracts.where((c) => c.status != ContractStatus.finalizado)) {
      for (var i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, contract.diaPago);
        final isPaid = i > 0;
        final isPending = i == 0;

        list.add(Payment(
          id: 'pay-${contract.id}-$i',
          contractId: contract.id,
          mes: date.month,
          anio: date.year,
          monto: contract.canonMensual,
          fechaVencimiento: date,
          status: isPaid
              ? PaymentStatus.pagado
              : isPending
                  ? PaymentStatus.pendiente
                  : PaymentStatus.vencido,
          fechaPago: isPaid ? date.subtract(const Duration(days: 1)) : null,
          reciboId: isPaid ? 'doc-recibo-${contract.id}-$i' : null,
        ));
      }
    }

    return list;
  }

  List<AppDocument> _generateDocuments() {
    final now = DateTime.now();
    return [
      AppDocument(
        id: 'doc-contrato-1',
        nombre: 'Contrato - Apto 201',
        tipo: DocumentType.contrato,
        tamano: '1.2 MB',
        fecha: DateTime(2023, 6, 1),
        contractId: 'contract-1',
      ),
      AppDocument(
        id: 'doc-contrato-2',
        nombre: 'Contrato - Casa El Poblado',
        tipo: DocumentType.contrato,
        tamano: '1.4 MB',
        fecha: DateTime(2024, 1, 15),
        contractId: 'contract-2',
      ),
      AppDocument(
        id: 'doc-recibo-contract-1-1',
        nombre: 'Recibo ${_monthName(now.month - 1)} ${now.year}',
        tipo: DocumentType.recibo,
        tamano: '0.3 MB',
        fecha: DateTime(now.year, now.month - 1, 5),
        contractId: 'contract-1',
        paymentId: 'pay-contract-1-1',
      ),
      AppDocument(
        id: 'doc-recibo-contract-1-2',
        nombre: 'Recibo ${_monthName(now.month - 2)} ${now.year}',
        tipo: DocumentType.recibo,
        tamano: '0.3 MB',
        fecha: DateTime(now.year, now.month - 2, 5),
        contractId: 'contract-1',
        paymentId: 'pay-contract-1-2',
      ),
      AppDocument(
        id: 'doc-otros-1',
        nombre: 'Inventario - Apto 201',
        tipo: DocumentType.otro,
        tamano: '0.8 MB',
        fecha: DateTime(2023, 6, 1),
        contractId: 'contract-1',
      ),
    ];
  }

  List<AppNotification> _generateNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'notif-1',
        titulo: 'Pago registrado',
        descripcion: 'Se registró el pago de arriendo de Apartamento 201.',
        fecha: now.subtract(const Duration(hours: 2)),
        type: NotificationType.pagoRegistrado,
        group: NotificationGroup.hoy,
        contractId: 'contract-1',
      ),
      AppNotification(
        id: 'notif-2',
        titulo: 'Próximo pago de arriendo',
        descripcion:
            'El pago de \$1.250.000 vence el 05 de ${_monthName(now.month)}. Recuerda registrar el pago.',
        fecha: now,
        type: NotificationType.pagoProximo,
        group: NotificationGroup.proximos,
        contractId: 'contract-1',
      ),
      AppNotification(
        id: 'notif-3',
        titulo: 'Contrato por vencer',
        descripcion:
            'El contrato de Casa El Poblado vence en 30 días. Considera renovarlo.',
        fecha: now.add(const Duration(days: 1)),
        type: NotificationType.contratoPorVencer,
        group: NotificationGroup.proximos,
        contractId: 'contract-2',
      ),
      AppNotification(
        id: 'notif-4',
        titulo: 'Recordatorio de pago',
        descripcion:
            'Notificación enviada al arrendador y arrendatario sobre el pago pendiente.',
        fecha: now.subtract(const Duration(days: 3)),
        type: NotificationType.recordatorio,
        group: NotificationGroup.anteriores,
        contractId: 'contract-1',
      ),
      AppNotification(
        id: 'notif-5',
        titulo: 'Contrato renovado',
        descripcion: 'El contrato de Apartamento 201 fue renovado exitosamente.',
        fecha: now.subtract(const Duration(days: 15)),
        type: NotificationType.contratoRenovado,
        group: NotificationGroup.anteriores,
        contractId: 'contract-1',
      ),
    ];
  }

  List<Reminder> _generateReminders() {
    final now = DateTime.now();
    return [
      Reminder(
        id: 'rem-1',
        titulo: 'Pago de arriendo - Apartamento 201',
        fecha: DateTime(now.year, now.month, 5),
        type: ReminderType.pagoArriendo,
        contractId: 'contract-1',
        contractName: 'Apartamento 201',
      ),
      Reminder(
        id: 'rem-2',
        titulo: 'Pago de arriendo - Casa El Poblado',
        fecha: DateTime(now.year, now.month, 15),
        type: ReminderType.pagoArriendo,
        contractId: 'contract-2',
        contractName: 'Casa El Poblado',
      ),
      Reminder(
        id: 'rem-3',
        titulo: 'Vencimiento contrato - Casa El Poblado',
        fecha: DateTime(2025, 6, 30),
        type: ReminderType.vencimientoContrato,
        contractId: 'contract-2',
        contractName: 'Casa El Poblado',
      ),
    ];
  }

  String _monthName(int month) {
    const names = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    var m = month;
    while (m <= 0) {
      m += 12;
    }
    while (m > 12) {
      m -= 12;
    }
    return names[m - 1];
  }
}
