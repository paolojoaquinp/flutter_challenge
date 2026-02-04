
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/src/core/design/tokens/palette.dart';
import 'package:flutter_challenge/src/features/post_detail/presenter/page/post_detail_page.dart';
import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_challenge/src/features/posts/presentation/page/widgets/post_card.dart';
import 'package:google_fonts/google_fonts.dart';

class PostsList extends StatelessWidget {
  final bool isFavorites;

  const PostsList({super.key, required this.isFavorites});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PostError) {
          return Center(child: Text(state.message));
        } else if (state is PostLoaded) {
          final posts = isFavorites
              ? state.posts.where((p) => p.isLiked).toList()
              : state.filteredPosts;

          if (posts.isEmpty) {
            return Center(
              child: Text(
                isFavorites ? 'No tienes favoritos aún.' : 'No se encontraron posts.',
                style: GoogleFonts.poppins(color: Palette.textSecondary),
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!isFavorites && scrollInfo is ScrollUpdateNotification) {
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
                itemCount: posts.length + (state.isLoadingMore && !isFavorites ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final post = posts[index];
                  return PostCard(
                    post: post,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(post: post),
                        ),
                      );
                    },
                    onLikeToggle: () {
                      context.read<PostBloc>().add(ToggleLikeEvent(post.id));
                    },
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