import '../models/user_model.dart';

abstract class RegisterView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showSuccess();
}

abstract class RegisterPresenter {
  void attachView(RegisterView view);
  void detachView();
  Future<void> register(
      String fullName,
      String email,
      String password,
      String confirmPassword,
      );
}