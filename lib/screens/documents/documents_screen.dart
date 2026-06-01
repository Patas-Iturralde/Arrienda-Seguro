import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_document.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, this.contractId});

  final String? contractId;

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<AppDocument> _documents = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final docs = await ServiceLocator.instance.documentRepository.getDocuments(
      contractId: widget.contractId,
    );
    if (mounted) setState(() => _documents = docs);
  }

  IconData _iconFor(DocumentType type) {
    return switch (type) {
      DocumentType.contrato => Icons.description,
      DocumentType.recibo => Icons.receipt_long,
      DocumentType.otro => Icons.folder,
    };
  }

  @override
  Widget build(BuildContext context) {
    final contratos =
        _documents.where((d) => d.tipo == DocumentType.contrato).toList();
    final recibos =
        _documents.where((d) => d.tipo == DocumentType.recibo).toList();
    final otros = _documents.where((d) => d.tipo == DocumentType.otro).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contractId != null ? 'Documentos del contrato' : 'Documentos'),
      ),
      body: _documents.isEmpty
          ? const Center(
              child: Text(
                'No hay documentos disponibles',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (contratos.isNotEmpty) ...[
                  _SectionHeader(title: 'Contratos'),
                  ...contratos.map((d) => _DocumentTile(document: d, icon: _iconFor(d.tipo))),
                ],
                if (recibos.isNotEmpty) ...[
                  _SectionHeader(title: 'Recibos mensuales'),
                  ...recibos.map((d) => _DocumentTile(document: d, icon: _iconFor(d.tipo))),
                ],
                if (otros.isNotEmpty) ...[
                  _SectionHeader(title: 'Otros documentos'),
                  ...otros.map((d) => _DocumentTile(document: d, icon: _iconFor(d.tipo))),
                ],
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document, required this.icon});

  final AppDocument document;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(document.nombre),
        subtitle: Text(
          'PDF · ${document.tamano} · ${Formatters.dateShort(document.fecha)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: AppColors.primary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Descarga simulada: ${document.nombre}')),
            );
          },
        ),
      ),
    );
  }
}
