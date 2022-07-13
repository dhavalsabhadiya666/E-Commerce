//App Expection...
class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([
    this._prefix,
    this._message,
  ]);

  String toString() {
    return "$_prefix$_message";
  }
}

class NoInternetException extends AppException {
  NoInternetException([String message])
      : super(
          "",
          message,
        );
}

class FetchDataException extends AppException {
  FetchDataException([String message])
      : super(
          "Error During Communication!, ",
          message,
        );
}

class BadRequestException extends AppException {
  BadRequestException([String message])
      : super(
          "",
          message,
        );
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String message])
      : super(
          "",
          message,
        );
}

class InvalidInputException extends AppException {
  InvalidInputException([String message])
      : super(
          "",
          message,
        );
}
