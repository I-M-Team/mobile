import 'dart:async';

import 'package:app/extensions.dart';
import 'package:app/retry_when_stream.dart';
import 'package:rxdart/rxdart.dart' hide RetryWhenStream;
import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

export 'dart:async';

export 'package:rxdart/rxdart.dart';

extension Streams<T> on Stream<T> {
  /*
   * UTILS
   */

  static Stream<R> combineLatest<T, R>(
          Iterable<Stream<T>>? streams, R Function(List<T> values) combiner) =>
      streams.isNullOrEmpty
          ? Stream.value(combiner(<T>[]))
          : Rx.combineLatest(streams!, combiner);

  static Stream<List<T>> combineLatestList<T>(Iterable<Stream<T>>? streams) =>
      streams.isNullOrEmpty
          ? Stream.value(<T>[])
          : Rx.combineLatestList(streams!);

  static Stream<int> interval(Duration period,
      {Duration? initialDelay, int start = 0}) async* {
    if (initialDelay != null) {
      yield await Future.delayed(initialDelay).then((_) => start);
    } else {
      yield await Future.delayed(period).then((_) => start);
    }

    yield* interval(period, start: start + 1);
  }

  static Stream<int> intervalRange(int start, int count, Duration period,
      {Duration? initialDelay}) async* {
    if (count <= 0) {
      return;
    }

    if (initialDelay != null) {
      yield await Future.delayed(initialDelay).then((_) => start);
    } else {
      yield await Future.delayed(period).then((_) => start);
    }

    yield* intervalRange(start + 1, count - 1, period);
  }

  static Stream<T> value<T>(T value) => Stream.value(value);

  static Stream<T> refreshWhen<T>(
    Stream<T> Function() streamFactory,
    Stream<void> Function() repeatWhenFactory,
  ) =>
      repeatWhenFactory()
          .startWith(null)
          .flatMapUntilNext((event) => streamFactory());

  static Stream<T> repeatWhen<T>(
    Stream<T> Function() streamFactory,
    Stream<void> Function() repeatWhenFactory,
  ) =>
      _RepeatWhenStream<T>(streamFactory, repeatWhenFactory);

  static Stream<T> retryWhen<T>(
    Stream<T> Function() streamFactory,
    RetryWhenStreamFactory retryWhenFactory,
  ) =>
      RetryWhenStream<T>(streamFactory, retryWhenFactory);

  static RetryWhenStreamFactory retryFactory<T>(Duration delay,
      {int retries = 0, bool test(Object e, StackTrace? s) = _confirmError}) {
    var count = retries;
    return (e, s) {
      count -= 1;
      printLog(() => 'retry ERROR:\n$e\n$s');
      if ((count > 0 || retries == 0) && test(e, s))
        return Stream.value('retry#$count').delay(delay);
      return Stream.error(e, s);
    };
  }

  static bool _confirmError(Object e, StackTrace? s) => true;

  /*
   * EXTENSIONS
   */

  // Stream<E> asyncExpandUntilNext<E>(Stream<E> convert(T event)) {
  //   final stream = this.share();
  //   return stream.asyncExpand((it) => convert(it).takeUntil(stream));
  // }

  Stream<S> flatMapUntilNext<S>(Stream<S> Function(T value) mapper) =>
      transform(StreamTransformer.fromBind((stream) =>
          forwardStream(stream, () => _FlatMapUntilNextStreamSink(mapper))));

  Stream<T> startWithStream(Stream<T> value) => Rx.concat([value, this]);

  Stream<T> endWithStream(Stream<T> value) => Rx.concat([this, value]);

  Future<T> firstOr(FutureOr<T> value) =>
      this.first.catchError((e) => value, test: (e) => e is StateError);

