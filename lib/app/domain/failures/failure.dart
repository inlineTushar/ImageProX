abstract class Failure {
  const Failure(this.message);
  final String message;
}

class ProcessingFailure extends Failure {
  const ProcessingFailure(String message) : super(message);
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}

class OcrFailure extends Failure {
  const OcrFailure(String message) : super(message);
}
