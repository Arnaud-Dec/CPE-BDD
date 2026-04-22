



-- ECRIRE INSTRUCTIONS DROP TABLE

-- 1. Suppression des tables
DROP TABLE IF EXISTS T_E_ANCIEN_ANC CASCADE;
DROP TABLE IF EXISTS T_E_EDITIONFETE_EDF CASCADE;
DROP TABLE IF EXISTS T_E_ENSEIGNANT_ENS CASCADE;
DROP TABLE IF EXISTS T_E_ETUDIANT_ETU CASCADE;
DROP TABLE IF EXISTS T_E_FETE_FET CASCADE;
DROP TABLE IF EXISTS T_E_PARTICIPANT_PAR CASCADE;
DROP TABLE IF EXISTS T_J_INSCRIPTION_INS CASCADE;
DROP TABLE IF EXISTS T_R_FILIERE_FIL CASCADE;
DROP TABLE IF EXISTS T_R_PROMOTION_PRO CASCADE;


/*==============================================================*/
/* Table : T_E_ANCIEN_ANC                                       */
/*==============================================================*/
create table T_E_ANCIEN_ANC (
   PAR_ID               INT4                 not null,
   PRO_ANNEEPROMO       INT4                 not null,
   ANC_ENTREPRISE       VARCHAR(50)          null,
   ANC_FONCTION         VARCHAR(50)          null,
   constraint PK_ANC primary key (PAR_ID)
);

/*==============================================================*/
/* Table : T_E_EDITIONFETE_EDF                                  */
/*==============================================================*/
create table T_E_EDITIONFETE_EDF (
   FET_ID               INT4                 not null,
   EDF_NUM              INT4                 not null, -- Le n° d’édition doit être >=1
   EDF_DATE             DATE                 not null,
   EDF_BUDGETPREVI      NUMERIC(8,2)         not null, -- Le budget doit être >=0
   constraint PK_EDF primary key (FET_ID, EDF_NUM),
    constraint CK_BUDGETPREVI check (EDF_BUDGETPREVI >= 0),
    constraint CK_NUM check ( EDF_NUM >= 1 )
);

/*==============================================================*/
/* Table : T_E_ENSEIGNANT_ENS                                   */
/*==============================================================*/
create table T_E_ENSEIGNANT_ENS (
   PAR_ID               INT4                 not null,
   ENS_NUMBUREAU        CHAR(4)              not null,
   constraint PK_ENS primary key (PAR_ID)
);

/*==============================================================*/
/* Table : T_E_ETUDIANT_ETU                                     */
/*==============================================================*/
create table T_E_ETUDIANT_ETU (
   PAR_ID               INT4                 not null,
   ETU_INE              NUMERIC(8)           not null,
   ETU_ANNEE            INT4                 not null, -- L’année d’un étudiant est soit 3, 4 ou 5.
   constraint PK_ETU primary key (PAR_ID)
);

/*==============================================================*/
/* Table : T_E_FETE_FET                                         */
/*==============================================================*/
create table T_E_FETE_FET (
   FET_ID               INT4                 not null,
   FET_TYPE             VARCHAR(20)          not null, -- Valeurs possibles : 'Classique', 'Anniversaire'
   FIL_ID               INT4                 not null,
   FET_NOM              VARCHAR(50)          not null,
   constraint PK_FET primary key (FET_ID),
    constraint CK_TYPE_FETE check ( FET_TYPE IN ('Classique','Anniversaire'))
);

/*==============================================================*/
/* Table : T_E_PARTICIPANT_PAR                                  */
/*==============================================================*/
create table T_E_PARTICIPANT_PAR (
   PAR_ID               INT4                 not null,
   FIL_ID               INT4                 not null,
   PAR_NOM              VARCHAR(50)          ,
   PAR_PRENOM           VARCHAR(50)          ,
   PAR_SEXE             CHAR(1)   			 , -- Sexe : H ou F ou NUll (RGPD !)
   PAR_MAIL             VARCHAR(100)		 ,
   PAR_MOBILE           CHAR(10)             , -- Le mobile est soit Null, soit commence par 06 ou 07.
   constraint PK_PAR primary key (PAR_ID)
);

/*==============================================================*/
/* Table : T_J_INSCRIPTION_INS                                  */
/*==============================================================*/

-- ECRIRE CREATE TABLE avec contraintes :
-- PK
-- Clé unique
-- Valeurs possibles pour le TypeParticipation : 'Gratuit', 'Payant'

create table T_J_INSCRIPTION_INS (
   INS_ID               INT4                 not null,
   FET_ID               INT4                 not null,
   EDF_NUM              INT4                 not null,
   PAR_ID               INT4                 not null,
   INS_TYPEPARTICIPATION VARCHAR(10)         ,
   INS_ACCOMPAGNE       BOOL                 ,
   constraint AK_INSCRIPTION unique (FET_ID, EDF_NUM, PAR_ID),
   constraint PK_INS primary key (INS_ID),
   constraint CK_INS_TYPE check ( INS_TYPEPARTICIPATION IN ('Gratuit','Payant'))

);

/*==============================================================*/
/* Table : T_R_FILIERE_FIL                                      */
/*==============================================================*/
create table T_R_FILIERE_FIL (
   FIL_ID               INT4                 not null,
   FIL_NOM              VARCHAR(20)          null,
   constraint PK_FIL primary key (FIL_ID)
);

/*==============================================================*/
/* Table : T_R_PROMOTION_PRO                                    */
/*==============================================================*/
create table T_R_PROMOTION_PRO (
   PRO_ANNEEPROMO       INT4                 not null,
   constraint PK_PRO primary key (PRO_ANNEEPROMO)
);





-- ECRIRE FK

