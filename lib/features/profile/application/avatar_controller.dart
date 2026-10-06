import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';

/// Why a chosen photo couldn't be used - shown to the user as-is.
class AvatarException implements Exception {
  const AvatarException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The signed-in patient's profile photo (`null` = none, the default avatar is shown instead). Loaded
/// from the backend; [pickAndUpload] and [remove] change it.
class AvatarController extends AsyncNotifier<Uint8List?> {
  static const _maxBytes =
      500 * 1024; // the backend refuses anything over 512 KB

  @override
  Future<Uint8List?> build() async {
    // Nothing to load until we have a session token.
    if (ref.watch(apiClientProvider).accessToken == null) return null;
    try {
      return await ref.read(profileRepositoryProvider).fetchAvatar();
    } on ApiException {
      return null; // offline or signed out: fall back to the default avatar
    }
  }

  /// Opens the camera or library, shrinks the photo, uploads it, and shows it. Returns false if the
  /// user backed out; throws [AvatarException] / [ApiException] if it couldn't be used.
  Future<bool> pickAndUpload(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return false;

    final bytes = await picked.readAsBytes();
    final contentType = _contentTypeOf(bytes);
    if (contentType == null) {
      throw const AvatarException(
        'That photo format isn\'t supported. Choose a JPEG, PNG or WebP image.',
      );
    }
    if (bytes.length > _maxBytes) {
      throw const AvatarException(
        'That photo is too large. Choose a smaller one.',
      );
    }

    await ref
        .read(profileRepositoryProvider)
        .uploadAvatar(bytes, contentType: contentType);
    state = AsyncData(bytes);
    return true;
  }

  Future<void> remove() async {
    await ref.read(profileRepositoryProvider).removeAvatar();
    state = const AsyncData(null);
  }

  /// Forget the photo (on sign out) so the next account never sees it.
  void clear() => state = const AsyncData(null);

  static String? _contentTypeOf(Uint8List b) {
    if (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (b.length > 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47) {
      return 'image/png';
    }
    if (b.length > 12 &&
        String.fromCharCodes(b.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(b.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }
}

final avatarProvider = AsyncNotifierProvider<AvatarController, Uint8List?>(
  AvatarController.new,
);
