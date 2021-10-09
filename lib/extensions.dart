import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

R? whenValue<T, R>(T value, Map<T, R Function()> mapping) {
  return mapping[value]?.call();
}

List<int> range({int start = 0, required int count}) {
  final indexes = <int>[];
  for (int i = 0; i < count; i++) {
    indexes.add(start + i);
  }
  return indexes;
}

void repeat(int count, void f(int index)) {
  for (int i = 0; i < count; i++) {
    f(i);
  }
}

T min<T extends Comparable>(T a, T b) => a <= b ? a : b;

T max<T extends Comparable>(T a, T b) => a >= b ? a : b;

T? trySafe<T>(T fun()) {
  try {
    return fun();
  } catch (e) {
    printLog(() => 'trySafe=$e');
    return null;
  }
}

printLog(Object? what()) {
  if (kDebugMode) {
    print(what());
  }
}

extension NullStringExtensions on String? {
  String orDefault() => this ?? "";

  int get size => this?.length ?? 0;

  bool get isNullOrEmpty => (this?.isEmpty).orElseSafe(() => true);

  String? take(int n) {
    if (this == null) return null;
    if (n == 0) return '';
    if (n >= this!.length) return this;

    var count = 0;
    String result = '';
    for (var item in this!.characters) {
      result += item;
      if (++count == n) break;
    }
    return result;
  }

  String? takeLast(int n) {
    if (this == null) return null;
    if (n == 0) return '';
    if (n >= this!.length) return this;

    String result = '';
    int lastIndex = this!.length - n;
    for (var i = lastIndex; i < this!.length; i++) {
      result += this![i];
    }
    return result;
  }
}

extension StringExtensions on String {
  int get lastIndex => length - 1;

  String get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();

  String zeroPrefix(int count) {
    if (length >= count) {
      return this;
    } else {
      var builder = '';
      for (int i = 0; i < count - length; i++) {
        builder += '0';
      }
      builder += this;
      return builder;
    }
  }

  int? toInt() => int.tryParse(this);

  double? toDouble() => double.tryParse(this);

  String initials() => this
      .split(' ')
      .filter((it) => it.isNotEmpty)
      .map((it) => it[0])
      .take(2)
      .join()
      .toUpperCase();

  String capitalize() => "${this[0].toUpperCase()}${this.substring(1)}";

  int? parseInt() => int.tryParse(this);

  double? parseDouble() => double.tryParse(this);
}

extension NumExtensions<T extends num> on T {
  T plus(T value) {
    return this + value as T;
  }
}

extension NullIntExtensions on int? {
  int orDefault() => this ?? 0;
}

extension IntExtensions on int {
  String zeroPrefix(int count) {
    var it = this.toString();
    if (it.length >= count) {
      return it;
    } else {
      var builder = '';
      for (int i = 0; i < count - it.length; i++) {
        builder += '0';
      }
      builder += it;
      return builder;
    }
  }
}

extension DoubleExtensions on double? {
  double orDefault() => this ?? 0.0;
}

extension NullBoolExtensions on bool? {
  bool orDefault() => this ?? false;
}

extension BoolExtensions on bool {
  int toInt() => this ? 1 : 0;
}

extension NullAnyExtensions<T> on T? {
  T orElseSafe(T supplier()) => this ?? supplier();
}

extension AnyExtensions<T> on T {
  T orElse(T supplier()) => this ?? supplier();
}

extension DateTimeExtensions on DateTime {
  String toIso8601() {
    String y = (year >= -9999 && year <= 9999)
        ? _minDigits(year, 4)
        : _minDigits(year, 6);
    String m = _minDigits(month, 2);
    String d = _minDigits(day, 2);
    String h = _minDigits(hour, 2);
    String min = _minDigits(minute, 2);
    String sec = _minDigits(second, 2);
    String ms = _minDigits(millisecond, 3);
    String us = microsecond == 0 ? "" : _minDigits(microsecond, 3);
    if (isUtc) {
      return "$y-$m-${d}T$h:$min:$sec.$ms${us}Z";
    } else {
      return "$y-$m-${d}T$h:$min:$sec.$ms$us${_timeZoneOffset(this.timeZoneOffset)}";
    }
  }

