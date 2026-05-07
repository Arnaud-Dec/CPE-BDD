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
### Question 7 — Index multicolonnes sur table de jointure (Realise)

#### Avec index unique multicolonne sur (id_film, id_real)

`WHERE id_film=1` → **Index Only Scan** via `idx_realise` (coût 4.30). La 1ère colonne correspond : index utilisé et même pas besoin d'accéder à la table (toutes les colonnes sont dans l'index).

`WHERE id_real=2` → **Seq Scan** (coût 174.06). La 2ème colonne seule ne suffit pas : index ignoré, 10 243 lignes parcourues inutilement.

#### Avec index unique multicolonne + 2 index mono-colonne (id_film et id_real)

`WHERE id_film=1` → **Index Only Scan** via `idx_realise` (coût 4.30). Identique.

`WHERE id_real=2` → **Index Scan** via `idx_realise_idreal` (coût 10.87). Cette fois l'index mono-colonne sur `id_real` est utilisé.

#### Préconisation
Pour une table de jointure (association), il faut **combiner les deux approches** :
- Un **index unique multicolonne** sur (id_film, id_real) pour garantir l'unicité (équivalent PK) et couvrir les recherches sur la 1ère colonne.
- Un **index mono-colonne sur la 2ème FK** (id_real) pour couvrir les recherches sur cette colonne seule.

Règle générale : **toujours indexer les clés étrangères** (FK) car elles sont très fréquemment utilisées dans les jointures et les recherches.

---

---
| 6 | 2 mono — OR | Bitmap Heap Scan + BitmapOr | ~75 |
| 7 | idx multicolonne — WHERE id_film | Index Only Scan | 4.30 |
| 7 | idx multicolonne — WHERE id_real | Seq Scan (index ignoré) | 174.06 |
| 7 | + idx mono id_real — WHERE id_real | Index Scan | 10.87 |


### Question 8 — `SELECT * FROM film WHERE SUBSTR(pays,1,2) = 'CH';`

**Avec `idx_film_pays` (index sur pays) :** Seq Scan, coût **207.59**. L'index sur `pays` est ignoré car la requête n'utilise pas `pays` directement mais une **fonction** appliquée dessus (`SUBSTR`). PostgreSQL ne peut pas utiliser un index B-tree sur `pays` pour rechercher sur `SUBSTR(pays,1,2)`.

**Avec `idx_film_substr_pays` (index sur expression) :** Bitmap Heap Scan, coût **67.10**. En indexant directement l'expression `substr(pays,1,2)`, PostgreSQL peut utiliser l'index car la valeur calculée est stockée dans l'index. L'index sur fonction résout exactement ce problème.

**Conclusion :** Un index classique sur une colonne est inefficace si une fonction est appliquée dans le WHERE. Il faut créer un **index sur expression** qui pré-calcule et stocke le résultat de la fonction.

---

---

### Question 9 — JOIN Film / Titres sans restriction

**Sans index :** Hash Join, coût **903.25**. PostgreSQL charge film en table de hachage (Hash) puis parcourt titres séquentiellement pour matcher. Les 2 tables sont entièrement lues via Seq Scan car toutes les lignes sont retournées (20 247 résultats).

**Avec idx_film_id (PK film) :** Hash Join, coût **678.03**. Le plan ne change pas (toujours Hash Join + Seq Scans) car **toutes les lignes sont retournées**. L'index sur la PK n'est d'aucune utilité ici : PostgreSQL doit de toute façon lire film entièrement pour construire la table de hachage.

**Avec idx_film_id + idx_titres_id_film :** Hash Join, coût **678.03** — identique. Même raisonnement : la jointure retourne 20 247 lignes, soit la totalité de titres. Les index ne servent à rien quand il n'y a pas de restriction réduisant le volume.

**Conclusion :** Sans clause WHERE restrictive, une jointure complète utilise toujours le **Hash Join** et les **Seq Scans**, quel que soit l'indexation. Les index ne sont utiles que si une restriction filtre suffisamment les données.

---

### Question 10 — JOIN Film / Titres avec `WHERE f.pays='FR/BE'`

**Sans index :** Hash Join, coût **604.89**. Titres est parcourue entièrement (Seq Scan, 20 247 lignes), film aussi (Seq Scan avec filtre pays, 35 résultats). La restriction réduit le volume mais sans index PostgreSQL doit tout lire.

**Avec idx_film_id (PK film) :** Hash Join, coût **581.40** — quasiment identique. L'index sur id ne sert pas ici car la restriction porte sur `pays`, pas sur `id`.

**Avec idx_film_id + idx_film_pays :** Hash Join, coût **458.62**. L'index sur `pays` est utilisé : Bitmap Heap Scan sur film (35 lignes récupérées directement). Titres est toujours en Seq Scan car aucun index n'y est posé.

