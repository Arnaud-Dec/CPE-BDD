# TP Optimisation - Index et Tables Partitionnées

## INDEX

---

### Question 1 — `SELECT * FROM film WHERE id=5200;`

#### Sans index
![Q1 sans index](screenshots/q1_sans_index.png)

Coût : **183.32**. Sans index, PostgreSQL effectue un **Seq Scan** : il parcourt les 9 706 lignes une par une. 9 705 lignes sont lues inutilement pour retourner 1 seul résultat.

#### Avec `CREATE UNIQUE INDEX idx_film_id ON film(id)`
![Q1 avec index](screenshots/q1_avec_index.png)

Coût : **8.30** (~22x moins coûteux). PostgreSQL utilise un **Index Scan** : il descend dans l'arbre B-tree pour trouver directement l'id 5200, puis lit la page de données. Seulement 3 pages lues au total (2 niveaux d'index + 1 page de données).

---

### Question 2 — `SELECT * FROM film WHERE id=5200 AND pays='CH/FR';`

#### Sans index
![Q2 sans index](screenshots/q2_sans_index.png)

Coût : **207.59**. Seq Scan complet sur les 9 706 lignes.

#### Avec index unique sur ID uniquement
![Q2 avec index sur ID](screenshots/q2_avec_index.png)

Coût : **8.30**. L'index sur `id` isole directement 1 ligne, puis `pays` est vérifié en mémoire. Avec AND, le critère le plus sélectif suffit.

#### Avec les 2 index (id + pays)
![Q2 avec 2 index](screenshots/q2_etape3.png)

Coût : **8.30** — identique. PostgreSQL **ignore l'index sur pays** : l'index sur `id` (unique) est déjà optimal, ajouter un second index n'apporte rien avec AND.

#### Tailles des index
![Q2 tailles des index](screenshots/q2_etape4.png)

L'index sur `id` est plus volumineux (232 kB) car dense (1 entrée par ligne). L'index sur `pays` est plus petit (112 kB) car peu de valeurs distinctes. Les 2 index représentent 69% du volume data de la table.

---

### Question 3 — `SELECT * FROM film WHERE id=5200 OR pays='CH/FR';`

#### Sans index
![Q3 sans index](screenshots/q3_etape1.png)

Coût : **207.59**. Seq Scan obligatoire.

#### Avec index sur ID uniquement
![Q3 avec index ID seulement](screenshots/q3_etape2.png)

Coût : **207.59** — aucun changement. Avec OR, un seul index ne suffit pas : PostgreSQL devrait quand même parcourir toute la table pour `pays='CH/FR'`, il préfère donc le Seq Scan direct.

#### Avec les 2 index (id + pays)
![Q3 avec 2 index](screenshots/q3_etape3.png)

Coût : **32.13**. PostgreSQL utilise un **Bitmap OR** : chaque index produit un bitmap des lignes correspondantes, ils sont fusionnés puis les 8 lignes sont lues directement dans la table.

**Conclusion :** Avec AND (Q2), 1 index suffit (le plus sélectif). Avec OR, il faut **un index sur chaque condition** sinon PostgreSQL revient au Seq Scan.

---

### Question 4 — `SELECT * FROM film WHERE id>2000;`

#### Sans index
![Q4 sans index](screenshots/q4_etape1.png)

Coût : **183.32**. Seq Scan, 7 706 lignes retournées sur 9 706 (~79% de la table).

#### Avec `CREATE UNIQUE INDEX idx_film_id ON film(id)`
![Q4 avec index](screenshots/q4_etape2.png)

Coût : **183.32** — **aucun changement**. PostgreSQL ignore l'index. Retourner 79% de la table via un index serait plus coûteux qu'un Seq Scan direct sur les 62 pages. L'index n'est utile que si peu de lignes sont retournées (< ~20-30%).

---
