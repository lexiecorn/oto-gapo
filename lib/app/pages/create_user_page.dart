import 'package:flutter/material.dart';
import 'package:otogapo/app/pages/create_user_section.dart';

class CreateUserPage extends StatelessWidget {
  const CreateUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New User'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: CreateUserSection(),
      ),
    );
  }
}
