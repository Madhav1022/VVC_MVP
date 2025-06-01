import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/profile_contract.dart';

class ProfilePresenterImpl implements ProfilePresenter {
  ProfileView? _view;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void attachView(ProfileView view) {
    _view = view;
  }

  @override
  void detachView() {
    _view = null;
  }

  @override
  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _view?.showError('No user logged in');
      return;
    }
    _view?.showProfile(user.email ?? '', user.displayName ?? '');
  }

  @override
  Future<void> updateProfile(String displayName) async {
    if (displayName.isEmpty) {
      _view?.showError('Display name cannot be empty');
      return;
    }
    _view?.showLoading();
    try {
      final user = _auth.currentUser;
      await user!.updateDisplayName(displayName);
      await user.reload();
      final updated = _auth.currentUser!;
      _view?.hideLoading();
      _view?.showProfileUpdated(updated.displayName ?? '');
    } catch (e) {
      _view?.hideLoading();
      _view?.showError('Failed to update profile');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _view?.showSignedOut();
  }
}