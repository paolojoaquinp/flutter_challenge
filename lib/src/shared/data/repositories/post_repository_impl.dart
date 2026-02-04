import 'package:dio/dio.dart';
import 'package:oxidized/oxidized.dart';
import 'package:flutter_challenge/src/core/helpers/hive_helper.dart';
import 'package:flutter_challenge/src/shared/domain/repositories/post_repository.dart';
import 'package:flutter_challenge/src/shared/data/models/post_model.dart';
import 'package:flutter_challenge/src/shared/data/models/comment_model.dart';


class PostRepositoryImpl implements PostRepository {
  final Dio _dio;
  final HiveHelper _hiveHelper = HiveHelper();
  
  PostRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'FlutterChallenge/1.0',
      },
    ),
  );

  @override
  Future<Result<List<PostModel>, Exception>> getPosts() async {
    return getPaginatedPosts(page: 1, limit: 100);
  }

  @override
  Future<Result<List<PostModel>, Exception>> getPaginatedPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {
          '_page': page,
          '_limit': limit,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final posts = data.map((json) {
          final post = PostModel.fromJson(json);
          return post.copyWith(isLiked: _hiveHelper.isLiked(post.id));
        }).toList();
        return Ok(posts);
      } else {
        return Err(Exception('Failed to load posts: ${response.statusCode}'));
      }
    } catch (e) {
      return Err(Exception('Failed to load posts: $e'));
    }
  }

  @override
  Future<Result<List<CommentModel>, Exception>> getComments(int postId) async {
    try {
      final response = await _dio.get('/posts/$postId/comments');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final comments = data.map((json) => CommentModel.fromJson(json)).toList();
        return Ok(comments);
      } else {
        return Err(Exception('Failed to load comments: ${response.statusCode}'));
      }
    } catch (e) {
      return Err(Exception('Failed to load comments: $e'));
    }
  }

  Future<void> toggleLike(int postId) async {
    if (_hiveHelper.isLiked(postId)) {
      await _hiveHelper.removeLike(postId);
    } else {
      await _hiveHelper.addLike(postId);
    }
  }
  
  bool isLiked(int postId) => _hiveHelper.isLiked(postId);
}
