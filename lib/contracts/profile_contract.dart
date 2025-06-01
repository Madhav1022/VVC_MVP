abstract class ProfileView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showProfile(String email, String displayName);
  void showProfileUpdated(String displayName);
  void showSignedOut();
}

abstract class ProfilePresenter {
  void attachView(ProfileView view);
  void detachView();
  Future<void> loadProfile();
  Future<void> updateProfile(String displayName);
  Future<void> signOut();
}