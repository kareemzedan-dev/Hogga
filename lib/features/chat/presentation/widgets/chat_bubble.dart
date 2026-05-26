import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import '../../data/models/message_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? context.cardBg : const Color(0xFF331D11),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? Border.all(color: context.divColor) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachmentType == AttachmentType.image && message.attachmentUrl != null)
               Padding(
                 padding: const EdgeInsets.only(bottom: 8.0),
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(8),
                   child: CachedNetworkImage(
                     imageUrl: message.attachmentUrl!,
                     placeholder: (context, url) => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                     errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white54, size: 40),
                   ),
                 ),
               )
            else if (message.attachmentType == AttachmentType.file && message.attachmentUrl != null)
               Padding(
                 padding: const EdgeInsets.only(bottom: 8.0),
                 child: Row(
                   children: [
                     const Icon(Icons.insert_drive_file, color: AppColors.cream),
                     const SizedBox(width: 8),
                     const Expanded(child: Text("ملف مرفق", style: TextStyle(color: AppColors.cream))),
                   ],
                 ),
               ),

            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: context.text.bodySmall?.copyWith(
                  color: AppColors.cream,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}",
                style: context.text.labelSmall?.copyWith(
                  color: Colors.white54,
                  fontSize: 9,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
