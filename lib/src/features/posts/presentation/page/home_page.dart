import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/src/core/design/tokens/palette.dart';
import 'package:flutter_challenge/src/features/post_detail/presenter/page/post_detail_page.dart';
import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_challenge/src/features/posts/presentation/widgets/post_card.dart';
import 'package:flutter_challenge/src/features/posts/presentation/widgets/search_bar_widget.dart';
import 'package:google_fonts/google_fonts.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<double> _scrollFactorNotifier = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _scrollFactorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Palette.background,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification && notification.depth == 0) {
              final newScrollFactor = (notification.metrics.pixels / 100.0).clamp(0.0, 1.0);
              _scrollFactorNotifier.value = newScrollFactor;
            }
            return true;
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 110.0,
                  pinned: true,
                  backgroundColor: Palette.cardBackground,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    expandedTitleScale: 1.0,
                    titlePadding: EdgeInsets.zero,
                    title: ValueListenableBuilder<double>(
                      valueListenable: _scrollFactorNotifier,
                      builder: (context, factor, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Social Feed',
                                style: GoogleFonts.poppins(
                                  fontSize: lerpDouble(32, 20, factor),
                                  fontWeight: FontWeight.bold,
                                  color: Palette.textBody,
                                ),
                              ),
                              if (factor < 0.5)
                                Opacity(
                                  opacity: (1.0 - factor * 2).clamp(0.0, 1.0),
                                  child: Text(
                                    'Bienvenido de vuelta',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Palette.textSecondary,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Palette.cardBackground,
                    padding: EdgeInsets.all(16),
                    child: SearchBarWidget(
                      onChanged: (query) {
                        context.read<PostBloc>().add(SearchPostsEvent(query));
                      },
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: Palette.textBody,
                      unselectedLabelColor: Palette.textSecondary,
                      indicatorColor: Palette.accent,
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      tabs: const [
                        Tab(text: 'Feed'),
                        Tab(text: 'Favoritos'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: const TabBarView(
              children: [
                _PostsList(isFavorites: false),
                _PostsList(isFavorites: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  final bool isFavorites;

  const _PostsList({required this.isFavorites});

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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Palette.cardBackground,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
