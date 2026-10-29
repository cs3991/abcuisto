# Installation Linux

Construire le bundle de production depuis la racine du projet :

```bash
flutter build linux --release --target lib/main_prod.dart
```

Le bundle contient le binaire, ses bibliothèques, les données Flutter, l’icône,
le lanceur `.desktop` et le script d’installation. Pour une machine x64 :

```bash
python3 build/linux/x64/release/bundle/install.py
```

Pour une autre architecture, adapter le chemin au bundle généré par Flutter.
L’installation nécessite Python 3.9 ou plus. Elle copie l’application dans
`~/.local/lib/abcuisto`, le lanceur dans `~/.local/share/applications` et l’icône
dans `~/.local/share/icons/hicolor`. Elle ne nécessite pas de droits administrateur.
Fermer l’application avant de réexécuter le script pour une mise à jour.

Le lanceur pointe vers le chemin absolu du binaire installé. Son nom et le nom
de l’icône reprennent `APPLICATION_ID` défini dans `linux/CMakeLists.txt`, afin
de permettre au bureau d’associer la fenêtre à son icône. Le bundle peut être
déplacé avant installation ; après installation, relancer le script pour changer
sa destination. L’apparition du lanceur peut nécessiter une reconnexion au bureau.

Pour désinstaller, supprimer `~/.local/lib/abcuisto`, puis le fichier
`~/.local/share/applications/com.example.abcuisto.desktop` et l’icône
`~/.local/share/icons/hicolor/1024x1024/apps/com.example.abcuisto.png`.
Les données utilisateur sont conservées.
