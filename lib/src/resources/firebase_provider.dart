import 'package:app/async.dart';
import 'package:app/extensions.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/models/person_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseProvider {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn(
    scopes: [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/userinfo.profile",
    ],
  );
  static final _users = _collection('users');
  static final _questions = _collection('questions');

  static DocumentReference<Map<String, dynamic>> _doc(String path) =>
      FirebaseFirestore.instance.doc(path);

  static CollectionReference<Map<String, dynamic>> _collection(String path) =>
      FirebaseFirestore.instance.collection(path);

  static CollectionReference<Map<String, dynamic>> _answers(String path) =>
      _doc(path).collection('answers');

  static CollectionReference<Map<String, dynamic>> _reactions(String path) =>
      _doc(path).collection('reactions');

  Stream<bool> isAuthorized() => currentPerson().map((it) => it != null);

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
        'users/${user.uid}',
        googleUser.displayName.orDefault(),
        googleUser.email,
        googleUser.photoUrl.orDefault(),
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
    _doc(person.path).set(person.toJson(), SetOptions(merge: true));
  }

  Stream<Person?> currentPerson() {
    return _auth.authStateChanges().flatMapUntilNext(
          (event) => event == null
              ? Stream.value(null)
              : _users.doc(event.uid).snapshots().map((json) => json
                  .takeIf((it) => it.exists)
                  ?.let((it) => Person.fromSnapshot(it))),
        );
  }

  Stream<List<Question>> questions() {
    return _questions
        .snapshots()
        .map((event) => event.docs.mapToList((e) => Question.fromSnapshot(e)));
  }

  Stream<List<Answer>> answers(Question item) {
    return _answers(item.path)
        .snapshots()
        .map((event) => event.docs.mapToList((e) => Answer.fromSnapshot(e)));
  }

  Stream<List<Reaction>> reactions(Doc item) {
    return _reactions(item.path)
        .snapshots()
        .map((event) => event.docs.mapToList((e) => Reaction.fromSnapshot(e)));
  }

  Stream<bool> isReactionAvailable(Personalized item) {
    return _auth.authStateChanges().flatMapUntilNext((value) =>
        _doc(item.personPath).id == value?.uid
            ? Stream.value(false)
            : _reactions(item.path)
                .doc(value?.uid)
                .snapshots()
                .map((event) => !event.exists));
  }
}

class AuthCanceled implements Exception {
  @override
  String toString() => 'AuthCanceled: cancelled by user';
}
