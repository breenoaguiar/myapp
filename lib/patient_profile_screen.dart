// lib/patient_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'anamnesis_form_screen.dart'; // Importa a tela da anamnese

class PatientProfileScreen extends StatefulWidget {
  final Patient patient; // Recebe o paciente

  const PatientProfileScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  // Variável local para refletir mudanças na anamnese sem precisar recarregar toda a lista
  // Isso é uma simplificação. Estado global seria melhor.
  late Anamnesis? _currentAnamnesis;

  @override
  void initState() {
    super.initState();
    _currentAnamnesis = widget.patient.anamnesis; // Pega a anamnese inicial
  }

  // Navega para a tela de anamnese e atualiza o estado local se ela for salva
  void _navigateToAnamnesisForm(BuildContext context) async {
    final savedAnamnesis = await Navigator.push<Anamnesis>(
      context,
      MaterialPageRoute(
          builder: (context) => AnamnesisFormScreen(patient: widget.patient)),
    );

    if (savedAnamnesis != null && mounted) {
      setState(() {
        _currentAnamnesis = savedAnamnesis;
        // !! IMPORTANTE: Atualiza o objeto original também para refletir na lista !!
        // Isso funciona porque objetos são passados por referência em Dart.
        widget.patient.updateAnamnesis(savedAnamnesis);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anamnese salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      // Indica para a tela anterior que algo mudou (opcional)
      // Navigator.pop(context, true); // Não precisamos mais disso se atualizarmos o objeto diretamente
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = widget.patient; // Atalho para o paciente

    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name), // Nome do paciente na AppBar
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Dados Pessoais', theme),
            _buildDetailItem(
                Icons.badge_outlined, 'CPF', patient.cpf ?? 'Não informado'),
            _buildDetailItem(
                Icons.cake_outlined,
                'Data de Nascimento',
                patient.dateOfBirth != null
                    ? DateFormat('dd/MM/yyyy').format(patient.dateOfBirth!)
                    : 'Não informada'),
            _buildDetailItem(Icons.phone_android_outlined, 'Telefone',
                patient.phoneNumber ?? 'Não informado'),
            _buildDetailItem(Icons.email_outlined, 'E-mail',
                patient.email ?? 'Não informado'),
            const SizedBox(height: 20),

            _buildSectionTitle('Endereço', theme),
            _buildDetailItem(
                Icons.signpost_outlined,
                'Logradouro',
                '${patient.street ?? '-'} Nº ${patient.number ?? 'S/N'} ${patient.complement ?? ''}'
                    .trim()),
            _buildDetailItem(Icons.holiday_village_outlined, 'Bairro',
                patient.neighborhood ?? 'Não informado'),
            _buildDetailItem(Icons.location_city_outlined, 'Cidade/UF',
                '${patient.city ?? '-'} / ${patient.state ?? '-'}'),
            _buildDetailItem(Icons.local_post_office_outlined, 'CEP',
                patient.cep ?? 'Não informado'),
            const SizedBox(height: 25),

            _buildSectionTitle('Anamnese', theme),
            _currentAnamnesis == null
                ? _buildAnamnesisPrompt(context) // Mostra o botão/prompt
                : _buildAnamnesisDisplay(
                    _currentAnamnesis!, theme), // Mostra os detalhes

            const SizedBox(height: 25),
            // TODO: Adicionar seção de Histórico de Atendimentos aqui no futuro
            // _buildSectionTitle('Histórico de Atendimentos', theme),
            // Center(child: Text('Nenhum atendimento registrado.', style: TextStyle(color: Colors.white54))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper para título de seção (pode ser o mesmo do form)
  Widget _buildSectionTitle(String title, ThemeData theme) {
    /* ... código do título ... */
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

  // Helper para exibir um item de detalhe
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? '-' : value,
                    style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget mostrado quando a anamnese NÃO foi feita
  Widget _buildAnamnesisPrompt(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orangeAccent[100]),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Anamnese não realizada!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          const SizedBox(height: 10),
          Text(
              'É fundamental preencher a anamnese antes de iniciar qualquer procedimento.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.assignment_outlined),
            label: const Text('Realizar Anamnese Agora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary, // Coral
              foregroundColor: Colors.white,
            ),
            onPressed: () => _navigateToAnamnesisForm(context),
          ),
        ]),
      ),
    );
  }

  // Widget para exibir os detalhes da anamnese JÁ PREENCHIDA
  Widget _buildAnamnesisDisplay(Anamnesis anamnesisData, ThemeData theme) {
    // Função auxiliar para simplificar a exibição de booleanos
    String boolToString(bool value) => value ? 'Sim' : 'Não';
    Color boolToColor(bool value) =>
        value ? Colors.orangeAccent : Colors.white70;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem(Icons.question_answer_outlined, 'Queixa Principal',
              anamnesisData.chiefComplaint),
          _buildDetailItem(
              Icons.healing_outlined,
              'Alergias Descritas',
              anamnesisData.allergies.isEmpty
                  ? 'Nenhuma'
                  : anamnesisData.allergies.join(', ')),
          // Detalhes específicos de alergias (simplificado)
          Wrap(
            // Usa Wrap para os itens de alergia/doença
            spacing: 10, runSpacing: 5,
            children: [
              Chip(
                  label: Text(
                      'Penicilina: ${boolToString(anamnesisData.allergyPenicillin)}'),
                  backgroundColor: boolToColor(anamnesisData.allergyPenicillin)
                      .withOpacity(0.3)),
              Chip(
                  label: Text(
                      'Analgésicos: ${boolToString(anamnesisData.allergyAnalgesics)}'),
                  backgroundColor: boolToColor(anamnesisData.allergyAnalgesics)
                      .withOpacity(0.3)),
              Chip(
                  label: Text(
                      'Anestésicos: ${boolToString(anamnesisData.allergyAnesthetics)}'),
                  backgroundColor: boolToColor(anamnesisData.allergyAnesthetics)
                      .withOpacity(0.3)),
              Chip(
                  label: Text(
                      'Látex: ${boolToString(anamnesisData.allergyLatex)}'),
                  backgroundColor:
                      boolToColor(anamnesisData.allergyLatex).withOpacity(0.3)),
            ],
          ),
          const Divider(height: 20, color: Colors.white12),
          Text('Doenças Preexistentes:',
              style:
                  theme.textTheme.titleSmall?.copyWith(color: Colors.white70)),
          Wrap(spacing: 10, runSpacing: 5, children: [
            Chip(
                label: Text(
                    'Cardíaco: ${boolToString(anamnesisData.hasHeartProblems)}'),
                backgroundColor: boolToColor(anamnesisData.hasHeartProblems)
                    .withOpacity(0.3)),
            Chip(
                label: Text(
                    'Diabetes: ${boolToString(anamnesisData.hasDiabetes)}'),
                backgroundColor:
                    boolToColor(anamnesisData.hasDiabetes).withOpacity(0.3)),
            Chip(
                label: Text(
                    'Sangramento: ${boolToString(anamnesisData.hasBleedingDisorders)}'),
                backgroundColor: boolToColor(anamnesisData.hasBleedingDisorders)
                    .withOpacity(0.3)),
            Chip(
                label: Text(
                    'Osteoporose: ${boolToString(anamnesisData.hasOsteoporosis)}'),
                backgroundColor: boolToColor(anamnesisData.hasOsteoporosis)
                    .withOpacity(0.3)),
            if (anamnesisData.hasOsteoporosis)
              Chip(
                  label: Text(
                      'Usa Bifosfonato: ${boolToString(anamnesisData.usesBisphosphonates)}'),
                  backgroundColor:
                      boolToColor(anamnesisData.usesBisphosphonates)
                          .withOpacity(0.3)),
            Chip(
                label: Text(
                    'Contagiosa: ${boolToString(anamnesisData.hasContagiousDisease)}'),
                backgroundColor: boolToColor(anamnesisData.hasContagiousDisease)
                    .withOpacity(0.3)),
          ]),
          const Divider(height: 20, color: Colors.white12),
          _buildDetailItem(
              Icons.medication_outlined,
              'Medicações em Uso',
              anamnesisData.medicationsInUse.isEmpty
                  ? 'Nenhuma'
                  : anamnesisData.medicationsInUse),
          _buildDetailItem(Icons.pregnant_woman_outlined, 'Gravidez',
              boolToString(anamnesisData.isPregnant)),
          _buildDetailItem(
              Icons.report_problem_outlined,
              'Reação Adversa Anterior',
              boolToString(anamnesisData.hadAdverseReaction)),
          _buildDetailItem(Icons.smoking_rooms_outlined, 'Fumante',
              boolToString(anamnesisData.isSmoker)),
          _buildDetailItem(Icons.local_bar_outlined, 'Consome Álcool',
              boolToString(anamnesisData.consumesAlcohol)),
          const SizedBox(height: 10),
          // Botão para editar (opcional)
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text("Editar Anamnese"),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              onPressed: () =>
                  _navigateToAnamnesisForm(context), // Reabre o form
            ),
          ),
        ],
      ),
    );
  }
}
