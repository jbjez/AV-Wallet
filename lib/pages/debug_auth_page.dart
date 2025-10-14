import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

final logger = Logger('DebugAuthPage');

class DebugAuthPage extends StatefulWidget {
  const DebugAuthPage({Key? key}) : super(key: key);

  @override
  State<DebugAuthPage> createState() => _DebugAuthPageState();
}

class _DebugAuthPageState extends State<DebugAuthPage> {
  String _status = 'Checking...';
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      _user = session?.user;
      
      setState(() {
        _status = _user != null 
          ? 'Connected: ${_user!.email}' 
          : 'Not connected';
      });
      
      logger.info('Auth status: $_status');
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      await _checkAuthStatus();
    } catch (e) {
      setState(() {
        _status = 'Sign out error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Auth'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Status: $_status'),
            const SizedBox(height: 20),
            if (_user != null) ...[
              Text('User ID: ${_user!.id}'),
              Text('Email: ${_user!.email}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signOut,
                child: const Text('Sign Out'),
              ),
            ] else ...[
              const Text('No user connected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkAuthStatus,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}





