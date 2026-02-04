import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_challenge/src/shared/data/models/comment_model.dart';
import 'package:flutter_challenge/src/shared/data/models/post_model.dart';
import 'package:flutter_challenge/src/shared/data/repositories/post_repository_impl.dart';
import 'package:flutter_challenge/src/features/post_detail/presenter/bloc/post_detail_bloc.dart';
import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_challenge/src/core/design/tokens/palette.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailBloc>(
      create: (context) => PostDetailBloc(
        postRepository: PostRepositoryImpl(),
      )..add(LoadPostCommentsEvent(post.id)),
      child: _Page(post: post),
    );
  }
}

class _Page extends StatelessWidget {
  final PostModel post;
  const _Page({required this.post});

  @override
  Widget build(BuildContext context) {
    return _Body(post: post);
  }
}

class _Body extends StatelessWidget {
  final PostModel post;
  const _Body({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Palette.textBody),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalle del Post',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Palette.textBody,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              bool isLiked = false;
              if (state is PostLoaded) {
                final currentPost = state.posts.firstWhere(
                  (p) => p.id == post.id,
                  orElse: () => post,
                );
                isLiked = currentPost.isLiked;
              }
              return IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Palette.textBody,
                ),
                onPressed: () {
                  context.read<PostBloc>().add(ToggleLikeEvent(post.id));
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildPostHeader(post),
          ),
          SliverToBoxAdapter(
            child: _buildSectionHeader('COMENTARIOS'),
          ),
          // Comments section
          BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              if (state is PostDetailLoading) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (state is PostDetailLoaded) {
                final comments = state.comments;
                if (comments.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No hay comentarios.',
                          style: Palette.p.copyWith(color: Palette.textSecondary),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comment = comments[index];
                      return Column(
                        children: [
                          _buildCommentTile(comment),
                          if (index < comments.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Divider(
                                height: 1,
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                        ],
                      );
                    },
                    childCount: comments.length,
                  ),
                );
              }

              if (state is PostDetailError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Error: ${state.message}'),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(PostModel post) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: Palette.h1,
          ),
          const SizedBox(height: 16),
          Text(
            post.body,
            style: Palette.p.copyWith(
              color: Palette.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Palette.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Palette.brandPrimary.withValues(alpha: 0.1),
                child: Text(
                  comment.name.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Palette.brandPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.name,
                      style: Palette.b2.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      comment.email,
                      style: GoogleFonts.poppins(
                        color: Palette.brandPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.body,
            style: Palette.p.copyWith(
              color: Palette.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
