import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videomeet/presentation/screens/home_screen.dart';
import '../providers/login_provider.dart';
import '../screens/user_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'eve.holt@reqres.in');
  final _passwordController = TextEditingController(text: 'cityslicka');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<LoginProvider>();
    await provider.login(_emailController.text, _passwordController.text);

    if (!mounted) return;

    if (provider.state == LoginState.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else if (provider.state == LoginState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _buildHeader(),
                        Expanded(child: _buildForm(theme)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.circle_outlined,
            color: Colors.black,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Container(
      transform: Matrix4.translationValues(0, -40, 0),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              "Login",
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'eve.holt@reqres.in',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!value.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your password';
                return null;
              },
            ),

            const SizedBox(height: 30),
            _buildLoginButton(),
            const SizedBox(height: 25),

            const Text.rich(
              TextSpan(
                text: "Don't have any account? ",
                style: TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: "Sign Up",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<LoginProvider>(
      builder: (context, provider, child) {
        if (provider.state == LoginState.loading) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _attemptLogin,
            child: const Text('Login'),
          ),
        );
      },
    );
  }
}