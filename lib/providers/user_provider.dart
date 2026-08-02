import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? get user => _user;

  Future<void> fetchUser(String uid) async {
    // Try getting by document ID first (standard way)
    var doc = await _firestore.collection('users').doc(uid).get();
    
    if (doc.exists) {
      _user = AppUser.fromFirestore(doc.data()!);
    } else {
      // Fallback: search for a document where the 'uid' field matches
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isNotEmpty) {
        _user = AppUser.fromFirestore(querySnapshot.docs.first.data());
      }
    }
    notifyListeners();
  }

  Future<void> setUser(AppUser user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> updateAddress(String address) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).update({'address': address});
      _user = AppUser(
        uid: _user!.uid,
        name: _user!.name,
        email: _user!.email,
        phoneNumber: _user!.phoneNumber,
        address: address,
        photoUrl: _user!.photoUrl,
      );
      notifyListeners();
    }
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).update({'phoneNumber': phoneNumber});
      _user = AppUser(
        uid: _user!.uid,
        name: _user!.name,
        email: _user!.email,
        phoneNumber: phoneNumber,
        address: _user!.address,
        photoUrl: _user!.photoUrl,
      );
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
