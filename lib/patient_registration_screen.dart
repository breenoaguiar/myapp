// lib/patient_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar a data
import 'models.dart'; // Importa o modelo Patient

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos
  final _nameController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _cepController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    // Limpa todos os controladores
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  // Função para mostrar o seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900), // Data mínima
      lastDate: DateTime.now(), // Data máxima (hoje)
      locale: const Locale('pt', 'BR'), // Define local PT-BR
      builder: (context, child) {
        // Aplica tema escuro
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary, // Coral
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor:
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  // Função para salvar (concluir)
  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      }); // Mostra loading (simples)

      // Cria o novo paciente
      // !! Em um app real, aqui você enviaria os dados para API/Banco de Dados !!
      final newPatient = Patient(
        // Gera ID simples (NÃO USE EM PRODUÇÃO)
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        dateOfBirth: _selectedDateOfBirth,
        cpf: _cpfController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        street: _streetController.text.trim(),
        number: _numberController.text.trim(),
        complement: _complementController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        cep: _cepController.text.trim(),
        anamnesis: null, // Novo paciente começa sem anamnese
      );

      // Simula um tempo de salvamento
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Verifica se ainda está na tela
          setState(() {
            _isLoading = false;
          });
          // Retorna o paciente criado para a tela anterior
          Navigator.pop(context, newPatient);
        }
      });
    } else {
      // Mostra erro se a validação falhar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, corrija os erros no formulário.'),
            backgroundColor: Colors.orangeAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Pega o tema
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Novo Paciente'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Dados Pessoais ---
              _buildSectionTitle('Dados Pessoais', theme),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                    labelText: 'Nome Completo', icon: Icons.person),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 15),
              // Seletor de Data de Nascimento
              InputDecorator(
                decoration: _buildInputDecoration(
                    labelText: 'Data de Nascimento',
                    icon: Icons.calendar_today),
                child: InkWell(
                  // Permite toque na área toda
                  onTap: () => _selectDate(context),
                  child: Container(
                    height: 24, // Altura similar ao texto do TextFormField
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedDateOfBirth == null
                          ? 'DD/MM/AAAA'
                          : DateFormat('dd/MM/yyyy')
                              .format(_selectedDateOfBirth!),
                      style: TextStyle(
                          color: _selectedDateOfBirth == null
                              ? Colors.white54
                              : Colors.white,
                          fontSize: 16 // Tamanho padrão
                          ),
                    ),
                  ),
                ),
              ),
              // Validação simples para data (opcional)
              // if (_selectedDateOfBirth == null) Text('Selecione a data', style: TextStyle(color: Colors.red[700], fontSize: 12)),
              const SizedBox(height: 15),
              TextFormField(
                controller: _cpfController,
                decoration: _buildInputDecoration(
                    labelText: 'CPF', icon: Icons.badge_outlined),
                keyboardType: TextInputType.number,
                // TODO: Adicionar máscara/validador de CPF real
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration(
                    labelText: 'Telefone Celular (DDD)',
                    icon: Icons.phone_android),
                keyboardType: TextInputType.phone,
                // TODO: Adicionar máscara de telefone
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration(
                      labelText: 'E-mail', icon: Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        !value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null; // Email é opcional
                  }),
              const SizedBox(height: 25),

              // --- Endereço ---
              _buildSectionTitle('Endereço', theme),
              TextFormField(
                controller: _streetController,
                decoration: _buildInputDecoration(
                    labelText: 'Rua / Logradouro',
                    icon: Icons.signpost_outlined),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2, // Ocupa mais espaço
                    child: TextFormField(
                      controller: _numberController,
                      decoration: _buildInputDecoration(
                          labelText: 'Número', icon: Icons.looks_one_outlined),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _complementController,
                      decoration: _buildInputDecoration(
                          labelText: 'Complemento', icon: Icons.more_horiz),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _neighborhoodController,
                decoration: _buildInputDecoration(
                    labelText: 'Bairro', icon: Icons.holiday_village_outlined),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: _buildInputDecoration(
                          labelText: 'Cidade', icon: Icons.location_city),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Campo obrigatório'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1, // Menor espaço para UF
                    child: TextFormField(
                      controller: _stateController,
                      decoration: _buildInputDecoration(
                          labelText: 'UF', icon: Icons.map_outlined),
                      maxLength: 2, // Limita a 2 caracteres
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Req.'
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _cepController,
                decoration: _buildInputDecoration(
                    labelText: 'CEP', icon: Icons.local_post_office_outlined),
                keyboardType: TextInputType.number,
                // TODO: Adicionar máscara de CEP
              ),

              const SizedBox(height: 40),

              // --- Botões ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancelar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () =>
                              Navigator.pop(context), // Volta sem retornar nada
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Concluir Cadastro'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: _savePatient, // Chama a função de salvar
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para criar decoração padrão dos inputs
  InputDecoration _buildInputDecoration(
      {required String labelText, required IconData icon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, size: 20), // Ícone um pouco menor
      // Usa o tema global, mas podemos ajustar se precisar
      // Ex: border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      // filled: true, fillColor: Colors.white.withOpacity(0.05),
    );
  }

  // Helper para título de seção
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary, // Usa a cor Coral
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
