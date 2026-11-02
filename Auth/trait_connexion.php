<?php
session_start();
include __DIR__ . "/../DATABASE/database.php";

if (isset($_POST["submit"])) {
    $email    = trim($_POST["email"] ?? "");
    $password = $_POST["password"] ?? "";

    if ($email === "" || $password === "") {
        echo "Veuillez remplir tous les champs";
        exit();
    }

    $stmt = $pdo->prepare("SELECT * FROM utilisateur WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($password, $user["mot_de_passe"])) {
        echo "Email ou mot de passe incorrect";
        exit();
    }

    if ($user["statut_compte"] === "en_attente") {
        echo "Votre compte est en attente de validation";
        exit();
    }

    if ($user["statut_compte"] === "refuse") {
        echo "Votre compte a été refusé : " . htmlspecialchars($user["motif_refus"]);
        exit();
    }

    session_regenerate_id(true);
    $_SESSION["id_utilisateur"] = $user["id_utilisateur"];
    $_SESSION["nom"]            = $user["nom"];
    $_SESSION["prenom"]         = $user["prenom"];
    $_SESSION["role"]           = $user["role"];

    switch ($user["role"]) {
        case "administrateur":
            header("Location: ../admin/dashboard.php");
            break;
        case "bibliothecaire":
            header("Location: ../biblio/dashboard.php");
            break;
        default:
            header("Location: ../dashboard.php");
    }
    exit();
}
?>
