import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController(text: 'Priya Nair');
  final _emailController = TextEditingController(text: 'priya@folio.app');
  final _passwordController = TextEditingController(text: '••••••••••');
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            FolioSpacing.pageX,
            12,
            FolioSpacing.pageX,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FolioIconButton(
                icon: Icons.arrow_back_rounded,
                semanticsLabel: 'Back',
                onPressed: () => safePop(context, fallback: '/genres'),
              ),
              const SizedBox(height: 16),
              Text(
                'Create your shelf',
                style: FolioTypography.h1(size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                'Your reading progress and drafts stay synced in one quiet place.',
                style: FolioTypography.caption(size: 14),
              ),
              const SizedBox(height: 28),
              _RegisterField(
                label: 'Name',
                controller: _nameController,
                hintText: 'Your full name',
              ),
              const SizedBox(height: 18),
              _RegisterField(
                label: 'Email',
                controller: _emailController,
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              _RegisterField(
                label: 'Password',
                controller: _passwordController,
                hintText: 'At least 8 characters',
                obscureText: _obscure,
                suffix: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: FolioColors.mutedIcon,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Create account',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: FolioTypography.caption(size: 14),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/login'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: FolioColors.accentText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _RegisterField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FolioTypography.caption(
            size: 12,
            weight: FontWeight.w500,
            color: FolioColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: FolioTypography.body(size: 15),
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: FolioColors.surface,
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: FolioColors.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
