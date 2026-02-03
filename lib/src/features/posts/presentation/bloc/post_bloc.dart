import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_challenge/src/features/posts/data/models/post_model.dart';
import 'package:flutter_challenge/src/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_challenge/src/features/posts/data/repositories/post_repository_impl.dart';
import 'package:flutter_challenge/src/core/utils/native_api.g.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  final NativeNotificationsApi nativeApi;

  PostBloc({
    required this.postRepository,
    required this.nativeApi,
  }) : super(const PostInitial()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<SearchPostsEvent>(
      _onSearchPosts,
      transformer: restartable(),
    );
    on<ToggleLikeEvent>(_onToggleLike);
  }

  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());
    final result = await postRepository.getPosts();
    
    result.when(
      ok: (posts) => emit(PostLoaded(
        posts: posts,
        filteredPosts: posts,
      )),
      err: (error) => emit(PostError(error.toString())),
    );
  }

  void _onSearchPosts(
    SearchPostsEvent event,
    Emitter<PostState> emit,
  ) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final query = event.query.toLowerCase();
      
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredPosts: currentState.posts,
          query: '',
        ));
      } else {
        final filtered = currentState.posts.where((post) {
          return post.title.toLowerCase().contains(query) ||
                 post.body.toLowerCase().contains(query);
        }).toList();
        
        emit(currentState.copyWith(
          filteredPosts: filtered,
          query: event.query,
        ));
      }
    }
  }

  void _onToggleLike(
    ToggleLikeEvent event,
    Emitter<PostState> emit,
  ) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      
      // Update repository (in-memory persistent state)
      if (postRepository is PostRepositoryImpl) {
        (postRepository as PostRepositoryImpl).toggleLike(event.postId);
      }

      // Update current state items
      final updatedPosts = currentState.posts.map<PostModel>((post) {
        if (post.id == event.postId) {
          final newIsLiked = !post.isLiked;
          if (newIsLiked) {
             // Trigger native notification if liked
             nativeApi.showNotification(NotificationPayload(
               id: post.id,
               title: 'Te ha gustado:',
               body: post.title,
             ));
          }
          return post.copyWith(isLiked: newIsLiked);
        }
        return post;
      }).toList();

      final updatedFiltered = currentState.filteredPosts.map<PostModel>((post) {
         if (post.id == event.postId) {
          return post.copyWith(isLiked: !post.isLiked);
        }
        return post;
      }).toList();

      emit(currentState.copyWith(
        posts: updatedPosts,
        filteredPosts: updatedFiltered,
      ));
    }
  }
}