**Avec idx_film_id + idx_film_pays + idx_titres_id_film :** **Nested Loop**, coût **304.53**. Changement majeur : PostgreSQL bascule vers une boucle imbriquée. Film est filtré via `idx_film_pays` (35 lignes), puis pour chacune, `idx_titres_id_film` (FK) localise directement les titres correspondants. C'est le plan optimal.

**Index utilisés et principe :**
- `idx_film_pays` → index sur la **condition de recherche** (WHERE)
- `idx_film_id` → index sur la **PK** (clé de jointure côté film)
- `idx_titres_id_film` → index sur la **FK** (clé de jointure côté titres)

**Principe :** Pour optimiser une jointure avec restriction, il faut indexer : (1) les champs du WHERE, (2) les PK, (3) les FK. C'est la même conclusion qu'en Q7.

---

### Question 11 — Index partiel

```sql
CREATE INDEX idx_film_annee ON film(annee) WHERE annee >= 2000;
```

**`WHERE annee = 2003` :** Index Scan, coût **29.51**. 2003 >= 2000 → l'index partiel couvre cette valeur, il est utilisé.

**`WHERE annee = 1995` :** Seq Scan, coût **183.32**. 1995 < 2000 → hors de la plage de l'index partiel, PostgreSQL l'ignore et parcourt toute la table. Pourtant il y a moins de films en 1995 (639) qu'en 2003 (756) — l'index n'est pas disponible pour les années < 2000.

**Conclusion :** Un index partiel couvre uniquement le sous-ensemble de données défini par sa condition. Il est plus compact et plus rapide qu'un index complet, mais uniquement pour les requêtes portant sur la plage couverte. Ici, il est pertinent si les films récents (>= 2000) sont beaucoup plus souvent requêtés que les anciens.

---

## RÉSULTATS ATTENDUS — GUIDE DE REVIEW

| Q | Étape | Type de scan attendu | Coût attendu |
|---|---|---|---|
| 1 | Sans index | Seq Scan | 183.32 |
| 1 | Avec idx_film_id | Index Scan | 8.30 |
| 2 | Sans index | Seq Scan | 207.59 |
| 2 | Avec idx_film_id | Index Scan | 8.30 |
| 2 | Avec idx_film_id + idx_film_pays | Index Scan (idx_film_id, pays ignoré) | 8.30 |
| 3 | Sans index | Seq Scan | 207.59 |
| 3 | Avec idx_film_id seul | Seq Scan (index ignoré) | 207.59 |
| 3 | Avec idx_film_id + idx_film_pays | Bitmap Heap Scan + BitmapOr | 32.13 |
| 4 | Sans index | Seq Scan | 183.32 |
| 4 | Avec idx_film_id | Seq Scan (index ignoré, 79% lignes) | 183.32 |
| 5 | Avec idx_film_id | Index Scan | 68.14 |
| 6 | (pays,annee) — WHERE pays | Bitmap Heap Scan | ~25 |
| 6 | (pays,annee) — WHERE annee | Seq Scan (index ignoré) | 183.32 |
| 6 | (pays,annee) — OR | Seq Scan | 207.59 |
| 6 | (annee,pays) — WHERE pays | Index Scan (Skip Scan PG18) | ~40 |
| 6 | (annee,pays) — WHERE annee | Bitmap Heap Scan | ~70 |
| 6 | (annee,pays) — OR | Bitmap Heap Scan + BitmapOr | ~96 |
| 6 | 2 mono — OR | Bitmap Heap Scan + BitmapOr | ~75 |
| 7 | idx multicolonne — WHERE id_film | Index Only Scan | 4.30 |
| 7 | idx multicolonne — WHERE id_real | Seq Scan (index ignoré) | 174.06 |
| 7 | + idx mono id_real — WHERE id_real | Index Scan | 10.87 |
| 8 | Index sur pays | Seq Scan (fonction ignorée) | 207.59 |
| 8 | Index sur substr(pays,1,2) | Bitmap Heap Scan | 67.10 |
| 9 | Sans index | Hash Join | 903.25 |
| 9 | Avec idx_film_id | Hash Join (identique) | 678.03 |
| 9 | Avec idx_film_id + idx_titres_id_film | Hash Join (identique) | 678.03 |
| 10 | Sans index | Hash Join | 604.89 |
| 10 | + idx_film_id | Hash Join (quasi identique) | 581.40 |
| 10 | + idx_film_pays | Hash Join (Bitmap sur film) | 458.62 |
| 10 | + idx_titres_id_film | Nested Loop | 304.53 |
| 11 | annee=2003 (index partiel >= 2000) | Index Scan | 29.51 |
| 11 | annee=1995 (hors plage index) | Seq Scan | 183.32 |