  static String _minDigits(int n, int digitCount) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    return "$sign${absN.zeroPrefix(digitCount)}";
  }

  static String _timeZoneOffset(Duration duration) {
    var minutes = duration.inMinutes % 60;
    var sign = duration.inMilliseconds < 0 ? "-" : "+";
    return '$sign${duration.inHours.zeroPrefix(2)}:${minutes.zeroPrefix(2)}';
  }

  DateTimeRange toRange(Duration duration) {
    return DateTimeRange(start: this, end: this.add(duration));
  }

  String toTime(BuildContext context) =>
      TimeOfDay.fromDateTime(this.asLocal()).format(context);

  String formatDate() {
    DateTime it = this.toLocal();
    String y = it.year.zeroPrefix(4);
    String m = it.month.zeroPrefix(2);
    String d = it.day.zeroPrefix(2);
    return "$y-$m-$d";
  }

  String toDate() => DateFormat.yMd().format(this);

  String formatDateTime({dynamic locale}) {
    DateTime it = this.toLocal();
    return DateFormat('EE, dd MMM yyyy HH:mm:ss', locale).format(it);
  }

  String formatMonthYear({dynamic locale}) {
    DateTime it = this.toLocal();
    return DateFormat('MMM yyyy', locale).format(it);
  }

  String formatDayMonthYear({dynamic locale}) {
    DateTime it = this.toLocal();
    return DateFormat('MMMM dd, yyyy', locale).format(it);
  }

  String formatWeek({dynamic locale}) {
    DateTime it = this.toLocal();
    return DateFormat.E(locale).format(it).toUpperCase();
  }

  String formatTime({dynamic locale}) {
    DateTime it = this.toLocal();
    return DateFormat.Hm(locale).format(it);
  }

  String formatTimeDurationFrom(Duration duration, {dynamic locale}) {
    DateTime it = this.toLocal();
    var format = DateFormat.Hm(locale);
    return '${format.format(it)} - ${format.format(it.add(duration))}';
  }

  Duration untilNextDay() {
    return this.nextDayStart().difference(this);
  }

  DateTime daysBefore(int days) => this.copyWith(day: day - days);

  DateTime daysAfter(int days) => this.copyWith(day: day + days);

  DateTime nextDayStart() => this.onlyDate().daysAfter(1);

  DateTime startOfDay() => this.copyOnly(year: year, month: month, day: day);

  DateTime endOfDay() => this.copyWith(
      hour: 23, minute: 59, second: 59, millisecond: 0, microsecond: 0);

  DateTime localTimeToday() => DateTime.now().let((now) => DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      ));

  DateTime onlyDate() => startOfDay();

  DateTime onlyMonth() => this.copyOnly(year: year, month: month);

  DateTime onlyTime() => DateTime.utc(
        1970,
        1,
        1,
        hour,
        minute,
        0,
        0,
        0,
      );

  DateTime utcTimeFirstDaySinceEpoch() => DateTime.utc(
        1970,
        1,
        1,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  DateTime asUtc() => isUtc
      ? this
      : DateTime.utc(
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        );

  DateTime asLocal() => !isUtc
      ? this
      : DateTime(
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        );

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) =>
      isUtc
          ? DateTime.utc(
              year ?? this.year,
              month ?? this.month,
              day ?? this.day,
              hour ?? this.hour,
              minute ?? this.minute,
              second ?? this.second,
              millisecond ?? this.millisecond,
              microsecond ?? this.microsecond,
            )
          : DateTime(
              year ?? this.year,
              month ?? this.month,
              day ?? this.day,
              hour ?? this.hour,
              minute ?? this.minute,
              second ?? this.second,
              millisecond ?? this.millisecond,
              microsecond ?? this.microsecond,
            );

  DateTime copyOnly({
    int year = 1970,
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  }) =>
      isUtc
          ? DateTime.utc(
              year, month, day, hour, minute, second, millisecond, microsecond)
          : DateTime(
              year, month, day, hour, minute, second, millisecond, microsecond);
}

