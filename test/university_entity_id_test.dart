import 'package:flutter_test/flutter_test.dart';
import 'package:ikms/data/universities/university_entity_id.dart';
import 'package:ikms/data/universities/university_ids.dart';

void main() {
  test('encode/decode round-trips university and remote ids', () {
    final encoded = UniversityEntityId.encode(UniversityIds.donstu, 4242);
    expect(UniversityEntityId.universityId(encoded), UniversityIds.donstu);
    expect(UniversityEntityId.remoteId(encoded), 4242);
    expect(UniversityEntityId.isLegacy(encoded), isFalse);
  });

  test('legacy remote ids are detected', () {
    expect(UniversityEntityId.isLegacy(4242), isTrue);
    expect(UniversityEntityId.isLegacy(1 << 32), isFalse);
  });
}
