// import 'package:flutter/material.dart';
// import 'package:fyp/screens/wrapper.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _opacityAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 初始化动画控制器
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2), // 动画持续时间为2秒
//     );
//
//     // 定义淡入的动画
//     _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//
//     // 启动动画
//     _animationController.forward();
//
//     // 延迟3秒后跳转到 Wrapper 页面
//     Future.delayed(const Duration(seconds: 4), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const Wrapper()),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose(); // 释放动画资源
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: FadeTransition(
//         opacity: _opacityAnimation,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/logos.png', // 确保logo文件在assets中
//                 width: 150,
//                 height: 150,
//               ),
//               const SizedBox(height: 15),
//               ShaderMask(
//                 shaderCallback: (bounds) => const LinearGradient(
//                   colors: [Color(0xFF98D645), Color(0xFF4A8623)], // 浅青到深青的渐变色
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ).createShader(bounds),
//                 child: const Text(
//                   'SAVE EARTH',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white, // 渐变色要设为白色
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               const Text(
//                 'SMALL STEPS, BIG IMPACT\nSAVE EARTH TODAY!',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Color(0xFF3DA930),
//                   fontSize: 14,
//                   fontFamily: 'Rajdhani',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
