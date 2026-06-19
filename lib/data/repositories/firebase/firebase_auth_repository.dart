import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/firebase_auth_errors.dart';
import '../../models/app_user.dart';
import '../../models/auth_result.dart';
import '../../models/id_document_type.dart';
import '../../models/marital_status.dart';
import '../../models/user_role.dart';
import '../auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AppUser? _cachedUser;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  AppUser? get currentUser => _cachedUser;

  @override
  Stream<AppUser?> get authStateChanges async* {
    await for (final firebaseUser in _auth.authStateChanges()) {
      if (firebaseUser == null) {
        // Evita borrar la sesión por eventos transitorios del stream en web.
        if (_auth.currentUser == null) {
          _cachedUser = null;
          yield null;
        }
        continue;
      }
      try {
        _cachedUser = await _loadUser(firebaseUser.uid);
        yield _cachedUser;
      } catch (e) {
        debugPrint('Error al cargar usuario en authStateChanges: $e');
        if (_cachedUser != null) {
          yield _cachedUser;
        }
      }
    }
  }

  Future<AppUser?> _loadUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        final firebaseUser = _auth.currentUser;
        if (firebaseUser == null) return null;
        return AppUser(
          id: uid,
          nombre: firebaseUser.displayName?.split(' ').first ?? 'Usuario',
          apellido:
              firebaseUser.displayName?.split(' ').skip(1).join(' ') ?? '',
          email: firebaseUser.email ?? '',
          telefono: firebaseUser.phoneNumber ?? '',
          cedula: '',
          role: UserRole.arrendatario,
          estadoCivil: MaritalStatus.soltero,
          ocupacion: '',
          domicilio: '',
          tipoDocumentoIdentidad: IdDocumentType.cedula,
          fechaNacimiento: DateTime(1990, 1, 1),
        );
      }
      return AppUser.fromMap({...doc.data()!, 'id': uid});
    } catch (e) {
      debugPrint('Error al cargar perfil de usuario: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResult> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _cachedUser = await _loadUser(credential.user!.uid);
      return AuthResult.success(_cachedUser);
    } catch (e) {
      return AuthResult.failure(FirebaseAuthErrors.message(e));
    }
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required String cedula,
    required UserRole role,
    required MaritalStatus estadoCivil,
    required String ocupacion,
    required String domicilio,
    required IdDocumentType tipoDocumentoIdentidad,
    required DateTime fechaNacimiento,
    required String documentoIdentidadBase64,
    String? fotoBase64,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = AppUser(
        id: credential.user!.uid,
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        cedula: cedula,
        role: role,
        estadoCivil: estadoCivil,
        ocupacion: ocupacion,
        domicilio: domicilio,
        tipoDocumentoIdentidad: tipoDocumentoIdentidad,
        fechaNacimiento: fechaNacimiento,
        documentoIdentidadBase64: documentoIdentidadBase64,
        fotoBase64: fotoBase64,
      );

      await _users.doc(user.id).set(user.toMap());
      _cachedUser = user;
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure(FirebaseAuthErrors.message(e));
    }
  }

  @override
  Future<AuthResult> updateProfilePhoto(String userId, String fotoBase64) async {
    try {
      await _users.doc(userId).update({'fotoBase64': fotoBase64});
      if (_cachedUser?.id == userId) {
        _cachedUser = _cachedUser!.copyWith(fotoBase64: fotoBase64);
        return AuthResult.success(_cachedUser);
      }
      final user = await _loadUser(userId);
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure(FirebaseAuthErrors.message(e));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _cachedUser = null;
  }

  @override
  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    final snapshot =
        await _users.where('role', isEqualTo: role.name).get();
    return snapshot.docs
        .map((doc) => AppUser.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap({...doc.data()!, 'id': id});
  }
}
