# 🎬 MovieStreamingApp – Application de Streaming de Films

MovieStreamingApp est une **application iOS moderne** développée en **Swift & SwiftUI** qui permet de **découvrir, filtrer et gérer vos films favoris**.  

Avec MovieStreamingApp, plongez dans un catalogue complet de films, filtrez par critères pertinents et construisez votre collection personnalisée.

---

## 🚀 Démarrage

### Prérequis
- Xcode 15+
- iOS 16+
- Clé API TMDB (stockée dans `XSecret`)

### Installation

1. Cloner le projet
2. Obtenir une clé API sur [TMDB](https://www.themoviedb.org/settings/api)
3. Ajouter la clé dans `XSecret`
4. Ouvrir le projet dans Xcode et lancer l’application

---

## 🎯 Fonctionnalités clés

- **Authentification** : Inscription / Connexion  
- **Catalogue de films** : Films populaires, recherche et détails via TMDB API  
- **Filtres intelligents** :  
  - Par date de sortie  
  - Par nom / titre  
  - Par note  
- **Favoris** : Ajouter et consulter vos films préférés  
- **Profil utilisateur** : Gestion des informations et préférences  
- **Persistance locale** : Sauvegarde des utilisateurs et favoris dans **SQLite**  
- **Navigation fluide** : Interface par onglets, responsive iOS  

---

## 🏗️ Architecture technique

- **MVVM** : Modèle clair Model / View / ViewModel  
- **DAO + SQLite** : Tables `User` et `Favorite` pour persistance robuste  
- **Services** :  
  - `APIService` : communication avec TMDB  
  - `AuthService` : gestion des sessions  
- **SwiftUI** : UI moderne, animations fluides, composants réutilisables  
- **Async/Await** : gestion asynchrone simple et performante  

---

## 📱 API utilisée

**TMDB (The Movie Database)**  
- Base URL : `https://api.themoviedb.org/3`  
- Endpoints utilisés :  
  - Films populaires  
  - Recherche par mot-clé  
  - Détails des films  

> La clé API est désormais **sécurisée** via `XSecret` pour éviter toute fuite.

---

## 💾 Persistance locale

- **SQLite via DAO** : Tables principales  
  - `User` : informations utilisateur et session  
  - `Favorite` : films ajoutés aux favoris  
- Les favoris et préférences sont stockés localement et synchronisés par utilisateur  

---

## ✨ Avantages

- Interface **100% SwiftUI** et moderne  
- Gestion **robuste des données locales**  
- Filtres avancés pour une **recherche rapide et pertinente**  
- Architecture **scalable**, pensée pour ajouter facilement des fonctionnalités  

---

> MovieStreamingApp combine la puissance de **SwiftUI**, la robustesse de **SQLite** et la richesse du catalogue **TMDB** pour offrir une expérience utilisateur immersive et personnalisée.
