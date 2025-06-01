import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../contracts/camera_contract.dart';
import '../database/db_helper.dart';
import '../models/contact_model.dart';
import '../utils/constants.dart';  // Import for ContactProperties

class CameraPresenterImpl implements CameraPresenter {
  CameraView? _view;
  String name = '', mobile = '', email = '', company = '';
  String designation = '', address = '', website = '';
  String imageLocal = '';

  @override
  bool get isFormValid => name.isNotEmpty && mobile.isNotEmpty;

  @override
  void attachView(CameraView v) => _view = v;

  @override
  void detachView() => _view = null;

  @override
  Future<void> processImage(String path) async {
    try {
      _view?.showLoading('Processing...');
      final dir = await getApplicationDocumentsDirectory();
      final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = '${dir.path}/$filename';
      final File copied = await File(path).copy(newPath);
      imageLocal = filename;
      _view?.updateImagePath(filename);

      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final report = await textRecognizer.processImage(InputImage.fromFile(copied));

      final List<String> lines = [];
      for (var block in report.blocks) {
        for (var line in block.lines) {
          lines.add(line.text);
        }
      }

      _view?.updateScannedLines(lines);
      _view?.updateScanStatus(true);
      _view?.hideLoading();
    } catch (e) {
      _view?.hideLoading();
      _view?.showError('Error processing image: $e');
    }
  }

  @override
  void updatePropertyValue(String property, String value) {
    switch (property) {
      case ContactProperties.name:
        name = value;
        break;
      case ContactProperties.mobile:
        mobile = value;
        break;
      case ContactProperties.email:
        email = value;
        break;
      case ContactProperties.company:
        company = value;
        break;
      case ContactProperties.designation:
        designation = value;
        break;
      case ContactProperties.address:
        address = value;
        break;
      case ContactProperties.website:
        website = value;
        break;
      default:
        break;
    }
  }

  @override
  ContactModel getContact() {
    return ContactModel(
      firebaseId: null,
      name: name,
      mobile: mobile,
      email: email,
      address: address,
      company: company,
      designation: designation,
      website: website,
      imageLocal: imageLocal,
      imageUrl: '',
      favorite: false,
    );
  }
}
