import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_challenge/src/shared/data/models/comment_model.dart';
import 'package:flutter_challenge/src/features/shared/domain/entities/comment.dart';

void main() {
  group('CommentModel', () {
    const id = 1;
    const postId = 101;
    const name = 'Test Name';
    const email = 'test@example.com';
    const body = 'Test comment body';
    const jsonMap = {
      'id': id,
      'postId': postId,
      'name': name,
      'email': email,
      'body': body,
    };

    test('should return a valid model from JSON', () {
      final result = CommentModel.fromJson(jsonMap);

      expect(result, isA<CommentModel>());
      expect(result.id, id);
      expect(result.postId, postId);
      expect(result.name, name);
      expect(result.email, email);
      expect(result.body, body);
    });

    test('should return a JSON map containing the proper data', () {
      const model = CommentModel(
        id: id,
        postId: postId,
        name: name,
        email: email,
        body: body,
      );
      final result = model.toJson();
      expect(result, jsonMap);
    });

    test('should extend CommentEntity', () {
      const model = CommentModel(
        id: id,
        postId: postId,
        name: name,
        email: email,
        body: body,
      );

      expect(model, isA<CommentEntity>());
    });

    test('should have correct property access', () {
      const model = CommentModel(
        id: id,
        postId: postId,
        name: name,
        email: email,
        body: body,
      );

      expect(model.id, id);
      expect(model.postId, postId);
      expect(model.name, name);
      expect(model.email, email);
      expect(model.body, body);
    });
  });
}
