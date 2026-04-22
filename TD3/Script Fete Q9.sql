drop table IF EXISTS T_E_ANCIEN_ANC CASCADE;

drop table IF EXISTS T_E_EDITIONFETE_EDF CASCADE;

drop table IF EXISTS T_E_ENSEIGNANT_ENS CASCADE;

drop table IF EXISTS T_E_ETUDIANT_ETU CASCADE;

drop table IF EXISTS T_E_FETE_FET CASCADE;

drop table IF EXISTS T_E_PARTICIPANT_PAR CASCADE;

drop table IF EXISTS T_J_INSCRIPTION_INS CASCADE;

drop table IF EXISTS T_R_FILIERE_FIL CASCADE;

drop table IF EXISTS T_R_PROMOTION_PRO CASCADE;

DROP SEQUENCE IF EXISTS SEQ_PAR CASCADE;

drop TYPE IF EXISTS TYPE_ADRESSE;

DROP TYPE IF EXISTS TYPE_TELEPHONE;

drop DOMAIN if exists DOM_NUMERO cascade ;

create sequence SEQ_PAR
start with 1
increment by 1;

CREATE DOMAIN DOM_NUMERO AS VARCHAR(15)
    CHECK (VALUE LIKE '0%' OR VALUE IS NULL OR VALUE LIKE '6%' OR VALUE LIKE '7%' OR VALUE LIKE '4%');

CREATE TYPE TYPE_ADRESSE AS (
    NUM_RUE VARCHAR(10),
    RUE VARCHAR(100),
    CP CHAR(5),
    VILLE VARCHAR(50),
    PAYS VARCHAR(50)
);

CREATE TYPE TYPE_TELEPHONE AS (
    INDICATIF VARCHAR(4),
    NUMERO DOM_NUMERO,
    TYPE_TEL VARCHAR(30)
);
/*==============================================================*/
/* Table : T_E_PARTICIPANT_PAR                                  */
/*==============================================================*/
create table T_E_PARTICIPANT_PAR (
   PAR_ID               INT4                 not null default nextval('SEQ_PAR'),
   FIL_ID               INT4                 not null,
   PAR_NOM              VARCHAR(50)         	,
   PAR_PRENOM           VARCHAR(50)[]         	,
   PAR_SEXE             CHAR(1)             	,
   PAR_MAIL             VARCHAR(100)        	,
   PAR_TELEPHONES           TYPE_TELEPHONE[]          	,
    PAR_ADRESSE TYPE_ADRESSE,
   constraint PK_PAR primary key (PAR_ID),
   constraint CK_PAR_SEXE check (PAR_SEXE in ('H','F') OR PAR_SEXE is null)

);

/*==============================================================*/
/* Table : T_E_ANCIEN_ANC                                       */
/*==============================================================*/
create table T_E_ANCIEN_ANC (
   PRO_ANNEEPROMO       INT4                 not null,
   ANC_ENTREPRISE       VARCHAR(50)          null,
   ANC_FONCTION         VARCHAR(50)          null,
   constraint PK_ANC primary key (PAR_ID)
)INHERITS (T_E_PARTICIPANT_PAR);

/*==============================================================*/
/* Table : T_E_EDITIONFETE_EDF                                  */
/*==============================================================*/
create table T_E_EDITIONFETE_EDF (
   FET_ID               INT4                 not null,
   EDF_NUM              INT4                 not null,
   EDF_DATE             DATE                 not null,
   EDF_BUDGETPREVI      NUMERIC(8,2)         not null,
    EDF_DETAILS         jsonb,
   constraint PK_EDF primary key (FET_ID, EDF_NUM),
   constraint CK_EDF_NUM check (EDF_NUM >=1),
   constraint CK_EDF_BUDGETPREVI check (EDF_BUDGETPREVI >=0)

);

