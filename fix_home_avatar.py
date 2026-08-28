filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add image_picker and dart:convert imports
imports = """import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher';"""

content = content.replace("import 'dart:async';\nimport 'package:url_launcher/url_launcher.dart';", imports)

# 2. Modify _buildHeader avatar region
old_avatar = """              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.bluePrimary.withValues(alpha: 0.3), width: 2),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.blueHighlight,
                  child: const Text('RM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),"""

new_avatar = """              GestureDetector(
                onTap: () => _showAvatarUploadDialog(context),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.bluePrimary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: context.colors.blueHighlight,
                    backgroundImage: ref.watch(userAvatarProvider) != null
                        ? MemoryImage(base64Decode(ref.watch(userAvatarProvider)!))
                        : null,
                    child: ref.watch(userAvatarProvider) == null
                        ? const Text('RM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))
                        : null,
                  ),
                ),
              ),"""

content = content.replace(old_avatar, new_avatar)

# 3. Add _showAvatarUploadDialog helper method definition
upload_dialog_method = """  void _showAvatarUploadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final hasPhoto = ref.watch(userAvatarProvider) != null;
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
                  Text(
                    'Profile Photo',
                    style: TextStyle(
                      color: context.colors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.photo_library_rounded, color: context.colors.bluePrimary),
                    title: Text('Upload from Gallery', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);
                        if (image != null) {
                          final bytes = await image.readAsBytes();
                          ref.read(userAvatarProvider.notifier).state = base64Encode(bytes);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error picking image: $e')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt_rounded, color: context.colors.bluePrimary),
                    title: Text('Take a Photo', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.camera, maxWidth: 300, maxHeight: 300);
                        if (image != null) {
                          final bytes = await image.readAsBytes();
                          ref.read(userAvatarProvider.notifier).state = base64Encode(bytes);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error taking photo: $e')),
                        );
                      }
                    },
                  ),
                  if (hasPhoto)
                    ListTile(
                      leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                      title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(userAvatarProvider.notifier).state = null;
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }"""

# Inject it after the start of class _HomeScreenState
class_start_idx = content.find("class _HomeScreenState extends ConsumerState<HomeScreen> {")
if class_start_idx != -1:
    body_start_idx = content.find("{", class_start_idx) + 1
    content = content[:body_start_idx] + "\n" + upload_dialog_method + "\n" + content[body_start_idx:]

with open(filepath, 'w') as f:
    f.write(content)

print("Home screen avatar upload integrated.")
