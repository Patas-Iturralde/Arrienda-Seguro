import '../../models/app_document.dart';
import '../document_repository.dart';
import '../../services/mock_data_service.dart';

class MockDocumentRepository implements DocumentRepository {
  MockDocumentRepository(this._data);

  final MockDataService _data;

  @override
  Future<List<AppDocument>> getDocuments({String? contractId, String? userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    var docs = List<AppDocument>.from(_data.documents);
    if (contractId != null) {
      docs = docs.where((d) => d.contractId == contractId).toList();
    }
    docs.sort((a, b) => b.fecha.compareTo(a.fecha));
    return docs;
  }

  @override
  Future<AppDocument> createDocument(AppDocument document) async {
    _data.documents.add(document);
    return document;
  }

  @override
  Future<void> deleteDocument(String id) async {
    _data.documents.removeWhere((d) => d.id == id);
  }
}
