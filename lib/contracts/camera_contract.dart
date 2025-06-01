import '../models/contact_model.dart';

abstract class CameraView {
  void updateScannedLines(List<String> lines);
  void updateScanStatus(bool isScanOver);
  void updateImagePath(String path);
  void showLoading(String message);
  void hideLoading();
  void showError(String message);
}

abstract class CameraPresenter {
  void attachView(CameraView view);
  void detachView();
  Future<void> processImage(String imagePath);
  void updatePropertyValue(String property, String value);
  ContactModel getContact();
  bool get isFormValid;
}