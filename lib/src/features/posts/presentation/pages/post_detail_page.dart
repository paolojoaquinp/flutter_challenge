import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/src/features/posts/data/models/post_model.dart';
import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_challenge/src/core/design/tokens/palette.dart';

class PostDetailPage extends StatelessWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        title: const Text('Detalle del Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              final currentPost = (state is PostLoaded)
                  ? state.posts.firstWhere((p) => p.id == post.id, orElse: () => post)
                  : post;
              return IconButton(
                icon: Icon(
                  currentPost.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: currentPost.isLiked ? Colors.red : Palette.textSecondary,
                ),
                onPressed: () {
                  context.read<PostBloc>().add(ToggleLikeEvent(post.id));
                },
              );
            },
          ),
        ],
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
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'COMENTARIOS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Palette.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            FutureBuilder(
              future: context.read<PostBloc>().postRepository.getComments(post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                
                if (snapshot.hasData) {
                  final result = snapshot.data!;
                  return result.when(
                    ok: (comments) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
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
                        },
                      );
                    },
                    err: (error) => Center(child: Text('Error: $error')),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
