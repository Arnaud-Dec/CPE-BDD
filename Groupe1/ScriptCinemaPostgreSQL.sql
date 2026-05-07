drop table if exists Personne cascade;

drop table if exists Genre cascade;

drop table if exists Film cascade;

drop table if exists Acteur cascade;

drop table if exists Distribution cascade;

drop table if exists Cinema cascade;

drop table if exists Salle cascade;

drop table if exists Programmation cascade;




-- Création table Personne

create table Personne(  NumPersonne INTEGER NOT NULL PRIMARY KEY,Prenom VARCHAR(30) NOT NULL,Nom VARCHAR(30) NOT NULL,Datenais INTEGER,Nationalite VARCHAR(30) NOT NULL,Adresse VARCHAR(50),CP CHAR(5),Ville VARCHAR(30),Telephone CHAR(20));



-- Insertion des données dans Personne

insert into Personne values(1,'Leonardo','Di Caprio',1974,'Americain','9255 Sunset Blvd','CA900','West Hollywood', '310 300 1390');

insert into Personne values(2,'Quentin','Tarentino',1963,'Americain','3rd Floor','CA902','Beverly Hills',null);

insert into Personne values(3,'Benjamin','Renner',1965,'Belges','rue des Mages','01007','Bruxelles',null);

insert into Personne values(4,'Neill','Blomkamp ',1979,'Sud Africain',null,null,null,null);

insert into Personne values(5,'Charles','Badiale',null,'Francais',null,null,null,null);--agent
insert into Personne values(6,'Emile','Genecrois',null,'Francais',null,null,null,null);--agent
insert into Personne values(7,'Jacques','Audiard',1952,'Francais',null,null,null,null);

insert into Personne values(8,'Berenice','Bejo',1972,'Francais','bd Henry Troya','75008','Paris','0113121415');

insert into Personne values(9,'Jean','Dujardin',1972,'Francais','avenue de Messine','75008','Paris','0133456189');

insert into Personne values(10,'Michel','Hazanavicius',1967,'Francais','28 rue Pierre Semard','75009','Paris','0135729328');

insert into Personne values(11,'Daniel','Radcliffe',1989,'Anglais','Saint Martin Lane','WC3N','Londres','5635435789');

insert into Personne values(12,'David','Yates',1963,'Anglais','7 12 Noel Street','W1F','Londres','34432437237');

insert into Personne values(13,'Ian','Mckellen',1939,'Anglais','1777 Carri','QCH3C','Montreal','30394770813');

insert into Personne values(14,'Peter','Jackson',1961,'Neo Zelandais','15e Avenue',null,'New York',555555);

insert into Personne values(15,'Francois','Cluzet',1955,'Francais','20 Avenue Rapp','75007','Paris','0137853890');

insert into Personne values(16,'Omar','Sy',1978,'Francais','18 rue Duret','75006','Paris','0154543278');

insert into Personne values(17,'Eric','Toledano',1971,'Francais','Avenue Stalingrad','75018','Paris','0123435356');

insert into Personne values(18,'Baz ','Luhrmann',1962,'Australien','PO Box 430',null,'Kings Cross','612093341500');

insert into Personne values(19,'Jamie','Foxx',1967,'Americain','Melrose Avenue 7th Floor','CA900','Los Angeles','0110203040');
insert into Personne values(20,'Thor','Freudenthal',1967,'Allemand','rue Est',NULL,'Berlin','45310203040');

-- Création Table Genre

Create table Genre (
	NumGenre INTEGER NOT NULL PRIMARY KEY,
	LibelleGenre VARCHAR(20) NOT NULL
);


-- Insertion des données dans Genre
Insert Into Genre Values(1, 'Drame');
Insert Into Genre Values(2, 'Comedie');
Insert Into Genre Values(3, 'Aventure');
Insert Into Genre Values(4, 'Science-fiction');
Insert Into Genre Values(5, 'Historique');
Insert Into Genre Values(6, 'Thriller');
Insert Into Genre Values(7, 'Fantastique');

-- Création table Film
create table Film (NumFilm INTEGER NOT NULL PRIMARY KEY,Titre VARCHAR(50) NOT NULL,Genre INTEGER NOT NULL,Annee INTEGER NOT NULL,Longueur INTEGER NOT NULL,Budget INTEGER NOT NULL,nb_spectateurs_cumule INTEGER NOT NULL,Realisateur INTEGER NOT NULL,Salaire_real INTEGER NOT NULL,FOREIGN KEY (Realisateur) REFERENCES Personne (NumPersonne),FOREIGN KEY (Genre) REFERENCES Genre (NumGenre)
			);
-- Insertion des données dans Film
insert into Film values (1, 'Django Unchained', 6, 2013, 164, 100000000, 4293000, 2, 100000);
insert into Film values (2, 'Gatsby Le Magnifique', 1, 2013, 142, 127000000, 1544000, 18, 200000);
insert into Film values (3, 'Intouchables', 2, 2011, 112, 12000000, 19385000, 17, 750000);
insert into Film values (4, 'Le Hobbit La désolation de Smaug', 3, 2013, 165, 70000000, 4500000, 14, 1000000);
insert into Film values (5, 'Harry Potter et les reliques de la mort - partie 2', 7, 2011, 130, 30000000, 6500000, 12, 1200000);
insert into Film values (6, 'The Artist', 1, 2011, 100, 12000000, 3064000, 10, 20000);
insert into Film values (7, 'De Rouille et d''os', 1, 2012, 120, 20000000, 1800000, 1, 37000);
insert into Film values (8, ' Inglourious Basterds ', 2, 2009, 153, 70000000, 2860000, 2, 80000);
insert into Film values (9, 'Elysium', 4, 2013, 110, 100000000, 400000, 8, 30000); 
insert into Film values (10, 'Un prophete', 1, 2009, 155, 15000000, 1329000, 7, 75000);
insert into Film values (12, 'Le Hobbit un voyage inattendu', 3, 2012, 165, 50000000, 2500000, 14, 100000);

