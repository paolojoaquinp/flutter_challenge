class PostEntity {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool isLiked;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.isLiked = false,
  });

  PostEntity copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    bool? isLiked,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
