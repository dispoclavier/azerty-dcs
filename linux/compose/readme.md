# Compose

Le fichier Compose.yml contient les chaînes de caractères pour touches vives et le contenu des touches mortes, dont celui de la touche morte de composition éponyme, pour les dispositions de clavier définies dans le dépôt [dispoclavier/azerty-dcs](https://github.com/dispoclavier/azerty-dcs/). Son nom avec majuscule est calqué sur des noms de fichier dans /usr/share/X11/locale/ sous Linux.

Ce fichier n’est pas au format YAML. L’extension ".yml" sert à la coloration syntaxique, et sous Windows elle facilite l’ouverture.

Le contenu de Compose.yml est dupliqué dans les trois fichiers compose-1.yml, compose-2.yml et compose-3.yml. Ces partiels ne dépassent pas 2 Mo afin de bénéficier des fonctionnalités de github.com, absentes de github.dev qui affiche Compose.yml en entier.

* compose-1.yml : séquences de composition dédiées, grec sauf touche morte grec-ou-cerclé
* compose-2.yml : touches mortes jusqu’à rond en chef sauf touche morte groupe
* compose-3.yml : touches mortes à partir d’accent circonflexe et touche morte groupe

## Versionnage

Dans Compose.yml et compose-1.yml, le numéro de version est inclus sous la forme d’une chaîne de caractères pour touche vive, parce que ces dispositions de clavier sortent leur numéro de version par AltGr + Échap.

Le numéro de version sur trois nombres est complété par le numéro de build, aussi pour Linux (depuis le build 6.0.7.03, sans zéro de remplissage depuis 6.0.9.6) parce que le fichier Compose.yml sert aussi de code source au contenu de touches mortes transpilé pour Windows.

Un numéro de commit complète le numéro de build pour aboutir à un identifiant unique utilisable comme résumé de commit, depuis la version 7.1.0.0.1).

Le numéro complet est de la forme MAJEURE.MINEURE.PATCH+BUILD.COMMIT depuis la 7.1.0+0.3.

L’historique des versions v1.0.0 à 1.6.0 a été restauré de [c6c939f](https://github.com/dispoclavier/azerty-complet/commit/c6c939f1ec1a84dc4a1ec4aaf49df552b887e5dd) à [bebf6f8](https://github.com/dispoclavier/azerty-complet/commit/bebf6f8e44270b5623bf4eae95454b8b657497e2).

## Documentation

Les touches mortes sont documentées sur la page [Touches mortes](https://dispoclavier.com/nouvel-azerty/touches-mortes/) et ses 30 sous-pages, une par touche morte, et sur celle des [séquences de composition](https://dispoclavier.com/nouvel-azerty/composition/), avec une sous-page pour les [symboles mathématiques](https://dispoclavier.com/nouvel-azerty/composition/symboles-mathematiques/).

Les tableaux d’entrée/sortie affichés sur ces pages sont générés à partir du fichier Compose.yml par les [scripts](https://github.com/dispoclavier/azerty-dcs/blob/main/linux-chromeos/outils/) dont les noms commencent par "generate-" et se terminent par "-tables" ou "-table" autour de "deadkey", "math" et "multikey".
