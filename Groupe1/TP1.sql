
-- Afficher la liste de tous les films
SELECT * FROM film;

-- Afficher le titre des films et leur budget pour les films de moins de 20.000.000 $ de
-- budget et faire afficher au niveau de chaque enregistrement ‘Film à petit budget’
-- Indications : avant d’écrire cette requête, testez la requête suivante : SELECT *,
-- 'unfilm' AS "monchamp" FROM Film;

SELECT titre ,budget from film ;

SELECT titre,budget,'Film à petit budget' AS "monchamp"
FROM FILM WHERE budget <20000000;


--- 2 a 13

-- 14. Afficher les noms des réalisateurs habitant une ville commençant par la lettre ’N

SELECT nom,prenom,ville
FROM personne p
WHERE ville LIKE 'N%';

-- 15. Trouver le titre et l’année des comédies dont le budget dépasse 500.000$
SELECT titre, annee From film f join genre g on f.genre = g.numgenre
    where budget > 500000 and libellegenre = 'Comedie';

-- 16. Afficher pour chaque réalisateur (nom, prénom) et chaque film (titre) son salaire à la minute de film

SELECT p.nom, p.prenom , f.titre , (salaire_real/longueur) AS "Salaire du réal"
    FROM personne p
    JOIN film f ON f.realisateur = p.numpersonne

-- 17. Trouver le titre des films qui passent dans un cinéma de la compagnie UGC.

SELECT f.titre from film f
    join programmation p on p.numfilm = f.numfilm
    join cinema c on c.numcinema = p.numcinema
    where c.compagnie = 'UGC';

-- 18. Afficher pour chaque film, les nom et prénom des acteurs, leur salaire et leur rôle (afficher) le titre du film par ordre alphabétique et le salaire par ordre décroissant)

SELECT f.Titre, p.Nom, p.Prenom, d.salaire, d.role
FROM Film f
JOIN Distribution d ON f.NumFilm = d.NumFilm
JOIN Acteur a ON d.NumActeur = a.NumActeur
JOIN Personne p ON a.NumPersonne = p.NumPersonne
ORDER BY f.Titre ASC, d.salaire DESC;

-- 19. Trouver le nom et le prénom des acteurs qui ont eu touché un salaire plus important dans un film particulier que le salaire du réalisateur du même film.

SELECT p.Prenom, p.Nom
FROM Personne p
JOIN Acteur a ON p.NumPersonne = a.NumPersonne
JOIN Distribution d ON a.NumActeur = d.NumActeur
JOIN Film f ON d.NumFilm = f.NumFilm
WHERE d.salaire > f.Salaire_real;

-- Quels sont les acteurs dramatiques (nom, prénom) qui ont joué dans un film de Hazanavicius.

SELECT DISTINCT p_act.Nom, p_act.Prenom
FROM Personne p_act
JOIN Acteur a ON p_act.NumPersonne = a.NumPersonne
JOIN Distribution d ON a.NumActeur = d.NumActeur
JOIN Film f ON d.NumFilm = f.NumFilm
JOIN Personne p_real ON f.Realisateur = p_real.NumPersonne
WHERE a.Specialite = 'Drame'
  AND p_real.Nom = 'Hazanavicius';