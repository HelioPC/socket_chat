import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_test/repositories/auth/auth_repository_impl.dart';
import 'package:socket_test/router/app_router.dart';
import 'package:socket_test/utils/decorations.dart';
import 'package:validatorless/validatorless.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  bool get _isFormValid => _formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Entre com sua conta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.only(top: 40),
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  child: Visibility(
                    visible: !isLoading,
                    replacement: const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                onFieldSubmitted: (_) => setState(() {}),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: Validatorless.multiple([
                                  Validatorless.required('Email obrigatório'),
                                  Validatorless.email('Email inválido'),
                                ]),
                                decoration: CustomInputDecoration(
                                  leadingIcon: const Icon(Icons.email),
                                  text: 'Seu email',
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _passwordController,
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                onFieldSubmitted: (_) => setState(() {}),
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                validator:
                                    Validatorless.required('Senha obrigatória'),
                                decoration: CustomInputDecoration(
                                  leadingIcon: const Icon(Icons.lock),
                                  text: 'Sua senha',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            text: TextSpan(
                              text: 'Não tem uma conta? ',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context
                                          .pushNamed(AppRoutes.register.name);
                                    },
                                  text: 'Cadastre-se',
                                  style: const TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: _isFormValid
                                    ? () async {
                                        setState(() => isLoading = true);

                                        await ref
                                            .read(authRepositoryProvider(null))
                                            .signInWithEmailAndPassword(
                                              email: _emailController.text,
                                              password: _passwordController.text,
                                            );

                                        setState(() => isLoading = false);
                                      }
                                    : null,
                                child: const Text(
                                  'Entrar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
