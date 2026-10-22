
-- =========================================================
-- PROJET : MEMOTHEQUE
-- Bibliotheque de memoires academiques
-- MySQL / MariaDB - XAMPP
-- =========================================================

CREATE DATABASE IF NOT EXISTS memotheque
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE memotheque;


-- =========================================================
-- 1. UTILISATEUR
-- Visiteur : aucun compte necessaire
-- Les autres profils sont enregistres ici.
-- =========================================================

CREATE TABLE IF NOT EXISTS utilisateur (
    id_utilisateur INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,

    role ENUM(
        'utilisateur_standard',
        'etudiant',
        'bibliothecaire',
        'administrateur'
    ) NOT NULL DEFAULT 'utilisateur_standard',

    statut_compte ENUM(
        'en_attente',
        'valide',
        'refuse',
        'suspendu'
    ) NOT NULL DEFAULT 'valide',

    niveau_etudes ENUM(
        'Licence 1',
        'Licence 2',
        'Licence 3',
        'Master 1',
        'Master 2',
        'Doctorat'
    ) DEFAULT NULL,

    -- Justificatif prive, a supprimer apres la decision
    certificat_scolarite VARCHAR(255) DEFAULT NULL,

    motif_refus_compte TEXT DEFAULT NULL,

    date_inscription DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    derniere_connexion DATETIME DEFAULT NULL,

    INDEX idx_utilisateur_role (role),
    INDEX idx_utilisateur_statut (statut_compte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- 2. FILIERE
-- Gere les filieres disponibles sur la plateforme.
-- =========================================================

CREATE TABLE IF NOT EXISTS filiere (
    id_filiere INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(150) NOT NULL UNIQUE,
    description TEXT DEFAULT NULL,
    date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- 3. MEMOIRE
-- Depot, validation, publication et retrait.
-- =========================================================

CREATE TABLE IF NOT EXISTS memoire (
    id_memoire INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    titre VARCHAR(255) NOT NULL,
    auteur VARCHAR(200) NOT NULL,
    resume TEXT NOT NULL,
    mots_cles VARCHAR(500) NOT NULL,
    annee_soutenance YEAR NOT NULL,

    id_filiere INT UNSIGNED NOT NULL,
    id_deposant INT UNSIGNED NOT NULL,
    id_validateur INT UNSIGNED DEFAULT NULL,

    -- Fichiers stockes hors de l'espace public
    fichier_pdf VARCHAR(255) NOT NULL,
    attestation_soutenance VARCHAR(255) NOT NULL,

    autorisation_diffusion BOOLEAN NOT NULL DEFAULT FALSE,
    declaration_sans_contenu_confidentiel BOOLEAN NOT NULL DEFAULT FALSE,

    -- Reference a un eventuel accord ecrit de confidentialite
    accord_confidentialite VARCHAR(255) DEFAULT NULL,

    statut_memoire ENUM(
        'en_attente',
        'valide',
        'refuse',
        'retire'
    ) NOT NULL DEFAULT 'en_attente',

    motif_refus TEXT DEFAULT NULL,

    date_depot DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_validation DATETIME DEFAULT NULL,
    date_retrait DATETIME DEFAULT NULL,

    -- Jeton aleatoire pour partager la fiche, jamais le PDF
    jeton_partage CHAR(64) DEFAULT NULL UNIQUE,

    CONSTRAINT fk_memoire_filiere
        FOREIGN KEY (id_filiere)
        REFERENCES filiere(id_filiere)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_memoire_deposant
        FOREIGN KEY (id_deposant)
        REFERENCES utilisateur(id_utilisateur)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_memoire_validateur
        FOREIGN KEY (id_validateur)
        REFERENCES utilisateur(id_utilisateur)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_memoire_statut (statut_memoire),
    INDEX idx_memoire_annee (annee_soutenance),
    INDEX idx_memoire_titre (titre),
    INDEX idx_memoire_auteur (auteur),
    INDEX idx_memoire_deposant (id_deposant),
    INDEX idx_memoire_filiere_annee (id_filiere, annee_soutenance)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- 4. DEMANDE
-- Fonctionnalites du Lot 2.
-- Regroupe les demandes et les recours.
-- =========================================================

CREATE TABLE IF NOT EXISTS demande (
    id_demande INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_utilisateur INT UNSIGNED NOT NULL,
    id_memoire INT UNSIGNED DEFAULT NULL,
    id_traitant INT UNSIGNED DEFAULT NULL,

    type_demande ENUM(
        'changement_niveau',
        'modification_memoire',
        'suppression_memoire',
        'recours'
    ) NOT NULL,

    motif TEXT NOT NULL,

    -- Informations pour une demande de changement de niveau
    nouveau_niveau ENUM(
        'Licence 1',
        'Licence 2',
        'Licence 3',
        'Master 1',
        'Master 2',
        'Doctorat'
    ) DEFAULT NULL,

    nouveau_certificat VARCHAR(255) DEFAULT NULL,

    statut_demande ENUM(
        'en_attente',
        'en_cours',
        'acceptee',
        'refusee'
    ) NOT NULL DEFAULT 'en_attente',

    motif_decision TEXT DEFAULT NULL,
    date_demande DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_decision DATETIME DEFAULT NULL,

    CONSTRAINT fk_demande_utilisateur
        FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur(id_utilisateur)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_demande_memoire
        FOREIGN KEY (id_memoire)
        REFERENCES memoire(id_memoire)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_demande_traitant
        FOREIGN KEY (id_traitant)
        REFERENCES utilisateur(id_utilisateur)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_demande_statut (statut_demande),
    INDEX idx_demande_type (type_demande),
    INDEX idx_demande_utilisateur (id_utilisateur)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- 5. TELECHARGEMENT
-- Historique et controle des telechargements.
-- =========================================================

CREATE TABLE IF NOT EXISTS telechargement (
    id_telechargement BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_utilisateur INT UNSIGNED NOT NULL,
    id_memoire INT UNSIGNED NOT NULL,

    date_telechargement DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_telechargement_utilisateur
        FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur(id_utilisateur)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_telechargement_memoire
        FOREIGN KEY (id_memoire)
        REFERENCES memoire(id_memoire)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    INDEX idx_telechargement_compte_date
        (id_utilisateur, date_telechargement),

    INDEX idx_telechargement_memoire (id_memoire)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- 6. SIGNALEMENT
-- Signalements de memoires publies, Lot 2.
-- Peut etre soumis sans compte.
-- =========================================================

CREATE TABLE IF NOT EXISTS signalement (
    id_signalement INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    id_memoire INT UNSIGNED NOT NULL,

    nom_signaleur VARCHAR(150) NOT NULL,
    email_signaleur VARCHAR(190) NOT NULL,

    motif ENUM(
        'droit_auteur',
        'confidentialite',
        'contenu_inapproprie',
        'autre'
    ) NOT NULL,

    description TEXT NOT NULL,

    statut_signalement ENUM(
        'en_attente',
        'en_cours',
        'retabli',
        'retrait_definitif'
    ) NOT NULL DEFAULT 'en_attente',

    id_administrateur INT UNSIGNED DEFAULT NULL,
    decision_motivee TEXT DEFAULT NULL,

    date_signalement DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_decision DATETIME DEFAULT NULL,

    CONSTRAINT fk_signalement_memoire
        FOREIGN KEY (id_memoire)
        REFERENCES memoire(id_memoire)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_signalement_administrateur
        FOREIGN KEY (id_administrateur)
        REFERENCES utilisateur(id_utilisateur)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_signalement_statut (statut_signalement)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- FIN DE LA CREATION DE MEMOTHEQUE
-- =========================================================