  Stream<T> firstElement() {
    StreamSubscription? sub;
    var controller = StreamController<T>(sync: true);
    controller.onListen = () {
      sub = this.listen(
        (event) {
          controller.add(event);
          controller.close();
          sub?.cancel();
        },
        onError: (e, s) {
          controller.addError(e);
          controller.close();
          sub?.cancel();
        },
        // todo throw no element
        onDone: () => controller.close(),
      );
    };
    controller.onPause = () => sub?.pause();
    controller.onResume = () => sub?.resume();
    controller.onCancel = () => sub?.cancel();

    return controller.stream;
  }

  FutureSubscription<T> firstElementFuture() {
    Completer<T> completer = Completer<T>();
    StreamSubscription<T> subscription =
        this.listen(null, onError: completer.completeError, onDone: () {
      try {
        throw IterableElementError.noElement();
      } catch (e, s) {
        completer.completeError(e, s);
      }
    }, cancelOnError: true);
    subscription.onData((value) {
      subscription.cancel().whenComplete(() => completer.complete(value));
    });

    return FutureSubscription(completer.future, subscription);
  }

  Stream<T> asyncListen<R>(Stream<R> stream(), {void onData(R event)?}) {
    late StreamSubscription sub;
    return this
        .doOnListen(() => sub = stream().listen(onData ?? (event) {}))
        .doOnCancel(() => sub.cancel());
  }

  Stream<T> filter(bool test(T event)) => this.where(test);
}

extension NullStreams<T> on Stream<T?> {
  Stream<T> whereNotNull() => this.where((event) => event != null).cast();

  Stream<T> filterNotNull() => whereNotNull();
}

class FutureSubscription<T> implements Future<T>, StreamSubscription<T> {
  final Future<T> _future;
  final StreamSubscription<T> _subscription;

  FutureSubscription(this._future, this._subscription);

  @override
  Future<E> asFuture<E>([E? futureValue]) =>
      _subscription.asFuture(futureValue);

  @override
  Future<void> cancel() => _subscription.cancel();

  @override
  bool get isPaused => _subscription.isPaused;

  @override
  void onData(void Function(T data)? handleData) =>
      _subscription.onData(handleData);

  @override
  void onDone(void Function()? handleDone) => _subscription.onDone(handleDone);

  @override
  void onError(Function? handleError) => _subscription.onError(handleError);

  @override
  void pause([Future<void>? resumeSignal]) => _subscription.pause(resumeSignal);

  @override
  void resume() => _subscription.resume();

  @override
  Stream<T> asStream() => _future.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue,
          {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);
}

abstract class IterableElementError {
  /// Error thrown thrown by, e.g., [Iterable.first] when there is no result.
  static StateError noElement() => new StateError("No element");

  /// Error thrown by, e.g., [Iterable.single] if there are too many results.
  static StateError tooMany() => new StateError("Too many elements");

  /// Error thrown by, e.g., [List.setRange] if there are too few elements.
  static StateError tooFew() => new StateError("Too few elements");
}

extension Futures<T> on Future<T> {
  Future<T> onErrorReturn(Function onError, {bool test(Object error)?}) =>
      catchError(onError, test: test);

  Future<T> onErrorReturnNull({bool test(Object error)?}) =>
      onErrorReturnValue(null, test: test);

  Future<T> onErrorReturnValue(T? value, {bool test(Object error)?}) =>
      catchError((_) => value, test: test);

  Future<R> thenWhere<R>(bool test(T value), FutureOr<R> onValue(T value),
          {Function? onError}) =>
      then((it) => test(it) ? onValue(it) : Future.value(null),
          onError: onError);

  WhereMapping<T> where(bool test(T value)) => WhereMapping(this, test);

  Future<T> doOnData(void onData(T value)) {
    return this.then((value) {
      onData(value);
      return value;
    });
  }

  Future<T> doOnError(void onError(dynamic e, dynamic s)) {
    return this.catchError((value, s) {
      onError(value, s);
      throw value;
    });
  }

  static Future<T> retry<T>(int retries, FutureSupplier<T> supplier) async {
    try {
      return await supplier();
    } catch (e) {
      if (retries > 1) {
        return retry(retries - 1, supplier);
      }

      rethrow;
    }
  }

