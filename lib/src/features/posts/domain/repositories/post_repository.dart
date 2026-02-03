import 'package:flutter_challenge/src/features/posts/data/models/comment_model.dart';
import 'package:flutter_challenge/src/features/posts/data/models/post_model.dart';
import 'package:oxidized/oxidized.dart';

abstract class PostRepository {
  Future<Result<List<PostModel>, Exception>> getPosts();
  Future<Result<List<CommentModel>, Exception>> getComments(int postId);
}
