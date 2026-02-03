import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/src/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_challenge/src/features/shared/domain/entities/comment.dart';

part 'post_detail_event.dart';
part 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final PostRepository postRepository;

  PostDetailBloc({required this.postRepository}) : super(const PostDetailInitial()) {
    on<LoadPostCommentsEvent>(_onLoadPostComments);
  }

  Future<void> _onLoadPostComments(
    LoadPostCommentsEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(const PostDetailLoading());
    final result = await postRepository.getComments(event.postId);
    
    result.when(
      ok: (comments) => emit(PostDetailLoaded(comments: comments)),
      err: (error) => emit(PostDetailError(error.toString())),
    );
  }
}
