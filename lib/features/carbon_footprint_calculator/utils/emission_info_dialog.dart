import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class EmissionInfoDialog {
  /// Build info icon button with metadata dialog
  static Widget buildInfoIcon({
    required BuildContext context,
    required Map<String, dynamic> metadata,
    required bool dark,
    Color? color,
  }) {
    final iconColor = color ?? FColors.info;

    return InkWell(
      onTap: () => _showMetadataDialog(context, metadata, dark, iconColor),
      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      child: Container(
        padding: const EdgeInsets.all(FSizes.xs),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
        ),
        child: Icon(
          Iconsax.info_circle,
          size: FSizes.iconSm,
          color: iconColor,
        ),
      ),
    );
  }

  /// Show enhanced metadata dialog
  static void _showMetadataDialog(
      BuildContext context,
      Map<String, dynamic> metadata,
      bool dark,
      Color themeColor,
      ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: FSizes.defaultSpace,
          vertical: FSizes.spaceBtwSections,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.white,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg * 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(FSizes.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeColor.withOpacity(0.15),
                      themeColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(FSizes.borderRadiusLg * 1.5),
                    topRight: Radius.circular(FSizes.borderRadiusLg * 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                      child: Icon(
                        Iconsax.document_text_1,
                        color: themeColor,
                        size: FSizes.iconLg,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emission Factor',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Data Source Information',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: dark
                                  ? FColors.darkGrey
                                  : FColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(FSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source
                      _buildInfoCard(
                        context: context,
                        icon: Iconsax.book,
                        label: 'Source',
                        value: metadata['source'] ?? 'N/A',
                        themeColor: themeColor,
                        dark: dark,
                      ),
                      const SizedBox(height: FSizes.sm),

                      // Year & Region in a row
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                context: context,
                                icon: Iconsax.calendar,
                                label: 'Year',
                                value: metadata['year']?.toString() ?? 'N/A',
                                themeColor: themeColor,
                                dark: dark,
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: FSizes.sm),
                            Expanded(
                              child: _buildInfoCard(
                                context: context,
                                icon: Iconsax.global,
                                label: 'Region',
                                value: metadata['region'] ?? 'N/A',
                                themeColor: themeColor,
                                dark: dark,
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: FSizes.sm),

                      // Unit
                      _buildInfoCard(
                        context: context,
                        icon: Iconsax.weight,
                        label: 'Unit',
                        value: metadata['unit'] ?? 'N/A',
                        themeColor: themeColor,
                        dark: dark,
                      ),

                      // Notes (if available)
                      if (metadata['notes'] != null) ...[
                        const SizedBox(height: FSizes.sm),
                        _buildNotesCard(
                          context: context,
                          notes: metadata['notes'],
                          themeColor: themeColor,
                          dark: dark,
                        ),
                      ],

                      // Link button (if available)
                      if (metadata['link'] != null) ...[
                        const SizedBox(height: FSizes.lg),
                        _buildLinkButton(
                          context: context,
                          url: metadata['link'],
                          themeColor: themeColor,
                          dark: dark,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.darkSurface.withOpacity(0.5)
                      : FColors.lightContainer,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(FSizes.borderRadiusLg * 1.5),
                    bottomRight: Radius.circular(FSizes.borderRadiusLg * 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.shield_tick,
                      size: FSizes.iconSm,
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Expanded(
                      child: Text(
                        'Verified data from peer-reviewed sources',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark
                              ? FColors.darkGrey
                              : FColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build info card
  static Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color themeColor,
    required bool dark,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? FSizes.sm : FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.darkSurface.withOpacity(0.5)
            : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        border: Border.all(
          color: dark
              ? FColors.borderDark.withOpacity(0.5)
              : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.xs),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            ),
            child: Icon(
              icon,
              size: compact ? FSizes.iconSm : FSizes.iconMd,
              color: themeColor,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 10 : 11,
                  ),
                ),
                SizedBox(height: compact ? 2 : FSizes.xs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: compact ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build notes card
  static Widget _buildNotesCard({
    required BuildContext context,
    required String notes,
    required Color themeColor,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        border: Border.all(
          color: themeColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.note_text,
            size: FSizes.iconSm,
            color: themeColor,
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Notes',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  notes,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build link button with copy fallback
  static Widget _buildLinkButton({
    required BuildContext context,
    required String url,
    required Color themeColor,
    required bool dark,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleLink(context, url, themeColor),
            icon: const Icon(Iconsax.link, size: FSizes.iconSm),
            label: const Text('View Source'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: dark ? FColors.dark : FColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.lg,
                vertical: FSizes.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: FSizes.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: themeColor.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
          ),
          child: IconButton(
            onPressed: () => _copyLink(context, url, themeColor),
            icon: Icon(
              Iconsax.copy,
              size: FSizes.iconSm,
              color: themeColor,
            ),
            tooltip: 'Copy Link',
            padding: const EdgeInsets.all(FSizes.sm),
          ),
        ),
      ],
    );
  }

  /// Handle link - try to open, fallback to copy
  static Future<void> _handleLink(
      BuildContext context,
      String url,
      Color themeColor,
      ) async {
    try {
      // 确保 URL 有协议前缀
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(finalUrl);

      // 先尝试 externalApplication
      bool launched = false;
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('External application failed: $e');
      }

      // 如果失败，尝试 platformDefault
      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          print('Platform default failed: $e');
        }
      }

      if (launched && context.mounted) {
        _showSuccessSnackBar(
          context,
          'Opening link in browser...',
          themeColor,
        );
      } else {
        // 如果都失败，复制链接
        if (context.mounted) {
          await _copyLink(context, finalUrl, themeColor);
        }
      }
    } catch (e) {
      print('Launch error: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Could not open link. Link copied instead.');
        await _copyLink(context, url, themeColor);
      }
    }
  }

  /// Copy link to clipboard
  static Future<void> _copyLink(
      BuildContext context,
      String url,
      Color themeColor,
      ) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      _showSuccessSnackBar(
        context,
        'Link copied to clipboard!',
        themeColor,
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to copy link');
    }
  }

  /// Show success snackbar
  static void _showSuccessSnackBar(
      BuildContext context,
      String message,
      Color themeColor,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.xs),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Icon(
                Iconsax.tick_circle,
                color: Colors.white,
                size: FSizes.iconSm,
              ),
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: themeColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        ),
        margin: const EdgeInsets.all(FSizes.md),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.xs),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: const Icon(
                Iconsax.close_circle,
                color: Colors.white,
                size: FSizes.iconSm,
              ),
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: FColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        ),
        margin: const EdgeInsets.all(FSizes.md),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}