// lib/agenda_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de datas
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart'; // Para o WhatsApp
import 'models.dart'; // Importa nossos modelos
import 'appointment_form_screen.dart'; // Tela que vamos criar

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  // Estado do Calendário
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Gerenciamento de Eventos (Agendamentos) - Usar um Map
  // A chave é o dia (normalizado para meia-noite) e o valor é a lista de agendamentos
  Map<DateTime, List<Appointment>> _events = {}; // Inicialmente vazio

  // Lista de eventos para o dia selecionado
  List<Appointment> _selectedEvents = [];

  // Mock de pacientes (em um app real, viria do banco de dados/API)
  late List<Patient> _availablePatients;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _availablePatients = Patient.getMockPatients();
    // Inicializa com alguns eventos mockados (OPCIONAL)
    _events = _createMockEvents();
    // Carrega os eventos para o dia inicialmente selecionado
    _selectedEvents = _getEventsForDay(_selectedDay!);
  }

  // --- Funções Auxiliares ---

  // Cria eventos mockados para teste
  Map<DateTime, List<Appointment>> _createMockEvents() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));
    final patients = Patient.getMockPatients(); // Pega os pacientes mockados

    // Normaliza as datas para meia-noite para usar como chave do Map
    DateTime normalizeDate(DateTime date) =>
        DateTime(date.year, date.month, date.day);

    return {
      normalizeDate(today): [
        Appointment(
          id: 'a1',
          patient: patients[0],
          procedure: 'Limpeza',
          date: today,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 9, minute: 45),
        ),
        Appointment(
          id: 'a2',
          patient: patients[1],
          procedure: 'Avaliação',
          date: today,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 30),
        ),
      ],
      normalizeDate(tomorrow): [
        Appointment(
          id: 'a3',
          patient: patients[3],
          procedure: 'Restauração',
          date: tomorrow,
          startTime: const TimeOfDay(hour: 14, minute: 0),
          endTime: const TimeOfDay(hour: 15, minute: 0),
        ),
      ],
      normalizeDate(dayAfter): [
        Appointment(
          id: 'a4',
          patient: patients[2],
          procedure: 'Extração Simples',
          date: dayAfter,
          startTime: const TimeOfDay(hour: 8, minute: 30),
          endTime: const TimeOfDay(hour: 9, minute: 30),
        ),
        Appointment(
          id: 'a5',
          patient: patients[4],
          procedure: 'Clareamento',
          date: dayAfter,
          startTime: const TimeOfDay(hour: 11, minute: 0),
          endTime: const TimeOfDay(hour: 12, minute: 0),
        ),
      ],
    };
  }

  // Retorna a lista de eventos para um determinado dia
  List<Appointment> _getEventsForDay(DateTime day) {
    // Normaliza o dia para garantir que a chave do Map seja correspondida
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ??
        []; // Retorna lista vazia se não houver eventos
  }

  // Chamada quando um dia é selecionado no calendário
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay; // Atualiza o foco também
        _selectedEvents = _getEventsForDay(
          selectedDay,
        ); // Atualiza a lista de eventos
      });
    }
  }

  // Navega para a tela de formulário para adicionar novo agendamento
  void _navigateAndAddAppointment(BuildContext context) async {
    final result = await Navigator.push<Appointment>(
      // Espera um Appointment de volta
      context,
      MaterialPageRoute(
        builder:
            (context) => AppointmentFormScreen(
              selectedDate:
                  _selectedDay ?? DateTime.now(), // Passa o dia selecionado
              availablePatients:
                  _availablePatients, // Passa a lista de pacientes
            ),
      ),
    );

    // Se um agendamento foi criado e retornado
    if (result != null && mounted) {
      // Verifica se o widget ainda está montado
      final appointmentDate = DateTime(
        result.date.year,
        result.date.month,
        result.date.day,
      );
      setState(() {
        if (_events.containsKey(appointmentDate)) {
          // Adiciona à lista existente
          _events[appointmentDate]!.add(result);
          // Ordena por horário de início (opcional mas recomendado)
          _events[appointmentDate]!.sort((a, b) {
            final timeA = a.startTime.hour * 60 + a.startTime.minute;
            final timeB = b.startTime.hour * 60 + b.startTime.minute;
            return timeA.compareTo(timeB);
          });
        } else {
          // Cria uma nova lista para esta data
          _events[appointmentDate] = [result];
        }
        // Atualiza a lista de eventos selecionados se o agendamento for para o dia atual
        if (isSameDay(appointmentDate, _selectedDay)) {
          _selectedEvents = _getEventsForDay(_selectedDay!);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Agendamento para ${result.patient.name} salvo!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Mostra o diálogo com detalhes do agendamento e ações
  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor.withOpacity(
            0.95,
          ), // Fundo do tema
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Detalhes do Agendamento',
            style: theme.textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            // Caso o conteúdo seja grande
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Para ocupar o mínimo de espaço vertical
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paciente:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  appointment.patient.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Procedimento:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(appointment.procedure, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(
                  'Data:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy', 'pt_BR').format(appointment.date),
                  style: theme.textTheme.titleMedium,
                ), // Formata data
                const SizedBox(height: 12),
                Text(
                  'Horário:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  appointment.formattedTimeRange,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (appointment.patient.phoneNumber !=
                    null) // Mostra telefone se disponível
                  Text(
                    'Telefone:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                if (appointment.patient.phoneNumber != null)
                  Text(
                    appointment.patient.phoneNumber!,
                    style: theme.textTheme.titleMedium,
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            // Botão WhatsApp (se tiver número)
            if (appointment.patient.phoneNumber != null)
              TextButton.icon(
                icon: const Icon(Icons.message, color: Colors.greenAccent),
                label: const Text(
                  'WhatsApp',
                  style: TextStyle(color: Colors.greenAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  _launchWhatsApp(appointment);
                },
              ),
            // Botão Google Agenda (Placeholder)
            TextButton.icon(
              icon: Icon(
                Icons.calendar_month,
                color: theme.colorScheme.primary,
              ),
              label: Text(
                'Google Agenda',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                _addToGoogleCalendar(appointment);
              },
            ),
            TextButton(
              child: const Text(
                'Fechar',
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }

  // Função para tentar enviar mensagem via WhatsApp
  Future<void> _launchWhatsApp(Appointment appointment) async {
    final String? phoneNumber = appointment.patient.phoneNumber?.replaceAll(
      RegExp(r'\D'),
      '',
    ); // Remove não dígitos
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Número de telefone do paciente não cadastrado.'),
        ),
      );
      return;
    }

    // Mensagem padrão (pode ser personalizada)
    final String message = Uri.encodeComponent(
      'Olá ${appointment.patient.name}, lembrando da sua consulta odontológica no dia ${DateFormat('dd/MM', 'pt_BR').format(appointment.date)} às ${appointment.formattedTimeRange.split(' - ')[0]}. Procedimento: ${appointment.procedure}. Clínica DentalCare.',
    );

    // Cria a URL do WhatsApp (wa.me)
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=$message',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        ); // Abre no app externo
      } else {
        throw 'Não foi possível abrir o WhatsApp.';
      }
    } catch (e) {
      print('Erro ao abrir WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tentar abrir o WhatsApp: $e')),
      );
    }
  }

  // Função placeholder para adicionar ao Google Agenda
  void _addToGoogleCalendar(Appointment appointment) {
    // Esta é uma funcionalidade complexa.
    // Requer integração com a API do Google Calendar ou uso de pacotes como 'add_2_calendar'.
    // Por enquanto, apenas exibimos uma mensagem.
    print(
      'Tentando adicionar ao Google Agenda (NÃO IMPLEMENTADO): ${appointment.procedure}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Integração com Google Agenda ainda não implementada.'),
        duration: Duration(seconds: 3),
      ),
    );

    // Exemplo básico usando add_2_calendar (se instalado):
    /*
     import 'package:add_2_calendar/add_2_calendar.dart';

     final Event event = Event(
       title: 'Consulta Odontológica: ${appointment.procedure}',
       description: 'Consulta com ${appointment.patient.name}. Procedimento: ${appointment.procedure}.',
       location: 'Consultório DentalCare', // Adicione o local se tiver
       startDate: DateTime(appointment.date.year, appointment.date.month, appointment.date.day, appointment.startTime.hour, appointment.startTime.minute),
       endDate: DateTime(appointment.date.year, appointment.date.month, appointment.date.day, appointment.endTime.hour, appointment.endTime.minute),
       // iosParams: IOSParams( reminder: Duration(minutes: 30),), // Lembrete no iOS
       // androidParams: AndroidParams( emailInvites: [], ), // Convidados no Android
       allDay: false,
     );
     Add2Calendar.addEvent2Cal(event);
     */
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        automaticallyImplyLeading: false,
        elevation: 2, // Uma leve sombra para destacar do calendário
      ),
      body: Column(
        children: [
          TableCalendar<Appointment>(
            locale: 'pt_BR', // Define o idioma para Português do Brasil
            firstDay: DateTime.utc(2020, 1, 1), // Data inicial permitida
            lastDay: DateTime.utc(2030, 12, 31), // Data final permitida
            focusedDay: _focusedDay, // Dia/Mês em foco
            selectedDayPredicate:
                (day) =>
                    isSameDay(_selectedDay, day), // Marca o dia selecionado
            calendarFormat: _calendarFormat, // Formato (mês, 2 semanas, semana)
            eventLoader:
                _getEventsForDay, // Função que carrega eventos para cada dia
            startingDayOfWeek:
                StartingDayOfWeek.monday, // Começa a semana na segunda
            // Estilização do Calendário (ajuste conforme o tema)
            calendarStyle: CalendarStyle(
              // Marcador de hoje
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(
                  0.5,
                ), // Coral semitransparente
                shape: BoxShape.circle,
              ),
              // Marcador do dia selecionado
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary, // Coral sólido
                shape: BoxShape.circle,
              ),
              // Marcadores de eventos (pontos abaixo do dia)
              markerDecoration: BoxDecoration(
                color:
                    Theme.of(
                      context,
                    ).colorScheme.secondary, // Pode usar outra cor
                shape: BoxShape.circle,
              ),
              markerSize: 5.0,
              markersAlignment: Alignment.bottomCenter,
              // Cores do texto
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false, // Esconde o botão de trocar formato
              titleCentered: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white70),
              weekendStyle: TextStyle(color: Colors.white54),
            ),

            // Callbacks
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // Não precisa selecionar o dia ao mudar de página
              _focusedDay = focusedDay;
              // Atualiza o estado para reconstruir, se necessário (opcional)
              // setState((){});
            },
          ),
          const SizedBox(height: 8.0),
          // Linha divisória
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.white24),
          ),
          // Lista de eventos para o dia selecionado
          Expanded(
            // Ocupa o espaço restante
            child:
                _selectedEvents.isEmpty
                    ? Center(
                      child: Text(
                        "Nenhum agendamento para este dia.",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        final appointment = _selectedEvents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          color: Colors.white.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              // Horário como avatar
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.8),
                              radius: 22,
                              child: Text(
                                appointment.startTime
                                    .format(context)
                                    .split(' ')[0], // Pega só a hora HH:MM
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            title: Text(
                              appointment.patient.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              appointment.procedure,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            trailing: Text(
                              appointment
                                  .formattedTimeRange, // Intervalo completo
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            onTap:
                                () => _showAppointmentDetails(
                                  context,
                                  appointment,
                                ), // Mostra detalhes ao tocar
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndAddAppointment(context),
        tooltip: 'Novo Agendamento',
        backgroundColor: Theme.of(context).colorScheme.primary, // Coral
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