  static Future<T> _retryWithDelay<T>(
      int retries,
      Duration delay,
      FutureSupplier<T> supplier,
      Reference<dynamic> error,
      Reference<void Function([dynamic reason])> cancel) async {
    if (error.value != null) throw CancelledException(error.value);
    try {
      var future = supplier();
      cancel.value = future.onCancel;
      var value = await future;
      cancel.value = null;
      return value;
    } catch (e) {
      printLog(() => 'retry=$e');
      cancel.value = null;
      if (retries > 1) {
        return Future.delayed(delay,
            () => _retryWithDelay(retries - 1, delay, supplier, error, cancel));
      }

      rethrow;
    }
  }

  static CancelableFuture<T> retryWithDelay<T>(
      int retries, Duration delay, FutureSupplier<T> supplier) {
    final error = Reference<dynamic>(null);
    final cancel = Reference<void Function([dynamic reason])>(null);
    return CancelableFuture(
        _retryWithDelay(retries, delay, supplier, error, cancel), ([reason]) {
      error.value = reason ?? 'Cancelled';
      cancel.value?.call();
    });
  }
}

typedef CancelableFuture<T> FutureSupplier<T>();

class CancelledException {
  final String? message;

  CancelledException([this.message]);
}

abstract class Mapping<T> {
  const Mapping();

  Stream<T> asStream();

  Mapping<T> catchError(Function onError,
          {bool Function(Object error)? test}) =>
      ChildMapping<T, T>(
          this, (it) => Future.value(it).catchError(onError, test: test));

  Mapping<R> then<R>(FutureOr<R> Function(T value) onValue,
          {Function? onError}) =>
      ChildMapping<T, R>(
          this, (it) => Future.value(it).then(onValue, onError: onError));

  Future<T> get({Function? onError});

  Future<R> _get<R>(FutureOr<R> Function(FutureOr<T> value) onValue);

  Mapping<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      ChildMapping<T, T>(this,
          (it) => Future.value(it).timeout(timeLimit, onTimeout: onTimeout));

  Mapping<T> whenComplete(FutureOr Function() action) => then((v) {
        var f2 = action();
        if (f2 is Future) return f2.then((_) => v);
        return v;
      }, onError: (e) {
        var f2 = action();
        if (f2 is Future)
          return f2.then((_) {
            throw e;
          });
        throw e;
      });
}

class WhereMapping<T> extends Mapping<T?> {
  final Future<T> _target;

  final bool Function(T value) _test;

  const WhereMapping(this._target, this._test);

  @override
  Stream<T> asStream() {
    return _target.asStream().where(_test);
  }

  @override
  Future<R> _get<R>(FutureOr<R> Function(Future<T?> value) onValue) {
    return _target.then((it) => onValue(Future.value(_test(it) ? it : null)),
        onError: (e) => onValue(Future.error(e)));
  }

  @override
  Future<T?> get({Function? onError}) =>
      _target.then((it) => _test(it) ? it : null, onError: onError);
}

class ChildMapping<S, T> extends Mapping<T> {
  final Mapping<S> mapping;
  final FutureOr<T> Function(FutureOr<S> value) onValue;

  ChildMapping(this.mapping, this.onValue);

  @override
  Stream<T> asStream() =>
      mapping.asStream().asyncMap((it) => onValue(Future.value(it)));

  @override
  Future<R> _get<R>(FutureOr<R> Function(FutureOr<T> value) onPreValue) {
    return mapping._get((it) => onPreValue(onValue(it)));
  }

  @override
  Future<T> get({Function? onError}) {
    if (onError != null) {
      return catchError(onError).get();
    } else {
      return mapping._get(onValue);
    }
  }
}

extension StreamSubscriptionExtension on List<StreamSubscription> {
  void cancelAll() => this.forEach((d) => d.cancel());
}

class _RepeatWhenStream<T> extends Stream<T> {
  /// The factory method used at subscription time
  final Stream<T> Function() streamFactory;

