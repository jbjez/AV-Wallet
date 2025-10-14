import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/subscription_service.dart';
import 'biometric_settings_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.standard;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
    // Délayer la vérification de l'auth pour éviter l'erreur Riverpod
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAuthState();
    });
  }

  Future<void> _refreshAuthState() async {
    // Forcer la vérification de l'état d'authentification
    await ref.read(authProvider.notifier).checkAuthStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await _subscriptionService.getSubscriptionStatus();
      setState(() => _subscriptionStatus = status);
    } catch (e) {
      // Gérer l'erreur
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1128),
        title: Text(
          AppLocalizations.of(context)!.settingsPage_title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoSection(user),
                  const SizedBox(height: 24),
                  _buildSecuritySection(),
                  const SizedBox(height: 24),
                  _buildSubscriptionSection(),
                  const SizedBox(height: 24),
                  _buildAccountSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoSection(user) {
    return _buildSection(
      AppLocalizations.of(context)!.settingsPage_userInfo,
      [
        _buildInfoTile(
          AppLocalizations.of(context)!.settingsPage_email,
          user?.email ?? AppLocalizations.of(context)!.settingsPage_notAvailable,
          Icons.email,
        ),
        _buildInfoTile(
          AppLocalizations.of(context)!.settingsPage_name,
          user?.displayName?.isNotEmpty == true 
              ? user!.displayName! 
              : AppLocalizations.of(context)!.settingsPage_notDefined,
          Icons.person,
        ),
        _buildInfoTile(
          AppLocalizations.of(context)!.settingsPage_status,
          _subscriptionStatus == SubscriptionStatus.premium 
              ? AppLocalizations.of(context)!.settingsPage_premium
              : AppLocalizations.of(context)!.settingsPage_standard,
          _subscriptionStatus == SubscriptionStatus.premium 
              ? Icons.star 
              : Icons.star_border,
          statusColor: _subscriptionStatus == SubscriptionStatus.premium 
              ? Colors.amber 
              : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      AppLocalizations.of(context)!.settingsPage_security,
      [
        _buildActionTile(
          AppLocalizations.of(context)!.settingsPage_changePassword,
          Icons.lock,
          () => _showChangePasswordDialog(),
        ),
        _buildActionTile(
          AppLocalizations.of(context)!.settingsPage_biometricAuth,
          Icons.fingerprint,
          () => _navigateToBiometricSettings(),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    return _buildSection(
      AppLocalizations.of(context)!.settingsPage_subscription,
      [
        _buildActionTile(
          AppLocalizations.of(context)!.settingsPage_premiumSubscription,
          Icons.subscriptions,
          () => _navigateToSubscription(),
          color: Colors.blue,
        ),
        _buildActionTile(
          AppLocalizations.of(context)!.settingsPage_freemiumTest,
          Icons.science,
          () => _navigateToFreemiumTest(),
          color: Colors.orange,
        ),
        if (_subscriptionStatus == SubscriptionStatus.standard)
          _buildActionTile(
            AppLocalizations.of(context)!.settingsPage_subscribeToPremium,
            Icons.upgrade,
            () => _showSubscribeDialog(),
            color: Colors.green,
          )
        else
          _buildActionTile(
            AppLocalizations.of(context)!.settingsPage_unsubscribe,
            Icons.cancel,
            () => _showUnsubscribeDialog(),
            color: Colors.red,
          ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      AppLocalizations.of(context)!.settingsPage_account,
      [
        _buildActionTile(
          AppLocalizations.of(context)!.settingsPage_signOut,
          Icons.logout,
          () => _showSignOutDialog(),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {Color? statusColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3748)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: statusColor ?? Colors.white70,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: statusColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: const Color(0xFF1A1F3A),
      ),
    );
  }

  void _showChangePasswordDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.settingsPage_featureNotImplemented)),
    );
  }

  void _navigateToBiometricSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BiometricSettingsPage(),
      ),
    );
  }

  void _showSubscribeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          AppLocalizations.of(context)!.settingsPage_subscribeDialogTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)!.settingsPage_subscribeDialogContent,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsPage_cancel, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _subscribe,
            child: Text(AppLocalizations.of(context)!.settingsPage_subscribe),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe() async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    
    try {
      final success = await _subscriptionService.subscribeToPremium();
      if (success) {
        setState(() => _subscriptionStatus = SubscriptionStatus.premium);
        _showSuccessDialog(AppLocalizations.of(context)!.settingsPage_premiumActivated);
      } else {
        _showErrorDialog(AppLocalizations.of(context)!.settingsPage_subscriptionError);
      }
    } catch (e) {
      _showErrorDialog('${AppLocalizations.of(context)!.settingsPage_error}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showUnsubscribeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          AppLocalizations.of(context)!.settingsPage_unsubscribeDialogTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)!.settingsPage_unsubscribeDialogContent,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsPage_cancel, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _unsubscribe,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.settingsPage_confirmUnsubscribe),
          ),
        ],
      ),
    );
  }

  Future<void> _unsubscribe() async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    
    try {
      final success = await _subscriptionService.unsubscribe();
      if (success) {
        setState(() => _subscriptionStatus = SubscriptionStatus.standard);
        _showSuccessDialog(AppLocalizations.of(context)!.settingsPage_unsubscribe);
      } else {
        _showErrorDialog(AppLocalizations.of(context)!.settingsPage_subscriptionError);
      }
    } catch (e) {
      _showErrorDialog('${AppLocalizations.of(context)!.settingsPage_error}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(
          AppLocalizations.of(context)!.settingsPage_signOutDialogTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)!.settingsPage_signOutDialogContent,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsPage_cancel, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.settingsPage_confirmSignOut),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    Navigator.pop(context);
    await ref.read(authProvider.notifier).signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(AppLocalizations.of(context)!.settingsPage_error, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsPage_ok),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: Text(AppLocalizations.of(context)!.settingsPage_success, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.settingsPage_ok),
          ),
        ],
      ),
    );
  }

  void _navigateToSubscription() {
    Navigator.of(context).pushNamed('/payment');
  }

  void _navigateToFreemiumTest() {
    Navigator.of(context).pushNamed('/freemium-test');
  }
}