enum CleanerType { purifier, defender }

abstract class CleanerBase {
  final CleanerType type;

  CleanerBase(this.type);
}