insert into Film values (13, 'Ernest et Celestine', 2, 2012, 80, 9000000, 900000, 3, 80000);
insert into Film values (14, 'Percy Jackson : La mer des monstres ', 7, 2013, 106, 90000000, 1200000, 20, 250000);

-- Création table Acteur
create table Acteur (NumActeur INTEGER NOT NULL PRIMARY KEY,
NumPersonne INTEGER NOT NULL,
Agent INTEGER,
Specialite INTEGER,
Taille INTEGER,
poids INTEGER, 
FOREIGN KEY (NumPersonne) REFERENCES Personne (NumPersonne),
FOREIGN KEY (Agent) REFERENCES Personne (NumPersonne),
FOREIGN KEY (Specialite) REFERENCES Genre (NumGenre)
			);
-- Insertion des données dans Acteur

insert into Acteur values(1,19,6,3,183,72);
insert into Acteur values(2,1,6,3,167,68);
insert into Acteur values(3,16,5,2,185,69);
insert into Acteur values(4,15,5,1,178,68);
insert into Acteur values(5,9,5,2,185,78);
insert into Acteur values(6,8,5,1,175,67);
insert into Acteur values(7,11,6,4,165,65);
insert into Acteur values(8,13,6,4,188,78);
insert into Acteur values(9,2,6,1,180,75);

insert into Acteur values(10,18,11,2,172,60);

-- Création table Distribution
create table Distribution(NumFilm integer,NumActeur integer,role VARCHAR(50),salaire integer,PRIMARY KEY (NumFilm, NumActeur, role),
	FOREIGN KEY (NumFilm) REFERENCES Film (NumFilm),FOREIGN KEY (NumActeur) REFERENCES Acteur (NumActeur)	);
-- Insertion des données dans Distribution
insert into Distribution values(1,1,'Django',2000000);
insert into Distribution values(1,2,'Calvin Candie',5000000);
insert into Distribution values(2,2,'Jay Gatsby',4000000);
insert into Distribution values(3,3,'Driss',500000);
insert into Distribution values(3,4,'Philippe',500000);
insert into Distribution values(6,5,'Georges Valentin',167000);
insert into Distribution values(6,6,'Peppy Miller',155000);
insert into Distribution values(5,7,'Harry',1100000);
insert into Distribution values(4,8,'Gandalf ',150000);
insert into Distribution values(8,9,'First Scalped ',0);
insert into Distribution values(8,9,'Soldat Americain',0);

-- Création table Cinema
create table Cinema(NumCinema integer PRIMARY KEY,nom VARCHAR(15),adresse VARCHAR(50),ville VARCHAR(20),telephone CHAR(10),	compagnie VARCHAR(20)
	);
-- Insertion des données dans Cinema
insert into cinema values(1,'Utopia','avenue de Messine','Paris','0113129392','indep');
insert into cinema values(2,'UGC','cours Truc','Bordeaux','0513223588','UGC');
insert into cinema values(3,'Pathe','rue Machin','Bordeaux','0545327733','Gaumont');
insert into cinema values(4,'Vigo','rue Franklin','Bordeaux','0543283257','indep');
insert into cinema values(5,'Decavision','rue Carnot','Annecy','0443283257','indep');

-- Création table Salle
create table Salle(NumCinema INTEGER NOT NULL,NumSalle INTEGER NOT NULL,Taille_Ecran INTEGER NOT NULL,Nbplaces INTEGER NOT NULL,PRIMARY KEY (NumCinema, NumSalle),FOREIGN KEY (NumCinema) REFERENCES Cinema(NumCinema)
                    );
-- Insertion des données dans Salle
insert into Salle values( 1,1,40,200);
insert into Salle values( 1,2,32,150);
insert into Salle values( 1,3,25,85);
insert into Salle values( 2,1,60,252);
insert into Salle values( 2,2,32,168);
insert into Salle values( 2,3,52,180);
insert into Salle values( 4,1,49,122);
insert into Salle values( 3,1,35,70);
insert into Salle values( 3,2,43,120);

-- Création table Programmation
create table Programmation (NumFilm INTEGER NOT NULL,NumCinema INTEGER NOT NULL,NumSalle INTEGER NOT NULL,Date_deb DATE NOT NULL,Date_fin DATE NOT NULL,Horaire CHAR(5) NOT NULL,Prix INTEGER NOT NULL,PRIMARY KEY (NumFilm, NumCinema, NumSalle, Date_deb),FOREIGN KEY (NumCinema,NumSalle) REFERENCES Salle(NumCinema, NumSalle),FOREIGN KEY (NumFilm) REFERENCES Film (NumFilm));
insert into Programmation values(14,1,2,'2013-02-12','2013-02-28','22:00',8);
insert into Programmation values(1,1,3,'2013-01-28','2013-04-14','15:00',8);
insert into Programmation values(5,2,1,'2013-01-28','2013-04-07','15:35',10);
insert into Programmation values(8,2,2,'2013-01-13','2013-02-22','20:30',10);
insert into Programmation values(10,4,1,'2013-01-01','2013-12-31','18:00',9);