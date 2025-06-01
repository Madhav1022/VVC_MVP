import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/register_contract.dart';
import '../models/user_model.dart';

class RegisterPresenterImpl implements RegisterPresenter {
  RegisterView? _view;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void attachView(RegisterView view) {
    _view = view;
  }

  @override
  void detachView() {
    _view = null;
  }

  @override
  Future<void> register(
      String fullName,
      String email,
      String password,
      String confirmPassword,
      ) async {
    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _view?.showError('All fields are required');
      return;
    }
    if (password != confirmPassword) {
      _view?.showError('Passwords do not match');
      return;
    }

    _view?.showLoading();
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCred.user!.updateDisplayName(fullName);

      _view?.hideLoading();
      _view?.showSuccess();
    } on FirebaseAuthException catch (e) {
      _view?.hideLoading();
      _view?.showError(e.message ?? 'Registration failed');
    } catch (e) {
      _view?.hideLoading();
      _view?.showError('Error: \$e');
    }
  }
}