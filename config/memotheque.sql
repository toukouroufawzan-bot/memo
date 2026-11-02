CREATE DATABASE IF NOT EXISTS memotheque
    CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE memotheque;

CREATE TABLE filiere (
    id_filiere INT AUTO_INCREMENT PRIMARY KEY,
    nom_filiere VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE utilisateur (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    statut_compte VARCHAR(20) NOT NULL DEFAULT 'en_attente',
    motif_refus VARCHAR(255),
    date_inscription DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_validateur INT,
    FOREIGN KEY (id_validateur) REFERENCES utilisateur(id_utilisateur)
);

CREATE TABLE etudiant (
    id_utilisateur INT PRIMARY KEY,
    niveau_etudes VARCHAR(20) NOT NULL,
    certificat_scolarite VARCHAR(255) NOT NULL,
    nouveau_niveau VARCHAR(20),
    nouveau_certificat VARCHAR(255),
    id_filiere INT,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur),
    FOREIGN KEY (id_filiere) REFERENCES filiere(id_filiere)
);

CREATE TABLE memoire (
    id_memoire INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    auteur VARCHAR(100) NOT NULL,
    resume TEXT NOT NULL,
    mots_cles VARCHAR(255),
    annee INT NOT NULL,
    fichier_pdf VARCHAR(255) NOT NULL,
    attestation_soutenance VARCHAR(255) NOT NULL,
    lien_partage VARCHAR(100) UNIQUE,
    statut VARCHAR(20) NOT NULL DEFAULT 'en_attente',
    motif_refus VARCHAR(255),
    date_depot DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_filiere INT NOT NULL,
    id_deposant INT NOT NULL,
    id_validateur INT,
    FOREIGN KEY (id_filiere) REFERENCES filiere(id_filiere),
    FOREIGN KEY (id_deposant) REFERENCES etudiant(id_utilisateur),
    FOREIGN KEY (id_validateur) REFERENCES utilisateur(id_utilisateur)
);

CREATE TABLE demande (
    id_demande INT AUTO_INCREMENT PRIMARY KEY,
    type_demande VARCHAR(20) NOT NULL,
    motif VARCHAR(255) NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'en_attente',
    date_demande DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_memoire INT NOT NULL,
    id_etudiant INT NOT NULL,
    id_traitant INT,
    FOREIGN KEY (id_memoire) REFERENCES memoire(id_memoire),
    FOREIGN KEY (id_etudiant) REFERENCES etudiant(id_utilisateur),
    FOREIGN KEY (id_traitant) REFERENCES utilisateur(id_utilisateur)
);