extension DateTimeRangeExtensions on DateTimeRange {
  String formatDuration({dynamic locale}) {
    var format = DateFormat.Hm(locale);
    return '${format.format(this.start.toLocal())} - ${format.format(this.end.toLocal())}';
  }

  List<DateTimeRange> subtract(DateTimeRange other) {
    var result = <DateTimeRange>[];
    if (other.start <= this.start && other.end >= this.end) {
      return result;
    } else if (this.start <= other.start && this.end >= other.end) {
      // split case
      return result
        ..add(DateTimeRange(start: this.start, end: other.start))
        ..add(DateTimeRange(start: other.end, end: this.end));
    } else if (this.start < other.end && other.end <= this.end) {
      return result..add(DateTimeRange(start: other.end, end: this.end));
    } else if (this.end > other.start && this.start <= other.start) {
      return result..add(DateTimeRange(start: this.start, end: other.start));
    } else {
      return result..add(this);
    }
  }

  bool intersect(DateTimeRange other) {
    return this.atLeastOnePointInside(other) ||
        other.atLeastOnePointInside(this);
  }

  bool atLeastOnePointInside(DateTimeRange other) {
    return (other.start >= this.start && other.start <= this.end) ||
        (other.end >= this.start && other.end <= this.end);
  }
}

extension TextEditingControllerExtension on TextEditingController {
  void assign(String value, void update(String value)) {
    this.text = value;
    this.addListener(() => update(this.text));
  }
}

extension NullDurationExtensions on Duration? {
  Duration orDefault() => this ?? Duration.zero;
}

extension DurationExtensions on Duration {
  double operator /(Duration value) =>
      this.inMicroseconds / value.inMicroseconds;

  Duration operator %(Duration value) =>
      Duration(microseconds: this.inMicroseconds % value.inMicroseconds);

  int operator *(Duration value) => this.inMicroseconds * value.inMicroseconds;
}

enum TimeZone { utc, local }

extension DateExtensions on int {
  DateTime localDateTime() =>
      DateTime.fromMillisecondsSinceEpoch(this, isUtc: false);

  DateTime utcDateTime() =>
      DateTime.fromMillisecondsSinceEpoch(this, isUtc: true);

  DateTime asDateTime({TimeZone from = TimeZone.utc}) {
    switch (from) {
      case TimeZone.local:
        return localDateTime();
      case TimeZone.utc:
      default:
        return utcDateTime();
    }
  }

  DateTime asLocal({TimeZone from = TimeZone.utc}) =>
      asDateTime(from: from).asLocal();

  String toTime(BuildContext context, {TimeZone from = TimeZone.utc}) =>
      asDateTime(from: from).toTime(context);

  int localTimeToday({TimeZone from = TimeZone.utc}) =>
      asDateTime(from: from).localTimeToday().millisecondsSinceEpoch;

  int onlyDate({TimeZone from = TimeZone.utc}) =>
      asDateTime(from: from).onlyDate().millisecondsSinceEpoch;

  int onlyTime({TimeZone from = TimeZone.utc}) =>
      asDateTime(from: from).utcTimeFirstDaySinceEpoch().millisecondsSinceEpoch;

  int utcTimeFirstDaySinceEpoch({TimeZone from = TimeZone.utc}) =>
      asDateTime(from: from).utcTimeFirstDaySinceEpoch().millisecondsSinceEpoch;

  Duration asDuration() => Duration(milliseconds: this);
}

extension Lambdas<T> on T {
  T also(void fun(T it)) {
    fun(this);
    return this;
  }

  R let<R>(R fun(T it)) => fun(this);

  T? takeIf(bool test(T it)) => test(this) ? this : null;

