// lib/home_screen.dart
import 'package:flutter/material.dart';

// Enum e Classe AppointmentInfo aqui (como definido anteriormente)
enum AppointmentStatus { inProgress, waiting, attended, canceled }

class AppointmentInfo {
  final String patientName;
  final AppointmentStatus status;
  AppointmentInfo(this.patientName, this.status);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Função de Logout
  void _logout(BuildContext context) {
    // Navega para a tela de login e remove todas as rotas anteriores
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Dados Fictícios
    const int totalAppointments = 25;
    const int attendedAppointments = 10;
    const int remainingAppointments = totalAppointments - attendedAppointments;
    final List<AppointmentInfo> timeline = [
      AppointmentInfo("Maria Silva", AppointmentStatus.inProgress),
      AppointmentInfo("João Pereira", AppointmentStatus.waiting),
      AppointmentInfo("Ana Costa", AppointmentStatus.waiting),
      AppointmentInfo("Carlos Souza", AppointmentStatus.attended),
      AppointmentInfo("Beatriz Lima", AppointmentStatus.canceled),
      AppointmentInfo("Ricardo Alves", AppointmentStatus.waiting),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        backgroundColor:
            Colors.transparent, // AppBar transparente para misturar com fundo
        elevation: 0,
        actions: [
          // Adiciona a seção de ações na AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _logout(context), // Chama a função de logout
          ),
        ],
      ),
      // Estende o corpo para trás da AppBar
      extendBodyBehindAppBar: true,
      body: Container(
        // Container para aplicar gradiente ou cor sólida de fundo se necessário
        decoration: BoxDecoration(
          color:
              Theme.of(
                context,
              ).scaffoldBackgroundColor, // Usa a cor roxa principal
          // Ou adicione um gradiente se desejar:
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [primaryPurple.withOpacity(0.8), primaryPurple],
          // ),
        ),
        child: SafeArea(
          // SafeArea dentro do corpo para evitar sobreposição com status bar
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: kToolbarHeight - 20,
                ), // Espaço para compensar AppBar transparente
                // --- Seção de Métricas ---
                Text(
                  'Resumo do Dia',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: [
                    _buildMetricCard(
                      context,
                      title: 'Agendados Hoje',
                      value: totalAppointments.toString(),
                      icon: Icons.calendar_month_outlined,
                      color: Colors.blue.withOpacity(0.8),
                    ),
                    _buildMetricCard(
                      context,
                      title: 'Atendidos',
                      value: attendedAppointments.toString(),
                      icon: Icons.check_circle_outline,
                      color: Colors.green.withOpacity(0.8),
                    ),
                    _buildMetricCard(
                      context,
                      title: 'Restantes',
                      value: remainingAppointments.toString(),
                      icon: Icons.hourglass_bottom_outlined,
                      color: Colors.orange.withOpacity(0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- Seção da Timeline ---
                Text(
                  'Próximos Atendimentos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  // Usar ListView.builder é melhor para listas dinâmicas
                  shrinkWrap:
                      true, // Necessário dentro de SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Desabilita scroll do ListView
                  itemCount: timeline.length,
                  itemBuilder: (context, index) {
                    return _buildTimelineTile(context, timeline[index]);
                  },
                ),
                const SizedBox(height: 20), // Espaço no final
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares (_buildMetricCard, _buildTimelineTile) ---
  // Mantenha os widgets auxiliares como definidos anteriormente
  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    /* ... código do card ... */
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 150,
        minHeight: 120,
      ), // Define altura minima também
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ), // Mais arredondado
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Distribui espaço
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Icon(icon, size: 28, color: Colors.white.withOpacity(0.8)),
                ],
              ),

              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTile(BuildContext context, AppointmentInfo info) {
    /* ... código do tile ... */
    final theme = Theme.of(context);
    IconData statusIcon;
    Color statusColor;
    String statusText;
    switch (info.status) {
      case AppointmentStatus.inProgress:
        statusIcon = Icons.directions_run;
        statusColor = theme.colorScheme.primary;
        statusText = 'Em atendimento';
        break;
      case AppointmentStatus.waiting:
        statusIcon = Icons.hourglass_top_outlined;
        statusColor = Colors.blueAccent;
        statusText = 'Aguardando';
        break;
      case AppointmentStatus.attended:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Atendido';
        break;
      case AppointmentStatus.canceled:
        statusIcon = Icons.cancel_outlined;
        statusColor = Colors.redAccent;
        statusText = 'Desmarcado';
        break;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          // Avatar para o ícone
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor, size: 20),
          radius: 20,
        ),
        title: Text(
          info.patientName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          statusText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:
            info.status == AppointmentStatus.waiting ||
                    info.status == AppointmentStatus.inProgress
                ? IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  color: Colors.white54,
                  tooltip: "Ver detalhes",
                  onPressed: () {
                    print("Ver detalhes de ${info.patientName}");
                    // TODO: Navegar para detalhes do paciente/agenda
                  },
                )
                : null,
      ),
    );
  }
}
