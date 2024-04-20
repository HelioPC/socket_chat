import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_test/router/app_router.dart';
import 'package:socket_test/utils/decorations.dart';
import 'package:validatorless/validatorless.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  bool get _isFormValid => _formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                'Crie sua conta',
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
                                controller: _nameController,
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                onFieldSubmitted: (_) => setState(() {}),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                validator: Validatorless.multiple([
                                  Validatorless.required('Nome obrigatório'),
                                  Validatorless.regex(
                                    RegExp(r'^[A-ZÁÉÍÓÚÂÊÎÔÛÃÕÇa-záéíóúâêîôûãõç]+(?: [A-ZÁÉÍÓÚÂÊÎÔÛÃÕÇa-záéíóúâêîôûãõç]+)+$'),
                                    'Nome inválido',
                                  ),
                                ]),
                                decoration: CustomInputDecoration(
                                  leadingIcon: const Icon(Icons.person),
                                  text: 'Seu nome completo',
                                ),
                              ),
                              const SizedBox(height: 24),
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
                                textInputAction: TextInputAction.next,
                                validator:
                                Validatorless.required('Senha obrigatória'),
                                decoration: CustomInputDecoration(
                                  leadingIcon: const Icon(Icons.lock),
                                  text: 'Sua senha',
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                onFieldSubmitted: (_) => setState(() {}),
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                validator: Validatorless.multiple([
                                  Validatorless.required(
                                      'Confirmação obrigatória'),
                                  Validatorless.compare(
                                    _passwordController,
                                    'Senhas diferentes',
                                  ),
                                ]),
                                decoration: CustomInputDecoration(
                                  leadingIcon: const Icon(Icons.lock),
                                  text: 'Confirme sua senha',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            text: TextSpan(
                              text: 'Já tem uma conta? ',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.pushNamed(AppRoutes.login.name);
                                    },
                                  text: 'Entre',
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

                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  );

                                  setState(() => isLoading = false);
                                }
                                    : null,
                                child: const Text(
                                  'Criar conta',
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
