import '../models/contact_model.dart';

abstract class HomeView {
  void showLoading();
  void showContacts(List<ContactModel> contacts);
  void showEmptyState();
  void showError(String message);
}

abstract class HomePresenter {
  void attachView(HomeView view);
  void detachView();
  Future<void> loadContacts({bool favorites = false});
  Future<void> deleteContact(int id);
  Future<void> toggleFavorite(ContactModel contact);
}