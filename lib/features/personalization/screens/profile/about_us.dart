import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: Text(
          'About Us',
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
            /// Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FColors.primary,
                    FColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.refresh_circle,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'EcoRecycle',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'Making Recycling Simple & Rewarding',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            /// Mission Statement
            _buildInfoCard(
              context,
              icon: Iconsax.global,
              title: 'Our Mission',
              content: 'We\'re on a mission to make recycling accessible, engaging, and rewarding for everyone. Through innovative technology and community engagement, we aim to create a sustainable future where waste becomes a valuable resource.',
              gradient: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
            ),

            /// Vision
            _buildInfoCard(
              context,
              icon: Iconsax.eye,
              title: 'Our Vision',
              content: 'To become the world\'s leading platform for sustainable waste management, empowering individuals and communities to take meaningful action against environmental challenges while building a circular economy.',
              gradient: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
            ),

            /// What We Do
            _buildInfoCard(
              context,
              icon: Iconsax.activity,
              title: 'What We Do',
              content: 'Our app uses advanced AI to help you identify recyclable materials, connects you with local recycling facilities, tracks your environmental impact, and rewards your sustainable actions with points and achievements.',
              gradient: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
            ),

            /// Impact Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
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
                    'Our Impact',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FColors.primary,
                    ),
                  ),
                  const SizedBox(height: FSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(context, '50K+', 'Active Users', Iconsax.people),
                      ),
                      Expanded(
                        child: _buildStatItem(context, '2M+', 'Items Recycled', Iconsax.refresh_circle),
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(context, '150+', 'Partner Centers', Iconsax.location),
                      ),
                      Expanded(
                        child: _buildStatItem(context, '500T', 'CO₂ Saved', Iconsax.global),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.lg),

            /// Team Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
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
                    'Meet Our Team',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FColors.primary,
                    ),
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'Our diverse team of environmental scientists, software engineers, and sustainability experts work together to create innovative solutions for a greener future.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: isDark ? FColors.textSecondary : FColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.lg),

            /// Contact Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
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
                    'Get In Touch',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FColors.primary,
                    ),
                  ),
                  const SizedBox(height: FSizes.md),
                  _buildContactItem(context, Iconsax.sms, 'Email', 'hello@ecorecycle.com'),
                  _buildContactItem(context, Iconsax.call, 'Phone', '+1 (555) 123-4567'),
                  _buildContactItem(context, Iconsax.location, 'Address', '123 Green Street\nEco City, EC 12345'),
                  _buildContactItem(context, Iconsax.global, 'Website', 'www.ecorecycle.com'),

                  const SizedBox(height: FSizes.md),

                  /// Social Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(context, Iconsax.message, 'Facebook', () {}),
                      const SizedBox(width: FSizes.md),
                      _buildSocialButton(context, Iconsax.message, 'Twitter', () {}),
                      const SizedBox(width: FSizes.md),
                      _buildSocialButton(context, Iconsax.video, 'Instagram', () {}),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.lg),

            /// Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: isDark
                    ? FColors.primary.withOpacity(0.1)
                    : FColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: Column(
                children: [
                  Icon(
                    Iconsax.heart,
                    color: FColors.primary,
                    size: 24,
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'Made with ❤️ for a Sustainable Future',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: FColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    '© 2024 EcoRecycle. All rights reserved.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? FColors.darkGrey : FColors.darkerGrey,
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

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
        required List<Color> gradient,
      }) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: FSizes.lg),
      padding: const EdgeInsets.all(FSizes.lg),
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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
                child: Icon(icon, color: gradient.first.withOpacity(0.8), size: 24),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
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

  Widget _buildStatItem(BuildContext context, String number, String label, IconData icon) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      margin: const EdgeInsets.symmetric(horizontal: FSizes.xs),
      decoration: BoxDecoration(
        color: FColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: FColors.primary, size: 24),
          const SizedBox(height: FSizes.xs),
          Text(
            number,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: FColors.primary,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? FColors.darkGrey : FColors.darkerGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String title, String content) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
            ),
            child: Icon(icon, color: FColors.primary, size: 20),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.textSecondary : FColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, IconData icon, String platform, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: FColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(color: FColors.primary.withOpacity(0.2)),
        ),
        child: Icon(icon, color: FColors.primary, size: 24),
      ),
    );
  }
}