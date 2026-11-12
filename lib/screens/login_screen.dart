import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool register}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (register) {
        await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
      // Při úspěchu nic neděláme, main.dart přepne obrazovku sám.
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _translateError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _translateError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Neplatný formát e-mailu.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Nesprávný e-mail nebo heslo.';
      case 'email-already-in-use':
        return 'Tento e-mail je již zaregistrovaný.';
      case 'weak-password':
        return 'Heslo musí mít alespoň 6 znaků.';
      case 'network-request-failed':
        return 'Chybí připojení k internetu.';
      default:
        return 'Něco se pokazilo ($code).';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.kitchen, size: 72, color: Colors.green),
                  const SizedBox(height: 8),
                  Text(
                    'Společná spíž',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Heslo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : () => _submit(register: false),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Přihlásit se'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _loading ? null : () => _submit(register: true),
                    child: const Text('Vytvořit účet'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}