<?php
include __DIR__."/../DATABASE/database.php";
?>
<?php
if(isset($_POST["submit"])){
    $nom=htmlspecialchars(trim($_POST["nom"]));
    $prenom=htmlspecialchars(trim($_POST["prenom"]));
    $email=htmlspecialchars(trim($_POST["email"]));
    $password1=htmlspecialchars(trim($_POST["password1"]));
    $password2=htmlspecialchars(trim($_POST["password2"]));
    {
        if(isset($nom) AND isset($prenom) AND isset($email) AND isset($password1) AND isset($password2)){
            if(!empty($nom) AND !empty($prenom) AND !empty($email) AND !empty($password1) AND !empty($password2)){
                if($password1===$password2){
                    $sql="SELECT id FROM users WHERE email=?";
                    $stmt=$pdo-> prepare ($sql);
                    $stmt-> execute([$email]);
                    if($stmt-> rowCount()==0){
                        $password=password_hash($password1 , PASSWORD_DEFAULT);
                        $insert="INSERT INTO users(nom,prenom,email,mot_de_passe) VALUES (?,?,?,?)";
                        $ams=$pdo-> prepare ($insert);
                    $ams-> execute([$nom,$prenom,$email,$password]);
                    header("location:../index.php");
                    exit();
                }
             else{
                echo"Email déjà utilisé";
                exit();
        } 
        }else{
            echo"Mot de passe différent";
            exit();
        }
    } else{
        echo"Veillez remplir tous les champs";
    }
    } else {
        echo"je n'existe pas";
    }
}
}
?>




