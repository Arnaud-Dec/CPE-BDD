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

### Question 5 — `SELECT * FROM film WHERE id>8000;`

#### Avec `CREATE UNIQUE INDEX idx_film_id ON film(id)`
![Q5 avec index](screenshots/q5_avec_index.png)

Coût : **68.14**. Cette fois PostgreSQL **utilise l'Index Scan**. Seulement **1 706 lignes** sur 9 706 sont retournées (~17% de la table), ce qui est en dessous du seuil de rentabilité de l'index (~20-30%).

**Comparaison avec Q4 :** `id>2000` retournait 79% des lignes → Seq Scan. `id>8000` retourne seulement 17% → Index Scan. C'est le **volume de données retourné** qui détermine si l'index est utilisé : plus la sélection est restrictive, plus l'index est rentable.

---

### Question 6 — Index multicolonnes

#### Bloc 1 — `CREATE INDEX idx_film_pays_annee ON film(pays, annee)`

![Q6 Bloc1 pays='CH/FR'](screenshots/q6_pays_annee_sur_pays.png)

`WHERE pays='CH/FR'` → **Bitmap Heap Scan** via `idx_film_pays_annee`. La 1ère colonne de l'index correspond au critère : l'index est utilisé.

`WHERE annee=1991` → **Seq Scan** (coût 183.32). La 2ème colonne seule ne suffit pas à exploiter l'index multicolonne : PostgreSQL l'ignore.

`WHERE pays='CH/FR' OR annee=1991` → **Seq Scan**. Avec OR et un seul index, si une condition ne peut pas utiliser l'index (annee seul), PostgreSQL revient au Seq Scan complet.

#### Bloc 2 — `CREATE INDEX idx_film_annee_pays ON film(annee, pays)`

`WHERE pays='CH/FR'` → **Index Scan** via `idx_film_annee_pays`. Grâce au **Skip Scan** de PostgreSQL 18, même la 2ème colonne peut utiliser l'index (contrairement au Bloc 1).

![Q6 Bloc2 annee=1991](screenshots/q6_annee_pays_sur_annee.png)

`WHERE annee=1991` → **Bitmap Heap Scan** via `idx_film_annee_pays`. La 1ère colonne correspond au critère : utilisation optimale.

![Q6 Bloc2 OR](screenshots/q6_annee_pays_or.png)

`WHERE pays='CH/FR' OR annee=1991` → **Bitmap OR** via le même index pour les 2 conditions grâce au Skip Scan.

#### Bloc 3 — 2 index mono-colonne : `idx_film_pays` + `idx_film_annee`

`WHERE pays='CH/FR'` → **Bitmap Heap Scan** via `idx_film_pays`.
`WHERE annee=1991` → **Index Scan** via `idx_film_annee`.

![Q6 mono OR](screenshots/q6_mono_or.png)

`WHERE pays='CH/FR' OR annee=1991` → **Bitmap OR** avec les 2 index distincts. Résultat identique au Bloc 2 mais avec 2 index séparés.

#### Tailles des index
![Q6 tailles](screenshots/q6_tailles.png)

| Index | Taille |
|---|---|
| idx_film_pays (mono) | 112 kB |
| idx_film_annee (mono) | 88 kB |
| **Total 2 mono** | **200 kB** |

Un index multicolonne est plus compact que 2 index mono-colonne séparés car il ne stocke qu'une seule entrée par ligne pour les 2 champs combinés.

#### Synthèse
L'index multicolonne est pertinent uniquement si la **1ère colonne est systématiquement présente dans les requêtes** (règle du préfixe). Sous PostgreSQL 18, le Skip Scan atténue cette contrainte. Les 2 index mono-colonne sont plus flexibles (chaque condition peut utiliser son index indépendamment) mais occupent plus d'espace et pénalisent davantage les écritures.

---
