#!/bin/bash

# =============================== VARIABLES ===============================  

# === COULEURS ===
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
WHITE='\033[1;37m'
YELLOW='\033[0;33m'

# === INFOS SYSTÈME ===
NOW="$(date '+%Y-%m-%d %H:%M:%S')"
USER_NAME="$(whoami)"
HOST_NAME="$(hostname -f 2>/dev/null || hostname)"

# === CHEMIN ==============================================


# Chemin absolu jusqu'au script en cours d'exécution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# SCRIPT PYTHON
MAIN_PY="$SCRIPT_DIR/main.py"
# DOCUMENTATION
MAIN_DOC="$SCRIPT_DIR/my_package/script/doc.md"
# BASH_ANIMATION
MAIN_BASH="$SCRIPT_DIR/my_package/script/load.sh"
# Charger les fonctions d'animation
source "$MAIN_BASH"

# =========================================================


# === VARIABLES ===========================================

# Prérequis/Dépendances python
#BASH
PREREQUIS=(curl gnupg gum gocryptfs python3 python3-pip pipx python3.13-venv  pass tmux)

#PYTHON
dependencies=(pyfiglet psutil cryptography python-nmap termcolor colorlog tabulate rich)

# === INSTALATION =========================================

# ### FONCTIONS ###

# GUM
repo_gum() {
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg > /dev/null 2>&1
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ /" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null 2>&1
    sudo apt -qq update -y > /dev/null 2>&1 && sudo apt install -qq gum -y > /dev/null 2>&1
}

# DOCUMENTATION
afficher_doc() {
    if [ -f "$MAIN_DOC" ]; then
        clear
        nano -v "$MAIN_DOC"    
        clear
    else
        echo -e "${RED}Le fichier de documentation n'a pas été trouvé.${NC}"
    fi
}

# Message de Bienvenue
afficher_bienvenue() {
    local message="${WHITE}Bienvenue dans le programme d'installation de G.Cert${NC}\n\n"
    echo -e "$message"
}

# === FONCTIONNEMENT SCRIPT ===

# Flag pour arrêter une répétition dans une boucle for.
stop=false

# Flag instalation paquet
all_installed=true 

# =============================== DEBUT SCRIPT INSTALLATION =============================== 


clear
                    
        # Vérification de l'interactivité du shell et de la présence de sudo et connexion réseau
        if [ -t 0 ]; then

            if dpkg -s "sudo" >/dev/null 2>&1; then

                # Demande le mot de passe sudo une seule fois au début du script                               
                afficher_bienvenue
                sudo -v    
            
                
                # Test WAN
                clear
                afficher_bienvenue
                
                msg="Test de la connexion WAN en cours "
            
                # Démarrer l'animation
                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                sleep 3
                
                # Effectuer le ping
                if ping -c 1 "1.1.1.1" > /dev/null 2>&1; then
                    BLA::stop_loading_animation
                    
                    echo -e "${GREEN}Connexion WAN OK !${NC}"
                else
                    BLA::stop_loading_animation
                    echo -e "${RED}Échec de la connexion WAN !${NC}"
                fi            
                        
                # Vérifier si le ping a réussi
                if [ $? -eq 0 ]; then
                                
                    clear
                    afficher_bienvenue
                    echo -e "${GREEN}Connexion WAN réussie !${NC}"
                    sleep 1
                    clear
                else
                
                # Si le ping échoue, afficher un message d'erreur et quitter
                                
                    clear  
                    afficher_bienvenue
                    echo -e "${RED}Le Ping vers WAN a échoué...${NC}"
                    echo -e "${RED}\nVeuillez vérifier votre connexion internet avant de poursuivre.\n${NC}"
                    sleep 2
                    clear
                    exit 1
                fi

                    #  Boucle por faire  revenir le menu
                    while true; do
                    echo -e "${WHITE}Bienvenue dans le programme d'installation de G.Cert${NC}\n\n"

                    echo -e "[1] ${YELLOW}Installation${NC}\n"
                    echo -e "[2] ${YELLOW}Documentation${NC}\n"
                    echo -e "[3] ${YELLOW}Sortir${NC}\n"

                    
                    read -p "Choisissez une option: " choix_menu_install
                    
                    # Choix multiple
                    case "$choix_menu_install" in

