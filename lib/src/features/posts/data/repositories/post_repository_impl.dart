import 'package:dio/dio.dart';
import 'package:oxidized/oxidized.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../../domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final Dio _dio;
  
  // In-memory persistent "likes" for the session
  final Set<int> _likedPostIds = {};

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
    try {
      final response = await _dio.get('/posts');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final posts = data.map((json) {
          final post = PostModel.fromJson(json);
          return post.copyWith(isLiked: _likedPostIds.contains(post.id));
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

  void toggleLike(int postId) {
    if (_likedPostIds.contains(postId)) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }
  }
  
  bool isLiked(int postId) => _likedPostIds.contains(postId);
}
