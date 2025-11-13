// import 'package:flutter/material.dart';
// import 'package:fyp/features/carbon_footprint_calculator/screens/food/food.dart';
//
// class CarbonFootprintCalculator extends StatelessWidget {
//   const CarbonFootprintCalculator({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Food'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: const SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: FoodInputScreen(),
//       ),
//     );
//   }
//
//   Widget _buildSliderQuestion(String question) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         Slider(
//           value: 3,
//           min: 0,
//           max: 7,
//           divisions: 7,
//           onChanged: (value) {},
//         ),
//       ],
//     );
//   }
// }
