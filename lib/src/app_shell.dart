import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'shared/data/repositories/post_repository_impl.dart';
import 'features/posts/presentation/bloc/post_bloc.dart';
import 'features/posts/presentation/page/home_page.dart';
import 'core/utils/native_api.g.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PostBloc(
            postRepository: PostRepositoryImpl(),
            nativeApi: NativeNotificationsApi(),
          )..add(const LoadPostsEvent()),
        ),
      ],
      child: const HomePage(),
    );
  }
}
