# TEST
    sudo rm -r gcert/

---
    
    chmod +x g_cert.sh
    
---
    
    ./g_cert.sh
# DOCKER
       docker run -ti --name gcert debian:latest
       apt update && apt -y install sudo git
       docker run -ti --name gcert debian:latest
---
       docker stop gcert
       docker rm -f gcert

# LINUX
      
      git clone https://github.com/NALSED/gcert.git

# WIN
      git clone https://github.com/NALSED/gcert.git "C:\Users\sednal\Desktop\PKI"
      git clone https://github.com/NALSED/gcert.git  "C:\Users\sednal\Documents\IT\PKI"


# TEST +VENV
      python3 -m venv [NOM PROJET]
      source venv/bin/activate
      pip freeze > requirements.txt

# SUDO GIT
      su -
      apt update && apt -y install sudo git && usermod -aG sudo sednal

# GIT

      
      mv .git .git_backup
      git init
      git add .
      git commit -m "Restauration après corruption du dépôt"
      git remote add origin https://github.com/NALSED/gcert
      git push -u origin main --force


# Arborecence du projet
           
                  g_cert.sh
                  main.py
                  README.md
                  setup.py
                  my_package/
                  ├── script/
                  |    ├── doc.md
                  |    ├── load.sh
                  |    ├── auth_config.json
                  ├── utils.py
                  ├── Certifs/
                  │   └── certif.py
                  ├── Gestion/
                  │   ├── Certif/
                  │   │   └── gestion_certif.py
                  │   ├── Key/
                  │   │    ├── mofif_mdp.py
                  │   │    └── delete_key.py
                  |   |     
                  │   ├── Pass/
                  │   │   ├── acces.py
                  │   │   ├── changement_mdp.py
                  │   │   ├── config_auth.py
                  │   │   ├── etat_mdp.py
                  │   │   ├── gestion_pass.py
                  │   │   ├── modif.py
                  │   │   └── modif_mdp.py
                  │   └── gestion_menu.py
                  ├── Lan/
                  │   └── lan.py
                  ├── Wan/
                  │   └── wan.py
                  └── Logs/
                      ├── logs_Arch.py
                      └── logs_Menu.py


# SCRIPT CHEMIN
          Install G.Cert (gcert.sh)
            │
            └── gpg
                │
                ├── "Continuer" ──► main.py
                │                  │
                │                  └── Menu principal G.Cert
                │                      │
                │                      └── Choix utilisateur
                │                          │ 
                |                          ├── Certificat WAN (Wan_Pass)
                │                          │      |
                |                          |      └── Création certificat
                │                          │    
                │                          │
                │                          ├── Certificat LAN (Lan_Pass)
                │                          │      |
                |                          |      └── Création certificat
                │                          │    
                │                          ├── Gestion 
                │                          │      ├── Certificat
                |                          |      |        |
                |                          |      |        ├── Import / export certificat
                │                          │      |        └── Suppression certificat
                │                          │      |
                │                          │      |
                │                          │      └── Mot de passe + Clées GPG
                │                          │               |
                │                          │               ├── Modification Mot de Passe
                │                          │               ├──Désactivation Mot de Passe
                │                          │               ├──Réactiver une clé expirée
                │                          │               └── Supprimer clé
                │                          │            
                │                          │
                │                          │
                │                          ├── Certificats (Certif_Pass)
                │                          │               │ 
                │                          │               └── Stockage Sécurisé
                │                          │    
                │                          │
                │                          ├── Logs (Log_Pass)
                │                          │          │
                │                          │          ├── Info.log
                │                          │          ├── Warning.log
                │                          │          ├── Error.log
                │                          │          ├── Critical.log
                │                          │          └── Retour
                │                          │
                │                          ├── Doc
                │                          │    └── Ouverture doc.md
                │                          │    
                │                          │
                │                          └── Quitter
                │                              
                │                              
                │                               
                │
                └── "Création Clé GPG + MDP" Et retour Menu Principal


# Arborecence du projet et détail fichier .py 
           
                  g_cert.sh => Script d'installation
                  main.py => Script principal gcert
                  README.md
                  setup.py => fichier setup
                  my_package/
                  ├── script/
                  |    ├── doc.md => Documentation gcert
                  |    ├── load.sh => Animation g_cert.sh
                  |    ├── auth_config.json => Activation / Désactivation MDP gcert
                  ├── utils.py => Variables communes
                  ├── Certifs/ 
                  │   └── certif.py => Depuis main.py : Menu de coffre fort certificats ssl (en cours)
                  ├── Gestion/
                  │   ├── Certif/
                  │   │   └── gestion_certif.py => Depuis gestion_menu.py : Permet l'administration des certificats ssl
                  │   ├── Key/
                  │   │    ├── mofif_mdp_gpg.py => Depuis delete_key.py : Supprimme le Password Store courant / création clé GPG et Password Store
                  │   │    └── delete_key.py => Depuis gestion_pass.py : Liste et supprime clé GPG
                  |   |     
                  │   ├── Pass/
                  │   │   ├── acces.py => Depuis main.py Permet l'accés au service par Mot de passe
                  │   │   ├── changement_mdp.py => Depuis modif.py ou modif_mdp_gpg.py : Créé de nouveau mot de passe
                  │   │   ├── config_auth.py => Avec etat_mdp.py et auth_config.json : Permet à etat_mdp.py de fonctionner. 
                  │   │   ├── etat_mdp.py Depuis => Depuis gestion_pass.py : Active ou désactive l’accès par mot de passe aux services et indique son état.(Permet de bypass access.py si désectivation Mot De Passe et fait direct main.py service)
                  │   │   ├── gestion_pass.py => Depuis gestion_menu.py : Menu de Gestion Mot de pass et clé GPG.
                  │   │   ├── modif.py => Depuis main.py : Efface le Password Store Et créé un nouvelle clé GPG (Utiliser en cas d'oublie de la passphrase).
                  │   │   └── modif_mdp.py => Depuis gestion_pass.py : Permet la modification des mots de passe, sans supprimmer Password Store et Clé GPG.
                  │   └── gestion_menu.py => Depuis main.py : Menu de gestion Certificat ou Mot de passe et clé GPG. 
                  ├── Lan/
                  │   └── lan.py => Depuis main.py : Menu de création certificat LAN (en cours)
                  ├── Wan/
                  │   └── wan.py => Depuis main.py : Menu de création certificat WAN (en cours)
                  └── Logs/
                      ├── logs_Arch.py Permet la mise en place de Logs (en cours)
                      └── logs_Menu.py => Depuis main.py : Menu de gestion des logs (en cours)