# =============================== CHOIX 1 => INSTALL PREREQUIS ===============================
                        1) 
                                clear
                                afficher_bienvenue
                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"
                                
                                echo -e "[1/4] Installation des prérequis...\n" 
                                echo -e "[2/4] Création de l'environnement Python...\n" 
                                echo -e "[3/4] Création de la clé GPG et du mot de passe...\n" 
                                echo -e "[4/4] Lancement du service G_Cert...\n\n"
                            while true; do
                            read -p "Appuyez sur [Entrée] pour continuer : " input
                        
                            if [[ -z "$input" ]]; then
                                
                            break
                            else
                                echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                            fi
                        done

                        clear
                        afficher_bienvenue
                        echo -e "${YELLOW}Vous avez choisi de lancer le programme d'installation.${NC}\n\n"
                        echo -e "${YELLOW}=== Installation des prérequis pour G.cert  ===${NC}\n"
                        echo -e "${WHITE}Avant de commencer, G.cert nécessite quelques programmes et bibliothèques :${NC}\n"

                        echo -e "${WHITE}• curl :${NC} pour récupérer des fichiers depuis Internet."
                        echo -e "${WHITE}• gnupg :${NC} pour générer vos clés RSA et chiffrer vos mots de passe."
                        echo -e "${WHITE}• gum :${NC} pour afficher des menus et messages clairs."
                        echo -e "${WHITE}• gocryptfs :${NC} pour sécuriser localement vos fichiers de mots de passe."
                        echo -e "${WHITE}• Python 3 (+ venv, pip, pipx) :${NC} pour exécuter les scripts de G.cert."
                        echo -e "${WHITE}• pass :${NC} pour gérer vos mots de passe chiffrés."
                        echo -e "${WHITE}• tmux :${NC} pour gérer des sessions terminal persistantes.\n"
                        
                        
                        while true; do
                            read -p "Appuyez sur [Entrée] pour continuer : " input
                            
                            # Menu Clé
                            if [[ -z "$input" ]]; then

                                # === TABLEAU RECAP ===
                          
                                clear
                                afficher_bienvenue
                                echo -e "\n${YELLOW}=== LISTE DES PAQUETS NECESSAIRES ===${NC}\n"

                                # Tableaux pour stocker les paquets
                                present=()
                                absent=()

                                # Remplir les tableaux
                                for pkg in "${PREREQUIS[@]}"; do
                                    if dpkg -s "$pkg" >/dev/null 2>&1; then
                                        present+=("$pkg")
                                    else
                                        absent+=("$pkg")
                                    fi
                                done

                                # Afficher les paquets présents
                                echo -e "${WHITE}=== PRESENTS ===${NC}"
                                for pkg in "${present[@]}"; do
                                    echo -e "${GREEN}$pkg${NC}"
                                done

                                echo -e "\n${WHITE}=== ABSENTS ===${NC}"
                                # Afficher les paquets absents
                                for pkg in "${absent[@]}"; do
                                    echo -e "${RED}$pkg${NC}"
                                done
                                sleep 3

                                # === INSTALL ===

                                clear
                                afficher_bienvenue

                                if [ ${#absent[@]} -eq 0 ]; then
                                    echo -e "${GREEN}Tous les paquets requis sont déjà installés.${NC}"
                                else
                                    echo -e "${YELLOW}=== INSTALLATION EN COURS ===${NC}\n"

                                    for pkg in "${absent[@]}"; do

                                        # === Message dynamique temporaire avant installation ===
                                        
                                        msg="Veuillez patienter durant l'installation de $pkg"
                                        
                                        
                                         BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                        
                                        if [[ ${pkg} == "gum" ]]; then        
                                            repo_gum    
                                        else       
                                            sudo apt install -qq ${pkg} -y > /dev/null 2>&1
                                        fi
                                        
                                        # Effacer la ligne du message dynamique
                                        echo -ne "\r\033[K"
                                        BLA::stop_loading_animation
                                        
                                        
                                        # Afficher le résultat final sur une ligne propre
                                        if dpkg -l | grep -q "^ii.*${pkg}"; then
                                            echo -e "${WHITE}$pkg${NC} ${GREEN}installé avec succès${NC}\n"
                                            sleep 1.5
                                        else
                                            echo -e "${RED}Problème lors de l'installation de ${WHITE}$pkg${NC}..."
                                            exit 1
                                        fi  
                                    done
                                fi                     
                        
                        
                        
                            break
                        else
                            echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                        fi
                    done
# =============================== DEPENDENCES via PIPX ===============================
                        
                                clear
                                afficher_bienvenue
                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"
                               
                                echo -e "${GREEN}[√] Installation des prérequis...${NC}\n" 
                                echo -e "[2/4] Création de l'environnement Python...\n" 
                                echo -e "[3/4] Création de la clé GPG et du mot de passe...\n" 
                                echo -e "[4/4] Lancement du service G_Cert...\n\n"
                                
                                
                        
                        while true; do
                            read -p "Appuyez sur [Entrée] pour continuer : " input
                        
                            if [[ -z "$input" ]]; then
                                
                            break
                            else
                                echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                            fi
                        done
                        
                        clear
                        afficher_bienvenue
                        echo -e "\n${YELLOW}=== INSTALLATION DEPENDANCES PYTHON DANS UN VENV ===${NC}\n"
                    
                        # Message pour l'animation
                        msg="Veuillez patienter"

                        # Assurer que pipx est installé et accessible
                        python3 -m pipx ensurepath > /dev/null 2>&1
                        export PATH="$HOME/.local/bin:$PATH"

                            
                            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                            # Supprime toute installation éventuelle passée de gcert pour éviter tout conflit de venv
                            rm -rf ~/.local/share/pipx/venvs/gcert
                            # Pipx force l'installation des prérequis
                            pipx install . --force > /dev/null 2>&1
                            BLA::stop_loading_animation
                        

                        # Vérification finale des dépendances
                        for pkg in "${dependencies[@]}"; do
                            
                            # Vérifie si le paquet $pkg est installé via pipx
                            if pipx runpip gcert show "$pkg" >/dev/null 2>&1; then
                                echo -e "${GREEN}$pkg : installée avec succès !${NC}"
                                sleep 1
                            else
                                echo -e "${RED}Dépendance manquante : $pkg${NC}"
                                rm -rf ~/.local/share/pipx/venvs/gcert
                                exit 1
                            fi
                        done

                      
# =============================== CREATION CLE GPG ET MOTS DE PASSE G.CERT ===============================
# Création des mots de passe pour accéder aux différentes options du programme G.Cert

# Menu récapitulatif 

clear
afficher_bienvenue

echo -e "${YELLOW}=== Création Clé GPG et Mots de Passe des Différents Services de G.cert  ===${NC}\n"
echo -e "${WHITE}Les Mots de passe et Clé GPG sont gérés via GnuPG et Pass, il est donc possible par la suite d'administrer via ces programmes... ${NC}\n\n"

echo -e "${WHITE}[1] Génération de la clé GPG :${NC}"
echo -e "   - Une clé RSA sera créée (3072 ou 4096 bits recommandé)."
echo -e "   - Vous devrez saisir votre nom et votre adresse e-mail."
echo -e "   - Une passphrase vous sera demandée."
echo -e "     Cette passphrase protégera tous vos mots de passe et permettra leur administrations.\n"

echo -e "${WHITE}[2] Initialisation de Pass :${NC}"
echo -e "   - Pass est un gestionnaire de mots de passe en ligne de commande."
echo -e "   - Il utilisera votre clé GPG pour chiffrer vos mots de passe."
echo -e "   - Après cette étape, Pass sera prêt à stocker vos mots de passe de manière sécurisée.\n"

echo -e "${WHITE}[3] Création des mots de passe pour les services :${NC}"
echo -e "   - Pour chaque service (WAN, LAN, Gestion Certificats, Certificats, Logs, ), il vous sera demandé de créer un mot de passe sécurisé."
echo -e "   - Ces mots de passe sont chiffrés avec votre clé GPG et permettront à l'application de gérer l'accès aux services de manière sécurisée."
echo -e "   - L'utilisateur n'aura qu'à entrer le mot de passe maître pour accéder à l'ensemble des services.\n"

echo -e "${YELLOW} Bonnes pratiques pour vos mots de passe :${NC}"
echo -e "${WHITE}   - Utilisez toujours des mots de passe uniques pour chaque service."
echo -e "   - Privilégiez des mots de passe longs (12 caractères ou plus) et complexes."
echo -e "   - Mélangez lettres majuscules, minuscules, chiffres et symboles."
echo -e "   - Ne partagez jamais votre mot de passe maître."


            # =============================== CREATION CLE GPG ==============================

                                clear
                                afficher_bienvenue
                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"
                                
                                echo -e "${GREEN}[√] Installation des prérequis...${NC}\n" 
                                echo -e "${GREEN}[√] Création de l'environnement Python...${NC}\n" 
                                echo -e "[3/4] Création de la clé GPG et du mot de passe...\n" 
                                echo -e "[4/4] Lancement du service G_Cert...\n\n"
                        
                        while true; do
                            read -p "Appuyez sur [Entrée] pour continuer : " input
                        
                            if [[ -z "$input" ]]; then
                                
                            break
                            else
                                echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                            fi
                        done
              


                        clear
                        afficher_bienvenue

                        echo -e "${YELLOW}====================================================${NC}"
                        echo -e "${WHITE}INFORMATION : Clé GPG pour le gestionnaire de mots de passe 'pass'${NC}"
                        echo -e "${YELLOW}====================================================${NC}"
                        echo -e "Pour utiliser ${GREEN}pass${NC}, seule une clé ${GREEN}RSA capable de signer et chiffrer${NC} est compatible."
                        echo -e "\nLes options disponibles lors de la création d'une clé GPG :"
                        echo -e "  (1) ${GREEN}RSA and RSA${NC}           => signature et chiffrement compatible avec pass"
                        echo -e "  (2) DSA and Elgamal                  => non compatible"
                        echo -e "  (3) DSA (sign only)                  => non compatible"
                        echo -e "  (4) RSA (sign only)                  => non compatible"
                        echo -e "  (9) ECC (sign and encrypt)           => non compatible (Attention par défaut)"
                        echo -e " (10) ECC (sign only)                  => non compatible"
                        echo -e " (14) Existing key from card           => Clé RSA existante ET RSA chiffrante"
                        echo -e "\n${YELLOW}====================================================${NC}\n"
                        
                        while true; do
                            read -p "Appuyez sur [Entrée] pour continuer : " input
                        
                            if [[ -z "$input" ]]; then
                                
                            break
                            else
                                echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                            fi
                        done

                while true; do

                clear
                afficher_bienvenue
                echo -e "${YELLOW}=== Clé GPG ===${NC}\n\n"
                echo -e "${YELLOW}[1] Créer un nouvelle Clé${NC}\n"
                echo -e "${YELLOW}[2] Entrer un clé existente${NC}\n"
                echo -e "${YELLOW}[3] Sortir...${NC}\n"
                                                        
                read -p "Choisissez une option: " choix_gpg_1

                case "$choix_gpg_1" in

                1)
                    # =============================== CREATION NOUVELLE CLE GPG ==============================
                    clear
                    afficher_bienvenue
                    echo -e "${YELLOW}=== Création d'une nouvelle clé GPG ===${NC}\n"
                    echo -e "${YELLOW}Génération interactive de la clé avec${NC} ${WHITE}GnuPG${NC}${YELLOW}...${NC}\n\n\n"
                    echo -e " ${RED}=> !!! RAPPEL: !!!${NC}  (1) ${GREEN}RSA and RSA${NC}  => compatible avec pass"
                    
                    echo
                    
                    # Génère une nouvelle clé GPG
                    gpg --full-generate-key
                    
                    # Donne la dernière clé GPG créée
                    LAST_CLE=$(gpg --list-keys --keyid-format long | grep -o '[0-9A-F]\{40\}' | tail -n1)
                    
                    # Si pas de clé le script sort
                    [[ -z "$LAST_CLE" ]] && { echo -e "${RED}Aucune clé trouvée, le programme d'installation va quitter...${NC}"; sleep 2; exit 1; }

                    # Message pour l'animation       
                    msg="Veuillez patientez"
                    echo -e "\n\n"
                    BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                    sleep 5
                    BLA::stop_loading_animation


                    clear
                    afficher_bienvenue
                    # Si clé GPG créee message OK
                    echo -e "\n${GREEN}[√] Clé GPG créée.${NC}\n"
                    echo -e "${WHITE}Fingerprint : ${GREEN}${LAST_CLE}${NC}\n"
                    sleep 4
                    break

                ;;

                2)
                     # =============================== ENTRER CLE GPG ==============================
                    while true; do
                        clear
                        afficher_bienvenue
                        echo -e "${YELLOW}=== Création d'une nouvelle clé GPG ===${NC}\n"
                        echo -e " ${RED}=> !!! RAPPEL: !!!${NC}  ${WHITE}Vous devez être en possession de la Pass Phrase de la clé...${NC}"
                        echo
                        
                        # MENU
                        echo -e "${YELLOW}[4] Entrer un Clé...${NC}"
                        echo -e "${YELLOW}[5] Sortir...${NC}\n"
                                                        
                        read -p "Choisissez une option: " choix_gpg_2

                        case "$choix_gpg_2" in
                        4)
                            clear
                            afficher_bienvenue
                            echo -e "${RED}Vous devez être en possession de la passphrase de la clé...${NC}\n\n"
                            sleep 2

                            clear
                            afficher_bienvenue

                            # Liste les clés GPG et les affiche numérotées :
                            # =>   1. 0123456789ABCDEF0123456789ABCDEF01234567
                            # =>   2. ABCDEF0123456789ABCDEF0123456789ABCDEF01
                            cle=$(gpg --list-keys --keyid-format long | grep -o '[0-9A-F]\{40\}' | nl -w2 -s'. ')
                            
                            # En tête liste clé:
                            echo -e "${YELLOW}=== Liste Clé :===${NC}\n"                                    
                            echo -e "$cle\n"
                                                                
                            echo -e "${YELLOW}Veuillez entrer le fingerprint de la clé GPG : ${NC}\n"
                            read -r LAST_CLE
                            #Lit en supprimant les espaces au début et à la fin
                            LAST_CLE="${LAST_CLE//[[:space:]]/}"                                    

                                # Teste le format du fingerprint => 40 caractères hexadécimaux                      
                                if [[ "$LAST_CLE" =~ ^[0-9A-Fa-f]{40}$ ]]; then
                                    echo -e "${WHITE}Clé sélectionnée : ${GREEN}${LAST_CLE}${NC}"
                                break 2
                                else
                                    echo -e "${RED}Clé invalide. Doit être 40 caractères hexadécimaux (0-9, A-F).${NC}"
                                continue 
                                fi
                        ;;
                
                        5)
                            clear
                            afficher_bienvenue
                            # SORTIE
                            echo -e "${RED}Le programme d'instalation va quitter...${NC}" 
                                                
                            msg="Veuillez patientez"
                            echo -e "\n"
                            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                            sleep 4
                            BLA::stop_loading_animation
                            
                            exit 1
                            ;;
                        *)
                            echo -e "${RED}Erreur, Réponse invalide .${NC}"
                            sleep 2
                        ;;
                        esac

                    done
                ;;
                
                3)
                    clear
                    afficher_bienvenue
                    # SORTIE
                    echo -e "${RED}Le programme d'installation va quitter...${NC}" 
                                                        
                    msg="Veuillez patientez"
                    echo -e "\n"
                    BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                    sleep 4
                    BLA::stop_loading_animation
                                    
                    exit 1         
                ;;

                *)
                    echo -e "${RED}Erreur, Réponse invalide .${NC}"
                ;;
                esac 

            done
                            

                # Initialiser pass avec la clé choisie
                clear
                afficher_bienvenue
                # Message d'initialisation
                echo -e "\n${YELLOW}Initialisation de ${WHITE}pass${NC} ${YELLOW}avec la clé${NC} ${GREEN}${LAST_CLE}${NC}${YELLOW}...${NC}\n"
                
                # Message animation
                msg="Veuillez patientez"
                echo -e "\n"
                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                sleep 2
                BLA::stop_loading_animation


                while true; do
                clear
                afficher_bienvenue
                # Confirmation utilisation clé GPG choisi :
                echo -e "${YELLOW}Clé GPG:${NC} ${GREEN}${LAST_CLE}${NC}\n"
                echo -e "${YELLOW}Êtes-vous sûr de vouloir utiliser cette clé ? [y/n] : ${NC}"
                read Choix_Valide_Cle

                # Si oui, pass init avec la clé choisie et le script continue
                if [[ "$Choix_Valide_Cle" =~ ^[yY]$ ]]; then
                    if pass init "$LAST_CLE" >/dev/null 2>&1; then
                        
                        # Vérifie la création du répertoire du Password Store
                        if [[ -d "$HOME/.password-store" ]]; then
                            clear
                            afficher_bienvenue
                            echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${WHITE}[2]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${WHITE}[3]wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                            echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            echo -e "\n\n${GREEN}Password Store créé avec succès !${NC}"
                            sleep 3
                            break
                        else
                            echo -e "${RED}Erreur : le répertoire .password-store n'a pas été créé.${NC}"
                            sleep 3
                            exit 1
                        fi

                    else
                        echo -e "${RED}Erreur : impossible d’initialiser le Password Store avec la clé ${LAST_CLE}.${NC}"
                        sleep 3
                        exit 1
                    fi

                # Si non, le script sort
                elif [[ "$Choix_Valide_Cle" =~ ^[nN]$ ]]; then
                    echo -e "${YELLOW}G.Cert à besoin d'une clé GPG pour le chiffrement des mots de passe...${NC}\n"
                    echo -e "${RED}Le programme d'installation va quitter...${NC}" 

                    msg="Veuillez patientez"
                    echo -e "\n\n"
                    BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                    sleep 4
                    BLA::stop_loading_animation
                    exit 1

                else
                    # Si l'utilisateur ne tape pas y/n
                    echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                fi
            done


