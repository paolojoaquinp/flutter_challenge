part of 'post_detail_bloc.dart';

abstract class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

class PostDetailInitial extends PostDetailState {
  const PostDetailInitial();
}

class PostDetailLoading extends PostDetailState {
  const PostDetailLoading();
}

class PostDetailLoaded extends PostDetailState {
  final List<CommentEntity> comments;
  const PostDetailLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class PostDetailError extends PostDetailState {
  final String message;
  const PostDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