  T? takeIfNot(bool test(T it)) => !test(this) ? this : null;
}

extension NullIterableExtensions<E> on Iterable<E>? {
  bool get isNullOrEmpty => (this?.isEmpty).orElseSafe(() => true);

  int get size => this?.length ?? 0;

  int count() => this?.length ?? 0;

  int countBy(bool test(E e)) {
    int sum = 0;
    this?.forEach((it) {
      if (test(it)) sum++;
    });
    return sum;
  }

  Iterable<E> orDefault() => this ?? <E>[];

  List<E> safeToList() => this?.toList() ?? <E>[];
}

extension NullElementItarableExtensions<E> on Iterable<E?> {
  List<E> filterNotNull() =>
      this.where((it) => it != null).cast<E>().toList(growable: false);
}

extension IterableExtensions<E> on Iterable<E> {
  /// Returns the first element.
  ///
  /// Returns `null` if `this` is empty.
  /// Otherwise returns the first element in the iteration order
  E? get firstOrNull =>
      iterator.let((it) => !it.moveNext() ? null : it.current);

  E firstOr(E supplier()) =>
      iterator.let((it) => !it.moveNext() ? supplier() : it.current);

  E? get lastOrNull {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return null;
    }
    E result;
    do {
      result = it.current;
    } while (it.moveNext());
    return result;
  }

  /// Returns the first element that satisfies the given predicate [test].
  ///
  /// Iterates through elements and returns the first to satisfy [test].
  ///
  /// If no element satisfies [test], the result returns `null`
  E? find(bool test(E e)) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  List<E> filter(bool test(E e), {bool growable = false}) =>
      this.where(test).toList(growable: growable);

  List<E> filterNot(bool test(E e), {bool growable = false}) =>
      this.where((e) => !test(e)).toList(growable: growable);

  List<E> shuffled([Random? random]) =>
      toList(growable: false)..shuffle(random);

  List<E> sorted(int compare(E a, E b)) =>
      toList(growable: false)..sort(compare);

  List<E> sortedBy<T extends Comparable>(T selector(E value)) =>
      toList(growable: false)
        ..sort((a, b) => selector(a).compareTo(selector(b)));

  E? minBy<R extends Comparable>(R selector(E element)) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    var minElem = iterator.current;
    if (!iterator.moveNext()) return minElem;
    var minValue = selector(minElem);
    do {
      final e = iterator.current;
      final v = selector(e);
      if (minValue > v) {
        minElem = e;
        minValue = v;
      }
    } while (iterator.moveNext());
    return minElem;
  }

  E? minWith(int compare(E a, E b)) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    var min = iterator.current;
    while (iterator.moveNext()) {
      final e = iterator.current;
      if (compare(min, e) > 0) min = e;
    }
    return min;
  }

  /// Returns the first element yielding the largest value of the given function or `null` if there are no elements.
  ///
  /// @sample samples.collections.Collections.Aggregates.maxBy
  E? maxBy<R extends Comparable>(R selector(E element)) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    var maxElem = iterator.current;
    if (!iterator.moveNext()) return maxElem;
    var maxValue = selector(maxElem);
    do {
      final e = iterator.current;
      final v = selector(e);
      if (maxValue < v) {
        maxElem = e;
        maxValue = v;
      }
    } while (iterator.moveNext());
    return maxElem;
  }

  /// Returns the first element having the largest value according to the provided [comparator] or `null` if there are no elements.
  E? maxWith(int compare(E a, E b)) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    var max = iterator.current;
    while (iterator.moveNext()) {
      final e = iterator.current;
      if (compare(max, e) < 0) max = e;
    }
    return max;
  }

  int sumBy(int fun(E element)) {
    int sum = 0;
    forEach((it) => sum += fun(it));
    return sum;
  }

  String joinToString(
      {String separator = "",
      String prefix = "",
      String postfix = "",
      Object? transform(E e)?}) {
    String result = prefix;

    var first = true;
    forEach((it) {
      if (!first) {
        result += separator;
      } else {
        first = false;
      }
      result += transform == null ? '$it' : '${transform(it)}';
    });

    result += postfix;
    return result;
  }

  Future<List<R>> asyncMap<R>(FutureOr<R> fun(E element)) async {
    final items = <R>[];
    for (var it in this) {
      items.add(await fun(it));
    }
    return items;
  }

  List<R> mapToList<R>(R f(E e), {bool growable = false}) =>
      this.map(f).toList(growable: growable);

  Map<K, List<E>> groupBy<K>(K selector(E e)) {
    final result = <K, List<E>>{};
    for (var it in this) {
      var key = selector(it);
      result[key] = result[key].orDefault()..add(it);
    }
    return result;
  }

  List<R> groupInto<K, R>(K keySelector(E e), R valueSelector(List<E> value)) {
    return <R>[
      for (var item in this.groupBy(keySelector).values) valueSelector(item)
    ];
  }
}

