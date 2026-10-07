/// Encodes/decodes Isar primary keys that namespace remote ids by university.
///
/// Layout: `[universityId : 32 bits][remoteId : 32 bits]`.
abstract final class UniversityEntityId {
  /// Combines [universityId] and API [remoteId] into a stable Isar [Id].
  static int encode(int universityId, int remoteId) =>
      (universityId << 32) | (remoteId & 0xFFFFFFFF);

  /// Extracts the remote (API) id from a composite Isar id.
  static int remoteId(int isarId) => isarId & 0xFFFFFFFF;

  /// Extracts the university id from a composite Isar id.
  static int universityId(int isarId) => isarId >> 32;

  /// Whether [isarId] looks like a legacy (non-composite) id.
  static bool isLegacy(int isarId) => isarId < (1 << 32);
}
