import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static final HiveHelper _singleton = HiveHelper._internal();
  late Box box;

  factory HiveHelper() {
    return _singleton;
  }

  HiveHelper._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('likes');
  }

  Future<void> addLike(int postId) async {
    List<int> likes = getLikedIds();
    if (!likes.contains(postId)) {
      likes.add(postId);
      await box.put('likedIds', likes);
    }
  }

  Future<void> removeLike(int postId) async {
    List<int> likes = getLikedIds();
    likes.remove(postId);
    await box.put('likedIds', likes);
  }

  List<int> getLikedIds() {
    final dynamic data = box.get('likedIds', defaultValue: <int>[]);
    if (data is List) {
      return data.cast<int>();
    }
    return <int>[];
  }

  bool isLiked(int postId) {
    return getLikedIds().contains(postId);
  }
}
