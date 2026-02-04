# 🎬 Application de Streaming de Films

Application iOS développée en Swift et SwiftUI permettant de découvrir, 
rechercher et gérer ses films favoris.

## 🚀 Démarrage

### Prérequis
- Xcode 15+
- iOS 16+
- Clé API TMDB

### Installation

1. Cloner le projet
2. Obtenir une clé API sur [TMDB](https://www.themoviedb.org/settings/api)
3. Remplacer `YOUR_TMDB_API_KEY` dans `TMDBEndpoint.swift`
4. Ouvrir dans Xcode et lancer

## 🎯 Fonctionnalités

✅ Authentification (inscription/connexion)
✅ Catalogue de films (TMDB API)
✅ Recherche de films
✅ Détails des films
✅ Gestion des favoris
✅ Profil utilisateur
✅ Persistance locale (UserDefaults)
✅ Navigation par onglets

## 🏗️ Architecture

- **MVVM** : Séparation Model/View/ViewModel
- **Services** : APIService, AuthService, PersistenceService
- **SwiftUI** : Interface 100% SwiftUI
- **Async/Await** : Gestion asynchrone moderne

## 📱 API Utilisée

**TMDB (The Movie Database)**
- Endpoint: https://api.themoviedb.org/3
- Films populaires, recherche, détails

## 💾 Persistance

- **UserDefaults** : Utilisateurs, sessions, favoris
- Données locales synchronisées par utilisateur
