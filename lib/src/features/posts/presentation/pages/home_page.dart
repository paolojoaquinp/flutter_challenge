import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_bloc.dart';
import '../widgets/post_card.dart';
import '../widgets/search_bar_widget.dart';
import 'post_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Posts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          SearchBarWidget(
            onChanged: (query) {
              context.read<PostBloc>().add(SearchPostsEvent(query));
            },
          ),
          Expanded(
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PostError) {
                  return Center(child: Text(state.message));
                } else if (state is PostLoaded) {
                  if (state.filteredPosts.isEmpty) {
                    return const Center(child: Text('No se encontraron posts.'));
                  }
                  return ListView.builder(
                    itemCount: state.filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = state.filteredPosts[index];
                      return PostCard(
                        post: post,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailPage(post: post),
                            ),
                          );
                        },
                        onLikeToggle: () {
                          context.read<PostBloc>().add(ToggleLikeEvent(post.id));
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
