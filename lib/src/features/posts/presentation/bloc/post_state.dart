part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostLoaded extends PostState {
  final List<PostModel> posts;
  final List<PostModel> filteredPosts;
  final String query;

  const PostLoaded({
    required this.posts,
    required this.filteredPosts,
    this.query = '',
  });

  @override
  List<Object?> get props => [posts, filteredPosts, query];

  PostLoaded copyWith({
    List<PostModel>? posts,
    List<PostModel>? filteredPosts,
    String? query,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      filteredPosts: filteredPosts ?? this.filteredPosts,
      query: query ?? this.query,
    );
  }
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}