extension NullListExtensions<E> on List<E>? {
  List<E> orDefault() => this ?? <E>[];
}

extension ListExtensions<E> on List<E> {
  E get(int index) => this[index];

  void set(int index, E element) => this[index] = element;

  E? getOrNull(int index) => index < 0 || index >= length ? null : this[index];

  E getOr(int index, E supplier()) =>
      index < 0 || index >= length ? supplier() : this[index];

  void forEachReversed(void f(int index, E element)) {
    for (int i = this.lastIndex; i >= 0; i--) {
      f(i, this[i]);
    }
  }

  void forEachIndexed(void f(int index, E element)) {
    for (int i = 0; i < this.length; i++) {
      f(i, this[i]);
    }
  }

  List<R> mapIndexed<R>(R transform(int index, E e)) =>
      this.mapIndexedTo<R, List<R>>(<R>[], transform);

  C mapIndexedTo<R, C extends List<R>>(
      C destination, R transform(int index, E e)) {
    this.forEachIndexed(
        (index, element) => destination.add(transform(index, element)));
    return destination;
  }

  int get lastIndex => length - 1;

  List<E> reversedList() => this.reversed.toList(growable: false);

  void moveAt(int oldIndex, int index) {
    final item = this[oldIndex];
    removeAt(oldIndex);
    insert(index, item);
  }

  void move(int index, E item) {
    remove(item);
    insert(index, item);
  }

  int indexOfItem(E element, Iterable<int> exclude) {
    for (int i = 0; i < this.length; i++) {
      if (!exclude.contains(i) && this[i] == element) return i;
    }
    return -1;
  }

  int indexOfWhere(bool test(int index, E element)) {
    for (int i = 0; i < this.length; i++) {
      if (test(i, this[i])) return i;
    }
    return -1;
  }

  List<E> insertBetween(E delimiter(int index)) {
    final sb = <E>[];
    bool firstTime = true;
    var index = 0;
    for (var token in this) {
      if (firstTime) {
        firstTime = false;
      } else {
        sb.add(delimiter(index++));
      }
      sb.add(token);
    }
    return sb;
  }
}

extension SetExtensions<E> on Set<E> {
  Set<E> filterNotNull() => this.where((it) => it != null).toSet();
}

extension ComparableIterableExtensions<E extends Comparable> on Iterable<E> {
  List<E> sorted() => toList()..sort();

  E? min() {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    var min = iterator.current;
    while (iterator.moveNext()) {
      final e = iterator.current;
      if (min > e) min = e;
    }
    return min;
  }

  E? max() {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    var max = iterator.current;
    while (iterator.moveNext()) {
      final e = iterator.current;
      if (max < e) max = e;
    }
    return max;
  }
}

extension ComparableExtensions<T> on Comparable<T> {
  bool operator >(T value) => compareTo(value) == 1;

  bool operator >=(T value) => compareTo(value).let((it) => it == 1 || it == 0);

  bool operator <(T value) => compareTo(value) == -1;

