part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class LoadPostsEvent extends PostEvent {
  const LoadPostsEvent();
}

class SearchPostsEvent extends PostEvent {
  final String query;
  const SearchPostsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleLikeEvent extends PostEvent {
  final int postId;
  const ToggleLikeEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}
