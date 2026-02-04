import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_challenge/src/shared/domain/entities/post_entity.dart';

void main() {
  group('PostEntity', () {
    const userId = 1;
    const id = 101;
    const title = 'Test Title';
    const body = 'Test Body';

    test('should have the correct properties', () {
      const postEntity = PostEntity(
        userId: userId,
        id: id,
        title: title,
        body: body,
      );

      expect(postEntity.userId, userId);
      expect(postEntity.id, id);
      expect(postEntity.title, title);
      expect(postEntity.body, body);
      expect(postEntity.isLiked, false); // Default value
    });

    test('should support custom isLiked value', () {
      const postEntity = PostEntity(
        userId: userId,
        id: id,
        title: title,
        body: body,
        isLiked: true,
      );

      expect(postEntity.isLiked, true);
    });

    test('copyWith should return a new instance with updated values', () {
      const postEntity = PostEntity(
        userId: userId,
        id: id,
        title: title,
        body: body,
      );

      final updatedEntity = postEntity.copyWith(
        title: 'Updated Title',
        isLiked: true,
      );

      expect(updatedEntity.title, 'Updated Title');
      expect(updatedEntity.isLiked, true);
      // Unchanged values should remain the same
      expect(updatedEntity.userId, userId);
      expect(updatedEntity.id, id);
      expect(updatedEntity.body, body);
    });

    test('copyWith with no arguments should return equivalent instance', () {
      const postEntity = PostEntity(
        userId: userId,
        id: id,
        title: title,
        body: body,
        isLiked: true,
      );

      final copiedEntity = postEntity.copyWith();

      expect(copiedEntity.userId, postEntity.userId);
      expect(copiedEntity.id, postEntity.id);
      expect(copiedEntity.title, postEntity.title);
      expect(copiedEntity.body, postEntity.body);
      expect(copiedEntity.isLiked, postEntity.isLiked);
    });
  });
}
