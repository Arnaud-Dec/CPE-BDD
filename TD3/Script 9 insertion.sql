insert into T_R_FILIERE_FIL values (1, 'CGP');
insert into T_R_FILIERE_FIL values (2, 'ETI');
insert into T_R_FILIERE_FIL values (3, 'IRC');
insert into T_R_FILIERE_FIL values (4, 'ICS');

INSERT INTO T_E_ENSEIGNANT_ENS (
    PAR_ID, FIL_ID, PAR_NOM, PAR_PRENOM, PAR_SEXE, PAR_MAIL, PAR_TELEPHONES, PAR_ADRESSE, ENS_NUMBUREAU
) VALUES (
    1,
    2,
    'DUPONT',
    ARRAY['Marc', 'André'],
    'H', -- Remplacement de 'M' par 'H'
    NULL, -- L'énoncé ne donne pas de mail, NULL est plus propre que 'jsp'
    ARRAY[
        ROW('+33', '660606060', 'Mobile')::TYPE_TELEPHONE,
        ROW('+33', '450505050', 'Résidence principale')::TYPE_TELEPHONE
    ],
    ROW('43', 'Bd du 11 Novembre 1918', '69100', 'Villeurbanne', 'France')::TYPE_ADRESSE,
    '1401'
);
INSERT INTO T_E_ENSEIGNANT_ENS (
    PAR_ID, FIL_ID, PAR_NOM, PAR_PRENOM, PAR_SEXE, PAR_MAIL, PAR_TELEPHONES, PAR_ADRESSE, ENS_NUMBUREAU
) VALUES (
    2,
    2,
    'MACHIN',
    ARRAY['Alain', 'Marc'],
    'H',
    NULL,
    ARRAY[
        ROW('+33', '770707070', 'Mobile')::TYPE_TELEPHONE
    ],
    ROW('10', 'Rue de la Gare', '69009', 'Lyon', 'France')::TYPE_ADRESSE,
    'I402'
);

insert into T_E_FETE_FET (FET_ID, FET_TYPE, FIL_ID, FET_NOM) values (1, 'Classique', 1, 'Fête de
fin d''année');
insert into T_E_FETE_FET (FET_ID, FET_TYPE, FIL_ID, FET_NOM) values (4, 'Classique', 3, 'Fête de
fin d''année');
insert into T_E_FETE_FET (FET_ID, FET_TYPE, FIL_ID, FET_NOM) values (5, 'Anniversaire', 1, 'Gala
anniversaire 20 ans');
insert into T_E_FETE_FET (FET_ID, FET_TYPE, FIL_ID, FET_NOM) values (6, 'Anniversaire', 3, 'Gala
anniversaire 10 ans');

insert into t_e_editionfete_edf(
                                fet_id, edf_num, edf_date, edf_budgetprevi, edf_details
) values (
          4,
          1,
          '2024-12-20',
          1000,
          '{
            "description": "Fête de fin année avec unconcert",
              "groupes": [
              "Shaka Ponk",
              "Gorillaz"
            ],
            "organisateurs": ["T. Asfour", "G. Morel"]
            }'::jsonb
         );

insert into t_e_editionfete_edf(
    fet_id, edf_num, edf_date, edf_budgetprevi, edf_details
) values (
    4,
    2,
    '2025-12-21',
    8000,
    '{
        "description": "Fête de fin année déguisée",
        "thèmes": [
            "montagne",
            "neige"
        ],
        "organisateurs": ["T. Asfour", "J. Saraydaryan"],
        "invités": ["M. Blanc", "G. Morel"],
        "notes": "à confirmer"
    }'::JSONB
);