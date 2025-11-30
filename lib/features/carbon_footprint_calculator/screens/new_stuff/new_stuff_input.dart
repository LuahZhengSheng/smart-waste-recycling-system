import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../config/emission_config/new_stuff.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/validators/new_stuff_emission_validator.dart';
import '../../controllers/new_stuff_controller.dart';
import '../../utils/emission_common_widgets.dart';
import '../../utils/emission_info_dialog.dart';

class NewStuffInputScreen extends StatelessWidget {
  const NewStuffInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewStuffController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('New Stuff'),
        showBackArrow: true,
        actionButtonText: 'Clear',
        onActionButtonPressed: () => controller.clearInputs(),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(FSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonEmissionWidgets.buildHeaderCard(
                      context: context,
                      title: 'Annual Consumer Goods',
                      subtitle: 'Track emissions from products you buy',
                      icon: Iconsax.shopping_bag,
                      color: FColors.stuff,
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    CommonEmissionWidgets.buildInfoCard(
                      context: context,
                      dataSource: 'Climatiq Data Explorer',
                      dataSet: 'USEEIO / EXIOBASE / UK BEIS Spend Factors',
                      dataYear: 2023,
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    CommonEmissionWidgets.buildInstructionsCard(
                      context: context,
                      instructions: const [
                        'Enter your approximate annual spending in RM (Ringgit Malaysia)',
                        'Check bank statements or shopping receipts to estimate',
                        'Leave fields at 0 if you didn\'t buy anything in that category',
                        'Emissions are calculated using global supply chain factors',
                      ],
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Exchange rate info
                    _buildExchangeRateCard(context, controller, dark),
                    const SizedBox(height: FSizes.md),

                    // Electronics & Appliances
                    _buildElectronicsSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),

                    // Clothing & Footwear
                    _buildClothingSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),

                    // Furniture & Homeware
                    _buildFurnitureSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),

                    // Other Consumer Goods
                    _buildOtherSection(context, controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    Obx(
                      () => CommonEmissionWidgets.buildResultsCard(
                        context: context,
                        totalEmissions: controller.totalEmissions.value,
                        color: FColors.stuff,
                        formatEmission: controller.formatEmissionTons,
                        breakdown: controller.emissionsBreakdown,
                        dark: dark,
                      ),
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    Obx(
                      () => CommonEmissionWidgets.buildSaveButton(
                        context: context,
                        onPressed: () => controller.saveEmissions(),
                        isSaving: controller.isSaving.value,
                        text: 'Save New Stuff Data',
                        color: FColors.stuff,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildExchangeRateCard(
      BuildContext context, NewStuffController controller, bool dark) {
    return Obx(
      () => Container(
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
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.xs),
              decoration: BoxDecoration(
                color: FColors.info.withOpacity(0.2),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Icon(
                Iconsax.money_change,
                color: FColors.info,
                size: FSizes.iconMd,
              ),
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exchange Rate',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: FColors.info,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.isRateFetching.value
                        ? 'Fetching live rate...'
                        : '1 USD = RM ${controller.usdToMyrRate.value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (controller.isRateFetching.value)
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(FColors.info),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectronicsSection(
      BuildContext context, NewStuffController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.borderDark
              : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.stuff.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.monitor,
                  color: FColors.stuff,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Electronics & Appliances',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Annual spending on tech products',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Computers & Laptops
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.computersLaptopsController,
            label: 'Computers & Laptops',
            hint: '3000',
            icon: Iconsax.monitor_mobbile,
            emissionObs: controller.computersLaptopsEmissions,
            metadataKey: 'computers_laptops',
            dark: dark,
          ),
          const SizedBox(height: FSizes.md),

          // Smartphones & Tablets
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.smartphonesTabletsController,
            label: 'Smartphones & Tablets',
            hint: '2000',
            icon: Iconsax.mobile,
            emissionObs: controller.smartphonesTabletsEmissions,
            metadataKey: 'smartphones_tablets',
            dark: dark,
          ),
          const SizedBox(height: FSizes.md),

          // TVs & Monitors
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.tvsMonitorsController,
            label: 'TVs & Monitors',
            hint: '1500',
            icon: Iconsax.monitor,
            emissionObs: controller.tvsMonitorsEmissions,
            metadataKey: 'tvs_monitors',
            dark: dark,
          ),
          const SizedBox(height: FSizes.md),

          // Small Appliances
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.smallAppliancesController,
            label: 'Small Appliances',
            hint: '500',
            icon: Iconsax.electricity,
            emissionObs: controller.smallAppliancesEmissions,
            metadataKey: 'small_appliances',
            dark: dark,
            subtitle: 'Toasters, kettles, fans, rice cookers, etc.',
          ),
        ],
      ),
    );
  }

  Widget _buildClothingSection(
      BuildContext context, NewStuffController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.borderDark
              : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.stuff.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.bag_2,
                  color: FColors.stuff,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Clothing & Footwear',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Annual spending on fashion items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Clothing
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.clothingController,
            label: 'Clothing',
            hint: '2000',
            icon: Iconsax.tag,
            emissionObs: controller.clothingEmissions,
            metadataKey: 'clothing',
            dark: dark,
            subtitle: 'Shirts, trousers, dresses, jackets, etc.',
          ),
          const SizedBox(height: FSizes.md),

          // Footwear
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.footwearController,
            label: 'Footwear',
            hint: '800',
            icon: Iconsax.shopping_bag,
            emissionObs: controller.footwearEmissions,
            metadataKey: 'footwear',
            dark: dark,
            subtitle: 'Shoes, sneakers, sandals, etc.',
          ),
          const SizedBox(height: FSizes.md),

