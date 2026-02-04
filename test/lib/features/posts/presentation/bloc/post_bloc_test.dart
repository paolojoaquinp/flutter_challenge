import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxidized/oxidized.dart';

import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_challenge/src/shared/domain/repositories/post_repository.dart';
import 'package:flutter_challenge/src/shared/data/models/post_model.dart';
import 'package:flutter_challenge/src/core/platform/notification_api.g.dart';

// Mock classes
class MockPostRepository extends Mock implements PostRepository {}

class MockNotificationApi extends Mock implements NotificationApi {}

class FakeNotificationPayload extends Fake implements NotificationPayload {}

void main() {
  late MockPostRepository mockPostRepository;
  late MockNotificationApi mockNotificationApi;

  // Sample test data
  final testPosts = [
    const PostModel(id: 1, userId: 1, title: 'Test Post 1', body: 'Body 1'),
    const PostModel(id: 2, userId: 1, title: 'Test Post 2', body: 'Body 2'),
    const PostModel(id: 3, userId: 2, title: 'Another Post', body: 'Body 3'),
  ];

  final paginatedPosts = [
    const PostModel(id: 4, userId: 2, title: 'Post 4', body: 'Body 4'),
    const PostModel(id: 5, userId: 2, title: 'Post 5', body: 'Body 5'),
  ];

  setUpAll(() {
    registerFallbackValue(FakeNotificationPayload());
  });

  setUp(() {
    mockPostRepository = MockPostRepository();
    mockNotificationApi = MockNotificationApi();

    // Default stub for requestNotificationPermission (called in constructor)
    when(() => mockNotificationApi.requestNotificationPermission())
        .thenAnswer((_) async => true);
  });

  PostBloc createBloc() => PostBloc(
        postRepository: mockPostRepository,
        nativeApi: mockNotificationApi,
      );

  group('PostBloc', () {
    test('initial state should be PostInitial', () {
      final bloc = createBloc();
      expect(bloc.state, const PostInitial());
      bloc.close();
    });

    group('LoadPostsEvent', () {
      blocTest<PostBloc, PostState>(
        'emits [PostLoading, PostLoaded] when getPaginatedPosts succeeds',
        build: () {
          when(() => mockPostRepository.getPaginatedPosts(page: 1, limit: 10))
              .thenAnswer((_) async => Ok(testPosts));
          return createBloc();
        },
        act: (bloc) => bloc.add(const LoadPostsEvent()),
        expect: () => [
          const PostLoading(),
          PostLoaded(
            posts: testPosts,
            filteredPosts: testPosts,
            currentPage: 1,
            hasReachedMax: true,
          ),
        ],
        verify: (_) {
          verify(() => mockPostRepository.getPaginatedPosts(page: 1, limit: 10))
              .called(1);
        },
      );

      blocTest<PostBloc, PostState>(
        'emits [PostLoading, PostError] when getPaginatedPosts fails',
        build: () {
          when(() => mockPostRepository.getPaginatedPosts(page: 1, limit: 10))
              .thenAnswer((_) async => Err(Exception('Network error')));
          return createBloc();
        },
        act: (bloc) => bloc.add(const LoadPostsEvent()),
        expect: () => [
          const PostLoading(),
          isA<PostError>(),
        ],
      );

      blocTest<PostBloc, PostState>(
        'sets hasReachedMax to false when posts count equals limit',
        build: () {
          // 10 posts - means there might be more
          final tenPosts = List.generate(
            10,
            (i) => PostModel(
              id: i,
              userId: 1,
              title: 'Post $i',
              body: 'Body $i',
            ),
          );
          when(() => mockPostRepository.getPaginatedPosts(page: 1, limit: 10))
              .thenAnswer((_) async => Ok(tenPosts));
          return createBloc();
        },
        act: (bloc) => bloc.add(const LoadPostsEvent()),
        expect: () => [
          const PostLoading(),
          isA<PostLoaded>().having(
            (state) => state.hasReachedMax,
            'hasReachedMax',
            false,
          ),
        ],
      );
    });

    group('LoadMorePostsEvent', () {
      blocTest<PostBloc, PostState>(
        'appends posts and increments page on success',
        build: () {
          when(() => mockPostRepository.getPaginatedPosts(page: 1, limit: 10))
              .thenAnswer((_) async => Ok(testPosts));
          when(() => mockPostRepository.getPaginatedPosts(page: 2, limit: 10))
              .thenAnswer((_) async => Ok(paginatedPosts));
          return createBloc();
        },
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: testPosts,
          currentPage: 1,
          hasReachedMax: false,
        ),
        act: (bloc) => bloc.add(const LoadMorePostsEvent()),
        expect: () => [
          // Loading more state
          PostLoaded(
            posts: testPosts,
            filteredPosts: testPosts,
            currentPage: 1,
            hasReachedMax: false,
            isLoadingMore: true,
          ),
          // Loaded with new posts
          PostLoaded(
            posts: [...testPosts, ...paginatedPosts],
            filteredPosts: [...testPosts, ...paginatedPosts],
            currentPage: 2,
            hasReachedMax: true,
            isLoadingMore: false,
          ),
        ],
      );

      blocTest<PostBloc, PostState>(
        'does nothing when hasReachedMax is true',
        build: () => createBloc(),
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: testPosts,
          currentPage: 1,
          hasReachedMax: true,
        ),
        act: (bloc) => bloc.add(const LoadMorePostsEvent()),
        expect: () => [],
      );

      blocTest<PostBloc, PostState>(
        'does nothing when already loading more',
        build: () => createBloc(),
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: testPosts,
          currentPage: 1,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        act: (bloc) => bloc.add(const LoadMorePostsEvent()),
        expect: () => [],
      );

      blocTest<PostBloc, PostState>(
        'does nothing when search query is active',
        build: () => createBloc(),
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: testPosts,
          currentPage: 1,
          hasReachedMax: false,
          query: 'search term',
        ),
        act: (bloc) => bloc.add(const LoadMorePostsEvent()),
        expect: () => [],
      );
    });

    group('SearchPostsEvent', () {
      blocTest<PostBloc, PostState>(
        'filters posts based on query matching title',
        build: () => createBloc(),
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: testPosts,
          currentPage: 1,
          hasReachedMax: true,
        ),
        act: (bloc) => bloc.add(const SearchPostsEvent('Another')),
        expect: () => [
          PostLoaded(
            posts: testPosts,
            filteredPosts: [testPosts[2]], // Only 'Another Post' matches
            currentPage: 1,
            hasReachedMax: true,
            query: 'Another',
          ),
        ],
      );

      blocTest<PostBloc, PostState>(
        'filters posts based on query matching body',
        build: () => createBloc(),
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: testPosts,
          currentPage: 1,
          hasReachedMax: true,
        ),
        act: (bloc) => bloc.add(const SearchPostsEvent('Body 1')),
        expect: () => [
          PostLoaded(
            posts: testPosts,
            filteredPosts: [testPosts[0]],
            currentPage: 1,
            hasReachedMax: true,
            query: 'Body 1',
          ),
        ],
      );

      blocTest<PostBloc, PostState>(
        'resets to full list when query is empty',
        build: () => createBloc(),
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: [testPosts[0]],
          currentPage: 1,
          hasReachedMax: true,
          query: 'Test',
        ),
        act: (bloc) => bloc.add(const SearchPostsEvent('')),
        expect: () => [
          PostLoaded(
            posts: testPosts,
            filteredPosts: testPosts,
            currentPage: 1,
            hasReachedMax: true,
            query: '',
          ),
        ],
      );

      blocTest<PostBloc, PostState>(
        'search is case insensitive',
        build: () => createBloc(),
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: testPosts,
          currentPage: 1,
          hasReachedMax: true,
        ),
        act: (bloc) => bloc.add(const SearchPostsEvent('TEST')),
        expect: () => [
          isA<PostLoaded>().having(
            (state) => state.filteredPosts.length,
            'filteredPosts length',
            2, // 'Test Post 1' and 'Test Post 2'
          ),
        ],
      );
    });

    group('ToggleLikeEvent', () {
      blocTest<PostBloc, PostState>(
        'toggles isLiked from false to true and shows notification',
        build: () {
          when(() => mockNotificationApi.showLikeNotification(any()))
              .thenAnswer((_) async {});
          return createBloc();
        },
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: testPosts,
          currentPage: 1,
          hasReachedMax: true,
        ),
        act: (bloc) => bloc.add(const ToggleLikeEvent(1)),
        expect: () => [
          isA<PostLoaded>().having(
            (state) => state.posts.firstWhere((p) => p.id == 1).isLiked,
            'isLiked for post 1',
            true,
          ),
        ],
        verify: (_) {
          verify(() => mockNotificationApi.showLikeNotification(any()))
              .called(1);
        },
      );

      blocTest<PostBloc, PostState>(
        'toggles isLiked from true to false without notification',
        build: () => createBloc(),
        seed: () {
          final postsWithLike = [
            testPosts[0].copyWith(isLiked: true),
            testPosts[1],
            testPosts[2],
          ];
          return PostLoaded(
            posts: postsWithLike,
            filteredPosts: postsWithLike,
            currentPage: 1,
            hasReachedMax: true,
          );
        },
        act: (bloc) => bloc.add(const ToggleLikeEvent(1)),
        expect: () => [
          isA<PostLoaded>().having(
            (state) => state.posts.firstWhere((p) => p.id == 1).isLiked,
            'isLiked for post 1',
            false,
          ),
        ],
        verify: (_) {
          verifyNever(() => mockNotificationApi.showLikeNotification(any()));
        },
      );

      blocTest<PostBloc, PostState>(
        'updates both posts and filteredPosts lists',
        build: () {
          when(() => mockNotificationApi.showLikeNotification(any()))
              .thenAnswer((_) async {});
          return createBloc();
        },
        seed: () => PostLoaded(
          posts: testPosts,
          filteredPosts: [testPosts[0], testPosts[1]],
          currentPage: 1,
          hasReachedMax: true,
          query: 'Test',
        ),
        act: (bloc) => bloc.add(const ToggleLikeEvent(1)),
        expect: () => [
          isA<PostLoaded>()
              .having(
                (state) => state.posts.firstWhere((p) => p.id == 1).isLiked,
                'isLiked in posts',
                true,
              )
              .having(
                (state) =>
                    state.filteredPosts.firstWhere((p) => p.id == 1).isLiked,
                'isLiked in filteredPosts',
                true,
              ),
        ],
      );
    });

    group('RefreshPostsEvent', () {
      blocTest<PostBloc, PostState>(
        'triggers LoadPostsEvent',
        build: () {
          when(() => mockPostRepository.getPaginatedPosts(page: 1, limit: 10))
              .thenAnswer((_) async => Ok(testPosts));
          return createBloc();
        },
        act: (bloc) => bloc.add(const RefreshPostsEvent()),
        expect: () => [
          const PostLoading(),
          PostLoaded(
            posts: testPosts,
            filteredPosts: testPosts,
            currentPage: 1,
            hasReachedMax: true,
          ),
        ],
      );
    });
  });
}
