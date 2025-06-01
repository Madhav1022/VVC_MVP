import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/forgot_password_contract.dart';

class ForgotPasswordPresenterImpl implements ForgotPasswordPresenter {
  ForgotPasswordView? _view;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void attachView(ForgotPasswordView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      _view?.showError('Please enter your email');
      return;
    }
    _view?.showLoading();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _view?.hideLoading();
      _view?.showSuccess();
    } on FirebaseAuthException catch (e) {
      _view?.hideLoading();
      _view?.showError(e.message ?? 'Failed to send reset email');
    } catch (e) {
      _view?.hideLoading();
      _view?.showError('Error: $e');
    }
  }
}