          // Bags & Accessories
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.bagsAccessoriesController,
            label: 'Bags & Accessories',
            hint: '500',
            icon: Iconsax.bag,
            emissionObs: controller.bagsAccessoriesEmissions,
            metadataKey: 'bags_accessories',
            dark: dark,
            subtitle: 'Handbags, belts, watches, jewelry, etc.',
          ),
        ],
      ),
    );
  }

  Widget _buildFurnitureSection(
      BuildContext context, NewStuffController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.borderDark
              : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.stuff.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.home,
                  color: FColors.stuff,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3. Furniture & Homeware',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Annual spending on home goods',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Furniture
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.furnitureController,
            label: 'Furniture',
            hint: '5000',
            icon: Iconsax.home_1,
            emissionObs: controller.furnitureEmissions,
            metadataKey: 'furniture',
            dark: dark,
            subtitle: 'Sofas, tables, chairs, mattresses, etc.',
          ),
          const SizedBox(height: FSizes.md),

          // Homeware & Kitchenware
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.homewareKitchenController,
            label: 'Homeware & Kitchenware',
            hint: '1000',
            icon: Iconsax.cup,
            emissionObs: controller.homewareKitchenEmissions,
            metadataKey: 'homeware_kitchen',
            dark: dark,
            subtitle: 'Pots, pans, plates, decor, etc.',
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(
      BuildContext context, NewStuffController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.borderDark
              : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.stuff.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.box,
                  color: FColors.stuff,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4. Other Consumer Goods',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Everything else not listed above',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Other Consumer Goods
          _buildSpendingInput(
            context: context,
            controller: controller,
            textController: controller.otherConsumerGoodsController,
            label: 'Other Goods',
            hint: '1500',
            icon: Iconsax.shopping_cart,
            emissionObs: controller.otherConsumerGoodsEmissions,
            metadataKey: 'other_consumer_goods',
            dark: dark,
            subtitle: 'Toys, sports equipment, tools, etc.',
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingInput({
    required BuildContext context,
    required NewStuffController controller,
    required TextEditingController textController,
    required String label,
    required String hint,
    required IconData icon,
    required RxDouble emissionObs,
    required String metadataKey,
    required bool dark,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                dark ? FColors.darkGrey : FColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            EmissionInfoDialog.buildInfoIcon(
              context: context,
              metadata: NewStuffEmissionConfig
                      .newStuffEmissionFactors[metadataKey]!['metadata']
                  as Map<String, dynamic>,
              dark: dark,
              color: FColors.stuff,
            ),
          ],
        ),
        const SizedBox(height: FSizes.xs),

        // 自己排一行：图标 + RM + TextField
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            border: Border.all(
              color: dark
                  ? FColors.borderDark
                  : FColors.borderPrimary.withOpacity(0.5),
            ),
            color: dark ? FColors.darkContainer : FColors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
          child: Row(
            children: [
              Icon(
                icon,
                size: FSizes.iconMd,
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'RM',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark ? FColors.white : FColors.black,
                    ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: TextFormField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  inputFormatters: NewStuffEmissionValidator.currencyFormatters,
                  decoration: InputDecoration(
                    hintText: '2000',
                    hintStyle: TextStyle(color: dark ? FColors.darkGrey : FColors.textSecondary,),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    // focusedErrorBorder: InputBorder.none,
                  ),
                  onChanged: (value) => controller.calculateEmissions(),
                ),
              ),
            ],
          ),
        ),

        Obx(
          () => CommonEmissionWidgets.buildEmissionPreview(
            context: context,
            emissions: emissionObs.value,
            formatEmission: controller.formatEmissionTons,
            color: FColors.stuff,
            dark: dark,
          ),
        ),
      ],
    );
  }
}
