import '../models/contact_model.dart';

abstract class FormView {
  void showSuccess(String message);
  void showError(String message);
}

abstract class FormPresenter {
  void attachView(FormView view);
  void detachView();
  Future<void> saveContact(ContactModel contact);
}