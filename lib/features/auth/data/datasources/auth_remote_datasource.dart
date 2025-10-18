import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> logout(String refreshToken);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await dioClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await dioClient.post(
      ApiConstants.logout,
      data: {
        'refresh': refreshToken,
      },
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.get(ApiConstants.me);
    return UserModel.fromJson(response.data);
  }
}
