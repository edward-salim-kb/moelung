import 'package:moelung_new/models/enums/user_role.dart'; // Assuming UserRole is defined here

bool isPenyetoer(UserRole role) {
  return role == UserRole.penyetoer;
}

bool isKolektoer(UserRole role) {
  return role == UserRole.kolektoer;
}