  bool operator <=(T value) =>
      compareTo(value).let((it) => it == -1 || it == 0);
}

extension IterableIterableExtensions<E> on Iterable<Iterable<E>> {
  List<E> flatten() => this.expand((it) => it).toList(growable: false);
}

extension NullMapExtensions<K, V> on Map<K, V>? {
  bool get isNullOrEmpty => (this?.isEmpty).orElseSafe(() => true);

  Map<K, V> orDefault() => this ?? <K, V>{};
}

extension MapExtensions<K, V> on Map<K, V> {
  Map<K, V> operator +(Map<K, V> other) => {...this, ...other};

  V? get(K key) => this[key];

  V? getOrElse(K key, V value) => containsKey(key) ? this[key] : value;

  void put(K key, V value) => this[key] = value;

  void putAllIfAbsent(Map<K, V>? other) {
    other?.forEach((key, value) {
      if (!this.containsKey(key)) {
        this[key] = value;
      }
    });
  }

  Map<K, V> filter(bool test(K k, V v)) {
    final result = <K, V>{};
    this.forEach((k, v) {
      if (test(k, v)) {
        result[k] = v;
      }
    });
    return result;
  }

  // // for List
  // bool operator == (List other) {
  //   if(length != other.length) return false;
  //   for(int i = 0; i < length; i++) if(this[i] != other[i]) return false;
  //   return true;
  // }

  bool deepEqual(Map<K, V>? other) {
    if (other == null) return false;
    if (length != other.length) return false;
    return this
        .keys
        .every((key) => other.containsKey(key) && this[key] == other[key]);
  }

  bool containsValues(Map<K, V>? other) {
    if (other == null) return false;
    return other.keys
        .every((key) => this.containsKey(key) && this[key] == other[key]);
  }

  Map<K2, V> mapKeys<K2>(K2 map(K)) =>
      this.map((key, value) => MapEntry(map(key), value));

  Map<K, V2> mapValues<V2>(V2 map(V value)) =>
      this.map((key, value) => MapEntry(key, map(value)));

  bool any(bool test(K key, V value)) {
    for (var element in this.entries) {
      if (test(element.key, element.value)) return true;
    }
    return false;
  }

  bool every(bool test(K key, V value)) {
    for (var element in this.entries) {
      if (!test(element.key, element.value)) return false;
    }
    return true;
  }

  List<E> toList<E>(E selector(K key, V value)) {
    return <E>[
      for (var entry in this.entries) selector(entry.key, entry.value)
    ];
  }
}

extension TextBoxExtensions on TextBox {
  double get width => right - left;

  double get height => bottom - top;
}

extension BrightnessExtensions on Brightness {
  Brightness inverse() {
    return this == Brightness.light ? Brightness.dark : Brightness.light;
  }
}

extension ColorExtensions on Color {
  Brightness get brightness {
    return ThemeData.estimateBrightnessForColor(this);
  }
}

extension ScrollUpdateNotificationExtensions on ScrollUpdateNotification {
  bool get isFromUser => dragDetails != null;
}

extension ContextExtensions on BuildContext {
  double percentOfWidth(int it) => fractionOfWidth(it / 100);

  double percentOfSafeAreaWidth(int it) => fractionOfSafeAreaWidth(it / 100);

  double fractionOfWidth(double it) => ScreenSizeConfig(this).screenWidth * it;

  double fractionOfSafeAreaWidth(double it) =>
      ScreenSizeConfig(this).safeAreaWidth * it;

  double get screenWidth => ScreenSizeConfig(this).screenWidth;

  double get safeAreaWidth => ScreenSizeConfig(this).safeAreaWidth;

  double percentOfHeight(int it) => fractionOfHeight(it / 100);

  double percentOfSafeAreaHeight(int it) => fractionOfSafeAreaHeight(it / 100);

  double fractionOfHeight(double it) =>
      ScreenSizeConfig(this).screenHeight * it;

