import 'package:app/async.dart';
import 'package:app/extensions.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/models/person_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseProvider {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn(hostedDomain: "", clientId: "");
  static final _firestore = FirebaseFirestore.instance;
  static final _users = _firestore.collection('users');
  static final _questions = _firestore.collection('questions');

  Stream<bool> isAuthorized() =>
      _auth.authStateChanges().map((it) => it != null);

  Future<void> signInGoogle() async {
    printLog(() => 'Starting google sign in');
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthCanceled();
    }

    printLog(() => 'Getting auth info');
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    printLog(() => 'Signing in');
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    printLog(() => "Signed in with google ${user?.uid}");

    if (user != null) {
      createPerson(Person(
        user.uid,
        googleUser.displayName.orDefault(),
        googleUser.email,
      ));
    } else {
      throw AuthCanceled();
    }
  }

  Future<void> signOut() {
    return _googleSignIn
        .signOut()
        .then((_) => _auth.signOut())
        .then((_) => printLog(() => 'Signed Out!'));
  }

  void createPerson(Person person) {
    _users.doc(person.id).set(person.toJson(), SetOptions(merge: true));
  }

  Stream<Person?> currentPerson() {
    return _auth.authStateChanges().flatMapUntilNext(
          (event) => event == null
              ? Stream.value(null)
              : _users
                  .doc(event.uid)
                  .snapshots()
                  .map((json) => json.data()?.let((it) => Person.fromJson(it))),
        );
  }

  Stream<List<Question>> questions() {
    return _questions.snapshots().map(
        (event) => event.docs.mapToList((e) => Question.fromJson(e.data())));
  }
}

class AuthCanceled implements Exception {
  @override
  String toString() => 'AuthCanceled: cancelled by user';
}