  /// The factory method used to create the [Stream] which triggers a re-listen
  final Stream<void> Function() repeatWhenFactory;
  StreamController<T>? _controller;
  StreamSubscription<T>? _subscription;
  StreamSubscription<void>? _retrySub;
  // bool _isCanceled = false;

  /// Constructs a [Stream] that will recreate and re-listen to the source
  /// [Stream] (created by the provided factory method).
  /// The retry will trigger whenever the [Stream] created by the retryWhen
  /// factory emits and event.
  _RepeatWhenStream(this.streamFactory, this.repeatWhenFactory);

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _controller ??= StreamController<T>(
      sync: true,
      onListen: _repeat,
      onPause: ([Future<dynamic>? resumeSignal]) =>
          _subscription?.pause(resumeSignal),
      onResume: () => _subscription?.resume(),
      onCancel: () async {
        printLog(() => '_subscription.cancel()');
        // _isCanceled = true;
        await _retrySub?.cancel();
        return _subscription?.cancel();
      },
    );

    return _controller!.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void _repeat() {
    try {
      _subscription = streamFactory().listen(
        _controller!.add,
        onError: _controller!.addError,
        onDone: () {
          _subscription?.cancel();

          _retrySub = repeatWhenFactory().listen(
            (event) {
              _retrySub?.cancel();
              _repeat();
            },
            onError: (Object e, [StackTrace? s]) {
              _retrySub?.cancel();
              _controller
                ?..addError(e, s)
                ..close();
            },
            onDone: _controller!.close,
          );
        },
        cancelOnError: false,
      );
    } catch (e, s) {
      _controller!.addError(e, s);
    }
  }
}

class _FlatMapUntilNextStreamSink<S, T> extends ForwardingSink<S, T> {
  final Stream<T> Function(S value) _mapper;
  StreamSubscription<T>? _subscription;
  bool _inputClosed = false;

  _FlatMapUntilNextStreamSink(this._mapper);

  @override
  void onData(S data) {
    final mappedStream = _mapper(data);

    _subscription?.cancel();

    late StreamSubscription<T> subscription;

    subscription = mappedStream.listen(
      sink.add,
      onError: sink.addError,
      onDone: () {
        _subscription = null;

        if (_inputClosed && _subscription == null) {
          sink.close();
        }
      },
    );

    _subscription = subscription;
  }

  @override
  void onError(Object e, StackTrace st) => sink.addError(e, st);

  @override
  void onDone() {
    _inputClosed = true;

    if (_subscription == null) {
      sink.close();
    }
  }

  @override
  FutureOr onCancel() => _subscription?.cancel();

  @override
  void onListen() {}

  @override
  void onPause() => _subscription?.pause();

  @override
  void onResume() => _subscription?.resume();
}

class CancelableFuture<T> implements Future<T> {
  Future<T> _origin;
  void Function([dynamic reason]) _onCancel;
  void Function([dynamic reason]) get onCancel => _onCancel;

  CancelableFuture(this._origin, this._onCancel);

  @override
  Stream<T> asStream() {
    return _origin.asStream();
  }

  @override
  CancelableFuture<R> then<R>(FutureOr<R> onValue(T value),
      {Function? onError}) {
    return CancelableFuture(
        _origin.then(onValue, onError: onError), this._onCancel);
  }

  @override
  CancelableFuture<T> catchError(Function onError,
      {bool Function(Object error)? test}) {
    return CancelableFuture(
        _origin.catchError(onError, test: test), this._onCancel);
  }

  @override
  CancelableFuture<T> timeout(Duration timeLimit,
      {FutureOr<T> Function()? onTimeout}) {
    return CancelableFuture(
        _origin.timeout(timeLimit, onTimeout: onTimeout), this._onCancel);
  }

  @override
  CancelableFuture<T> whenComplete(FutureOr<void> Function() action) {
    return CancelableFuture(_origin.whenComplete(action), this._onCancel);
  }

  void cancel({dynamic reason}) {
    _onCancel(reason);
  }
}
