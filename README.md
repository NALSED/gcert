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



# Arborecence du projet
           
                  g_cert.sh
                  main.py
                  README.md
                  setup.py
                  script/
                  ├── doc.md
                  ├── load.sh
                  my_package/
                  ├── __init__.py
                  ├── utils.py
                  ├── Certifs/
                  │   └── certif.py
                  ├── Gestion/
                  │   ├── Certif/
                  │   │   └── gestion_certif.py
                  │   ├── Key/
                  │   │   └── delete_key.py
                  │   ├── Pass/
                  │   │   ├── acces.py
                  │   │   ├── changement_mdp.py
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
                │                          │               ├──Durée de mise en cache de la passphrase
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

