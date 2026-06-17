import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthErrors {
  static String message(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-email' => 'El correo no es válido.',
        'user-disabled' => 'Esta cuenta fue deshabilitada.',
        'user-not-found' => 'No existe una cuenta con ese correo.',
        'wrong-password' => 'Contraseña incorrecta.',
        'invalid-credential' => 'Correo o contraseña incorrectos.',
        'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
        'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
        'network-request-failed' => 'Sin conexión. Revisa tu internet.',
        'too-many-requests' =>
          'Demasiados intentos. Espera un momento e intenta de nuevo.',
        'operation-not-allowed' =>
          'El inicio con email/contraseña no está activado en Firebase Console.',
        'unknown' when _isConfigurationError(error) =>
          _configurationErrorMessage,
        _ => error.message ?? 'Error de autenticación (${error.code}).',
      };
    }

    final text = error.toString().toLowerCase();
    if (_isFirestoreNotFound(text)) {
      return _firestoreNotFoundMessage;
    }

    return error.toString();
  }

  static bool _isConfigurationError(FirebaseAuthException error) {
    final text = '${error.message ?? ''} ${error.code}'.toLowerCase();
    return text.contains('configuration_not_found') ||
        text.contains('configuration-not-found');
  }

  static bool _isFirestoreNotFound(String text) {
    return text.contains('does not exist') ||
        text.contains('not_found') ||
        text.contains('not found') && text.contains('database');
  }

  static const _configurationErrorMessage =
      'Firebase Auth no está configurado para Android. '
      'Activa Email/Password en Authentication y agrega la huella SHA-1 '
      'de debug en la configuración de la app Android.';

  static const _firestoreNotFoundMessage =
      'Firestore no está creado en tu proyecto Firebase. '
      'Ve a Firebase Console → Firestore Database → Crear base de datos.';
}
