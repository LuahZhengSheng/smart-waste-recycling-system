import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:fyp/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:fyp/common/widgets/image_text_widgets/vertical_image_text.dart';
import 'package:fyp/common/widgets/texts/section_heading.dart';
import 'package:fyp/features/waste_classification/screens/home/widgets/home_appbar.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// Header
            MyPrimaryHeaderContainer(
                child: Column(
                  children: [

                    /// -- Appbar
                    const MyHomeAppBar(),
                    const SizedBox(height: MySizes.spaceBtwSections),

                    /// -- Searchbar
                    const MySearchContainer(text: 'Search Waste'),
                    const SizedBox(height: MySizes.spaceBtwSections),

                    /// Categories
                    Padding(
                      padding: const EdgeInsets.only(
                          left: MySizes.defaultSpace),
                      child: Column(
                        children: [

                          /// -- Headings
                          const MySectionHeading(
                              title: 'Popular Categories',
                              showActionButton: false,
                              textColor: Colors.white),
                          const SizedBox(height: MySizes.spaceBtwSections),

                          /// -- Categories
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 6,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, index) {
                                return MyVerticalImageText(image: MyImages.facebook, title: 'Waste', onTap: (){});
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}


