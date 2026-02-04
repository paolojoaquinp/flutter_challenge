import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/src/features/posts/data/models/comment_model.dart';
import 'package:flutter_challenge/src/features/posts/data/models/post_model.dart';
import 'package:flutter_challenge/src/features/posts/data/repositories/post_repository_impl.dart';
import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_detail_bloc.dart';
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
    return BlocListener<PostDetailBloc, PostDetailState>(
      listener: (context, state) {
        // Handle state changes if necessary (e.g., showing a SnackBar on error)
      },
      child: _Body(post: post),
    );
  }
}

class _Body extends StatelessWidget {
  final PostModel post;
  const _Body({required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailBloc, PostDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Palette.background,
          appBar: AppBar(
            title: const Text('Detalle del Post'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Palette.textBody,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post.body,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Palette.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    'COMENTARIOS',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Palette.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _CommentsContent(state: state),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentsContent extends StatelessWidget {
  final PostDetailState state;
  const _CommentsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is PostDetailLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is PostDetailLoaded) {
      final comments = (state as PostDetailLoaded).comments;
      if (comments.isEmpty) {
        return const Center(child: Text('No hay comentarios.'));
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comments.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final comment = comments[index];
          return _CommentTile(comment: comment);
        },
      );
    }

    if (state is PostDetailError) {
      return Center(child: Text('Error: ${(state as PostDetailError).message}'));
    }

    return const SizedBox.shrink();
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment.email,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            comment.body,
            style: const TextStyle(
              color: Palette.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
