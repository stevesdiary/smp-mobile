import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subdomainController = TextEditingController(text: 'greenwood');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _subdomainController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await context.read<AuthProvider>().login(
          _emailController.text.trim(),
          _passwordController.text,
          _subdomainController.text.trim().toLowerCase(),
        );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Login failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final loading = context.watch<AuthProvider>().loading;

    const inputBorder = InputBorder.none;
    const transparent = InputDecoration(
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder,
      errorBorder: inputBorder,
      focusedErrorBorder: inputBorder,
      fillColor: Colors.transparent,
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.school_rounded, size: 60, color: cs.primary),
                const SizedBox(height: 32),
                Text('Welcome back', style: tt.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Sign in to your school account', style: tt.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 32),

                // Grouped inputs
                Container(
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _subdomainController,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: transparent.copyWith(labelText: 'School Code'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter your school code' : null,
                      ),
                      Divider(height: 1, color: cs.outlineVariant, indent: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: transparent.copyWith(labelText: 'Email Address'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      Divider(height: 1, color: cs.outlineVariant, indent: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSignIn(),
                        decoration: transparent.copyWith(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: cs.outline,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your password';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: loading ? null : _handleSignIn,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Sign In', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
