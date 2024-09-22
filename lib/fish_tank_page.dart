import 'package:flutter/material.dart';

class FishTankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取设备屏幕的宽度和高度
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0), // 移除 padding 以便全屏显示
          child: Image.asset(
            'assets/images/fish_tank.gif', // 显示 GIF
            width: screenWidth, // 使用设备的宽度
            height: screenHeight, // 使用设备的高度
            fit: BoxFit.cover, // 让图片尽可能铺满屏幕
          ),
        ),
      ),
    );
  }
}
