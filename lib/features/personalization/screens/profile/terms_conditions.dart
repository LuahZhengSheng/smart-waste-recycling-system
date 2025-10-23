import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: Text(
          'Terms & Conditions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FColors.primary.withOpacity(0.1),
                    FColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              ),
              child: Column(
                children: [
                  Icon(
                    Iconsax.document_text,
                    size: 48,
                    color: FColors.primary,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'Terms & Conditions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FColors.primary,
                    ),
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? FColors.darkGrey : FColors.darkerGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            /// Content
            _buildSection(
              context,
              title: '1. Acceptance of Terms',
              content: 'By accessing and using this recycling application, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),

            _buildSection(
              context,
              title: '2. Use License',
              content: 'Permission is granted to temporarily download one copy of the materials on our recycling app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose\n• Attempt to decompile or reverse engineer any software\n• Remove any copyright or other proprietary notations',
            ),

            _buildSection(
              context,
              title: '3. User Accounts',
              content: 'When you create an account with us, you must provide information that is accurate, complete, and current at all times. You are responsible for safeguarding the password and for all activities that occur under your account.',
            ),

            _buildSection(
              context,
              title: '4. Prohibited Uses',
              content: 'You may not use our service:\n\n• For any unlawful purpose or to solicit others to unlawful acts\n• To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances\n• To infringe upon or violate our intellectual property rights or the intellectual property rights of others\n• To harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate\n• To submit false or misleading information',
            ),

            _buildSection(
              context,
              title: '5. Content Guidelines',
              content: 'Users may community content related to recycling, sustainability, and environmental topics. All content must be:\n\n• Respectful and appropriate\n• Accurate and truthful\n• Not infringing on others\' rights\n• Compliant with applicable laws\n\nWe reserve the right to remove any content that violates these guidelines.',
            ),

            _buildSection(
              context,
              title: '6. Privacy Policy',
              content: 'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your information when you use our service. By using our service, you agree to the collection and use of information in accordance with our Privacy Policy.',
            ),

            _buildSection(
              context,
              title: '7. Rewards and Points',
              content: 'Our app features a reward system where users can earn points for recycling activities. These points have no monetary value and cannot be exchanged for cash. We reserve the right to modify or discontinue the rewards program at any time.',
            ),

            _buildSection(
              context,
              title: '8. Limitation of Liability',
              content: 'In no event shall our company, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, punitive, consequential, or special damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.',
            ),

            _buildSection(
              context,
              title: '9. Service Availability',
              content: 'We strive to keep our service available at all times, but we cannot guarantee uninterrupted access. The service may be temporarily unavailable for maintenance, updates, or due to circumstances beyond our control.',
            ),

            _buildSection(
              context,
              title: '10. Modifications',
              content: 'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days notice prior to any new terms taking effect.',
            ),

            _buildSection(
              context,
              title: '11. Governing Law',
              content: 'These Terms shall be interpreted and governed by the laws of the jurisdiction in which our company is established, without regard to its conflict of law provisions.',
            ),

            _buildSection(
              context,
              title: '12. Contact Information',
              content: 'If you have any questions about these Terms and Conditions, please contact us at:\n\nEmail: support@recycleapp.com\nPhone: +1 (555) 123-4567\nAddress: 123 Green Street, Eco City, EC 12345',
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            /// Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: isDark ? FColors.darkContainer : FColors.lightContainer,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: Text(
                'By continuing to use our app, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: isDark ? FColors.darkGrey : FColors.darkerGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: FSizes.lg),
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: isDark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: FColors.primary,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark ? FColors.textSecondary : FColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}