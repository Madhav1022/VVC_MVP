import '../models/user_model.dart';

abstract class LoginView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showSuccess();
}

abstract class LoginPresenter {
  void attachView(LoginView view);
  void detachView();
  Future<void> login(String email, String password);
}
