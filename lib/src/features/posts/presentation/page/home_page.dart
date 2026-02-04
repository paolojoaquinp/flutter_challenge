import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/src/core/design/tokens/palette.dart'; 
import 'package:flutter_challenge/src/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_challenge/src/features/posts/presentation/page/widgets/posts_list.dart';
import 'package:flutter_challenge/src/features/posts/presentation/page/widgets/search_bar_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_challenge/src/core/utils/connectivity/connectivity_bloc.dart';


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
        body: BlocListener<ConnectivityCubit, ConnectivityStatus>(
          listener: (context, status) {
            final isOffline = status == ConnectivityStatus.offline;
            if (isOffline) {
              _showConnectivitySnackBar(context, isOffline: true);
            } else {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              _showConnectivitySnackBar(context, isOffline: false);
            }
          },
          child: NotificationListener<ScrollNotification>(
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
                      padding: const EdgeInsets.all(16),
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
                  PostsList(isFavorites: false),
                  PostsList(isFavorites: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showConnectivitySnackBar(BuildContext context, {required bool isOffline}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOffline ? Icons.wifi_off : Icons.wifi,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              isOffline ? 'Sin conexión a internet' : 'Conexión restaurada',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: isOffline ? Colors.redAccent : Colors.green,
        duration: isOffline ? const Duration(days: 1) : const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
