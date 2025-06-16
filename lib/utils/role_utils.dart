import 'package:moelung_new/models/enums/user_role.dart'; // Assuming UserRole is defined here

bool isPenyetoer(UserRole role) {
  return role == UserRole.penyetoerJempoet ||
         role == UserRole.penyetoerKumpoelAdat ||
         role == UserRole.penyetoerKumpoelModern;
}
