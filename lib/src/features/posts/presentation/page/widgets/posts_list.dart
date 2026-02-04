
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/src/core/design/tokens/palette.dart';
import 'package:flutter_challenge/src/features/post_detail/presenter/page/post_detail_page.dart';
import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_challenge/src/features/posts/presentation/page/widgets/post_card.dart';
import 'package:google_fonts/google_fonts.dart';

class PostsList extends StatefulWidget {
  final bool isFavorites;

  const PostsList({super.key, required this.isFavorites});

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final Set<int> _animatedIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PostError) {
          return Center(child: Text(state.message));
        } else if (state is PostLoaded) {
          final posts = widget.isFavorites
              ? state.posts.where((p) => p.isLiked).toList()
              : state.filteredPosts;

          if (posts.isEmpty) {
            return Center(
              child: Text(
                widget.isFavorites ? 'No tienes favoritos aún.' : 'No se encontraron posts.',
                style: GoogleFonts.poppins(color: Palette.textSecondary),
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!widget.isFavorites && scrollInfo is ScrollUpdateNotification) {
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8) {
                  context.read<PostBloc>().add(const LoadMorePostsEvent());
                }
              }
              return true;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(const RefreshPostsEvent());
                // Wait for the state to transition out of loading or just a bit of time
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                itemCount: posts.length + (state.isLoadingMore && !widget.isFavorites ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final post = posts[index];
                  final bool shouldAnimate = index < 5 && !_animatedIds.contains(post.id) && !widget.isFavorites;

                  final card = PostCard(
                    post: post,
                    onTap: () {
                      final postBloc = context.read<PostBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: postBloc,
                            child: PostDetailScreen(post: post),
                          ),
                        ),
                      );
                    },
                    onLikeToggle: () {
                      context.read<PostBloc>().add(ToggleLikeEvent(post.id));
                    },
                  );

                  if (!shouldAnimate) {
                    return card;
                  }

                  // Record that this ID has been animated
                  _animatedIds.add(post.id);

                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 900 + (index * 350)),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: card,
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}