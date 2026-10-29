# Points à améliorer

- [ ] Backend photo (`pi`, `backend-dev/src/ABCuisto/Services/UserService.cs`, `UpdateImage`) : `oldImage == null` passe le contrôle `oldImage != ""` et entraîne `DeleteImage(null)`. Le client envoie désormais une chaîne vide en l’absence de photo. Corriger aussi le serveur avec un contrôle de valeur vide, conserver l’exception d’origine dans le contrôleur et supprimer l’ancienne photo seulement après enregistrement réussi de la nouvelle (actuellement supprimée avant validation de l’envoi).

- [ ] Changement d’e-mail : le repository expose `confirmUpdateEmail`, mais aucun parcours de confirmation n’est raccordé dans le profil. Clarifier le retour de l’API et la réception du token ; après confirmation, synchroniser aussi `authEmail` et `api_auth_email` avec l’adresse effective (actuellement enregistrée seulement à la connexion).


- [ ] Adaptation des quantités (`lib/models/ingredient.dart`, `Ingredient.quantityFormatted`) : l’affichage impose une seule décimale ; une quantité positive inférieure à 0,05 apparaît comme « 0.0 » après réduction des portions. Prévoir une précision adaptée aux petites quantités et un affichage français cohérent lors de l’étape de calcul à partir d’un ingrédient.
