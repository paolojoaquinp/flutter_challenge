import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_challenge/src/shared/data/models/post_model.dart';
import 'package:flutter_challenge/src/shared/domain/repositories/post_repository.dart';
import 'package:flutter_challenge/src/shared/data/repositories/post_repository_impl.dart';
import 'package:flutter_challenge/src/core/platform/notification_api.g.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  final NotificationApi nativeApi;

  PostBloc({
    required this.postRepository,
    required this.nativeApi,
  }) : super(const PostInitial()) {
    _initializeNotifications();
    on<LoadPostsEvent>(_onLoadPosts);
    on<LoadMorePostsEvent>(_onLoadMorePosts);
    on<RefreshPostsEvent>(_onRefreshPosts);
    on<SearchPostsEvent>(
      _onSearchPosts,
      transformer: restartable(),
    );
    on<ToggleLikeEvent>(_onToggleLike);
  }

  void _initializeNotifications() {
    nativeApi.requestNotificationPermission();
  }

  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());
    final result = await postRepository.getPaginatedPosts(page: 1, limit: 10);
    
    result.when(
      ok: (posts) => emit(PostLoaded(
        posts: posts,
        filteredPosts: posts,
        currentPage: 1,
        hasReachedMax: posts.length < 10,
      )),
      err: (error) => emit(PostError(error.toString())),
    );
  }

  Future<void> _onLoadMorePosts(
    LoadMorePostsEvent event,
    Emitter<PostState> emit,
  ) async {
    if (state is! PostLoaded) return;
    final currentState = state as PostLoaded;
    
    if (currentState.hasReachedMax || currentState.isLoadingMore || currentState.query.isNotEmpty) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await postRepository.getPaginatedPosts(page: nextPage, limit: 10);

    result.when(
      ok: (newPosts) {
        if (newPosts.isEmpty) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          final updatedPosts = List<PostModel>.from(currentState.posts)..addAll(newPosts);
          emit(currentState.copyWith(
            posts: updatedPosts,
            filteredPosts: updatedPosts, // Assuming search is empty as per check above
            currentPage: nextPage,
            hasReachedMax: newPosts.length < 10,
            isLoadingMore: false,
          ));
        }
      },
      err: (error) => emit(currentState.copyWith(isLoadingMore: false)),
    );
  }

  Future<void> _onRefreshPosts(
    RefreshPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    add(const LoadPostsEvent());
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
      
      if (postRepository is PostRepositoryImpl) {
        (postRepository as PostRepositoryImpl).toggleLike(event.postId);
      }

      final updatedPosts = currentState.posts.map<PostModel>((post) {
        if (post.id == event.postId) {
          final newIsLiked = !post.isLiked;
          if (newIsLiked) {
             nativeApi.showLikeNotification(
               NotificationPayload(
                 postId: post.id,
                 title: 'Te ha gustado:',
               ),
             );
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
