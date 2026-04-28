# Gigbag (Flutter Web)

App para organizar equipamentos por evento, com briefing/checklist de **ida** e **volta**.

## Requisitos

- Flutter (recomendado: stable)
- Chrome (para rodar no Web)

Este projeto foi criado para rodar **primeiro no Web** e depois evoluir para Android/iOS.

## Rodar local (Web)

No Windows (PowerShell ou CMD):

```bash
cd gigbag_app
flutter pub get
flutter run -d chrome
```

## Build Web (entregável)

```bash
cd gigbag_app
flutter build web --release
```

O output fica em `gigbag_app/build/web/`.

## O que o MVP faz

- **Inventário**
  - Criar/editar/excluir equipamentos
- **Eventos**
  - Criar/editar/excluir eventos
  - Selecionar quais equipamentos levar em cada evento
- **Briefings**
  - Briefing de **Ida** e de **Volta**
  - Checklist item a item, com barra de progresso
  - Ao finalizar, indica itens faltando; só permite “Concluir” quando tudo estiver marcado
- **Persistência local**
  - Dados ficam salvos no navegador (offline-friendly)

## Onde ficam os dados

Os dados são persistidos via `shared_preferences` (armazenamento local do browser).

Em **Ajustes → Apagar todos os dados** você limpa tudo do navegador atual.

# gigbag_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
