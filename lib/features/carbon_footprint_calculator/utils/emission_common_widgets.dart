import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

/// Common widgets for emission input screens
class CommonEmissionWidgets {
  CommonEmissionWidgets._();

  /// Build header card with icon and title
  static Widget buildHeaderCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              color: color,
              size: FSizes.iconLg,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build info card with data source
  static Widget buildInfoCard({
    required BuildContext context,
    required String dataSource,
    required String dataSet,
    required int dataYear,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.info.withOpacity(0.1)
            : FColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: FColors.info.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.info_circle,
            color: FColors.info,
            size: FSizes.iconMd,
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Source',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: FColors.info,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  '$dataSource - $dataSet ($dataYear)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build instructions card
  static Widget buildInstructionsCard({
    required BuildContext context,
    required List<String> instructions,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.warning.withOpacity(0.1)
            : FColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: FColors.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.lamp_charge,
                color: FColors.warning,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'How to Use',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: FColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            instructions.asMap().entries.map((entry) {
              return '${entry.key + 1}. ${entry.value}';
            }).join('\n'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build results card with total emissions
  static Widget buildResultsCard({
    required BuildContext context,
    required double totalEmissions,
    required Color color,
    required String Function(double) formatEmission,
    Map<String, double>? breakdown,
    required bool dark,
  }) {
    return Container(
      width: double.infinity, // 强制占满整行
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Annual Emissions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            formatEmission(totalEmissions),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: FColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'CO₂e',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FColors.white.withOpacity(0.9),
            ),
          ),

          if (breakdown != null && breakdown.isNotEmpty) ...[
            const SizedBox(height: FSizes.md),
            const Divider(color: Colors.white24),
            const SizedBox(height: FSizes.md),
            Wrap(
              spacing: FSizes.md,
              runSpacing: FSizes.sm,
              alignment: WrapAlignment.spaceAround,
              children: breakdown.entries.map((entry) {
                return _buildBreakdownItem(
                  context,
                  entry.key,
                  formatEmission(entry.value),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Build breakdown item
  static Widget _buildBreakdownItem(
      BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: FColors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: FColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build save button
  static Widget buildSaveButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required bool isSaving,
    required String text,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: FSizes.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.buttonRadius),
          ),
        ),
        child: isSaving
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(FColors.white),
          ),
        )
            : Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: FColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build info icon button with metadata dialog
  static Widget buildInfoIcon({
    required BuildContext context,
    required Map<String, dynamic> metadata,
    required bool dark,
  }) {
    return IconButton(
      icon: Icon(
        Iconsax.info_circle,
        size: FSizes.iconSm,
        color: dark ? FColors.darkGrey : FColors.textSecondary,
      ),
      onPressed: () => _showMetadataDialog(context, metadata, dark),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  /// Show metadata dialog
  static void _showMetadataDialog(
      BuildContext context, Map<String, dynamic> metadata, bool dark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Iconsax.document_text,
              color: FColors.info,
              size: FSizes.iconMd,
            ),
            const SizedBox(width: FSizes.sm),
            const Text('Emission Factor Source'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMetadataRow(
                context,
                'Source',
                metadata['source'] ?? 'N/A',
                dark,
              ),
              const SizedBox(height: FSizes.sm),
              _buildMetadataRow(
                context,
                'Year',
                metadata['year']?.toString() ?? 'N/A',
                dark,
              ),
              const SizedBox(height: FSizes.sm),
              _buildMetadataRow(
                context,
                'Unit',
                metadata['unit'] ?? 'N/A',
                dark,
              ),
              const SizedBox(height: FSizes.sm),
              _buildMetadataRow(
                context,
                'Region',
                metadata['region'] ?? 'N/A',
                dark,
              ),
              if (metadata['notes'] != null) ...[
                const SizedBox(height: FSizes.sm),
                _buildMetadataRow(
                  context,
                  'Notes',
                  metadata['notes'],
                  dark,
                ),
              ],
              if (metadata['link'] != null) ...[
                const SizedBox(height: FSizes.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchURL(metadata['link']),
                    icon: const Icon(Iconsax.link, size: FSizes.iconSm),
                    label: const Text('View Source'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.info,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build metadata row
  static Widget _buildMetadataRow(
      BuildContext context, String label, String value, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: dark ? FColors.darkGrey : FColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Launch URL
  static Future<void> _launchURL(String url) async {
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      FHelperFunctions.showSnackBar('Error opening link: $e');
    }
  }

  /// Build small emissions preview chip/card
  static Widget buildEmissionPreview({
    required BuildContext context,
    required double emissions,
    required String Function(double) formatEmission,
    required Color color,
    required bool dark,
    String label = '',
    IconData icon = Iconsax.flash_1,
  }) {
    if (emissions <= 0) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: FSizes.sm),
      child: Container(
        padding: const EdgeInsets.all(FSizes.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: FSizes.iconSm,
            ),
            const SizedBox(width: FSizes.xs),
            if (label.isNotEmpty) ...[
              Text(
                '$label: ',
                style: textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            Text(
              formatEmission(emissions),
              style: textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' CO₂e',
              style: textTheme.bodySmall?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}