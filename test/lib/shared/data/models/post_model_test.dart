import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_challenge/src/shared/data/models/post_model.dart';
import 'package:flutter_challenge/src/shared/domain/entities/post_entity.dart';

void main() {
  group('PostModel', () {
    const userId = 1;
    const id = 101;
    const title = 'Test Title';
    const body = 'Test Body';
    const jsonMap = {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };

    test('should return a valid model from JSON', () {
      final result = PostModel.fromJson(jsonMap);

      expect(result, isA<PostModel>());
      expect(result.userId, userId);
      expect(result.id, id);
      expect(result.title, title);
      expect(result.body, body);
      expect(result.isLiked, false); // Default value from fromJson
    });

    test('should return a JSON map containing the proper data', () {
      const model = PostModel(
        userId: userId,
        id: id,
        title: title,
        body: body,
      );
      final result = model.toJson();
      expect(result, jsonMap);
    });

    test('copyWith should return a new instance with updated values', () {
      const model = PostModel(
        userId: userId,
        id: id,
        title: title,
        body: body,
      );
      final updatedModel = model.copyWith(
        title: 'Updated Title',
        isLiked: true,
      );

      expect(updatedModel.title, 'Updated Title');
      expect(updatedModel.isLiked, true);
      expect(updatedModel.userId, userId);
      expect(updatedModel.id, id);
      expect(updatedModel.body, body);
    });

    test('should extend PostEntity', () {
      const model = PostModel(
        userId: userId,
        id: id,
        title: title,
        body: body,
      );

      expect(model, isA<PostEntity>());
    });

    test('copyWith with no arguments should return equivalent instance', () {
      const model = PostModel(
        userId: userId,
        id: id,
        title: title,
        body: body,
        isLiked: true,
      );

      final copiedModel = model.copyWith();

      expect(copiedModel.userId, model.userId);
      expect(copiedModel.id, model.id);
      expect(copiedModel.title, model.title);
      expect(copiedModel.body, model.body);
      expect(copiedModel.isLiked, model.isLiked);
    });
  });
}
