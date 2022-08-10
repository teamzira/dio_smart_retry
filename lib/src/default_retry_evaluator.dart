import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

class DefaultRetryEvaluator {
  DefaultRetryEvaluator(this._retryableStatuses, this._retryDisableStatuses);

  final Set<int> _retryableStatuses;
  final Set<int> _retryDisableStatuses;

  /// Returns true only if the response hasn't been cancelled
  ///   or got a bad status code.
  // ignore: avoid-unused-parameters
  FutureOr<bool> evaluate(DioError error, int attempt) {
    bool shouldRetry;
    if (error.type == DioErrorType.response) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        shouldRetry = isRetryable(statusCode);
      } else {
        shouldRetry = true;
      }
    } else {
      shouldRetry = (error.error is SocketException) ||
          (error.type != DioErrorType.cancel &&
              error.error is! FormatException);
    }
    return shouldRetry;
  }

  bool isRetryable(int statusCode) =>
      _retryableStatuses.contains(statusCode) &&
      !_retryDisableStatuses.contains(statusCode);
}
