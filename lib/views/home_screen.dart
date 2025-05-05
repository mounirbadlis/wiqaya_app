import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiqaya_app/controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop,result) {
        if(!didPop) {return;}
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home Screen'),
        ),
        body: Center(
          child: Text('Welcome to the Home Screen! ${Provider.of<AuthController>(context, listen: false).user?.firstName}'),
        ),
      ),
    );
  }
}