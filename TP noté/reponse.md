# TP Optimisation - Index et Tables Partitionnées

## INDEX

---

### Question 1 — `SELECT * FROM film WHERE id=5200;`

#### Sans index
![Q1 sans index](screenshots/q1_sans_index.png)

Coût : **183.32**. Sans index, PostgreSQL effectue un **Seq Scan** : il parcourt les 9 706 lignes une par une. 9 705 lignes sont lues inutilement pour retourner 1 seul résultat.

#### Avec `CREATE UNIQUE INDEX idx_film_id ON film(id)`
[screenshot - EXPLAIN ANALYZE SELECT * FROM film WHERE id=5200 avec index]

Coût : **8.30** (~22x moins coûteux). PostgreSQL utilise un **Index Scan** : il descend dans l'arbre B-tree pour trouver directement l'id 5200, puis lit la page de données. Seulement 3 pages lues au total (2 niveaux d'index + 1 page de données).

---

### Question 2 — `SELECT * FROM film WHERE id=5200 AND pays='CH/FR';`

#### Sans index
[screenshot - EXPLAIN ANALYZE sans index]

Coût : **207.59**. Seq Scan complet sur les 9 706 lignes.

#### Avec index unique sur ID uniquement
[screenshot - EXPLAIN ANALYZE avec idx_film_id]

Coût : **8.30**. L'index sur `id` isole directement 1 ligne, puis `pays` est vérifié en mémoire. Avec AND, le critère le plus sélectif suffit.

#### Avec les 2 index (id + pays)
[screenshot - EXPLAIN ANALYZE avec idx_film_id + idx_film_pays]

Coût : **8.30** — identique. PostgreSQL **ignore l'index sur pays** : l'index sur `id` (unique) est déjà optimal, ajouter un second index n'apporte rien avec AND.

#### Tailles des index
| Élément | Taille |
|---|---|
| Table film (data) | 496 kB |
| idx_film_id | 232 kB |
| idx_film_pays | 112 kB |

L'index sur `id` est plus volumineux (index dense, 1 entrée par ligne). Les 2 index représentent 69% du volume data. L'index sur `id` est plus volumineux que celui sur `pays` car les valeurs d'id sont toutes uniques alors que `pays` a peu de valeurs distinctes.

---

### Question 3 — `SELECT * FROM film WHERE id=5200 OR pays='CH/FR';`

#### Sans index + avec index sur ID uniquement
[screenshot - EXPLAIN ANALYZE sans index / avec idx_film_id seulement]

Coût : **207.59** dans les deux cas. Avec OR, un seul index ne suffit pas : PostgreSQL devrait quand même parcourir toute la table pour `pays='CH/FR'`. Il préfère donc le Seq Scan direct.

#### Avec les 2 index (id + pays)
[screenshot - EXPLAIN ANALYZE avec idx_film_id + idx_film_pays]

Coût : **32.13**. PostgreSQL utilise un **Bitmap OR** : chaque index produit un bitmap des lignes correspondantes, ils sont fusionnés puis les 8 lignes sont lues directement dans la table.

**Conclusion :** Avec AND (Q2), 1 index suffit (le plus sélectif). Avec OR, il faut **un index sur chaque condition** sinon PostgreSQL revient au Seq Scan.

---

### Question 4 — `SELECT * FROM film WHERE id>2000;`

#### Sans index
[screenshot - EXPLAIN ANALYZE sans index]

Coût : **183.32**. Seq Scan, 7 706 lignes retournées sur 9 706.

#### Avec `CREATE UNIQUE INDEX idx_film_id ON film(id)`
[screenshot - EXPLAIN ANALYZE avec index]

Coût : **183.32** — **aucun changement**. PostgreSQL ignore l'index. La requête retourne ~79% de la table : passer par l'index 7 706 fois serait plus coûteux qu'un Seq Scan qui lit les 62 pages en une seule passe. L'index n'est utile que si peu de lignes sont retournées (< ~20-30%).

---