  double fractionOfSafeAreaHeight(double it) =>
      ScreenSizeConfig(this).safeAreaHeight * it;

  int logicalPixelToReal(double it) =>
      (it * mediaQuery.devicePixelRatio).round();

  double get screenHeight => percentOfHeight(100);

  double get safeAreaHeight => percentOfSafeAreaHeight(100);

  ThemeData get theme => Theme.of(this);

  FocusScopeNode get focusScope => FocusScope.of(this);

  NavigatorState get navigator => Navigator.of(this);

  NavigatorState get rootNavigator => Navigator.of(this, rootNavigator: true);

  ScaffoldState get scaffold => Scaffold.of(this);

  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Route? get currentRoute {
    Route? currentRoute;
    Navigator.popUntil(this, (route) {
      currentRoute = route;
      return true;
    });
    return currentRoute;
  }

  ModalRoute? get modalRoute => ModalRoute.of(this);

  T? routeArgument<T>() => currentRoute?.settings.arguments as T?;

  String? get currentRouteName => currentRoute?.settings.name;
}

extension FocusScopeExtensions on FocusScopeNode {
  void hideKeyboard() => requestFocus(new FocusNode());
}

extension NavigatorStateExtensions on NavigatorState {
  @optionalTypeArgs
  Future<T?> pushRoot<T extends Object>(
    Route<T> newRoute, {
    bool singleTop = false,
  }) {
    if (!singleTop || newRoute.settings.name != currentRouteName) {
      return pushAndRemoveUntil(newRoute, (it) => false);
    } else {
      return Future.value(null);
    }
  }

  @optionalTypeArgs
  Future<T?> pushNamedRoot<T extends Object>(
    String newRouteName, {
    Object? arguments,
    bool singleTop = false,
  }) {
    if (!singleTop || newRouteName != currentRouteName) {
      return pushNamedAndRemoveUntil(newRouteName, (it) => false,
          arguments: arguments);
    } else {
      return Future.value(null);
    }
  }

  @optionalTypeArgs
  Future<T?> pushSingleTop<T extends Object>(Route<T> newRoute) {
    if (newRoute.settings.name != currentRouteName) {
      return push(newRoute);
    } else {
      return Future.value(null);
    }
  }

  @optionalTypeArgs
  Future<T?> pushNamedSingleTop<T extends Object>(
    String newRouteName, {
    Object? arguments,
  }) {
    if (newRouteName != currentRouteName) {
      return pushNamed(newRouteName, arguments: arguments);
    } else {
      return Future.value(null);
    }
  }

  Route? get currentRoute {
    Route? currentRoute;
    popUntil((route) {
      currentRoute = route;
      return true;
    });
    return currentRoute;
  }

  String? get currentRouteName => currentRoute?.settings?.name;
}

class ScreenSizeConfig {
  final double screenWidth;
  final double screenHeight;

  final double _safeAreaHorizontalPadding;
  final double _safeAreaVerticalPadding;
  final double safeAreaWidth;
  final double safeAreaHeight;

  ScreenSizeConfig._(
    this.screenWidth,
    this.screenHeight,
    this._safeAreaHorizontalPadding,
    this._safeAreaVerticalPadding,
    this.safeAreaWidth,
    this.safeAreaHeight,
  );

  factory ScreenSizeConfig(BuildContext context) {
    MediaQueryData _mediaQueryData = context.mediaQuery;

    final screenWidth = _mediaQueryData.size.width;
    final screenHeight = _mediaQueryData.size.height;

    final _safeAreaHorizontalPadding =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    final _safeAreaVerticalPadding =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    final safeAreaWidth = screenWidth - _safeAreaHorizontalPadding;
    final safeAreaHeight = screenHeight - _safeAreaVerticalPadding;
    return ScreenSizeConfig._(
        screenWidth,
        screenHeight,
        _safeAreaHorizontalPadding,
        _safeAreaVerticalPadding,
        safeAreaWidth,
        safeAreaHeight);
  }
}

