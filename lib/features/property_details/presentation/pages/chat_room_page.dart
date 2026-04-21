import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../../domain/entities/property_owner_entity.dart';

class ChatRoomPage extends StatelessWidget {
  final ListingEntity listing;
  final PropertyOwnerEntity owner;

  const ChatRoomPage({
    super.key,
    required this.listing,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 72,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              owner.name,
              style: const TextStyle(
                color: AppColors.primaryDarkText,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              listing.title,
              style: const TextStyle(
                color: AppColors.secondaryGrayText,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Bubble(
                  text: 'Hi ${owner.name.split(' ').first}, I am interested in ${listing.title}. Is it still available?',
                  isMe: true,
                ),
                const SizedBox(height: 12),
                const _Bubble(
                  text: 'Yes, it is available. I can share more details and arrange a visit.',
                  isMe: false,
                ),
                const SizedBox(height: 12),
                const _Bubble(
                  text: 'Great, please send the floor plan and amenities list.',
                  isMe: true,
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.borderGray)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainPurple,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () {},
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _Bubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.mainPurple : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? AppColors.white : AppColors.primaryDarkText,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
