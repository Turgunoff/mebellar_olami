/// Represents a failure or error in the application.
class Failure {
  const Failure({required this.message});

  final String message;

  @override
  String toString() => 'Failure: $message';
}
