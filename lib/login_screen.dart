// lib/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIN PADRÃO PARA TESTES ---
  static const String adminEmail = 'admin@admin.com.br';
  static const String adminPassword = 'admin123';
  // --- FIM DO LOGIN PADRÃO ---

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simula um pequeno atraso para feedback visual
      await Future.delayed(const Duration(milliseconds: 500));

      // --- LÓGICA DE LOGIN HARDCODED ---
      // Verifica se as credenciais inseridas correspondem ao admin padrão
      final enteredEmail =
          _emailController.text.trim(); // Remove espaços extras
      final enteredPassword = _passwordController.text;

      bool loginSuccess =
          (enteredEmail == adminEmail && enteredPassword == adminPassword);
      print("Attempting login with: $enteredEmail");
      print("Credentials match admin: $loginSuccess");
      // --- FIM DA LÓGICA HARDCODED ---

      // Verifica se o widget ainda está na árvore antes de atualizar o estado
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (loginSuccess) {
        print("Login Successful! Navigating to main screen...");
        // Navega para a tela principal e remove a tela de login da pilha
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        print("Login Failed!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Email ou senha inválidos.',
            ), // Mensagem genérica
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } else {
      // Adiciona um feedback se o formulário for inválido
      print("Form validation failed.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, preencha os campos corretamente.'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- Logo e Título ---
                  const Icon(Icons.health_and_safety_outlined, size: 60),
                  const SizedBox(height: 8),
                  Text(
                    'DentalCare',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Acesso ao Sistema',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // --- Campo de Email ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu email';
                      }
                      // Removendo validação de formato estrita para permitir o email admin
                      // if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      //   return 'Por favor, insira um email válido';
                      // }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Campo de Senha ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      // Removendo validação de tamanho para permitir a senha admin
                      // if (value.length < 6) {
                      //   return 'A senha deve ter pelo menos 6 caracteres';
                      // }
                      return null; // Válido
                    },
                  ),
                  const SizedBox(height: 12),

                  // --- Esqueceu a Senha ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  print('Esqueceu a senha pressionado');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Funcionalidade não implementada.',
                                      ),
                                    ),
                                  );
                                  // TODO: Implementar recuperação de senha real
                                },
                        child: const Text('Esqueceu a senha?'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Botão de Login ---
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.primary, // Usa cor coral
                        ),
                      )
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ), // Botão um pouco maior
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: const Text('ENTRAR'),
                      ),
                  const SizedBox(height: 25),

                  // --- Opção de Cadastro ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Não tem uma conta? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  print("Ir para cadastro");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Funcionalidade não implementada.',
                                      ),
                                    ),
                                  );
                                  // TODO: Navegar para a tela de cadastro real
                                },
                        child: Text(
                          "Cadastre-se",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.primary, // Coral
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
