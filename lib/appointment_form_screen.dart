// lib/appointment_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart'; // Importa os modelos Patient e Appointment

class AppointmentFormScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Patient> availablePatients;

  const AppointmentFormScreen({
    Key? key,
    required this.selectedDate,
    required this.availablePatients,
  }) : super(key: key);

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Patient? _selectedPatient;
  final _procedureController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    // Define horários padrão (ex: 9:00 e 9:45)
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endTime = const TimeOfDay(hour: 9, minute: 45);
  }

  @override
  void dispose() {
    _procedureController.dispose();
    super.dispose();
  }

  // Função para mostrar o seletor de hora
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        // Aplica o tema escuro ao TimePicker
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary, // Cor de acento
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Theme.of(
              context,
            ).scaffoldBackgroundColor.withOpacity(0.9),
            // Estiliza botões se necessário
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.primary, // Cor de acento
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialTime) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Opcional: Ajusta a hora final se a inicial ultrapassá-la
          if (_endTime != null &&
              (picked.hour > _endTime!.hour ||
                  (picked.hour == _endTime!.hour &&
                      picked.minute >= _endTime!.minute))) {
            _endTime = TimeOfDay(
              hour: picked.hour,
              minute: picked.minute + 30,
            ); // Adiciona 30 min
          }
        } else {
          _endTime = picked;
          // Opcional: Garante que a hora final não seja antes da inicial
          if (_startTime != null &&
              (picked.hour < _startTime!.hour ||
                  (picked.hour == _startTime!.hour &&
                      picked.minute <= _startTime!.minute))) {
            // Poderia mostrar um erro ou ajustar a hora inicial
            _startTime = TimeOfDay(
              hour: picked.hour,
              minute: picked.minute - 30,
            );
          }
        }
      });
    }
  }

  // Função para salvar o agendamento
  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      // Verifica se os horários foram selecionados
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione os horários de início e fim.'),
          ),
        );
        return;
      }
      // Verifica se a hora final é depois da inicial
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O horário final deve ser após o horário inicial.'),
          ),
        );
        return;
      }

      // Cria o objeto Appointment
      final newAppointment = Appointment(
        // Gera um ID simples baseado no tempo (NÃO FAÇA ISSO EM PRODUÇÃO)
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patient: _selectedPatient!,
        procedure: _procedureController.text,
        date: widget.selectedDate, // Usa a data passada para a tela
        startTime: _startTime!,
        endTime: _endTime!,
      );

      // Retorna o novo agendamento para a tela anterior
      Navigator.pop(context, newAppointment);
    }
  }

  // Função auxiliar para formatar TimeOfDay
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Selecionar';
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(
      time,
      alwaysUse24HourFormat: true,
    ); // Usa formato 24h
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Pega o tema
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Novo Agendamento (${DateFormat('dd/MM/yyyy').format(widget.selectedDate)})',
        ),
        backgroundColor: theme.scaffoldBackgroundColor, // Mantém a cor de fundo
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Seleção de Paciente ---
              DropdownButtonFormField<Patient>(
                value: _selectedPatient,
                // Estilo para combinar com o tema
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ), // Cor do texto do item selecionado
                dropdownColor: theme.scaffoldBackgroundColor.withBlue(
                  150,
                ), // Cor de fundo do dropdown
                decoration: InputDecoration(
                  labelText: 'Paciente',
                  prefixIcon: const Icon(Icons.person_outline),
                  // Usa o tema global de input, mas podemos sobrescrever se necessário
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                items:
                    widget.availablePatients.map((Patient patient) {
                      return DropdownMenuItem<Patient>(
                        value: patient,
                        child: Text(patient.name), // Mostra o nome do paciente
                      );
                    }).toList(),
                onChanged: (Patient? newValue) {
                  setState(() {
                    _selectedPatient = newValue;
                  });
                },
                validator:
                    (value) => value == null ? 'Selecione um paciente' : null,
              ),
              const SizedBox(height: 20),

              // --- Procedimento ---
              TextFormField(
                controller: _procedureController,
                style: const TextStyle(
                  color: Colors.white,
                ), // Cor do texto digitado
                decoration: InputDecoration(
                  labelText: 'Procedimento',
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o procedimento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Seleção de Horário ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Início:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(_formatTimeOfDay(_startTime)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                theme.colorScheme.primary, // Cor texto/ícone
                            side: BorderSide(
                              color: theme.colorScheme.primary,
                            ), // Cor borda
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _selectTime(context, true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fim:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.access_time_filled),
                          label: Text(_formatTimeOfDay(_endTime)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _selectTime(context, false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40), // Espaço antes do botão
              // --- Botão Salvar ---
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Salvar Agendamento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveAppointment, // Chama a função de salvar
              ),
            ],
          ),
        ),
      ),
    );
  }
}