extension TextThemeExtensions on TextTheme {
  TextTheme applyPlatformFontFamilyFallback() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        final displayFontFallback = ['.SF UI Display'];
        final bodyFontFallback = ['.SF UI Text'];
        return TextTheme(
          headline1: headline1?.apply(fontFamilyFallback: displayFontFallback),
          headline2: headline2?.apply(fontFamilyFallback: displayFontFallback),
          headline3: headline3?.apply(fontFamilyFallback: displayFontFallback),
          headline4: headline4?.apply(fontFamilyFallback: displayFontFallback),
          headline5: headline5?.apply(fontFamilyFallback: displayFontFallback),
          headline6: headline6?.apply(fontFamilyFallback: displayFontFallback),
          subtitle1: subtitle1?.apply(fontFamilyFallback: bodyFontFallback),
          bodyText1: bodyText1?.apply(fontFamilyFallback: bodyFontFallback),
          bodyText2: bodyText2?.apply(fontFamilyFallback: bodyFontFallback),
          caption: caption?.apply(fontFamilyFallback: bodyFontFallback),
          button: button?.apply(fontFamilyFallback: bodyFontFallback),
          subtitle2: subtitle2?.apply(fontFamilyFallback: bodyFontFallback),
          overline: overline?.apply(fontFamilyFallback: bodyFontFallback),
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      default:
        final fontFallback = ['Roboto'];
        return TextTheme(
          headline1: headline1?.apply(fontFamilyFallback: fontFallback),
          headline2: headline2?.apply(fontFamilyFallback: fontFallback),
          headline3: headline3?.apply(fontFamilyFallback: fontFallback),
          headline4: headline4?.apply(fontFamilyFallback: fontFallback),
          headline5: headline5?.apply(fontFamilyFallback: fontFallback),
          headline6: headline6?.apply(fontFamilyFallback: fontFallback),
          subtitle1: subtitle1?.apply(fontFamilyFallback: fontFallback),
          bodyText1: bodyText1?.apply(fontFamilyFallback: fontFallback),
          bodyText2: bodyText2?.apply(fontFamilyFallback: fontFallback),
          caption: caption?.apply(fontFamilyFallback: fontFallback),
          button: button?.apply(fontFamilyFallback: fontFallback),
          subtitle2: subtitle2?.apply(fontFamilyFallback: fontFallback),
          overline: overline?.apply(fontFamilyFallback: fontFallback),
        );
    }
  }

  TextTheme applyFontFamilyFallback(List<String> fontFamilyFallback) {
    return TextTheme(
      headline1: headline1?.apply(fontFamilyFallback: fontFamilyFallback),
      headline2: headline2?.apply(fontFamilyFallback: fontFamilyFallback),
      headline3: headline3?.apply(fontFamilyFallback: fontFamilyFallback),
      headline4: headline4?.apply(fontFamilyFallback: fontFamilyFallback),
      headline5: headline5?.apply(fontFamilyFallback: fontFamilyFallback),
      headline6: headline6?.apply(fontFamilyFallback: fontFamilyFallback),
      subtitle1: subtitle1?.apply(fontFamilyFallback: fontFamilyFallback),
      bodyText1: bodyText1?.apply(fontFamilyFallback: fontFamilyFallback),
      bodyText2: bodyText2?.apply(fontFamilyFallback: fontFamilyFallback),
      caption: caption?.apply(fontFamilyFallback: fontFamilyFallback),
      button: button?.apply(fontFamilyFallback: fontFamilyFallback),
      subtitle2: subtitle2?.apply(fontFamilyFallback: fontFamilyFallback),
      overline: overline?.apply(fontFamilyFallback: fontFamilyFallback),
    );
  }
}

class Reference<T> {
  T? value;

  Reference([this.value]);
}

class FieldProxy<T> {
  final String title;
  final T Function() _get;
  final void Function(T value) _set;

  FieldProxy(this.title, this._get, this._set);

  T get value => this._get();
  set value(T value) => this._set(value);
}