/*==============================================================*/
/* Table : T_E_ENSEIGNANT_ENS                                   */
/*==============================================================*/
create table T_E_ENSEIGNANT_ENS (
   ENS_NUMBUREAU        CHAR(4)              not null,
   constraint PK_ENS primary key (PAR_ID)
)INHERITS (T_E_PARTICIPANT_PAR);

/*==============================================================*/
/* Table : T_E_ETUDIANT_ETU                                     */
/*==============================================================*/
create table T_E_ETUDIANT_ETU (
   ETU_INE              NUMERIC(8)           not null,
   ETU_ANNEE            INT4                 not null,

   -- On garde la contrainte de la clé primaire sur la colonne héritée
   constraint PK_ETU primary key (PAR_ID),
   constraint CK_ETU_ANNEE CHECK (ETU_ANNEE in (3,4,5))
) INHERITS (T_E_PARTICIPANT_PAR);

/*==============================================================*/
/* Table : T_E_FETE_FET                                         */
/*==============================================================*/
create table T_E_FETE_FET (
   FET_ID               INT4                 not null,
   FET_TYPE             VARCHAR(20)          not null,
   FIL_ID               INT4                 not null,
   FET_NOM              VARCHAR(50)          not null,
   constraint PK_FET primary key (FET_ID),
   constraint CK_FET_TYPE CHECK (FET_TYPE in ('Classique', 'Anniversaire'))
);


/*==============================================================*/
/* Table : T_J_INSCRIPTION_INS                                  */
/*==============================================================*/
create table T_J_INSCRIPTION_INS (
   INS_ID               INT4                 not null,
   FET_ID               INT4                 not null,
   EDF_NUM              INT4                 not null,
   PAR_ID               INT4                 not null,
   INS_TYPEPARTICIPATION VARCHAR(10)         not null,
   INS_ACCOMPAGNE       BOOL                 not null,
   constraint PK_INS primary key (INS_ID),
   constraint UQ_INS unique (FET_ID, EDF_NUM, PAR_ID),
   constraint CK_INS_TYPEPARTICIPATION CHECK (INS_TYPEPARTICIPATION in ('Gratuit', 'Payant'))
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





alter table T_E_ANCIEN_ANC
   add constraint FK_ANC_PRO foreign key (PRO_ANNEEPROMO)
      references T_R_PROMOTION_PRO (PRO_ANNEEPROMO);

alter table T_E_EDITIONFETE_EDF
   add constraint FK_EDF_FET foreign key (FET_ID)
      references T_E_FETE_FET (FET_ID);

alter table T_E_FETE_FET
   add constraint FK_FET_FIL foreign key (FIL_ID)
      references T_R_FILIERE_FIL (FIL_ID);

alter table T_E_PARTICIPANT_PAR
   add constraint FK_PAR_FIL foreign key (FIL_ID)
      references T_R_FILIERE_FIL (FIL_ID);

alter table T_J_INSCRIPTION_INS
   add constraint FK_INS_EDF foreign key (FET_ID, EDF_NUM)
      references T_E_EDITIONFETE_EDF (FET_ID, EDF_NUM);

alter table T_J_INSCRIPTION_INS
   add constraint FK_INS_PAR foreign key (PAR_ID)
      references T_E_PARTICIPANT_PAR (PAR_ID);

CREATE INDEX IDX_PAR_FIL ON T_E_PARTICIPANT_PAR (FIL_ID);
CREATE INDEX IDX_INS_EDF ON T_J_INSCRIPTION_INS (FET_ID, EDF_NUM);
CREATE INDEX IDX_INS_PAR ON T_J_INSCRIPTION_INS (PAR_ID);
CREATE INDEX IDX_EDF_FET ON T_E_EDITIONFETE_EDF (FET_ID);
CREATE INDEX IDX_FET_FIL ON T_E_FETE_FET (FIL_ID);
CREATE INDEX IDX_ANC_PRO ON T_E_ANCIEN_ANC (PRO_ANNEEPROMO);