import 'package:flutter/material.dart';
import 'package:flutter_challenge/src/features/posts/data/models/post_model.dart';
import '../../../../core/design/tokens/palette.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          post.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Palette.textBody,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          post.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Palette.textSecondary),
        ),
        trailing: IconButton(
          icon: Icon(
            post.isLiked ? Icons.favorite : Icons.favorite_border,
            color: post.isLiked ? Colors.red : Palette.textSecondary,
          ),
          onPressed: onLikeToggle,
        ),
      ),
    );
  }
}
