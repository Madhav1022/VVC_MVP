import '../models/contact_model.dart';

abstract class ContactDetailsView {
  void showLoading();
  void showContact(ContactModel contact);
  void showContactNotFound();
  void showError(String message);
}

abstract class ContactDetailsPresenter {
  void attachView(ContactDetailsView view);
  void detachView();
  void loadContact(int id);
}