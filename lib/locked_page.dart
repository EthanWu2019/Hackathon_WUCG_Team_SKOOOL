import 'package:flutter/material.dart';

class LockedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Join Skoool Prime Right now!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 弹出包含图片的对话框
                _showPrimeOfferDialog(context);
              },
              child: Text('Join Right now!'),
            ),
          ],
        ),
      ),
    );
  }

  // 显示 Prime Offer 图片的对话框
  void _showPrimeOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),  // 增加内边距
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 限制图片的大小，稍微放大
              Image.asset(
                'assets/images/prime_offer.png',
                width: 300, // 稍微增大宽度
                height: 300, // 稍微增大高度
                fit: BoxFit.contain, // 保持图片比例
              ),
              SizedBox(height: 20),
              Text(
                'Unlock exclusive benefits with Skoool Prime!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
