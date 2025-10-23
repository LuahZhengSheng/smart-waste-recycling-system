import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: Text(
          'Privacy Policy',
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
            /// Header with modern design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FColors.primary.withOpacity(0.15),
                    FColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                boxShadow: [
                  BoxShadow(
                    color: FColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FColors.primary,
                          FColors.primary.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: FColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.shield_security,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FColors.primary,
                    ),
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'Your Privacy Matters to Us',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark ? FColors.textSecondary : FColors.darkerGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.xs),
                    decoration: BoxDecoration(
                      color: isDark ? FColors.darkContainer : FColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: FColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Last updated: ${_formatDate(DateTime.now())}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: FColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            /// Content Sections with modern card design
            _buildPrivacySection(
              context,
              icon: Iconsax.info_circle,
              title: '1. Introduction & Scope',
              content: 'Welcome to EcoRecycle! We are committed to protecting your privacy and ensuring the security of your personal information. This privacy policy explains how we collect, use, store, and protect your data when you use our recycling application.\n\nThis policy applies to all users of our mobile application and related services. By using our app, you consent to the practices described in this policy.',
              iconColor: Colors.blue,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.user_octagon,
              title: '2. Information We Collect',
              content: 'We collect several types of information to provide and improve our service:\n\n• Personal Information: Name, email address, phone number, profile picture\n• Account Data: Username, password, preferences, settings\n• Usage Data: App interactions, features used, time spent\n• Device Information: Device type, operating system, unique identifiers\n• Location Data: Approximate location for nearby recycling centers (with your permission)\n• Camera Access: For waste identification and profile pictures (with your permission)',
              iconColor: Colors.purple,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.security_safe,
              title: '3. How We Use Your Information',
              content: 'We use your personal information for the following purposes:\n\n• Provide and maintain our recycling services\n• Create and manage your account\n• Process your recycling activities and award points\n• Send you important notifications and updates\n• Improve our app features and user experience\n• Provide customer support and respond to inquiries\n• Analyze usage patterns to enhance our services\n• Comply with legal obligations and prevent fraud',
              iconColor: Colors.green,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.shield_tick,
              title: '4. Legal Basis for Processing',
              content: 'We process your personal data based on the following legal grounds:\n\n• Consent: When you explicitly agree to data processing\n• Contract Performance: To provide our services as agreed\n• Legitimate Interests: To improve services and ensure security\n• Legal Compliance: To meet regulatory and legal requirements\n\nYou have the right to withdraw consent at any time without affecting the lawfulness of processing based on consent before withdrawal.',
              iconColor: Colors.orange,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.share,
              title: '5. Information Sharing & Disclosure',
              content: 'We do not sell, trade, or rent your personal information. We may share your information only in these circumstances:\n\n• Service Providers: With trusted partners who help us operate our app\n• Legal Requirements: When required by law, court order, or legal process\n• Safety & Security: To protect rights, property, or safety of users\n• Business Transfers: In connection with mergers or business sales\n• Your Consent: When you explicitly authorize sharing',
              iconColor: Colors.red,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.lock_1,
              title: '6. Data Security & Protection',
              content: 'We implement robust security measures to protect your information:\n\n• Encryption: Data is encrypted in transit and at rest\n• Access Controls: Limited access on a need-to-know basis\n• Regular Audits: Security assessments and vulnerability testing\n• Secure Infrastructure: Industry-standard hosting and storage\n• Staff Training: Regular privacy and security training\n\nHowever, no system is 100% secure. We cannot guarantee absolute security but continuously work to enhance our protection measures.',
              iconColor: Colors.indigo,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.timer,
              title: '7. Data Retention Policy',
              content: 'We retain your personal data only as long as necessary:\n\n• Account Data: Until you delete your account or request removal\n• Usage Analytics: Aggregated data for up to 2 years\n• Transaction Records: As required by applicable laws (typically 7 years)\n• Marketing Data: Until you opt out or withdraw consent\n• Legal Data: As required by legal obligations\n\nWhen retention periods expire, we securely delete or anonymize your data.',
              iconColor: Colors.teal,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.personalcard,
              title: '8. Your Privacy Rights',
              content: 'You have important rights regarding your personal data:\n\n• Access: Request copies of your personal data\n• Rectification: Correct inaccurate or incomplete data\n• Erasure: Request deletion of your personal data\n• Portability: Receive your data in a portable format\n• Restriction: Limit how we process your data\n• Objection: Object to certain types of processing\n• Withdraw Consent: Opt out of voluntary data processing\n\nTo exercise these rights, contact us through the app or email privacy@ecorecycle.com',
              iconColor: Colors.pink,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.global,
              title: '9. International Data Transfers',
              content: 'Your data may be processed in countries other than your own. We ensure adequate protection through:\n\n• Adequacy Decisions: Transfers to countries with adequate data protection\n• Standard Contractual Clauses: EU-approved data transfer agreements\n• Binding Corporate Rules: Internal privacy standards\n• Certification Schemes: Privacy frameworks and certifications\n\nWe take all reasonable steps to ensure your data receives the same level of protection regardless of location.',
              iconColor: Colors.cyan,
            ),

            _buildPrivacySection(
              context,
              icon: Iconsax.activity,
              title: '10. Children\'s Privacy',
              content: 'Our app is designed for users aged 13 and above. We do not knowingly collect personal information from children under 13.\n\nIf we become aware that we have collected personal information from a child under 13, we will:\n• Delete the information immediately\n• Terminate the account\n• Notify the parents if possible\n\nParents who believe their child has provided information should contact us immediately.',
              iconColor: Colors.amber,
            ),

            /// Contact & Support Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FColors.primary.withOpacity(0.1),
                    FColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                border: Border.all(
                  color: FColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Iconsax.message_question,
                    color: FColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'Questions About Privacy?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FColors.primary,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'We\'re here to help! If you have any questions about this privacy policy or how we handle your data, please don\'t hesitate to reach out.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? FColors.textSecondary : FColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactMethod(
                          context,
                          icon: Iconsax.sms,
                          title: 'Email',
                          content: 'privacy@ecorecycle.com',
                        ),
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: _buildContactMethod(
                          context,
                          icon: Iconsax.call,
                          title: 'Phone',
                          content: '+1 (555) 123-4567',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.lg),

            /// Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                color: isDark ? FColors.darkContainer : FColors.lightContainer,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.shield_tick,
                        color: FColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Text(
                        'Your Data is Safe With Us',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: FColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'We are committed to protecting your privacy and being transparent about our data practices. This policy may be updated periodically to reflect changes in our practices or applicable laws.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? FColors.darkGrey : FColors.darkerGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    '© 2024 EcoRecycle. All rights reserved.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? FColors.darkGrey : FColors.darkerGrey,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
        required Color iconColor,
      }) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: FSizes.md),
      decoration: BoxDecoration(
        color: isDark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? FColors.darkGrey.withOpacity(0.1) : FColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          /// Section Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.1),
                  iconColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(FSizes.cardRadiusLg),
                topRight: Radius.circular(FSizes.cardRadiusLg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Section Content
          Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: isDark ? FColors.textSecondary : FColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
      }) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.sm),
      decoration: BoxDecoration(
        color: isDark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: FColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: FColors.primary, size: 20),
          const SizedBox(height: FSizes.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: isDark ? FColors.darkGrey : FColors.darkerGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}