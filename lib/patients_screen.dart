// lib/patients_screen.dart
import 'package:flutter/material.dart';
import 'models.dart'; // Importa os modelos atualizados
import 'patient_registration_screen.dart'; // Importa a nova tela de cadastro
import 'patient_profile_screen.dart'; // Importa a tela de perfil

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  // Lista de pacientes gerenciada pelo estado (inicialmente mockada)
  // !! Em um app real, isso viria de um banco de dados/gerenciador de estado !!
  late List<Patient> _patients;

  @override
  void initState() {
    super.initState();
    // Carrega os pacientes mockados ao iniciar a tela
    // Em um app real, você carregaria do seu banco de dados/API aqui
    _patients = Patient.getMockPatients();
    // Ordena por nome (opcional)
    _patients.sort((a, b) => a.name.compareTo(b.name));
  }

  // Navega para a tela de cadastro e atualiza a lista se um novo paciente for adicionado
  void _navigateAndAddPatient(BuildContext context) async {
    // Navega para a tela de cadastro e espera um resultado (o novo paciente)
    final newPatient = await Navigator.push<Patient>(
      context,
      MaterialPageRoute(
          builder: (context) => const PatientRegistrationScreen()),
    );

    // Se um novo paciente foi retornado (ou seja, o cadastro foi concluído)
    if (newPatient != null && mounted) {
      // 'mounted' verifica se a tela ainda existe
      setState(() {
        _patients.add(newPatient);
        // Mantém a lista ordenada por nome após adicionar
        _patients.sort((a, b) => a.name.compareTo(b.name));
      });
      // Mostra uma confirmação para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paciente ${newPatient.name} cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Navega para o perfil do paciente selecionado
  void _navigateToPatientProfile(BuildContext context, Patient patient) async {
    // Navega para a tela de perfil, passando o objeto do paciente
    // Podemos esperar um resultado (ex: bool indicando se a anamnese foi salva)
    // para atualizar o estado se necessário, mas a abordagem atual modifica
    // o objeto 'patient' diretamente na tela de perfil/anamnese, o que já
    // reflete aqui (devido à passagem por referência).
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PatientProfileScreen(patient: patient)),
    );

    // Se precisássemos forçar uma reconstrução da lista (ex: se a fonte de dados fosse externa):
    // if (result == true && mounted) {
    //   setState(() {
    //      // Recarregaria os dados ou faria algo para atualizar a UI
    //      print("Retornou do perfil. Potencial atualização necessária.");
    //   });
    // }
    // Como estamos modificando o objeto em memória diretamente, apenas
    // reconstruir a tela (o que o setState faria) já mostraria as mudanças
    // se houvesse algo a ser exibido na lista (como um status de anamnese)
    // Atualmente, não há necessidade de setState aqui.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Pega o tema atual

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        automaticallyImplyLeading: false, // Remove o botão de voltar padrão
        elevation: 1, // Leve sombra para destacar a AppBar
      ),
      body: _patients.isEmpty
          // Se a lista de pacientes estiver vazia, mostra uma mensagem
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search,
                      size: 80, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum paciente cadastrado.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 20),
                  // Botão para adicionar o primeiro paciente
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar Primeiro Paciente'),
                    onPressed: () => _navigateAndAddPatient(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.primary, // Usa cor Coral do tema
                        foregroundColor: Colors.white // Cor do texto/ícone
                        ),
                  )
                ],
              ),
            )
          // Se houver pacientes, exibe a lista
          : ListView.builder(
              padding: const EdgeInsets.all(8.0), // Padding ao redor da lista
              itemCount: _patients.length, // Número de itens na lista
              itemBuilder: (context, index) {
                // Pega o paciente atual da lista
                final patient = _patients[index];
                // Cria um Card para cada paciente
                return Card(
                  margin: const EdgeInsets.only(
                      bottom: 8.0), // Espaço abaixo de cada card
                  color: Colors.white
                      .withOpacity(0.1), // Cor de fundo levemente transparente
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10)), // Bordas arredondadas
                  child: ListTile(
                    // Avatar com as iniciais do nome ou um ícone padrão
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary
                          .withOpacity(0.7), // Fundo coral semitransparente
                      foregroundColor: Colors.white,
                      child: Text(patient.name.isNotEmpty
                          ? patient.name[0].toUpperCase()
                          : '?'),
                    ),
                    // Nome do paciente
                    title: Text(patient.name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    // Subtítulo com contato (email ou telefone)
                    subtitle: Text(
                      patient.email ??
                          patient.phoneNumber ??
                          'Sem contato', // Mostra email ou telefone, ou texto padrão
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    // Ícone indicando que pode clicar para ver mais
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.white54),
                    // Ação ao tocar no item da lista
                    onTap: () => _navigateToPatientProfile(
                        context, patient), // Navega para o perfil do paciente
                  ),
                );
              },
            ),
      // Botão Flutuante para adicionar novo paciente
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndAddPatient(
            context), // Chama a função de navegação para cadastro
        tooltip: 'Adicionar Paciente', // Texto de ajuda ao pressionar e segurar
        backgroundColor: Theme.of(context).colorScheme.primary, // Cor Coral
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ), // Ícone de adicionar
      ),
    );
  }
}
