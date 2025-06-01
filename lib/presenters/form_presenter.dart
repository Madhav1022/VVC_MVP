import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../contracts/form_contract.dart';
import '../database/db_helper.dart';
import '../models/contact_model.dart';
import 'package:path_provider/path_provider.dart';

class FormPresenterImpl implements FormPresenter {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final DbHelper _db = DbHelper();

  FormView? _view;

  @override
  void attachView(FormView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  Future<void> saveContact(ContactModel contact) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // 1) Upload image first
      String imageUrl = contact.imageUrl;
      if (contact.imageLocal.isNotEmpty && !imageUrl.startsWith('http')) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${contact.imageLocal}');
        if (await file.exists()) {
          final ref = _storage.ref('users/${user.uid}/contacts/${contact.firebaseId ?? ''}/${contact.imageLocal}');
          await ref.putFile(file);
          imageUrl = await ref.getDownloadURL();
        }
      }
      contact.imageUrl = imageUrl;

      // 2) Write to Firestore
      final data = contact.toFirestore()..['imageUrl'] = imageUrl;
      final col = _firestore.collection('users').doc(user.uid).collection('contacts');
      DocumentReference<Map<String, dynamic>> doc;
      if (contact.firebaseId == null) {
        doc = await col.add(data);
        contact.firebaseId = doc.id;
      } else {
        doc = col.doc(contact.firebaseId);
        await doc.set(data, SetOptions(merge: true));
      }

      // 3) Cache locally
      await _db.insertOrUpdateContact(contact);

      _view?.showSuccess('Contact saved successfully');
    } catch (e) {
      _view?.showError('Failed to save: $e');
      rethrow;
    }
  }
}
