// lib/models.dart
import 'package:flutter/material.dart'; // Necessário para TimeOfDay

// --- Classe Anamnese ---
class Anamnesis {
  final String chiefComplaint; // Queixa principal
  final List<String> allergies; // Lista de alergias descritas
  // Campos específicos para alergias comuns (simplificado)
  final bool allergyPenicillin;
  final bool allergyAnalgesics;
  final bool allergyAnesthetics;
  final bool allergyLatex;
  // Doenças preexistentes (simplificado com booleanos)
  final bool hasHeartProblems;
  final bool hasDiabetes;
  final bool hasBleedingDisorders;
  final bool hasOsteoporosis;
  final bool usesBisphosphonates; // Específico para osteoporose
  final bool
      hasContagiousDisease; // Campo genérico para hepatite, HIV, etc. (sensível)
  final String medicationsInUse; // Medicamentos em uso
  final bool isPregnant; // Está grávida?
  final bool hadAdverseReaction; // Teve reação adversa anterior?
  final bool isSmoker; // Fuma?
  final bool consumesAlcohol; // Consome álcool regularmente?

  Anamnesis({
    required this.chiefComplaint,
    required this.allergies,
    required this.allergyPenicillin,
    required this.allergyAnalgesics,
    required this.allergyAnesthetics,
    required this.allergyLatex,
    required this.hasHeartProblems,
    required this.hasDiabetes,
    required this.hasBleedingDisorders,
    required this.hasOsteoporosis,
    required this.usesBisphosphonates,
    required this.hasContagiousDisease,
    required this.medicationsInUse,
    required this.isPregnant,
    required this.hadAdverseReaction,
    required this.isSmoker,
    required this.consumesAlcohol,
  });
}

// --- Classe Paciente Atualizada ---
class Patient {
  final String id;
  final String name;
  final DateTime? dateOfBirth;
  final String? cpf;
  final String? phoneNumber;
  final String? email;
  // Endereço
  final String? street;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? cep;
  // Link para Anamnese (pode ser nulo se não preenchido)
  Anamnesis? anamnesis; // Modificável

  Patient({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.cpf,
    this.phoneNumber,
    this.email,
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
    this.cep,
    this.anamnesis, // Incluído no construtor
  });

  // Método para atualizar a anamnese (útil após preenchimento)
  void updateAnamnesis(Anamnesis newAnamnesis) {
    anamnesis = newAnamnesis;
  }

  // Método estático para dados mockados (atualizado)
  static List<Patient> getMockPatients() {
    // Cria alguns pacientes mockados, alguns com anamnese null
    return [
      Patient(
          id: 'p1',
          name: 'Maria Silva',
          phoneNumber: '5511987654321',
          dateOfBirth: DateTime(1985, 5, 15),
          cpf: '111.222.333-44',
          email: 'maria.silva@email.com',
          street: 'Rua das Flores',
          number: '123',
          city: 'São Paulo',
          state: 'SP',
          cep: '01234-567',
          anamnesis: null),
      Patient(
          id: 'p2',
          name: 'João Pereira',
          phoneNumber: '5521912345678',
          dateOfBirth: DateTime(1990, 10, 20),
          cpf: '222.333.444-55',
          street: 'Av. Principal',
          number: '456',
          neighborhood: 'Centro',
          city: 'Rio de Janeiro',
          state: 'RJ',
          cep: '20000-000',
          anamnesis: null),
      Patient(
          id: 'p3',
          name: 'Ana Costa',
          dateOfBirth: DateTime(1978, 3, 8),
          cpf: '333.444.555-66',
          email: 'ana.costa@server.net',
          city: 'Curitiba',
          state: 'PR',
          anamnesis: Anamnesis(
              // Exemplo de paciente com anamnese preenchida
              chiefComplaint: 'Check-up e Limpeza',
              allergies: ['Poeira'],
              allergyPenicillin: false,
              allergyAnalgesics: false,
              allergyAnesthetics: false,
              allergyLatex: false,
              hasHeartProblems: false,
              hasDiabetes: false,
              hasBleedingDisorders: false,
              hasOsteoporosis: false,
              usesBisphosphonates: false,
              hasContagiousDisease: false,
              medicationsInUse: 'Nenhum',
              isPregnant: false,
              hadAdverseReaction: false,
              isSmoker: false,
              consumesAlcohol: false)),
      Patient(
          id: 'p4',
          name: 'Carlos Souza',
          phoneNumber: '5531999998888',
          dateOfBirth: DateTime(2000, 12, 1),
          cpf: '444.555.666-77',
          city: 'Belo Horizonte',
          state: 'MG',
          anamnesis: null),
      Patient(
          id: 'p5',
          name: 'Beatriz Lima',
          anamnesis: null), // Paciente com poucos dados
      Patient(
          id: 'p6',
          name: 'Ricardo Alves',
          phoneNumber: '5541977776666',
          anamnesis: null),
    ];
  }
}

// --- Classe Agendamento (sem alterações diretas, mas mantida aqui) ---
class Appointment {
  final String id;
  final Patient patient; // Usa a classe Patient atualizada
  final String procedure;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  Appointment({
    required this.id,
    required this.patient,
    required this.procedure,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  // Helper para obter a string de horário formatada
  String get formattedTimeRange {
    // Função auxiliar para formatar TimeOfDay
    String formatTime(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }
}
