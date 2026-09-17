import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hogga/core/widgets/custom_network_image.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../cubit/lawyer_chat_messages_cubit.dart';
import '../../../../chat/data/models/chat_message_model.dart';
import '../../../../chat/presentation/cubit/chat_messages_state.dart';
import 'package:hogga/core/network/fcm_service.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/cases/domain/repositories/cases_repository.dart';
import 'package:hogga/features/lawyer/chat/presentation/cubit/lawyer_call_cubit.dart';
import 'package:hogga/features/lawyer/chat/presentation/pages/lawyer_agora_call_screen.dart';
import 'package:hogga/features/lawyer/consultations/domain/repositories/lawyer_consultations_repository.dart';
import 'package:hogga/injection_container.dart' as di;

class LawyerChatScreen extends StatefulWidget {
  final int chatRoomId;
  final String clientName;
  final String? clientPhoto;
  final String? caseTitle;
  final bool? isCall;
  final bool isVideo;

  const LawyerChatScreen({
    super.key,
    required this.chatRoomId,
    required this.clientName,
    this.clientPhoto,
    this.caseTitle,
    this.isCall,
    this.isVideo = false,
  });

  @override
  State<LawyerChatScreen> createState() => _LawyerChatScreenState();
}

class _LawyerChatScreenState extends State<LawyerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late bool _canCall;
  late bool _isVideo;

  @override
  void initState() {
    super.initState();
    FcmService.instance.activeChatRoomId = widget.chatRoomId;
    _scrollController.addListener(_onScroll);
    _canCall = widget.isCall ?? _detectCallFromTitle(widget.caseTitle);
    _isVideo = widget.isVideo;

    if (widget.isCall == null && !_canCall) {
      _resolveCallCapability();
    }
  }

  bool _detectCallFromTitle(String? text) {
    if (text == null) return false;
    final t = text.toLowerCase();
    return t.contains('مكالمة') ||
        t.contains('صوت') ||
        t.contains('فيديو') ||
        t.contains('call') ||
        t.contains('audio') ||
        t.contains('video') ||
        t.contains('immediate') ||
        t.contains('scheduled');
  }

  Future<void> _resolveCallCapability() async {
    try {
      if (di.sl.isRegistered<LawyerConsultationsRepository>()) {
        final consultationsResult =
            await di.sl<LawyerConsultationsRepository>().getConsultations();
        consultationsResult.fold((_) {}, (consultations) {
          for (final c in consultations) {
            if (c.chatInfo?.id == widget.chatRoomId && c.isCallType) {
              if (mounted) {
                setState(() {
                  _canCall = true;
                  _isVideo = c.isVideoCall;
                });
              }
              return;
            }
          }
        });
      }

      if (_canCall) return;

      if (di.sl.isRegistered<CasesRepository>()) {
        final casesResult =
            await di.sl<CasesRepository>().getCases(type: 'all');
        casesResult.fold((_) {}, (cases) {
          for (final c in cases) {
            if (c.chatRoomId == widget.chatRoomId) {
              final type = c.serviceType.toLowerCase();
              final isCall = type.contains('call') ||
                  type.contains('audio') ||
                  type.contains('video') ||
                  type.contains('صوت') ||
                  type.contains('مكالمة');
              if (isCall && mounted) {
                setState(() {
                  _canCall = true;
                  _isVideo =
                      type.contains('video') || type.contains('فيديو');
                });
              }
              return;
            }
          }
        });
      }
    } catch (_) {}
  }

  void _startCall() {
    final state = context.read<LawyerChatMessagesCubit>().state;
    String name = widget.clientName.isNotEmpty
        ? widget.clientName
        : AppStrings.client.tr(context);
    if (state is ChatMessagesLoaded &&
        state.counterparty != null &&
        state.counterparty!.name.isNotEmpty) {
      name = state.counterparty!.name;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<LawyerCallCubit>(),
          child: LawyerAgoraCallScreen(
            roomId: widget.chatRoomId,
            clientName: name,
            isVideo: _isVideo,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (FcmService.instance.activeChatRoomId == widget.chatRoomId) {
      FcmService.instance.activeChatRoomId = null;
    }
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<LawyerChatMessagesCubit>().loadMoreMessages();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _messageController.clear();
    try {
      await context.read<LawyerChatMessagesCubit>().sendMessage(message: text);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackbar.showError(
        context,
        message: AppStrings.failedToSendMessage.tr(context),
      );
    }
  }

  Future<void> _sendFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final path = result.files.first.path;
    if (path == null || !mounted) {
      return;
    }
    try {
      await context.read<LawyerChatMessagesCubit>().sendMessage(
        file: File(path),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackbar.showError(
        context,
        message: AppStrings.failedToSendFile.tr(context),
      );
    }
  }

  String? _cleanPhoto(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'null' ||
        trimmed.toLowerCase() == '**null**') {
      return null;
    }
    final markdownMatch = RegExp(r'\]\((.*?)\)').firstMatch(trimmed);
    return markdownMatch?.group(1) ?? trimmed;
  }

  Widget _buildAvatar(BuildContext context, String? photo) {
    final cleanPhoto = _cleanPhoto(photo);

    final fallback = CircleAvatar(
      radius: 18.r,
      backgroundColor: context.divColor,
      child: Icon(
        Icons.person,
        color: context.textSecondary,
        size: 20.sp,
      ),
    );

    if (cleanPhoto == null) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: CustomNetworkImage(
        imageUrl: cleanPhoto,
        width: 36.w,
        height: 36.w,
        fit: BoxFit.cover,
        errorWidget: fallback,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        elevation: 0.5,
        shadowColor: context.divColor,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl ||
                    Localizations.localeOf(context).languageCode == 'ar'
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: context.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<LawyerChatMessagesCubit, ChatMessagesState>(
          builder: (context, state) {
            String name = widget.clientName.isNotEmpty
                ? widget.clientName
                : AppStrings.client.tr(context);
            String? photo = widget.clientPhoto;

            if (state is ChatMessagesLoaded && state.counterparty != null) {
              if (state.counterparty!.name.isNotEmpty) {
                name = state.counterparty!.name;
              }
              if (state.counterparty!.photo != null &&
                  state.counterparty!.photo!.isNotEmpty) {
                photo = state.counterparty!.photo;
              }
            }

            return Row(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 10.w),
                  child: _buildAvatar(context, photo),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.caseTitle != null)
                        Text(
                          widget.caseTitle!,
                          style: context.text.labelSmall?.copyWith(
                            color: context.textSecondary,
                            fontSize: 9.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          if (_canCall) ...[
            IconButton(
              onPressed: _startCall,
              tooltip: _isVideo
                  ? AppStrings.videoCall.tr(context)
                  : AppStrings.voiceCall.tr(context),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: context.accentGolden.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: context.accentGolden.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _isVideo
                      ? Icons.videocam_rounded
                      : Icons.phone_in_talk_rounded,
                  color: context.accentGolden,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 4.w),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<LawyerChatMessagesCubit, ChatMessagesState>(
              builder: (context, state) {
                if (state is ChatMessagesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.golden),
                  );
                }

                if (state is ChatMessagesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 12.h),
                        Text(state.message),
                        TextButton(
                          onPressed: () => context
                              .read<LawyerChatMessagesCubit>()
                              .loadMessages(),
                          child: Text(AppStrings.retry.tr(context)),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ChatMessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64.sp,
                            color: context.textSecondary.withValues(alpha: 0.4),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            AppStrings.startConversationWithClient.tr(context),
                            style: context.text.bodyMedium?.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    itemCount:
                        state.messages.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.golden,
                            ),
                          ),
                        );
                      }
                      return _ChatBubble(message: state.messages[index]);
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          // Input bar
          BlocBuilder<LawyerChatMessagesCubit, ChatMessagesState>(
            builder: (context, state) {
              final isSending = state is ChatMessagesLoaded && state.isSending;
              return SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    border: Border(
                      top: BorderSide(color: context.divColor, width: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: isSending ? null : _sendFile,
                        icon: Icon(
                          Icons.attach_file_rounded,
                          color: isSending
                              ? context.textSecondary
                              : AppColors.golden,
                          size: 22.sp,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.golden.withValues(
                            alpha: 0.08,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 42.h,
                            maxHeight: 112.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.pageBg,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: context.divColor),
                          ),
                          child: TextField(
                            controller: _messageController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            minLines: 1,
                            maxLines: 4,
                            style: context.text.bodyMedium?.copyWith(
                              color: context.textPrimary,
                              fontSize: 11.sp,
                              height: 1.35,
                            ),
                            decoration: InputDecoration(
                              hintText: Localizations.localeOf(context).languageCode == 'ar' 
                                  ? 'اكتب رسالتك...' 
                                  : AppStrings.typeYourMessage.tr(context),
                              hintStyle: TextStyle(
                                color: context.textSecondary,
                                fontSize: 11.sp,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 11.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: isSending
                            ? SizedBox(
                                width: 44.w,
                                height: 44.w,
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    color: AppColors.golden,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ), // SafeArea
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Chat Bubble ─────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        // For lawyer: isMe = lawyer's messages → right side
        mainAxisAlignment: isMe
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              constraints: BoxConstraints(maxWidth: 0.72.sw),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : context.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 18.r),
                ),
                border: isMe
                    ? null
                    : Border.all(color: context.divColor, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.hasFile) _buildAttachment(context, isMe),
                  if (message.hasText) ...[
                    if (message.hasFile) SizedBox(height: 6.h),
                    Text(
                      message.message!,
                      style: context.text.bodyMedium?.copyWith(
                        color: isMe ? Colors.white : context.textPrimary,
                        fontSize: 11.5.sp,
                        height: 1.45,
                      ),
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.65)
                              : context.textSecondary,
                          fontSize: 9.sp,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 12.sp,
                          color: message.isRead
                              ? Colors.lightBlueAccent
                              : Colors.white.withValues(alpha: 0.65),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(BuildContext context, bool isMe) {
    if (message.isImage) {
      return GestureDetector(
        onTap: () => launchUrl(
          Uri.parse(message.fileUrl!),
          mode: LaunchMode.externalApplication,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            message.fileUrl!,
            width: 200.w,
            height: 160.h,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 200.w,
              height: 80.h,
              color: Colors.grey.withValues(alpha: 0.2),
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(message.fileUrl!),
        mode: LaunchMode.externalApplication,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withValues(alpha: 0.15)
              : AppColors.golden.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              message.isPdf
                  ? Icons.picture_as_pdf_rounded
                  : Icons.insert_drive_file_rounded,
              color: isMe ? Colors.white : AppColors.golden,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                message.isPdf
                    ? AppStrings.pdfFile.tr(context)
                    : AppStrings.attachment.tr(context),
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.golden,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.download_rounded,
              color: isMe
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppColors.golden,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr.replaceFirst(' ', 'T'));
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
