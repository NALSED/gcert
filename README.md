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








                     ├
└──
├──  















