// lib/anamnesis_form_screen.dart
import 'package:flutter/material.dart';
import 'models.dart';

class AnamnesisFormScreen extends StatefulWidget {
  final Patient patient; // Recebe o paciente para associar a anamnese

  const AnamnesisFormScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  State<AnamnesisFormScreen> createState() => _AnamnesisFormScreenState();
}

class _AnamnesisFormScreenState extends State<AnamnesisFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores e Variáveis de Estado para cada campo
  final _chiefComplaintController = TextEditingController();
  final _allergiesController =
      TextEditingController(); // Para descrever outras alergias
  bool _allergyPenicillin = false;
  bool _allergyAnalgesics = false;
  bool _allergyAnesthetics = false;
  bool _allergyLatex = false;
  bool _hasHeartProblems = false;
  bool _hasDiabetes = false;
  bool _hasBleedingDisorders = false;
  bool _hasOsteoporosis = false;
  bool _usesBisphosphonates = false; // Só habilita se Osteoporose for true
  bool _hasContagiousDisease = false;
  final _medicationsInUseController = TextEditingController();
  bool _isPregnant = false;
  bool _hadAdverseReaction = false;
  bool _isSmoker = false;
  bool _consumesAlcohol = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-popula o formulário se a anamnese já existir (modo edição)
    final existingAnamnesis = widget.patient.anamnesis;
    if (existingAnamnesis != null) {
      _chiefComplaintController.text = existingAnamnesis.chiefComplaint;
      _allergiesController.text =
          existingAnamnesis.allergies.join(', '); // Junta a lista
      _allergyPenicillin = existingAnamnesis.allergyPenicillin;
      _allergyAnalgesics = existingAnamnesis.allergyAnalgesics;
      _allergyAnesthetics = existingAnamnesis.allergyAnesthetics;
      _allergyLatex = existingAnamnesis.allergyLatex;
      _hasHeartProblems = existingAnamnesis.hasHeartProblems;
      _hasDiabetes = existingAnamnesis.hasDiabetes;
      _hasBleedingDisorders = existingAnamnesis.hasBleedingDisorders;
      _hasOsteoporosis = existingAnamnesis.hasOsteoporosis;
      _usesBisphosphonates = existingAnamnesis.usesBisphosphonates;
      _hasContagiousDisease = existingAnamnesis.hasContagiousDisease;
      _medicationsInUseController.text = existingAnamnesis.medicationsInUse;
      _isPregnant = existingAnamnesis.isPregnant;
      _hadAdverseReaction = existingAnamnesis.hadAdverseReaction;
      _isSmoker = existingAnamnesis.isSmoker;
      _consumesAlcohol = existingAnamnesis.consumesAlcohol;
    }
  }

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _allergiesController.dispose();
    _medicationsInUseController.dispose();
    super.dispose();
  }

  void _saveAnamnesis() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Cria o objeto Anamnese com os dados do formulário
      final newAnamnesis = Anamnesis(
        chiefComplaint: _chiefComplaintController.text.trim(),
        // Separa a string de alergias por vírgula (simples)
        allergies: _allergiesController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        allergyPenicillin: _allergyPenicillin,
        allergyAnalgesics: _allergyAnalgesics,
        allergyAnesthetics: _allergyAnesthetics,
        allergyLatex: _allergyLatex,
        hasHeartProblems: _hasHeartProblems,
        hasDiabetes: _hasDiabetes,
        hasBleedingDisorders: _hasBleedingDisorders,
        hasOsteoporosis: _hasOsteoporosis,
        usesBisphosphonates: _hasOsteoporosis
            ? _usesBisphosphonates
            : false, // Só salva se tiver osteoporose
        hasContagiousDisease: _hasContagiousDisease,
        medicationsInUse: _medicationsInUseController.text.trim(),
        isPregnant: _isPregnant,
        hadAdverseReaction: _hadAdverseReaction,
        isSmoker: _isSmoker,
        consumesAlcohol: _consumesAlcohol,
      );

      // Simula salvamento
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Retorna a anamnese salva para a tela de perfil
          Navigator.pop(context, newAnamnesis);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor, corrija os erros ou preencha os campos obrigatórios.'),
            backgroundColor: Colors.orangeAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Anamnese - ${widget.patient.name}'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Queixa Principal ---
              Text('Queixa Principal / Motivo da Consulta:',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _chiefComplaintController,
                decoration: _buildInputDecoration(
                    hintText: 'Ex: Dor no dente, limpeza, check-up...'),
                maxLines: 3,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 20),

              // --- Alergias ---
              Text('Alergias Conhecidas:', style: theme.textTheme.titleMedium),
              _buildSwitchTile('Penicilina', _allergyPenicillin,
                  (value) => setState(() => _allergyPenicillin = value)),
              _buildSwitchTile(
                  'Anti-inflamatórios / Analgésicos',
                  _allergyAnalgesics,
                  (value) => setState(() => _allergyAnalgesics = value)),
              _buildSwitchTile('Anestésicos Locais', _allergyAnesthetics,
                  (value) => setState(() => _allergyAnesthetics = value)),
              _buildSwitchTile('Látex', _allergyLatex,
                  (value) => setState(() => _allergyLatex = value)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _allergiesController,
                decoration: _buildInputDecoration(
                    hintText:
                        'Descreva outras alergias (se houver), separadas por vírgula'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // --- Doenças Preexistentes ---
              Text('Doenças Preexistentes Relevantes:',
                  style: theme.textTheme.titleMedium),
              _buildSwitchTile(
                  'Problemas Cardíacos (Pressão Alta, Sopro, Cirurgia, etc.)',
                  _hasHeartProblems,
                  (value) => setState(() => _hasHeartProblems = value)),
              _buildSwitchTile('Diabetes', _hasDiabetes,
                  (value) => setState(() => _hasDiabetes = value)),
              _buildSwitchTile(
                  'Problemas de Coagulação / Sangramento',
                  _hasBleedingDisorders,
                  (value) => setState(() => _hasBleedingDisorders = value)),
              _buildSwitchTile('Osteoporose', _hasOsteoporosis, (value) {
                // Atualiza estado e visibilidade do campo de bifosfonatos
                setState(() {
                  _hasOsteoporosis = value;
                  if (!value) {
                    _usesBisphosphonates = false;
                  } // Reseta se não tem osteoporose
                });
              }),
              // Mostra campo de bifosfonatos SOMENTE se osteoporose for true
              if (_hasOsteoporosis)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0), // Indenta um pouco
                  child: _buildSwitchTile(
                      'Usa/usou Bifosfonatos (Alendronato, etc.)?',
                      _usesBisphosphonates,
                      (value) => setState(() => _usesBisphosphonates = value)),
                ),
              _buildSwitchTile(
                  'Doenças Contagiosas (Hepatite, HIV, Tuberculose, etc.)',
                  _hasContagiousDisease,
                  (value) => setState(() => _hasContagiousDisease = value)),
              const SizedBox(height: 20),

              // --- Medicações em Uso ---
              Text('Medicações em Uso Regular:',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicationsInUseController,
                decoration: _buildInputDecoration(
                    hintText:
                        'Liste todos os medicamentos, incluindo dosagem se possível'),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // --- Outras Perguntas ---
              Text('Outras Informações Importantes:',
                  style: theme.textTheme.titleMedium),
              _buildSwitchTile('Está grávida ou suspeita de gravidez?',
                  _isPregnant, (value) => setState(() => _isPregnant = value)),
              _buildSwitchTile(
                  'Já teve alguma reação adversa a tratamento odontológico anterior?',
                  _hadAdverseReaction,
                  (value) => setState(() => _hadAdverseReaction = value)),
              _buildSwitchTile('Fuma?', _isSmoker,
                  (value) => setState(() => _isSmoker = value)),
              _buildSwitchTile(
                  'Consome bebidas alcoólicas regularmente?',
                  _consumesAlcohol,
                  (value) => setState(() => _consumesAlcohol = value)),
              const SizedBox(height: 40),

              // --- Botão Salvar ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      // Centraliza o botão
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Salvar Anamnese'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        onPressed: _saveAnamnesis,
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para criar SwitchListTile padronizado
  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      dense: true, // Torna mais compacto
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 0, vertical: 0), // Remove padding extra
      activeColor:
          Theme.of(context).colorScheme.primary, // Cor Coral quando ativo
      inactiveTrackColor:
          Colors.white.withOpacity(0.2), // Cor da trilha inativa
    );
  }

  // Helper para criar decoração padrão dos inputs (pode ser o mesmo do outro form)
  InputDecoration _buildInputDecoration({String? labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
      // Adaptação para o formulário de anamnese
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5), // Destaca com Coral
      ),
      contentPadding: const EdgeInsets.symmetric(
          vertical: 12, horizontal: 15), // Padding interno
    );
  }
}
