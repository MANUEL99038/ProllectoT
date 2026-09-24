import 'package:flutter/material.dart';

import '../main.dart';
import 'home_page.dart';
import 'setup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController entranceController;
  bool registerMode = false;
  bool hidePassword = true;
  bool loading = false;
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    entranceController.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final store = AppScope.of(context).store;
    String? message;
    if (registerMode) {
      await store.registerAccount(email.text, password.text);
    } else if (!await store.login(email.text, password.text)) {
      message = 'El correo o la contraseña no son correctos.';
    }
    if (!mounted) return;
    if (message != null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    final destination = AppScope.of(context).business == null
        ? const SetupPage()
        : const HomePage();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: AnimatedBuilder(
                animation: entranceController,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthBrand(),
                      const SizedBox(height: 44),
                      Text(
                        registerMode ? 'Crea tu cuenta' : 'Bienvenido de nuevo',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        registerMode
                            ? 'Empieza a entender dónde se va tu dinero.'
                            : 'Inicia sesión para revisar la salud de tu negocio.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: (value) =>
                            value == null || !value.contains('@')
                            ? 'Ingresa un correo válido'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: password,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => hidePassword = !hidePassword),
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.length < 6
                            ? 'Usa al menos 6 caracteres'
                            : null,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        child: registerMode
                            ? Column(
                                children: [
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: confirmPassword,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Confirmar contraseña',
                                      prefixIcon: Icon(
                                        Icons.verified_user_outlined,
                                      ),
                                    ),
                                    validator: (value) => value != password.text
                                        ? 'Las contraseñas no coinciden'
                                        : null,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: loading ? null : submit,
                          icon: Icon(
                            registerMode
                                ? Icons.person_add_alt_1_rounded
                                : Icons.login_rounded,
                          ),
                          label: Text(
                            registerMode ? 'Registrarme' : 'Iniciar sesión',
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              setState(() => registerMode = !registerMode),
                          child: Text(
                            registerMode
                                ? 'Ya tengo una cuenta'
                                : 'Crear una cuenta nueva',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Tu cuenta funciona de forma local en este dispositivo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (context, child) {
                  final eased = Curves.easeOutCubic.transform(
                    entranceController.value,
                  );
                  return Opacity(
                    opacity: eased,
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - eased)),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 48,
        height: 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            'img/logo.jpg',
            fit: BoxFit.cover,
            semanticLabel: 'Logo de LossTrack',
          ),
        ),
      ),
      const SizedBox(width: 12),
      const Flexible(
        child: Text(
          'LossTrack',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}
