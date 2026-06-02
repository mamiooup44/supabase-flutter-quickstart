# ShieldCheck Mali - Application de Sécurité Anti-Vol

## 📱 Description

ShieldCheck Mali est une application Flutter conçue pour protéger les téléphones mobiles contre le vol. Elle permet de :

- **Surveiller** l'état d'un téléphone déclaré volé en temps réel via une base de données Supabase
- **Verrouiller** automatiquement l'écran du téléphone dès que son statut devient "recherche"
- **Tracker** la position GPS du téléphone toutes les 5 minutes et l'envoyer à la base de données
- **Demander** les droits d'administrateur Android pour activer les capacités de verrouillage

## 🚀 Fonctionnalités Principales

### 1. Gestion des Permissions Android
- Permission `BIND_DEVICE_ADMIN` pour le contrôle du verrouillage
- Permission d'accès aux données GPS (localisation fine et approximative)
- Permission d'accès à Internet pour Supabase

### 2. Connexion Base de Données
- Intégration Supabase avec surveillance en temps réel
- Surveillance de la colonne `identifiant` (basée sur l'IMEI du téléphone)
- Filtrage automatique des entrées avec statut = 'recherche'

### 3. Logique de Blocage
- Utilisation de DeviceAdmin pour verrouiller l'écran instantanément
- Appel à `lockNow()` dès que le statut devient 'recherche'
- Interface UI blocage affichant un message d'alerte en rouge

### 4. Tracking GPS
- Envoi automatique de la position GPS toutes les 5 minutes
- Mise à jour des colonnes `derniere_lat` et `derniere_long` dans la base de données
- Fonctionnement continu tant que le statut reste 'recherche'

## 📋 Structure de la Base de Données

Table `objets_voles` :
```sql
- identifiant (TEXT) - IMEI du téléphone
- statut (TEXT) - 'normal' ou 'recherche'
- derniere_lat (FLOAT) - Latitude de la dernière position
- derniere_long (FLOAT) - Longitude de la dernière position
```

## 🔧 Installation et Build

### Prérequis
- Flutter SDK 3.0.0 ou supérieur
- Android SDK 21 (API Level 21) ou supérieur
- Java JDK 11 ou supérieur

### Étapes d'Installation

1. **Cloner le répertoire**
```bash
git clone https://github.com/maluharik1-tech/supabase-flutter-quickstart.git
cd supabase-flutter-quickstart
```

2. **Installer les dépendances Flutter**
```bash
flutter pub get
```

3. **Configurer les identifiants Supabase** dans `lib/main.dart`
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

4. **Build l'APK**
```bash
flutter build apk --release
```

L'APK généré sera situé à : `build/app/outputs/apk/release/app-release.apk`

## 📦 Fichiers Clés Modifiés

- **`lib/main.dart`** - Logique principale avec MethodChannels pour Device Admin
- **`android/app/src/main/AndroidManifest.xml`** - Déclaration des permissions et récepteurs
- **`android/app/src/main/kotlin/.../MainActivity.kt`** - Gestion des MethodChannels
- **`android/app/src/main/kotlin/.../ShieldCheckDeviceAdminReceiver.kt`** - Récepteur Device Admin
- **`android/app/src/main/kotlin/.../BootReceiver.kt`** - Gestion du démarrage et GPS
- **`android/app/src/main/res/xml/device_admin_receiver.xml`** - Configuration Device Admin
- **`pubspec.yaml`** - Dépendances Flutter

## 🔐 Permissions Requises

L'application demandera les permissions suivantes au démarrage :

1. **Device Admin** - Pour le verrouillage d'écran
2. **Localisation** - Pour le tracking GPS
3. **Internet** - Pour la communication avec Supabase

## 📲 Utilisation

### Au Premier Lancement

1. L'application affichera votre IMEI unique
2. Un dialogue demandera l'activation des droits d'administrateur
3. Acceptez pour activer toutes les fonctionnalités

### Fonctionnement Normal

- L'application affiche "Système actif" et votre IMEI
- L'application surveille la base de données Supabase en temps réel

### En Cas de Vol

1. Mettez à jour le statut du téléphone à 'recherche' dans la base de données
2. L'écran du téléphone se verrouille **instantanément**
3. L'application commence à envoyer le GPS toutes les 5 minutes
4. Consultez la base de données pour retrouver la position

## 🔗 Lien de Téléchargement APK

**APK Généré Automatiquement** : [Voir les Artifacts GitHub](https://github.com/maluharik1-tech/supabase-flutter-quickstart/actions)

Pour télécharger l'APK :
1. Allez sur l'onglet **Actions** du repository
2. Cliquez sur le dernier workflow "Build ShieldCheck APK"
3. Téléchargez l'artifact "ShieldCheck-Mali-APK"

## 📝 Configuration Supabase

Assurez-vous que votre table `objets_voles` existe avec la structure suivante :

```sql
CREATE TABLE objets_voles (
  id BIGSERIAL PRIMARY KEY,
  identifiant TEXT UNIQUE NOT NULL,
  statut TEXT NOT NULL DEFAULT 'normal',
  derniere_lat FLOAT,
  derniere_long FLOAT,
  date_creation TIMESTAMP DEFAULT NOW(),
  date_modification TIMESTAMP DEFAULT NOW()
);
```

## 🐛 Dépannage

### L'écran ne se verrouille pas
- Vérifiez que les droits Device Admin sont activés
- Vérifiez que le statut dans la base de données est exactement 'recherche'

### Le GPS ne se met pas à jour
- Vérifiez la permission de localisation
- Vérifiez que le signal GPS est disponible
- Consultez les logs pour les erreurs

### L'application plante au démarrage
- Vérifiez que les identifiants Supabase sont corrects
- Vérifiez que Flutter est à jour : `flutter upgrade`

## 📧 Support

Pour tout problème ou question, créez une issue sur le repository GitHub.

## 📄 Licence

Ce projet est fourni tel quel à des fins de démonstration et d'utilisation.

---

**Version** : 1.0.0  
**Dernière mise à jour** : 2 Juin 2026  
**Développeur** : maluharik1-tech
