import 'package:demo/models/profile_model.dart';
import 'package:demo/services/auth_service.dart';

class ProfileService {
  Future<ProfileModel> getProfile() async {
    try {
      final data = await AuthService.getProfile();

      if (data != null) {
        return ProfileModel.fromJson(data);
      } else {
        // Retornar perfil vacío si no hay datos
        return ProfileModel.fromJson({});
      }
    } catch (e) {
      // En caso de error, retornar perfil vacío
      return ProfileModel.fromJson({});
    }
  }
}
