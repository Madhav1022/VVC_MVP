import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/login_contract.dart';

class LoginPresenterImpl implements LoginPresenter {
  LoginView? _view;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void attachView(LoginView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _view?.showError('Email and password are required');
      return;
    }
    _view?.showLoading();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _view?.hideLoading();
      _view?.showSuccess();
    } on FirebaseAuthException catch (e) {
      _view?.hideLoading();
      _view?.showError(e.message ?? 'Login failed');
    } catch (e) {
      _view?.hideLoading();
      _view?.showError('Error: $e');
    }
  }
}
