import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_ninja/src/data/services/firebase_auth.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  // log out the user
  Future<void> logout() async {
    try {
      // Hapus sesi autentikasi di Firebase
      await FirebaseAuth.instance.signOut();
      
      // Panggil fungsi signOut() tambahan dari FirebaseAuthService (jika perlu)
      await FirebaseAuthService(FirebaseAuth.instance).signOut();
      
      // Simpan status mode gelap sebelum membersihkan Hive
      bool isDarkMode = Hive.box('myBox').get('isDarkMode', defaultValue: false);
      
      // Bersihkan data Hive kecuali isDarkMode
      await Hive.box('myBox').clear();
      await Hive.box('myBox').put('isDarkMode', isDarkMode);
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }
}
