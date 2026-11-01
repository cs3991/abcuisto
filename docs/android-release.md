# Publication Android sur Google Play

## Outillage Android

Le projet utilise AGP 9.5.0, Gradle 9.8.2, Kotlin 2.4.21, le NDK r30 (`30.0.16248370`) et Java 17, avec Kotlin intégré à AGP. La version de Kotlin est déclarée aux côtés d’AGP dans `settings.gradle.kts` avec `apply false` pour fournir son runtime, sans appliquer le plugin Kotlin Android séparé dans les modules. Installer les outils SDK dans leur arborescence standard `SDK/cmdline-tools/latest/bin/` ; une extraction directement dans `SDK/cmdline-tools/bin/` n’est pas reconnue par Flutter pour `apkanalyzer` et les licences.

Déclarer une fois le SDK local auprès de Flutter :

```bash
flutter config --android-sdk /chemin/vers/le/sdk
flutter doctor -v
```

Le SDK et son chemin sont propres à la machine et ne sont pas versionnés. La compilation Android avec Kotlin intégré nécessite Flutter 3.47 au minimum ; les dépendances nécessitent Dart 3.12. `android.newDsl=false` reste nécessaire au plugin Gradle de Flutter ; Kotlin intégré est activé explicitement pour éviter le mode historique ajouté par son outil de migration.

## Ajouter la clé existante

Le fichier doit être un keystore Java contenant une clé privée (souvent `.jks` ou `.keystore`, éventuellement `.key`). Un certificat seul (`.pem`, `.der`) ne suffit pas.

1. Créer le dossier `android/keystore/` et y copier le fichier existant. Ce dossier est ignoré par Git, quelle que soit l’extension du fichier.
2. Copier le modèle depuis la racine du projet :

   ```bash
   cp android/key.properties.example android/key.properties
   ```

3. Modifier `android/key.properties` avec le nom réel du fichier, les mots de passe et l’alias :

   ```properties
   storeFile=keystore/upload-key.jks
   storePassword=mot_de_passe_du_keystore
   keyAlias=alias_de_la_cle
   keyPassword=mot_de_passe_de_la_cle
   ```

Le chemin est relatif à `android/`, ou peut être absolu. Ne pas entourer les valeurs de guillemets. Ce fichier utilise le format Java Properties : les antislashs doivent être doublés (sous Windows, préférer `/` pour les chemins). Le mot de passe de la clé peut être identique à celui du keystore.

Pour retrouver l’alias, utiliser le JDK Android/Flutter et saisir le mot de passe à l’invite :

```bash
keytool -list -v -keystore android/keystore/upload-key.jks
```

Repérer l’alias d’une entrée `PrivateKeyEntry`. Adapter le chemin au fichier réel. Ne pas transmettre les mots de passe dans le chat. Conserver une sauvegarde privée du keystore et de ses identifiants ; `android/key.properties` et `android/keystore/` sont ignorés par Git.

## Préparer la première publication

L’identifiant actuel est `com.example.abcuisto` dans `android/app/build.gradle.kts`. Choisir un identifiant définitif avant la première publication et coordonner ce changement avec la configuration des liens partagés (voir [App Links](app-links/README.md)). L’identifiant doit correspondre à l’application Play Console existante s’il s’agit d’une mise à jour.

Avec Play App Signing, la clé locale sert à signer l’envoi ; Google signe les applications distribuées avec la clé de signature de l’application. Pour une application déjà publiée, utiliser la clé d’importation enregistrée dans sa Play Console. Les empreintes App Links doivent correspondre au certificat de signature de Google Play pour les installations depuis le Store.

## Générer le fichier à envoyer

Depuis la racine du projet :

```bash
flutter build appbundle --release --target lib/main_prod.dart
```

Envoyer `build/app/outputs/bundle/release/app-release.aab` dans la Play Console, par exemple sur une piste de test interne. La compilation release échoue si la configuration de signature est absente ou incomplète ; les builds debug restent disponibles sans clé de publication.

Pour chaque nouvelle version envoyée, augmenter le nombre après `+` dans `pubspec.yaml` (actuellement `1.0.0+1`), par exemple `1.0.0+2`.

Pour produire aussi un APK signé à installer directement :

```bash
flutter build apk --release --target lib/main_prod.dart
```

Résultat : `build/app/outputs/flutter-apk/app-release.apk`.

Références : [publication Android avec Flutter](https://docs.flutter.dev/deployment/android), [signature Android et Play App Signing](https://developer.android.com/studio/publish/app-signing).
