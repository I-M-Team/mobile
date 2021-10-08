import 'dart:async';

/// Creates a Stream that will recreate and re-listen to the source
/// Stream when the notifier emits a new value. If the source Stream
/// emits an error or it completes, the Stream terminates.
///
/// If the [retryWhenFactory] emits an error a [RetryError] will be
/// thrown. The RetryError will contain all of the [Error]s and
/// [StackTrace]s that caused the failure.
///
/// ### Basic Example
/// ```dart
/// RetryWhenStream<int>(
///   () => Stream<int>.fromIterable(<int>[1]),
///   (dynamic error, StackTrace s) => throw error,
/// ).listen(print); // Prints 1
/// ```
///
/// ### Periodic Example
/// ```dart
/// RetryWhenStream<int>(
///   () => Stream<int>
///       .periodic(const Duration(seconds: 1), (int i) => i)
///       .map((int i) => i == 2 ? throw 'exception' : i),
///   (dynamic e, StackTrace s) {
///     return Rx<String>
///         .timer('random value', const Duration(milliseconds: 200));
///   },
/// ).take(4).listen(print); // Prints 0, 1, 0, 1
/// ```
///
/// ### Complex Example
/// ```dart
/// bool errorHappened = false;
/// RetryWhenStream(
///   () => Stream
///       .periodic(const Duration(seconds: 1), (i) => i)
///       .map((i) {
///         if (i == 3 && !errorHappened) {
///           throw 'We can take this. Please restart.';
///         } else if (i == 4) {
///           throw 'It\'s enough.';
///         } else {
///           return i;
///         }
///       }),
///   (e, s) {
///     errorHappened = true;
///     if (e == 'We can take this. Please restart.') {
///       return Stream.value('Ok. Here you go!');
///     } else {
///       return Stream.error(e);
///     }
///   },
/// ).listen(
///   print,
///   onError: (e, s) => print(e),
/// ); // Prints 0, 1, 2, 0, 1, 2, 3, RetryError
/// ```
class RetryWhenStream<T> extends Stream<T> {
  /// The factory method used at subscription time
  final Stream<T> Function() streamFactory;

  /// The factory method used to create the [Stream] which triggers a re-listen
  final RetryWhenStreamFactory retryWhenFactory;
  StreamController<T>? _controller;
  StreamSubscription<T>? _subscription;
  bool _isCanceled = false;
  bool _retryOnResume = false;
  StreamSubscription<void>? _retrySub;

  /// Constructs a [Stream] that will recreate and re-listen to the source
  /// [Stream] (created by the provided factory method).
  /// The retry will trigger whenever the [Stream] created by the retryWhen
  /// factory emits and event.
  RetryWhenStream(this.streamFactory, this.retryWhenFactory);

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _controller ??= StreamController<T>(
      sync: true,
      onListen: _retry,
      onPause: ([Future<dynamic>? resumeSignal]) {
        if (_retrySub != null) {
          _retrySub!.cancel();
          _retrySub = null;
          _retryOnResume = true;
        }
        _subscription?.pause(resumeSignal);
      },
      onResume: () {
        if (_retryOnResume) {
          _retry();
        } else {
          _subscription?.resume();
        }
      },
      onCancel: () {
        _isCanceled = true;
        return _subscription?.cancel();
      },
    );

    _isCanceled = false;
    return _controller!.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void _retry() {
    _retryOnResume = false;
    _subscription = streamFactory().listen(
      _controller!.add,
      onError: (Object origE, [StackTrace? origS]) {
        _subscription!.cancel();
        _subscription = null;

        if (_isCanceled) {
          _addErrorAndClose(origE, origS, origE, origS);
          return;
        }
        if (_controller!.isPaused) {
          _retryOnResume = true;
          return;
        }
        _retrySub = retryWhenFactory(origE, origS).listen(
          (event) {
            _retrySub!.cancel();
            _retrySub = null;
            if (_isCanceled) {
              _addErrorAndClose(origE, origS, origE, origS);
            } else {
              _retry();
            }
          },
          onError: (Object e, [StackTrace? s]) {
            _retrySub!.cancel();
            _retrySub = null;

            _addErrorAndClose(origE, origS, e, s);
          },
        );
      },
      onDone: _controller!.close,
      cancelOnError: false,
    );
  }

  void _addErrorAndClose(
    Object originalError,
    StackTrace? originalStacktrace,
    Object e,
    StackTrace? s,
  ) {
    if (identical(originalError, e)) {
      _controller!.addError(originalError, originalStacktrace);
    } else {
      _controller!.addError(originalError, originalStacktrace);
      _controller!.addError(e, s);
    }
    _controller!.close();
  }
}

typedef Stream<void> RetryWhenStreamFactory(
    Object error, StackTrace? stackTrace);
