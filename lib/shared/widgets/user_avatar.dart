import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

/// The picture on the account, in the three shapes it can take.
///
/// One stored string covers all of them: null means the initials, `fun:<n>`
/// one of the generated avatars, and `photo:<base64>` a picture the person
/// uploaded. Keeping it in one value means every avatar on screen changes
/// together, and there is no second setting to disagree with the first.
class Avatar {
  static const photoPrefix = 'photo:';
  static const funPrefix = 'fun:';

  /// Faces to pick from. Deliberately not people — nobody has to find
  /// themselves in a stock illustration.
  static const funFaces = ['🦁', '🐝', '🚀', '🌵', '🐙', '🥑', '⚡', '🦋'];

  static const funColors = [
    [Color(0xFFD9FF43), Color(0xFF7CB800)],
    [Color(0xFF10B981), Color(0xFF065F46)],
    [Color(0xFF4C45FF), Color(0xFF1B1740)],
    [Color(0xFFFF8A3D), Color(0xFFB23C00)],
    [Color(0xFF22D3EE), Color(0xFF0E7490)],
    [Color(0xFFF472B6), Color(0xFF9D174D)],
    [Color(0xFFFACC15), Color(0xFFA16207)],
    [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
  ];

  static bool isPhoto(String? value) => value?.startsWith(photoPrefix) ?? false;

  static bool isFun(String? value) => value?.startsWith(funPrefix) ?? false;

  static ImageProvider? photoOf(String? value) {
    if (!isPhoto(value)) return null;
    return MemoryImage(base64Decode(value!.substring(photoPrefix.length)));
  }

  /// Out-of-range or damaged values wrap rather than throw, so a bad stored
  /// string costs a different face, not a crash.
  static int funIndexOf(String? value) {
    if (!isFun(value)) return 0;
    final n = int.tryParse(value!.substring(funPrefix.length)) ?? 0;
    return n.abs() % funFaces.length;
  }
}

/// The account's picture at any size: photo, fun avatar, or initials.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({
    super.key,
    this.radius = 18,
    this.onTap,
    this.showEditBadge = false,
  });

  final double radius;
  final VoidCallback? onTap;

  /// A small camera badge, for the places where tapping the avatar is the
  /// whole point rather than a shortcut.
  final bool showEditBadge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(userAvatarProvider);
    final photo = Avatar.photoOf(value);

    Widget circle;
    if (photo != null) {
      circle = CircleAvatar(
        radius: radius,
        backgroundColor: context.colors.blueHighlight,
        backgroundImage: photo,
      );
    } else if (Avatar.isFun(value)) {
      final index = Avatar.funIndexOf(value);
      circle = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Avatar.funColors[index],
          ),
        ),
        alignment: Alignment.center,
        child: Text(Avatar.funFaces[index],
            style: TextStyle(fontSize: radius * 1.05)),
      );
    } else {
      circle = CircleAvatar(
        radius: radius,
        backgroundColor: context.colors.blueHighlight,
        child: Text(
          ref.watch(userInitialsProvider),
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: radius * 0.66),
        ),
      );
    }

    if (showEditBadge) {
      circle = Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: context.colors.bluePrimary,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.scaffoldBg, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 12, color: Colors.white),
            ),
          ),
        ],
      );
    }

    if (onTap == null) return circle;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: circle,
    );
  }
}

/// The sheet behind every avatar on the account: upload, generate, or go back
/// to initials.
Future<void> showAvatarSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.colors.bgSoft,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => const _AvatarSheet(),
  );
}

class _AvatarSheet extends ConsumerWidget {
  const _AvatarSheet();

  Future<void> _pick(
      BuildContext context, WidgetRef ref, ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 300,
        maxHeight: 300,
        // The picture is stored inline with the account, so it has to stay
        // small; 300px at this quality lands well under the document limit.
        imageQuality: 80,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      await ref.read(userAvatarProvider.notifier).setPhoto(bytes);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('That picture could not be used: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(userAvatarProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Your picture',
              style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Upload a photo, pick a character, or keep your initials.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.photo_library_rounded,
                color: context.colors.bluePrimary),
            title: Text('Upload from gallery',
                style: TextStyle(
                    color: context.colors.ink, fontWeight: FontWeight.w600)),
            onTap: () => _pick(context, ref, ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt_rounded,
                color: context.colors.bluePrimary),
            title: Text('Take a photo',
                style: TextStyle(
                    color: context.colors.ink, fontWeight: FontWeight.w600)),
            onTap: () => _pick(context, ref, ImageSource.camera),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Or pick a character',
                  style: TextStyle(
                      color: context.colors.inkSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(Avatar.funFaces.length, (index) {
                final selected =
                    Avatar.isFun(value) && Avatar.funIndexOf(value) == index;
                return GestureDetector(
                  onTap: () {
                    ref.read(userAvatarProvider.notifier).setFun(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: Avatar.funColors[index],
                      ),
                      border: selected
                          ? Border.all(
                              color: context.colors.bluePrimary, width: 3)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(Avatar.funFaces[index],
                        style: const TextStyle(fontSize: 24)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          if (value != null)
            ListTile(
              leading: Icon(Icons.text_fields_rounded,
                  color: context.colors.bluePrimary),
              title: Text('Use my initials',
                  style: TextStyle(
                      color: context.colors.ink, fontWeight: FontWeight.w600)),
              subtitle: Text(ref.watch(userInitialsProvider),
                  style: TextStyle(color: context.colors.inkSoft)),
              onTap: () {
                ref.read(userAvatarProvider.notifier).clear();
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
