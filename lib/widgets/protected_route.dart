import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final bool requireAdmin;

  const ProtectedRoute({
    super.key,
    required this.child,
    this.requireAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // لسه يحمل
        if (auth.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // مو مسجل دخول
        if (auth.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // محتاج أدمن وما هو أدمن
        if (requireAdmin && !auth.isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/chat');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('غير مصرح لك بالدخول'),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // مسموح
        return child;
      },
    );
  }
}
