import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('프로필'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 프로필 화면으로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('알림 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 알림 설정 화면으로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('데이터 백업/복원'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 데이터 백업/복원 화면으로 이동
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 정보'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '영양제 체크',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/images/icon-pill.png',
                  width: 48,
                  height: 48,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

