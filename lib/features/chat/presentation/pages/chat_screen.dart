import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import '../../../../core/network/socket_service.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String lawyerName;
  final String currentUserId;
  final String receiverId;

  const ChatScreen({
    super.key, 
    this.lawyerName = "د. أحمد علي",
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        socketService: SocketService(),
        currentUserId: widget.currentUserId,
        receiverId: widget.receiverId,
      )..initConnection('ws://YOUR_BACKEND_URL'), // Placeholder for backend URL
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          backgroundColor: context.cardBg,
          elevation: 1,
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white12,
                child: Icon(Icons.person, color: Colors.white70),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lawyerName,
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "نشط الآن",
                    style: context.text.labelSmall?.copyWith(color: Colors.green, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
            IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.golden));
                  } else if (state is ChatLoaded) {
                    if (state.messages.isEmpty) {
                      return Center(child: Text("لا توجد رسائل سابقة. ابدأ المحادثة الآن!", style: TextStyle(color: context.textSecondary)));
                    }
                    return ListView.builder(
                      reverse: true, // Show latest message at the bottom
                      padding: const EdgeInsets.all(20),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(message: state.messages[index]);
                      },
                    );
                  } else if (state is ChatError) {
                    return Center(child: Text("حدث خطأ: ${state.message}", style: const TextStyle(color: Colors.red)));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Builder(
              builder: (context) {
                return Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 24.h),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    border: Border(top: BorderSide(color: context.divColor, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: AppColors.cream),
                        onPressed: () {
                           // Implement file/image picker here when requested
                        },
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E0E06), // Very dark for input
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.divColor),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: AppColors.cream),
                            decoration: const InputDecoration(
                              hintText: "اكتب رسالتك...",
                              hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (_messageController.text.trim().isNotEmpty) {
                            context.read<ChatCubit>().sendMessage(_messageController.text);
                            _messageController.clear();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
