import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.id, userDoc.data()!);
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
    return null;
  }
}
