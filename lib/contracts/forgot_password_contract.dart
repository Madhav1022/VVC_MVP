abstract class ForgotPasswordView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showSuccess();
}

abstract class ForgotPasswordPresenter {
  void attachView(ForgotPasswordView view);
  void detachView();
  Future<void> resetPassword(String email);
}
