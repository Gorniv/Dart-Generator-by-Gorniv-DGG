// ignore_for_file: avoid_annotating_with_dynamic

import 'package:mobile/core/index.dart';
import 'package:mobile/services/logger/index.dart';

class DartDynamic {
  static String asrString(dynamic value) {
    return asrT<String>(value?.toString());
  }

  static double? asDouble(dynamic value) {
    return asT<double>(value, method: 'asDouble');
  }

  static double asrDouble(dynamic value) {
    return asrT<double>(value, method: 'asrDouble');
  }

  static bool? asBool(dynamic value) {
    return asT<bool>(value, method: 'asBool');
  }

  static bool asrBool(dynamic value) {
    return asrT<bool>(value, method: 'asrBool');
  }

  static int? asInt(dynamic value) {
    return asT<int>(value, method: 'asInt');
  }

  static int asrInt(dynamic value) {
    return asrT<int>(value, method: 'asrInt');
  }

  static Exception? asException(dynamic value) {
    return asT<Exception>(value, method: 'asException');
  }

  static Exception asrException(dynamic value) {
    return asrT<Exception>(value, method: 'asrException');
  }

  static DateTime? asDateTime(dynamic value) {
    return asT<DateTime>(value, method: 'asDateTime');
  }

  static DateTime asrDateTime(dynamic value) {
    return asrT<DateTime>(value, method: 'asrDateTime');
  }

  static List<T?>? asList<T>(dynamic value) {
    if (T is String?) {
      return asT<List>(value, method: 'asList')?.cast<T?>();
    }
    final list = asT<List>(value, method: 'asList');
    return _list(list);
  }

  static List<T?>? _list<T>(List? list) {
    if (list == null) {
      return null;
    }
    final result = <T?>[];
    var count = 0;
    while (count < list.length) {
      final newElement = DartDynamic.asT<T>(list[count]);
      result.add(newElement);
      count++;
    }
    return result;
  }

  static List<T> _rlist<T>(List list) {
    final result = <T>[];
    var count = 0;
    while (count < list.length) {
      final newElement = DartDynamic.asrT<T>(list[count]);
      result.add(newElement);
      count++;
    }
    return result;
  }

  static List<T> asrSafeList<T>(dynamic value) {
    if (T is String) {
      return asrT<List>(value, method: 'asList').cast<T>();
    }
    final list = asrT<List>(value, method: 'asList');
    return _rlist(list);
  }

  static List<T> asSafeList<T>(dynamic value) {
    if (T is String) {
      return asrT<List>(value, method: 'asList').cast<T>();
    }
    return asT<List>(value, method: 'asList').toSafeItemType<T>().toList();
  }

  static List<T> asrList<T>(dynamic value) {
    if (T is String) {
      return asrT<List>(value, method: 'asList').cast<T>().toList();
    }
    return asrT<List>(value, method: 'asrList').map((e) => DartDynamic.asrT<T>(e)).toList();
  }

  static Map<TKey, TValue>? asMap<TKey, TValue>(dynamic value) {
    return asT<Map<TKey, TValue>>(value, method: 'asMap');
    // ?.map(
    //   (key, value) => MapEntry(
    //     asrT<TKey>(key),
    //     asrT<TValue>(value),
    //   ),
    // );
  }

  static Map<TKey, TValue> asrMap<TKey, TValue>(dynamic value) {
    return asrT<Map<TKey, TValue>>(value, method: 'asrMap');
    // .map(
    //   (key, value) => MapEntry(
    //     asrT<TKey>(key),
    //     asrT<TValue>(value),
    //   ),
    // );
  }

  static Iterable<T>? asIterable<T>(dynamic value) {
    return asT<Iterable<T>>(value, method: 'asIterable');
  }

  static Iterable<T> asrIterable<T>(dynamic value) {
    return asrT<Iterable<T>>(value, method: 'asrIterable');
  }

  /// Convert int or String to Enum
  /// useful when one needs to turn int or String value came from a server
  /// to domestic enum
  ///
  /// Example:
  /// ```dart
  /// static PspFieldModel? fromMap(Map<String, dynamic>? map) {
  ///   if (map==null) {
  ///     return null;
  ///   }
  ///   return PspFieldModel(
  ///     type: DartDynamic.asEnum(map['type'], PspFieldModelType.values),
  ///   );
  /// }
  /// ```
  static T asEnum<T extends Enum>(dynamic value, List<T> enumValues) {
    try {
      if (value is int) {
        return enumValues.elementAt(value);
      }
      if (value is String) {
        return enumValues.firstWhere((element) => element.name == value);
      }
      throw Exception('value must be "int" or "String" type but it is "${value.runtimeType}" type');
    } catch (e, stackTrace) {
      final exception = Exception(
        '''
The value($value) cannot be converted to Enum $T (method asEnum),
the cause can be a new value from a server.
Details: $e''',
      );

      _logger.e('Cast as exception:', exception: exception, tag: _name, stackTrace: stackTrace);
    }
    const defaultValue = 0;
    return enumValues.elementAt(defaultValue);
  }

  static T asrEnum<T extends Enum>(dynamic value, List<T> enumValues) {
    try {
      if (value is int) {
        return enumValues.elementAt(value);
      }
      if (value is String) {
        return enumValues.firstWhere((element) => element.name == value);
      }
      throw RequiredException(
        messageFromCast: 'value must be "int" or "String" type but it is "${value.runtimeType}" type',
        stackTrace: StackTrace.current,
      );
    } catch (e, stackTrace) {
      throw RequiredException(
        messageFromCast: '''
The value($value) cannot be converted to Enum $T (method asEnum),
the cause can be a new value from a server.
Details: $e''',
        stackTrace: stackTrace,
      );
    }
  }

  static T? asT<T>(dynamic value, {String method = 'asT', bool ignoreError = false}) {
    if (value == null) {
      return null;
    }
    if (value is T) {
      return value;
    }
    if (!ignoreError) {
      _logger.e(
        'Cast as exception',
        exception: Exception('as for method = $method - and type = ${T.runtimeType} not applyed for $value'),
        tag: _name,
        stackTrace: StackTrace.current,
      );
    }
    return null;
  }

  static T asrT<T>(dynamic value, {String method = 'asrT'}) {
    if (value is T) {
      return value;
    }
    if (value == null) {
      throw RequiredException(
        messageFromCast: 'as required for method = $method - and type = ${T.runtimeType} not applyed for null value',
        stackTrace: StackTrace.current,
      );
    }
    throw RequiredException(
      messageFromCast: 'Cast exception as required for method = $method - and type = ${T.runtimeType} not applyed for $value',
      stackTrace: StackTrace.current,
    );
  }

  static const String _name = 'DartDynamic';
  static Logger get _logger => LoggerDi.logger(LogPath.core);
}
