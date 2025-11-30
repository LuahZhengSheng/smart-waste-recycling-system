// import 'package:flutter/material.dart';
//
// import '../../../../../utils/constants/colors.dart';
// import '../../../../../utils/constants/sizes.dart';
//
// class FuelSegmentButton extends StatelessWidget {
//   const FuelSegmentButton({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.selected,
//     required this.dark,
//     required this.onTap,
//   });
//
//   final String label;
//   final IconData icon;
//   final bool selected;
//   final bool dark;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//             vertical: FSizes.sm,
//             horizontal: FSizes.xs,
//           ),
//           decoration: BoxDecoration(
//             color: selected
//                 ? FColors.landTravel.withOpacity(0.15)
//                 : (dark ? FColors.darkContainer : FColors.lightContainer),
//             borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
//             border: Border.all(
//               color: selected
//                   ? FColors.landTravel
//                   : (dark ? FColors.borderDark : FColors.borderSecondary),
//               width: selected ? 2 : 1,
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 color: selected
//                     ? FColors.landTravel
//                     : (dark
//                     ? FColors.darkTextSecondary
//                     : FColors.textSecondary),
//                 size: FSizes.iconMd,
//               ),
//               const SizedBox(height: FSizes.xs),
//               Text(
//                 label,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: selected
//                       ? FColors.landTravel
//                       : (dark
//                       ? FColors.darkTextSecondary
//                       : FColors.textSecondary),
//                   fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }