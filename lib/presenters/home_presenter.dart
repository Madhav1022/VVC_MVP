import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/home_contract.dart';
import '../database/db_helper.dart';
import '../models/contact_model.dart';
import '../utils/helper_functions.dart';

class HomePresenterImpl implements HomePresenter {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final DbHelper _db = DbHelper();

  HomeView? _view;
  bool _showFav = false;

  @override
  void attachView(HomeView view) => _view = view;

  @override
  void detachView() => _view = null;

  // @override
  // Future<void> loadContacts({bool favorites = false}) async {
  //   final user = _auth.currentUser;
  //   if (user == null) {
  //     _view?.showError('Not authenticated');
  //     return;
  //   }
  //   _view?.showLoading();
  //   _showFav = favorites;
  //
  //   try {
  //     final col = _firestore
  //         .collection('users')
  //         .doc(user.uid)
  //         .collection('contacts');
  //
  //     List<ContactModel> contacts;
  //
  //     if (favorites) {
  //       // Fetch only favorites, then sort client-side by createdAt descending
  //       final snap = await col.where('favorite', isEqualTo: true).get();
  //       contacts = snap.docs.map((d) => ContactModel.fromDoc(d)).toList();
  //       contacts.sort((a, b) {
  //         final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  //         final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  //         return db.compareTo(da);
  //       });
  //     } else {
  //       // Fetch all contacts ordered by newest first
  //       final snap = await col.orderBy('createdAt', descending: true).get();
  //       contacts = snap.docs.map((d) => ContactModel.fromDoc(d)).toList();
  //     }
  //
  //     // Cache locally
  //     for (var c in contacts) {
  //       await _db.insertOrUpdateContact(c);
  //     }
  //
  //     if (contacts.isEmpty) {
  //       _view?.showEmptyState();
  //     } else {
  //       _view?.showContacts(contacts);
  //     }
  //   } catch (e) {
  //     _view?.showError('Failed to load contacts: $e');
  //   }
  // }


// latency log
  @override
  Future<void> loadContacts({bool favorites = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      _view?.showError('Not authenticated');
      return;
    }
    _view?.showLoading();
    _showFav = favorites;

    try {
      final col = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('contacts');

      List<ContactModel> contacts;

      // Measure Firestore fetch latency
      final startTime = DateTime.now();

      if (favorites) {
        // Fetch only favorites, then sort client-side by createdAt descending
        final snap = await col.where('favorite', isEqualTo: true).get();
        contacts = snap.docs.map((d) => ContactModel.fromDoc(d)).toList();
        contacts.sort((a, b) {
          final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        });
      } else {
        // Fetch all contacts ordered by newest first
        final snap = await col.orderBy('createdAt', descending: true).get();
        contacts = snap.docs.map((d) => ContactModel.fromDoc(d)).toList();
      }

      final endTime = DateTime.now();
      final durationMs = endTime.difference(startTime).inMilliseconds;

      // Log Firestore latency
      await logLatency('Fetch Contacts from Firestore', durationMs, source: 'Firestore');

      // Cache locally
      for (var c in contacts) {
        await _db.insertOrUpdateContact(c);
      }

      if (contacts.isEmpty) {
        _view?.showEmptyState();
      } else {
        _view?.showContacts(contacts);
      }
    } catch (e) {
      _view?.showError('Failed to load contacts: $e');
    }
  }



  @override
  Future<void> deleteContact(int id) async {
    final user = _auth.currentUser;
    if (user == null) {
      _view?.showError('Not authenticated');
      return;
    }
    try {
      final c = await _db.getContactById(id);
      if (c.firebaseId != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('contacts')
            .doc(c.firebaseId)
            .delete();
      }
      await _db.deleteContact(id);
      await loadContacts(favorites: _showFav);
    } catch (e) {
      _view?.showError('Failed to delete contact: $e');
    }
  }

  @override
  Future<void> toggleFavorite(ContactModel contact) async {
    final user = _auth.currentUser;
    if (user == null) {
      _view?.showError('Not authenticated');
      return;
    }
    try {
      final newFav = !contact.favorite;
      if (contact.firebaseId != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('contacts')
            .doc(contact.firebaseId)
            .update({'favorite': newFav});
      }
      contact.favorite = newFav;
      await _db.updateFavorite(contact.id, newFav ? 1 : 0);
      await loadContacts(favorites: _showFav);
    } catch (e) {
      _view?.showError('Failed to update favorite: $e');
    }
  }
}