# =============================== CREATION MOT DE PASSE ===============================
  

                   

                    # === Création de du Wan ===
                    clear
                    afficher_bienvenue
                    echo -e "${YELLOW}=== Création du Mots de passe Wan ===${NC}\n\n"
                    echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${WHITE}[2]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${WHITE}[3]wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                    echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"

                    # Boucle  du mot de passe
                    while true; do
                        echo -n "Veuillez entrer un Mot de passe Wan : "
                        read -s Wan
                        echo
                        echo -n "Confirmez le Mot de passe Wan : "
                        read -s WanConfirm
                        echo

                        # Teste le mot de passe et sa confirmation
                        if [[ -n "$Wan" && "$Wan" == "$WanConfirm" ]]; then
                            clear
                            afficher_bienvenue
                            echo -e "${YELLOW}=== Création du Mots de passe Wan ===${NC}\n\n"
                            echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${WHITE}[2]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${WHITE}[3]wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                            echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            # Création du embranchement caché dans pass pour la gestion des mot de passe dans gcert
                            # Ici on créé un embrenchement qui ne sera jamais supprimé, mais qu'il faut garder à tout pris pour le fonctionement de gcert
                            
                            #=== REEL ARBORECENCE DE PASS ===
                            #Password Store
                            #├── admin
                            #│   └── gestion_passphrase_NE_PAS_SUPPRIMER
                            #└── gcert
                            #    ├── certif
                            #    ├── gestion
                            #    ├── lan
                            #    ├── logs
                            #    └── wan
                            
                            # Création gestion de la passphrase
                            # Cette partie sera un est pour le déclanchement de la passphrase dans le programme afin de pourvoir utiliser les mot de passe du gestionaire pass.
                            printf '%s\n' "AdimGc3rt" | pass insert -f --multiline admin/gestion_passphrase_NE_PAS_SUPPRIMER >/dev/null 2>&1
                            if [[ -f "$HOME/.password-store/admin/gestion_passphrase_NE_PAS_SUPPRIMER.gpg" ]]; then
                                clear
                                afficher_bienvenue
                                
                                echo -e "${GREEN}Gestion PassPhrase OK...${NC}"
                                sleep 2
                            else
                                echo -e "${RED}Problème lors de la Gestion de la PassPhrase...${NC}"
                                sleep 2
                                exit 1
                            fi
                            # Création du mot de passe wan
                            printf '%s\n' "$Wan" | pass insert -f --multiline gcert/wan >/dev/null 2>&1

                            # Vérification
                            if [[ -f "$HOME/.password-store/gcert/wan.gpg" ]]; then
                                clear
                                afficher_bienvenue
                                echo -e "${YELLOW}=== Création du Mots de passe Wan ===${NC}\n\n"
                                echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${WHITE}[2]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${WHITE}[3]wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                                echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                                echo -e "${GREEN}Dossier gcert ET Mot de passe Wan créé avec succès${NC}"
                                sleep 3
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Wan${NC}"
                                sleep 2
                                exit 1
                            fi

                            break  # Sort de la boucle de saisie
                        else
                            echo -e "${RED}Erreur : les deux mots de passe ne correspondent pas.${NC}"
                            echo "Veuillez réessayer."
                        fi
                    done

                    # === Création de du Password Lan ===
                    clear
                    afficher_bienvenue

                    echo -e "${YELLOW}=== Création du Mots de passe Lan ===${NC}\n\n"
                    echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                    echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n" 

                    # Boucle  du mot de passe
                    while true; do
                        echo -n "Veuillez entrer un Mot de passe Lan : "
                        read -s Lan
                        echo
                        echo -n "Confirmez le Mot de passe Lan : "
                        read -s LanConfirm
                        echo

                        # Teste le mot de passe et sa confirmation
                        if [[ -n "$Lan" && "$Lan" == "$LanConfirm" ]]; then
                            clear
                            afficher_bienvenue

                            echo -e "${YELLOW}=== Création du Mots de passe Lan ===${NC}\n\n"
                            echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                            echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n" 
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            # Création du mot de passe 
                            

                            printf '%s\n' "$Lan" | pass insert -f --multiline gcert/lan >/dev/null 2>&1

                            # Vérification
                            if [[ -f "$HOME/.password-store/gcert/lan.gpg" ]]; then
                                clear
                                afficher_bienvenue

                                echo -e "${YELLOW}=== Création du Mots de passe Lan ===${NC}\n\n"
                                echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                                echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n" 
                                
                                echo -e "${GREEN}Mot de passe Lan créé avec succès${NC}"
                                sleep 2
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Lan${NC}"
                                sleep 2
                                exit 1
                            fi

                            break  # Sort de la boucle de saisie
                        else
                            echo -e "${RED}Erreur : les deux mots de passe ne correspondent pas.${NC}"
                            echo "Veuillez réessayer."
                        fi
                    done

                    # === Création de du Password Gestion ===
                    clear
                    afficher_bienvenue
                    echo -e "${YELLOW}=== Création du Mots de passe Gestion ===${NC}\n\n"
                    echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                    echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"

                    while true; do
                        echo -n "Veuillez entrer un Mot de passe Gestion : "
                        read -s Gestion
                        echo
                        echo -n "Confirmez le Mot de passe Gestion : "
                        read -s GestionConfirm
                        echo

                        if [[ -n "$Gestion" && "$Gestion" == "$GestionConfirm" ]]; then
                            clear
                            afficher_bienvenue
                            echo -e "${YELLOW}=== Création du Mots de passe Gestion ===${NC}\n\n"
                            echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                            echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            # Création du mot de passe 
                            

                            printf '%s\n' "$Gestion" | pass insert -f --multiline gcert/gestion >/dev/null 2>&1

                            # Teste le mot de passe et sa confirmation
                            if [[ -f "$HOME/.password-store/gcert/gestion.gpg" ]]; then
                                clear
                                afficher_bienvenue
                                echo -e "${YELLOW}=== Création du Mots de passe Gestion ===${NC}\n\n"
                                echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                                echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                                echo -e "${GREEN}Mot de passe Gestion créé avec succès${NC}"
                                sleep 2
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Gestion${NC}"
                                sleep 2
                                exit 1
                            fi 

                            break  # Sort de la boucle de saisie
                        else
                            echo -e "${RED}Erreur : les deux mots de passe ne correspondent pas.${NC}"
                            echo "Veuillez réessayer."
                        fi
                    done

                    # === Création de du Password Certif ===
                    clear
                    afficher_bienvenue
                    echo -e "${YELLOW}=== Création du Mots de passe Certif ===${NC}\n\n"
                    echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                    echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"

                    while true; do
                        echo -n "Veuillez entrer un Mot de passe Certif : "
                        read -s Certif
                        echo
                        echo -n "Confirmez le Mot de passe Certif : "
                        read -s CertifConfirm
                        echo
                        
                        # Teste le mot de passe et sa confirmation
                        if [[ -n "$Certif" && "$Certif" == "$CertifConfirm" ]]; then
                            clear
                            afficher_bienvenue
                            echo -e "${YELLOW}=== Création du Mots de passe Certif ===${NC}\n\n"
                            echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                            echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            # Création du mot de passe 
                            

                            printf '%s\n' "$Certif" | pass insert -f --multiline gcert/certif >/dev/null 2>&1

                            # Vérification
                            if [[ -f "$HOME/.password-store/gcert/certif.gpg" ]]; then
                                clear
                                afficher_bienvenue
                                echo -e "${YELLOW}=== Création du Mots de passe Certif ===${NC}\n\n"
                                echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${WHITE}[6]certif${NC}   - Mot de passe pour le service Certificats"
                                echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                                echo -e "${GREEN}Mot de passe Certif créé avec succès${NC}"
                                sleep 2
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Certif${NC}"
                                sleep 2
                                exit 1
                            fi 

                            break  # Sort de la boucle de saisie
                        else
                            echo -e "${RED}Erreur : les deux mots de passe ne correspondent pas.${NC}"
                            echo "Veuillez réessayer."
                        fi
                    done

                    # === Création de du Password Logs ===
                    clear
                    afficher_bienvenue
                    echo -e "${YELLOW}=== Création du Mots de passe logs ===${NC}\n\n"
                    echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}certif${NC}   - Mot de passe pour le service Certificats"
                    echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"

                    while true; do
                        echo -n "Veuillez entrer un Mot de passe Logs : "
                        read -s Logs
                        echo
                        echo -n "Confirmez le Mot de passe Logs : "
                        read -s LogsConfirm
                        echo

                        # Teste le mot de passe et sa confirmation
                        if [[ -n "$Logs" && "$Logs" == "$LogsConfirm" ]]; then
                            clear
                            afficher_bienvenue
                            echo -e "${YELLOW}=== Création du Mots de passe logs ===${NC}\n\n"
                            echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}certif${NC}   - Mot de passe pour le service Certificats"
                            echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            # Création du mot de passe 
                            

                            printf '%s\n' "$Logs" | pass insert -f --multiline gcert/logs >/dev/null 2>&1

                            # Vérification
                            if [[ -f "$HOME/.password-store/gcert/logs.gpg" ]]; then
                                clear
                                afficher_bienvenue
                                echo -e "${YELLOW}=== Création du Mots de passe logs ===${NC}\n\n"
                                echo -e "${YELLOW}=== Structure du Password Store G.cert ===${NC}\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}certif${NC}   - Mot de passe pour le service Certificats"
                                echo -e "    └── ${WHITE}[7]logs${NC}     - Mot de passe pour le service Logs\n\n"
                                echo -e "${GREEN}Mot de passe Logs créé avec succès${NC}"
                                sleep 2
                                
                                clear
                                afficher_bienvenue
                                
                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}certif${NC}   - Mot de passe pour le service Certificats"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}logs${NC}     - Mot de passe pour le service Logs\n\n"
                                sleep 3
                            
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Logs${NC}"
                                sleep 2
                                exit 1
                            fi 

                            break  # Sort de la boucle de saisie
                        else
                            echo -e "${RED}Erreur : les deux mots de passe ne correspondent pas.${NC}"
                            echo "Veuillez réessayer."
                        fi
                    done


