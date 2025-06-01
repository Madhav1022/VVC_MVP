import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/contact_details_contract.dart';
import '../database/db_helper.dart';
import '../models/contact_model.dart';

class ContactDetailsPresenterImpl implements ContactDetailsPresenter {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final DbHelper _db = DbHelper();

  ContactDetailsView? _view;

  @override
  void attachView(ContactDetailsView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  Future<void> loadContact(int localId) async {
    _view?.showLoading();
    final user = _auth.currentUser;
    if (user == null) {
      _view?.showError('Not authenticated');
      return;
    }

    try {
      // Fetch from Firestore by firebaseId stored locally
      final local = await _db.getContactById(localId);
      if (local.firebaseId != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('contacts')
            .doc(local.firebaseId)
            .get();
        if (doc.exists) {
          final remote = ContactModel.fromDoc(doc);
          remote.id = localId;
          // cache update
          await _db.insertOrUpdateContact(remote);
          _view?.showContact(remote);
          return;
        }
      }
      // fallback to local
      _view?.showContact(local);
    } catch (e) {
      _view?.showError('Failed to load contact details: $e');
    }
  }
}
