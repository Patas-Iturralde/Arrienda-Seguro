import '../models/app_document.dart';

/// Contrato abstracto para documentos.
/// Implementar con FirebaseDocumentRepository cuando se conecte Firebase.
abstract class DocumentRepository {
  Future<List<AppDocument>> getDocuments({String? contractId, String? userId});
  Future<AppDocument> createDocument(AppDocument document);
  Future<void> deleteDocument(String id);
}