# =============================== LANCEMENT DU SCRIPT PYTHON ===============================
                            
                            clear
                                afficher_bienvenue

                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"
                              
                                echo -e "${GREEN}[√] Installation des prérequis...${NC}\n" 
                                echo -e "${GREEN}[√] Création de l'environnement Python...${NC}\n" 
                                echo -e "${GREEN}[√] Création de la clé GPG et du mot de passe...${NC}\n" 
                                echo -e "[4/4] Lancement du service G_Cert...\n\n"
                            
                            while true; do
                            read -p "Appuyez sur [Entrée] pour continuer : " input
                        
                            if [[ -z "$input" ]]; then
                                
                                
                            break
                            else
                                echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                            fi
                        done
                            
                            
                            # S'assurer que le script Python est exécutable
                            chmod +x "$MAIN_PY"

                            # Lancer le script Python
                            if [ -f "$MAIN_PY" ]; then
                                
                                
                                clear
                                afficher_bienvenue

                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"
                                
                                echo -e "${GREEN}[√] Installation des prérequis...${NC}\n" 
                                echo -e "${GREEN}[√] Création de l'environnement Python...${NC}\n" 
                                echo -e "${GREEN}[√] Création de la clé GPG et du mot de passe...${NC}\n" 
                                echo -e "${GREEN}[√] Lancement du service G_Cert...${NC}\n\n"
                                
                                while true; do
                            read -p "Appuyez sur [Entrée] pour continuer : " input
                        
                            if [[ -z "$input" ]]; then
                                
                            break
                            else
                                echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                            fi
                        done

                                
                               clear
                                afficher_bienvenue

                               echo -e "${YELLOW}=====================================================================================${NC}"
                                echo -e "${WHITE}                          Le programme ${YELLOW}G.Cert${WHITE} va être lancé !${NC}"
                                echo -e "${WHITE}           => Après redémarrage, vous pourrez utiliser la commande :${NC}"
                                echo -e "                          ${GREEN}gcert${NC} pour lancer le programme"
                                echo -e "${YELLOW}=====================================================================================${NC}\n\n"

                                echo -e "${YELLOW}Souhaitez vous redemmarer maintenant [y/n]${NC}\n"
                                

                        
                        while true; do
                            read -r choix_redemmarage
                            
                            # Vérifie que la réponse fait exactement 1 caractère et est soit y/Y/n/N
                            if [[ ${#choix_redemmarage} -eq 1 ]]; then
                                
                                if [[ "$choix_redemmarage" == "y" || "$choix_redemmarage" == "Y" ]]; then   
                                    msg="Veuillez patienter"
                                    clear
                                    afficher_bienvenue

                                    echo -e "${YELLOW}=====================================================================================${NC}"
                                    echo -e "${WHITE}                          Le programme ${YELLOW}G.Cert${WHITE} va être lancé !${NC}"
                                    echo -e "${WHITE}           => Après redémarrage, vous pourrez utiliser la commande :${NC}"
                                    echo -e "                          ${GREEN}gcert${NC} pour lancer le programme"
                                    echo -e "${YELLOW}=====================================================================================${NC}\n\n"

                                    BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                    sleep 3
                                    BLA::stop_loading_animation
                                    sudo init 6
                                    break  # Sort de la boucle après un choix valide

                                elif [[ "$choix_redemmarage" == "n" || "$choix_redemmarage" == "N" ]]; then
                                    clear
                                    afficher_bienvenue
                                    msg="Lancement de : G.Cert"

                                    BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                    sleep 4
                                    BLA::stop_loading_animation
                                    clear

                                    # --- Ajout temporaire au PATH pour ce shell ---
                                    export PATH="$HOME/.local/bin:$PATH"

                                    # --- Ajout permanent du PATH pour tous les futurs terminaux ---
                                    grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
                                    grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.profile || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile

                                    # --- Lancement de G.Cert via le binaire pipx ---
                                    G_CERT_BIN="$HOME/.local/bin/gcert"
                                    if [ -x "$G_CERT_BIN" ]; then
                                        "$G_CERT_BIN"
                                    else
                                        echo -e "${RED}G.Cert n'est pas installé correctement.${NC}"
                                        exit 1
                                    fi
                                    break  # Sort de la boucle après un choix valide

                                else
                                    echo -e "${RED}Choix invalide. Entrez uniquement 'y' ou 'n'.${NC}"
                                fi
                            else
                                echo -e "${RED}Erreur : entrez uniquement 'y' ou 'n'.${NC}"
                            fi
                        done


                                        
                                else
                                    afficher_bienvenue
                                    
                                    echo -e "${RED}Problème dans le lancement de : ${WHITE}G.Cert${NC}"
                                    exit 1
                                fi
                        
                            ;;

# =============================== CHOIX 2 => DOC =============================== 

                        2)
                            msg="Vous avez choisi de lire la documentation "
                            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                            sleep 3
                            BLA::stop_loading_animation
                            afficher_doc
                            ;;

# =============================== CHOIX 3 => SORTIR ===============================

                        3)
                            echo -e "\n\nVous avez choisi de ${RED}quitter${NC} le programme d'installation.\n"
                            read -p "Etes-vous sûr? (y/n) : " quit
                            if [[ "$quit" == "y" ]]; then
                                clear
                                exit 1
                            fi    
                            ;;

                        *)
                            
                            echo -e "${RED}Choix invalide${NC}, veuillez choisir parmi les options proposées."
                            sleep 2
                            clear
                            ;;

                    esac

                    done
# =============================== FIN de la boucle d'installation ===============================
                

        else
            # Si sudo n'est pas installé
            afficher_bienvenue
            echo -e "${RED}!!! Sudo n'est pas installé, veuillez procéder à son installation et relancer le script. !!!\n${NC}"
            
            echo -e "\nsu -"
            echo -e "\napt update"
            echo -e "\napt install sudo"
            echo -e "\nusermod -aG sudo [UTILISATEUR COURANT]"
            echo -e "\nnano /etc/hosts"
            echo -e "\n# Ajouter la ligne suivante dans le fichier :"
            echo -e "127.0.1.1 [NOM  MACHINE]"
            echo -e "reboot"
            exit 1
        fi

    
fi    
