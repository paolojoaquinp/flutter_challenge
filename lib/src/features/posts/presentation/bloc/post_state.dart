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
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;

  const PostLoaded({
    required this.posts,
    required this.filteredPosts,
    this.query = '',
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [posts, filteredPosts, query, hasReachedMax, currentPage, isLoadingMore];

  PostLoaded copyWith({
    List<PostModel>? posts,
    List<PostModel>? filteredPosts,
    String? query,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      filteredPosts: filteredPosts ?? this.filteredPosts,
      query: query ?? this.query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}
