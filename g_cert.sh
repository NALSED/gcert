#!/bin/bash

# =============================== VARIABLES ===============================  

# === COULEURS NORMAL ===
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
WHITE='\033[1;37m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'  
CYAN='\033[0;36m'     

# === COULEUR VIVE ===
YELLOW_BRIGHT='\033[1;33m'  
BLUE_BRIGHT='\033[1;34m'
CYAN_BRIGHT='\033[1;36m'

# === AUTRE COSMETIQUE COULEUR ===

INVERSE='\033[7m'           # Inversé (fond et texte inversés)
UNDERLINE='\033[4m'         # Texte souligné

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

# === LOG ===

INSTALL_LOG="/tmp/install.log"
ERROR_LOG="/var/log/gcert_install/erreur.log"


# =========================================================


# === VARIABLES ===========================================

# Prérequis/Dépendances python
#BASH
PREREQUIS=(curl gnupg gum python3 python3-pip pipx python3.13-venv pass tmux)

#PYTHON
dependencies=(pyfiglet psutil cryptography python-nmap termcolor colorlog tabulate rich)

# === INSTALATION =========================================

# ### FONCTIONS ###

# GUM

repo_gum() {
    sudo mkdir -p /etc/apt/keyrings >/dev/null 2>> "$ERROR_LOG"
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>> "$ERROR_LOG" && echo "/etc/apt/keyrings/charm.gpg" >> "$INSTALL_LOG"
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ /" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null 2>> "$ERROR_LOG" && echo "/etc/apt/sources.list.d/charm.list" >> "$INSTALL_LOG"
    sudo apt -qq update -y >/dev/null 2>> "$ERROR_LOG" && sudo apt install -qq gum -y >/dev/null 2>> "$ERROR_LOG" && echo "gum" >> "$INSTALL_LOG"
}

# VAULT 

repo_vault() {
    sudo apt -qq update -y >/dev/null 2>> "$ERROR_LOG" && sudo apt install -y gnupg wget lsb-release >/dev/null 2>> "$ERROR_LOG" && {
        echo "gnupg" >> "$INSTALL_LOG"
        }
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>> "$ERROR_LOG" && echo "/usr/share/keyrings/hashicorp-archive-keyring.gpg" >> "$INSTALL_LOG"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null 2>> "$ERROR_LOG" && echo "/etc/apt/sources.list.d/hashicorp.list" >> "$INSTALL_LOG"
    sudo apt -qq update -y >/dev/null 2>> "$ERROR_LOG" && sudo apt install -qq vault -y >/dev/null 2>> "$ERROR_LOG" && echo "vault" >> "$INSTALL_LOG"
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
    local message="${YELLOW_BRIGHT}${UNDERLINE}Bienvenue dans le programme d'installation de G.Cert${NC}\n\n"
    echo -e "$message"
}

# Validation IP
validate_ip() {
                local ip="$1"
                if [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
                    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
                    if (( i1 <= 255 && i2 <= 255 && i3 <= 255 && i4 <= 255 )); then
                        return 0
                    fi
                fi
                return 1
            }

# Validation Message info

enter() {
    while true; do
        read -p "Appuyez sur [Entrée] pour continuer : " input

        if [[ -z "$input" ]]; then
            break
        else
            echo -e "\n${RED}Erreur : appuyez uniquement sur [Entrée].${NC}\n"
        fi
    done
}



# === SUPPRESSION ===

# Restauration systeme
clean_up() {
    while IFS= read -r i; do
        if [[ "$i" == gpg:* ]]; then
            key_id="${i#gpg:}"
            # Supprimer la clé (privée et/ou publique)
            sudo gpg --batch --yes --delete-secret-and-public-key "$key_id" >/dev/null 2>&1
        elif [[ "$i" == pipx:* ]]; then
            pkg_name="${i#pipx:}"
            # Désinstaller le package pipx
            pipx uninstall "$pkg_name" >/dev/null 2>&1
        else
            # Supprime les paquets et fichiers
            sudo dpkg -s "$i" >/dev/null 2>&1 && sudo apt-get purge -y "$i" >/dev/null 2>&1
            [ -e "$i" ] && sudo rm -rf "$i" >/dev/null 2>&1
        fi
    done < "$INSTALL_LOG"
    sudo rm -f "$INSTALL_LOG" >/dev/null 2>&1
    
}

# Nettoyage en cas d'echec + msg
clean_up_error(){
    
    clear
    echo -e "${RED}[ERREUR] Annulation de l'installation G.Cert et restauration du système [ERREUR]${NC}\n\n"
    echo -e "Vous pouvez consulter ${WHITE}/var/log/gcert_install/erreur.log${NC}, pour plus d'information\n"
    sleep 4

    clear
    msg="Veuillez patienter durant la restauration du système"

    BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
    
    clean_up
    
    BLA::stop_loading_animation
    clear
    sleep 1
    exit 1
}

# Nettoyage sortie utilisateur avec confirmation + msg
clean_up_choice(){
    
    while true; do
        clear
        afficher_bienvenue
        read -p "Etes vous sur de vouloir quitter (cela effacera tout l'avancement de l'installation de G.Cert) y/n : " choix_quit
        
        if [[ "$choix_quit" =~ ^[yY]$ ]]; then
            clear
            echo -e "${RED} XXX Vous avez choisi de quitter l'installation G.Cert, mise en route de la restauration du système XXX${NC}\n\n"
            
            sleep 4

            clear
            msg="Veuillez patienter durant la restauration du système"
            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
            
            clean_up
            
            BLA::stop_loading_animation
            clear
            sleep 1
            exit 1
        elif [[ "$choix_quit" =~ ^[nN]$ ]]; then
            break
        else
            echo -e "\n${RED}Réponse invalide. Tapez y ou n.${NC}"
        fi
    done
}


# === FONCTIONNEMENT SCRIPT ===

# Flag pour arrêter une répétition dans une boucle for.
stop=false

# Flag instalation paquet
all_installed=true 


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# =============================== DEBUT SCRIPT INSTALLATION =============================== 
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

clear
afficher_bienvenue        
        
        

        # Vérification de l'interactivité du shell et de la présence de sudo et connexion réseau
        if [ -t 0 ]; then

            if dpkg -s "sudo" >/dev/null 2>&1; then

                clear
                afficher_bienvenue
                
                echo -e "\n${WHITE}=== Redirections des logs du programme d'installation de G.Cert ===${NC}"
                echo -e "\n\n-${INVERSE}[1]${NC}- Création d'un fichier de logs pour les sorties d'erreur :"
                echo -e "   - Les erreurs sont redirigées vers ${WHITE}/var/log/gcert_install/erreur.log${NC}"
                echo -e "\n-${INVERSE}[2]${NC}- Création d'un fichier de logs pour lister les installations/actions du programme."
                echo -e "   - Elles seront redirigées vers ${WHITE}/tmp/install.log${NC}. En cas de crash, le programme d'installation effacera les actions réalisées pour une installation future propre.\n"

                enter

                sudo mkdir /var/log/gcert_install >/dev/null 2>&1          
                sudo chown $USER:$USER /var/log/gcert_install/ >/dev/null 2>&1
                sudo chmod 755 /var/log/gcert_install/ >/dev/null 2>&1
                sudo touch /tmp/install.log >/dev/null 2>&1
                sudo chown $USER:$USER /tmp/install.log >/dev/null 2>&1
                sudo chmod 644 /tmp/install.log >/dev/null 2>&1

               
                clear
                afficher_bienvenue

                # === REPERTOIRE ===

                # Vérifier si le répertoire /var/log/gcert_install existe
                if [ -d "/var/log/gcert_install" ]; then
                    echo -e "${GREEN}OK : Le répertoire ${WHITE}/var/log/gcert_install${GREEN} créé avec succès.${NC}\n"
                    sleep 1
                else
                    echo -e "${RED}ERREUR : Problème lors de la création du répertoire ${WHITE}/var/log/gcert_install${RED}.${NC}"
                    echo -e "Veuillez créer le répertoire avec la commande : ${WHITE}sudo mkdir /var/log/gcert_install${NC}"
                    sleep 3
                    exit 1
                fi

                # Vérifier si le fichier /tmp/install.log existe
                if [ -f "/tmp/install.log" ]; then
                    echo -e "${GREEN}OK : Le fichier ${WHITE}/tmp/install.log${GREEN} créé avec succès.${NC}\n"
                    sleep 1
                else
                    echo -e "${RED}ERREUR : Le fichier ${WHITE}/tmp/install.log${RED} n'existe pas.${NC}"
                    echo -e "Veuillez créer le fichier avec la commande : sudo touch /tmp/install.log"
                    sleep 3
                    exit 1
                fi

                # === PROPRIETE ===

                # Vérification de la propriété du répertoire /var/log/gcert_install
                if [[ $(stat -c "%U:%G" /var/log/gcert_install) == "$USER:$USER" ]]; then
                    echo -e "${GREEN}OK : Le propriétaire du répertoire ${WHITE}/var/log/gcert_install${GREEN} est correct : $USER.${NC}\n"
                    sleep 1
                else
                    echo -e "${RED}ERREUR : Le propriétaire du répertoire ${WHITE}/var/log/gcert_install${RED} est incorrect.${NC}"
                    echo -e "Veuillez corriger la propriété avec la commande : sudo chown $USER:$USER /var/log/gcert_install"
                    sleep 3
                    exit 1
                fi

                # Vérification du propriétaire du fichier /tmp/install.log
                if [[ $(stat -c "%U:%G" /tmp/install.log) == "$USER:$USER" ]]; then
                    echo -e "${GREEN}OK : Le propriétaire du fichier ${WHITE}/tmp/install.log${GREEN} est correct : $USER.${NC}\n"
                    sleep 1
                else
                    echo -e "${RED}ERREUR : Le propriétaire du fichier ${WHITE}/tmp/install.log${RED} est incorrect.${NC}"
                    echo -e "Veuillez corriger la propriété avec la commande : sudo chown $USER:$USER /tmp/install.log"
                    sleep 3
                    exit 1
                fi
                
                # === DROITS ===
                
                # Vérification des permissions du répertoire /var/log/gcert_install
                if [[ $(stat -c "%a" /var/log/gcert_install) == "755" ]]; then
                    echo -e "${GREEN}OK : Les permissions du répertoire ${WHITE}/var/log/gcert_install${GREEN} sont correctes :${NC} ${WHITE}755 ${NC}\n"
                    sleep 1
                else
                    echo -e "${RED}ERREUR : Les permissions du répertoire ${WHITE}/var/log/gcert_install${RED} sont incorrectes.${NC}"
                    echo -e "Veuillez corriger les permissions avec la commande : sudo chmod 755 /var/log/gcert_install"
                    sleep 3
                    exit 1
                fi

                # Vérification des permissions du fichier /tmp/install.log
                if [[ $(stat -c "%a" /tmp/install.log) == "644" ]]; then
                    echo -e "${GREEN}OK : Les permissions du fichier ${WHITE}/tmp/install.log${GREEN} sont correctes :${NC} ${WHITE}644.${NC}\n"
                    sleep 2
                else
                    echo -e "${RED}ERREUR : Les permissions du fichier ${WHITE}/tmp/install.log${RED} sont incorrectes.${NC}"
                    echo -e "Veuillez corriger les permissions avec la commande : sudo chmod 644 /tmp/install.log"
                    sleep 3
                    exit 1
                fi

                clear
                afficher_bienvenue
                echo -e "${WHITE}=== Informations en cas de problème ===${NC}\n"
                echo -e "   - En cas d'erreur, le script s'arrêtera immédiatement et effacera les installations effectuées."
                echo -e "   - Les erreurs seront enregistrées dans ${WHITE}/var/log/gcert_install/erreur.log${NC}.\n"
                
                enter       
                
                # Test WAN
                
                clear
                afficher_bienvenue
                
                # Démarrer l'animation
                msg="Test de la connexion WAN en cours "
                
                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                sleep 2
                
                # Effectuer le ping
                if ping -c 1 "1.1.1.1" > /dev/null 2>> "$ERROR_LOG"; then
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
                    echo -e "${YELLOW}Bienvenue dans le programme d'installation de G.Cert${NC}\n\n"

                    echo -e "-${INVERSE}[1]${NC}- ${WHITE}Installation${NC}\n"
                    echo -e "-${INVERSE}[2]${NC}- ${WHITE}Documentation${NC}\n"
                    echo -e "-${INVERSE}[3]${NC}- ${WHITE}Sortir${NC}\n"

                    
                    read -p "Choisissez une option: " choix_menu_install
                    
                    # Choix multiple
                    case "$choix_menu_install" in

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# =============================== CHOIX 1 => INSTALL PREREQUIS ===============================
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                        1) 
                                clear
                                afficher_bienvenue
                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"
                                
                                echo -e "-${INVERSE}[1/5]${NC}- Installation des prérequis..." 
                                echo -e "-${INVERSE}[2/5]${NC}- Installation et configuration de Vault..."
                                echo -e "-${INVERSE}[3/5]${NC}- Création de l'environnement Python..." 
                                echo -e "-${INVERSE}[4/5]${NC}- Création de la clé GPG et des mots de passe..." 
                                echo -e "-${INVERSE}[5/5]${NC}- Lancement du service G_Cert...\n\n"
                                
                                enter

                        clear
                        afficher_bienvenue
                        
                        
                        echo -e "${BLUE_BRIGHT}=== Installation des prérequis pour G.cert  ===${NC}\n"
                        
                        echo -e "${WHITE}Avant de commencer, G.cert nécessite quelques programmes et bibliothèques :${NC}\n"

                        echo -e "${WHITE}• curl :${NC} pour récupérer des fichiers depuis Internet."
                        echo -e "${WHITE}• gnupg :${NC} pour générer vos clés RSA et chiffrer."
                        echo -e "${WHITE}• gum :${NC} pour afficher des menus et messages clairs."
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
                                for pkg in "${PREREQUIS[@]}" ; do
                                    if dpkg -s "$pkg" > /dev/null 2>&1; then
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
                                    echo -e "${YELLOW}=== INSTALLATION EN COURS ===${NC}\n\n\n"

                                    for pkg in "${absent[@]}"; do

                                        # === Message dynamique temporaire avant installation ===
                                        
                                        msg="Veuillez patienter durant l'installation de $pkg"
                                        
                                        
                                        BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                        
                                        if [[ ${pkg} == "gum" ]]; then        
                                            repo_gum    
                                        else  
                                            sudo apt install -qq ${pkg} -y > /dev/null 2>> "$ERROR_LOG" && echo "${pkg}" >> "$INSTALL_LOG" 
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
                                            
                                            clean_up_error
                                        fi  
                                    done
                                fi                     
                        
                        
                        
                            break
                        else
                            echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                        fi
                    done

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# =============================== VAULT ===============================
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                                clear
                                afficher_bienvenue

                                # Récapitulation Installation Générale
                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"

                                echo -e "${GREEN}[√] Installation des prérequis...${NC}" 
                                echo -e "-${INVERSE}[2/5]${NC}- Installation et configuration de Vault..."
                                echo -e "-${INVERSE}[3/5]${NC}- Création de l'environnement Python..." 
                                echo -e "-${INVERSE}[4/5]${NC}- Création de la clé GPG et des mots de passe..." 
                                echo -e "-${INVERSE}[5/5]${NC}- Lancement du service G_Cert...\n\n"

                                enter

                                clear
                                afficher_bienvenue

                                # Récapitulation Installation Vault

                                echo -e "${BLUE_BRIGHT}=== Phases d'installation et de configuration de Vault ===${NC}\n"

                                echo -e "${WHITE}[1] Installation de Vault :${NC}"
                                echo -e "   - Ajout du dépôt HashiCorp et installation du paquet Vault."
                                echo -e "   - Vérification de la présence de vault.\n"

                                echo -e "${WHITE}[2] Clés GPG et Certificats TLS :${NC}"
                                echo -e "   - Création d'une clé GPG pour => unseal keys/root token."
                                echo -e "   - Génération de la clé TLS et certificat (auto-signé ou CA existante).\n"
                                

                                echo -e "${WHITE}[3] Configuration de Vault :${NC}"
                                echo -e "   - Création du fichier /etc/vault.d/vault.hcl."
                                echo -e "   - Définition du stockage, du listener et des paramètres de sécurité.\n"

                                echo -e "${WHITE}[4] Démarrage du service :${NC}"
                                echo -e "   - Activation et démarrage du service systemd vault."
                                echo -e "   - Vérification de l'état du service.\n"

                                echo -e "${WHITE}[5] Initialisation et Unseal :${NC}"
                                echo -e "   - Initialisation de Vault (vault operator init)."
                                echo -e "   - Déverrouillage (unseal) du service.\n"

                                echo -e "${WHITE}[6] PKI et Autorités de Certification :${NC}"
                                echo -e "   - Activation des moteurs PKI LAN et WAN."
                                echo -e "   - Création de la CA root et des CA intermédiaires."
                                echo -e "   - Définition des rôles de certificats.\n"

                                echo -e "${WHITE}[7] Audit et Sécurité :${NC}"
                                echo -e "   - Activation des logs d'audit."
                                echo -e "   - Traçabilité des opérations Vault.\n"

                                enter

# =============================== [1] INSTALLATION DE VAULT ===============================
                                
                                clear
                                afficher_bienvenue

                                echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                echo -e "${WHITE}=== Installation de Vault ===${NC}\n\n"

                                echo -e " ${WHITE}[1]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                echo -e "    └── ${WHITE}[2]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                echo -e "        └── ${WHITE}[3]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                echo -e " ${WHITE}[4]${NC}${WHITE}Création clé GPG${NC}"
                                echo -e "    └── ${WHITE}[5]${NC}${YELLOW}Certificat SSL${NC}"
                                echo -e "        └── ${WHITE}[6]${NC}${CYAN}Fichier de configuration${NC}"
                                echo -e "        └── ${WHITE}[7]${NC}${CYAN}Clé Privée${NC}"
                                echo -e "        └── ${WHITE}[8]${NC}${CYAN}Fichier CSR${NC}"
                                echo -e "        └── ${WHITE}[9]${NC}${CYAN}Certificat Vault${NC}"
                                echo -e "        └── ${WHITE}[10]${NC}${CYAN}Signature du Certificat${NC}\n"

                                echo -e " ${WHITE}[11]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"

                                echo -e " ${WHITE}[12]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                echo -e "    └── ${WHITE}[13]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"

                                


                                enter


                                clear
                                afficher_bienvenue

                                msg="Veuillez patienter durant l'installation de Vault"
                            
                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"

                                # Installation
                                repo_vault 

                                # Effacer la ligne du message dynamique
                                echo -ne "\r\033[K"
                                BLA::stop_loading_animation

                                # test l'installation de Vault
                                if dpkg -s vault >/dev/null 2>&1; then
                                    
                                    echo -e "${GREEN}Vault installé avec succès${NC}"
                                    sleep 2
                                
                                    if [ ! -d "/etc/vault.d" ]; then
                                        clear
                                        afficher_bienvenue
                                        echo -e "${YELLOW}Création du répertoire /etc/vault.d/${NC}"
                                        sleep 3
                                        sudo mkdir -p /etc/vault.d
                                        sudo chown vault:vault /etc/vault.d
                                        sudo chmod 755 /etc/vault.d
                                            if [ -d "/etc/vault.d" ] &&  [[ $(stat -c "%U:%G" /etc/vault.d) == "vault:vault" ]]; then
                                                clear
                                                afficher_bienvenue
                                                echo -e "${GREEN}OK : Le répertoire ${WHITE}/etc/vault.d${GREEN} créé avec succès, avec les doits et propiété correct.${NC}\n"
                                                sleep 4
                                            else
                                                
                                                clear
                                                afficher_bienvenue
                                                echo -e "${RED}ERREUR : Problème lors de la création du répertoire ${WHITE}/etc/vault.d${RED}.${NC}"
                                                echo -e "Veuillez créer le répertoire avec les commande :"
                                                echo -e ": ${WHITE}- sudo mkdir /etc/vault.d${NC}"
                                                echo -e ": ${WHITE}- sudo chown vault:vault /etc/vault.d${NC}"
                                                echo -e ": ${WHITE}- sudo chmod 755 /etc/vault.d${NC}"
                                                
                                                enter
                                            fi
                                    else
                                        echo -e "\n\n${GREEN}Le répertoire ${WHITE}/etc/vault.d${NC} existe déjà, l'instalation va poursuivre${NC}"
                                        sleep 3
                                    fi
                                
                                else
                                    
                                    clean_up_error
                                
                                fi

# =============================== [2] CLÉS GPG ET CERTIFICATS ===============================


                                # =============================== CLEES GPG ===============================
                        
                                clear
                                afficher_bienvenue    

                                echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                echo -e "${WHITE}=== Création clés GPG ===${NC}\n\n"

                                echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                echo -e " ${WHITE}[4]${NC}${WHITE}Création clé GPG${NC}"
                                echo -e "    └── ${WHITE}[5]${NC}${YELLOW}Certificat SSL${NC}"
                                echo -e "        └── ${WHITE}[6]${NC}${CYAN}Fichier de configuration${NC}"
                                echo -e "        └── ${WHITE}[7]${NC}${CYAN}Clé Privée${NC}"
                                echo -e "        └── ${WHITE}[8]${NC}${CYAN}Fichier CSR${NC}"
                                echo -e "        └── ${WHITE}[9]${NC}${CYAN}Certificat Vault${NC}"
                                echo -e "        └── ${WHITE}[10]${NC}${CYAN}Signature du Certificat${NC}\n"

                                echo -e " ${WHITE}[11]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"

                                echo -e " ${WHITE}[12]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                echo -e "    └── ${WHITE}[13]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"

                                enter


                                clear
                                afficher_bienvenue

                                msg="Initialisation Clé GPG et Certificat"
                                echo -e "\n"

                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                sleep 3
                                BLA::stop_loading_animation

                                clear
                                afficher_bienvenue

                                
                                
                                # === Clé GPG pour clé privée TLS ===
                                
                                clear
                                afficher_bienvenue
                                
                                echo -e "${CYAN_BRIGHT}=== Génération clés GPG ===${NC}\n"

                                echo -e "${WHITE}Clé GPG Vault :${NC}"
                                echo -e "   - Création d'une clé GPG dédiée à Vault (unseal keys et root token).\n"

                                enter

                                clear
                                afficher_bienvenue

                                msg=" Initialisation création clé GPG, afin de protéger la Clé privée du certificat : Vault"
                                echo -e "\n"

                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                sleep 2
                                BLA::stop_loading_animation

                                # Génération
                                clear
                                afficher_bienvenue
                                
                                echo -e "\n${YELLOW}=== Création clé GPG pour les unseal keys et le root token de Vault ===${NC}\n"
                                echo -e "${RED}  IMPORTANT : Sélectionnez un algorithme supportant le chiffrement ET le déchiffrement${NC}\n"
                                echo -e "   => Option recommandée : ${GREEN}}(9) ECC (sign and encrypt)${NC}"
                                echo -e "   => Alternative : ${GREEN}(1) RSA and RSA${NC}"
                                echo -e "   NE PAS choisir : ${RED}(3), (4) ou (10) - sign only (incompatibles)${NC}\n\n\n"

                                echo -e "\n${BLUE_BRIGHT}=== Création Clé GPG via GnuPG : ===${NC}\n\n"
                                
                                sudo gpg --full-generate-key

                                while true; do
                                    echo -e "\n\n${YELLOW}Veuillez enregistrer les informations ci-dessus${NC}\n"
                                    
                                    read -p "Appuyez sur [Entrée] pour continuer : " input

                                    if [[ -z "$input" ]]; then
                                        break
                                    else
                                        echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                                    fi
                                done

                                # Variable ID clé GPG ==========> Clées Vault
                                KEY_VAULT=$(sudo gpg --list-keys --keyid-format long | grep -o '[0-9A-Fa-f]\{40\}' | tail -n1)
                                KEY_ID=$KEY_VAULT
                                echo "gpg:$KEY_ID" >> "$INSTALL_LOG"

                                
                                
                                # =============================== CERTIFICAT OPENSSL POUR VAULT ===============================
                                
                                # === FICHIER DE CONFIGURATION ===
                                clear
                                afficher_bienvenue
                                
                                echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                echo -e "${WHITE}=== Certificat SSL Vault ===${NC}\n\n"

                                echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                echo -e " ${GREEN}[√]${NC}${WHITE}Création clé GPG${NC}"
                                echo -e "    └── ${WHITE}[5]${NC}${YELLOW}Certificat SSL${NC}"
                                echo -e "        └── ${WHITE}[6]${NC}${CYAN}Fichier de configuration${NC}"
                                echo -e "        └── ${WHITE}[7]${NC}${CYAN}Clé Privée${NC}"
                                echo -e "        └── ${WHITE}[8]${NC}${CYAN}Fichier CSR${NC}"
                                echo -e "        └── ${WHITE}[9]${NC}${CYAN}Certificat Vault${NC}"
                                echo -e "        └── ${WHITE}[10]${NC}${CYAN}Signature du Certificat${NC}\n"

                                echo -e " ${WHITE}[11]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"

                                echo -e " ${WHITE}[12]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                echo -e "    └── ${WHITE}[13]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"


                                enter

                                clear
                                afficher_bienvenue

                                # Choix utilisation nom de domain pour certificat
                                while true; do
                                    
                                    read -p "Voulez-vous utiliser un nom de domaine, pour l'édition du certificat y/n : " choix_domain_ssl

                                    # Avec nom de domaine
                                    if [[ "$choix_domain_ssl" =~ ^[yY]$ ]]; then
                                        
                                        while true; do
                                        
                                            clear
                                            afficher_bienvenue
                                        
                                            read -p "Veuillez indiquer le nom de domaine (format => FQDN) : " domain_ssl

                                            clear
                                            afficher_bienvenue

                                            echo -e "Domain = ${WHITE}$domain_ssl${NC}\n"
                                            read -p "Le nom de domaine est-il correct ? y/n : " validation_domain
                                        
                                                if [[ "$validation_domain" =~ ^[yY]$ ]]; then
                                                # test si le nom de domaine existe
                                                    if host "$domain_ssl" 2>&1 | grep -q "has address\|has IPv6 address"; then
                                            
                                                        clear
                                                        afficher_bienvenue
                                                        echo -e "${GREEN}Le domaine ${NC}$domain_ssl${NC} ${GREEN}existe et résout correctement.${NC}"
                                                        sleep 3
                                                        break 

                                                    # Si le domaine ne repond pas ou n'existe pas sortie de script
                                                    else
                                                        
                                                        
                                                        clear
                                                        afficher_bienvenue
                                                        echo -e "\n${RED}Le domaine '$domain_ssl' n'existe pas ou ne résout pas.${NC}\n"
                                                        echo "Veuillez résoudre le problème avant de poursuivre l'installation\n\n"
                                                        
                                                        
                                                        enter 
                                                        while true;do
                                                        
                                                            clear
                                                            afficher_bienvenue
                                                            
                                                            echo -e "${YELLOW}Veuillez pouvez : ${NC}\n"
                                    
                                                            echo -e "-${INVERSE}[1]${NC}- ${WHITE}Rester sur l'installationde G.Cert${NC}"    
                                                            echo -e "-${INVERSE}[2]${NC}- ${WHITE}Sortie Installation et repartir à Zéro...${NC}\n"

                                                            read -p "Choix CA : " choix_ca

                                                            case "$choix_ca" in    
                                                            
                                                                
                                                                1)
                                                                    break
                                                                
                                                                ;;
                                                                
                                                                2)
                                                                    clean_up_choice         
                                                                ;;

                                                                *)
                                                                    echo -e "${RED}Erreur, Réponse invalide.${NC}"
                                                                ;;


                                                            esac
                                                        done    

                                                    fi
                                                elif [[ "$validation_domain" =~ ^[nN]$ ]]; then
                                                    
                                                    clear
                                                    afficher_bienvenue
                                                    echo -e "\n${RED}Recommençons...${NC}"
                                                    sleep 2
                                                else
                                                    echo -e "\n${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                        done
                                        
                                        
                                        

                                            # === 1-3) NOM serveur CN ===
                                            while true; do
                                                
                                                clear
                                                afficher_bienvenue
                                                read -p "Veuillez indiquer le Nom principal du serveur (Common Name) : " cn_vault

                                                clear
                                                afficher_bienvenue

                                                echo -e "CN = ${WHITE}$cn_vault${NC}\n"
                                                read -p "Le CN est-il correct ? y/n : " validation_cn

                                                if [[ "$validation_cn" =~ ^[yY]$ ]]; then
                                                    
                                                    clear
                                                    afficher_bienvenue
                                                    echo -e "${GREEN}CN confirmé : ${NC}$cn_vault${NC}${GREEN}...${NC}"
                                                    sleep 2
                                                    break
                                                elif [[ "$validation_cn" =~ ^[nN]$ ]]; then
                                                    
                                                    clear
                                                    afficher_bienvenue
                                                    echo -e "\n${RED}Recommençons...${NC}"
                                                    sleep 2
                                                else
                                                    echo -e "\n${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                            done



                                            # === 2-3) NOM DNS serveur ===
                                            clear
                                            afficher_bienvenue

                                            while true; do
                                                clear
                                                afficher_bienvenue
                                                read -p "Veuillez indiquer Nom DNS utilisé par les clients pour contacter Vault (format => Nom + FQDN domaine) : " dns_vault

                                                clear
                                                afficher_bienvenue

                                                echo -e "DNS.1 = ${WHITE}$dns_vault${NC}\n"
                                                read -p "Le DNS.1 est-il correct ? y/n : " validation_dns1

                                                if [[ "$validation_dns1" =~ ^[yY]$ ]]; then
                                                    
                                                    clear
                                                    afficher_bienvenue
                                                    echo -e "${GREEN}DNS.1 confirmé : ${NC}$dns_vault${NC}${GREEN}...${NC}"
                                                    sleep 2
                                                    break
                                                elif [[ "$validation_dns1" =~ ^[nN]$ ]]; then
                                                    
                                                    clear
                                                    afficher_bienvenue
                                                    echo -e "\n${RED}Recommençons...${NC}"
                                                    sleep 2
                                                else
                                                    echo -e "\n${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                            done

                                            # === 3-3) IP serveur Vault ===
                                            while true; do
                                                clear
                                                afficher_bienvenue
                                            
                                                read -p "Veuillez indiquer l'IP du serveur Vault : " ip_vault

                                                # test format IP
                                                if validate_ip "$ip_vault"; then
                                                    
                                                    clear
                                                    afficher_bienvenue
                                                    
                                                    echo -e "${GREEN}Format adresse IP valide${NC}"
                                                    sleep 2

                                                    while true; do
                                                        clear
                                                        afficher_bienvenue

                                                        # Confirmation utilisation adresse IP
                                                        echo -e "Adresse IP choisie pour Vault = ${WHITE}$ip_vault${NC}\n"       
                                                        read -p "L'adresse IP est-elle correcte ? y/n : " validation_ip

                                                        if [[ "$validation_ip" =~ ^[yY]$ ]]; then
                                                        
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${GREEN}IP confirmée : ${NC}$ip_vault${NC}${GREEN}...${NC}"
                                                            sleep 2
                                                            break 2
                                                        elif [[ "$validation_ip" =~ ^[nN]$ ]]; then
                                                            
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "\n${RED}Recommençons...${NC}"
                                                            sleep 2
                                                            break
                                                        else
                                                            echo -e "\n${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                            sleep 2
                                                        fi
                                                    done
                                                else
                                                    echo -e "\n${RED}Format adresse IP invalide${NC}\n"
                                                    echo -e "\nRecommençons..."
                                                    sleep 2
                                                    
                                                fi
                                            done


                                                
                                                # /etc/vault.d/vault_tls.cnf
                                                clear
                                                afficher_bienvenue

                                                msg="Création fichier de configuration"
                                            
                                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"

                                                sleep 2

                                                # Effacer la ligne du message dynamique
                                                echo -ne "\r\033[K"
                                                BLA::stop_loading_animation

                                                # Edition fichier certificat vault_tls.cnf
                                                sudo tee /etc/vault.d/vault_tls.cnf <<-EOF > /dev/null 2>> "$ERROR_LOG"   
[ req ]
default_bits       = 4096
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[ dn ]
CN = $cn_vault.$domain_ssl

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $dns_vault
IP.1  = $ip_vault
EOF

                                
                                        break
                                        
                                        

                                    # Choix 2 pas de domaine
                                    elif [[ "$choix_domain_ssl" =~ ^[nN]$ ]]; then
                                            
                                            # === 1-3) NOM serveur CN ===
                                            clear
                                            afficher_bienvenue

                
                                            while true; do
                                            
                                                read -p "Veuillez indiquer le Nom principal du serveur (Common Name) : " cn_vault

                                                clear
                                                afficher_bienvenue

                                                echo -e "CN = ${WHITE}$cn_vault${NC}\n"
                                                read -p "Le CN est-il correct ? y/n : " validation_cn

                                                if [[ "$validation_cn" =~ ^[yY]$ ]]; then
                                                    
                                                    clear
                                                    afficher_bienvenue
                                                    echo -e "${GREEN}CN confirmé : ${NC} $cn_vault"
                                                    sleep 2
                                                    break
                                                elif [[ "$validation_cn" =~ ^[nN]$ ]]; then
                                                    echo -e "${RED}Recommençons...${NC}"
                                                else
                                                    echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                            done


                                            # === 2-3) NOM DNS serveur === 
                                            clear
                                            afficher_bienvenue

                                            while true; do
                                                
                                                
                                                read -p "Veuillez indiquer le nom DNS utilisé par les clients pour contacter Vault (format => Nom) : " dns_vault

                                                clear
                                                afficher_bienvenue

                                                echo -e "DNS.1 = ${WHITE}$dns_vault${NC}\n"
                                                read -p "Le DNS.1 est-il correct ? y/n : " validation_dns1

                                                if [[ "$validation_dns1" =~ ^[yY]$ ]]; then
                                                    
                                                    clear
                                                    afficher_bienvenue
                                                    echo -e "${GREEN}DNS.1 confirmé : ${NC} $dns_vault"
                                                    sleep 2
                                                    break
                                                elif [[ "$validation_dns1" =~ ^[nN]$ ]]; then
                                                    echo -e "${RED}Recommençons...${NC}"
                                                    sleep 1
                                                else
                                                    echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                            done

                                            while true; do
                                                
                                                
                                                # === 3-3) Ip serveur Vault ===
                                                clear
                                                afficher_bienvenue

                                                
                                                read -p "Veuillez indiquer l'IP du serveur Vault : " ip_vault

                                                # Test IP
                                                if validate_ip "$ip_vault"; then
                                                    echo -e "${GREEN}Format adresse IP valide${NC}"
                                                    sleep 2

                                                    while true; do
                                                        clear
                                                        afficher_bienvenue

                                                        # Confirmation utilisation adresse IP
                                                        echo -e "Adresse IP choisie pour Vault = ${WHITE}$ip_vault${NC}\n"       
                                                        read -p "L'adresse IP est-elle correcte ? y/n : " validation_ip

                                                        if [[ "$validation_ip" =~ ^[yY]$ ]]; then
                                                            
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${GREEN}IP confirmée : ${NC} $ip_vault"
                                                            sleep 2
                                                            break 2
                                                        elif [[ "$validation_ip" =~ ^[nN]$ ]]; then
                                                            echo -e "${RED}Recommençons...${NC}"
                                                            sleep 1
                                                            break
                                                        else
                                                            echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                            sleep 2
                                                        fi
                                                    done
                                                else
                                                    echo -e "${RED}Format adresse IP invalide${NC}"
                                                    sleep 2
                                                fi
                                            done


                                            # /etc/vault.d/vault_tls.cnf
                                            sudo tee /etc/vault.d/vault_tls.cnf <<-EOF > /dev/null 2>> "$ERROR_LOG" && echo "/etc/vault.d/vault_tls.cnf" >> "$INSTALL_LOG"
[ req ]
default_bits       = 4096
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[ dn ]
CN = $cn_vault

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $dns_vault
IP.1  = $ip_vault
EOF

                                    break
                                    else
                                        clear
                                        afficher_bienvenue 
                                        echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                    fi
                                done

                                # === CLEE PRIVEE CERTIFICAT === 
                                # /etc/vault.d/vault.key

                                clear
                                afficher_bienvenue
                                
                                echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                echo -e "${WHITE}=== Clé privée certificat Vault ===${NC}\n\n"

                                echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                echo -e " ${GREEN}[√]${NC}${WHITE}Création clé GPG${NC}"
                                echo -e "    └── ${WHITE}[5]${NC}${YELLOW}Certificat SSL${NC}"
                                echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier de configuration${NC}"
                                echo -e "        └── ${WHITE}[7]${NC}${CYAN}Clé Privée${NC}"
                                echo -e "        └── ${WHITE}[8]${NC}${CYAN}Fichier CSR${NC}"
                                echo -e "        └── ${WHITE}[9]${NC}${CYAN}Certificat Vault${NC}"
                                echo -e "        └── ${WHITE}[10]${NC}${CYAN}Signature du Certificat${NC}\n"

                                echo -e " ${WHITE}[11]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"

                                echo -e " ${WHITE}[12]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                echo -e "    └── ${WHITE}[13]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"
                                
                                sleep 3
                                
                                # Création de la clé privée
                                sudo openssl genrsa -out /etc/vault.d/vault.key > /dev/null 2>> "$ERROR_LOG" && echo "/etc/vault.d/vault.key" >> "$INSTALL_LOG" 
                                    
                                    clear
                                    afficher_bienvenue
                                    
                                    # Test presence clé privé
                                    if [ -f /etc/vault.d/vault.key ]; then
                                        
                                        clear
                                        afficher_bienvenue
                                        echo -e "${GREEN}OK : Clé privée ${WHITE}/etc/vault.d/vault.key${NC} ${GREEN}créée.${NC}\n\n"
                                        echo -e "\n${RED}=== Avertissement ===${NC}"
                                        echo -e "${YELLOW}--------------------------------------------------${NC}"
                                        echo -e "${WHITE}1. Stockez la clé dans un emplacement sécurisé.${NC}"
                                        echo -e "${WHITE}2. Limitez l'accès aux utilisateurs autorisés.${NC}"
                                        echo -e "${WHITE}3. Effectuez des sauvegardes régulières.${NC}"
                                        echo -e "${YELLOW}--------------------------------------------------${NC}\n"                                        
                                        
                                        enter
                                    else
                                        echo -e "${RED}ERREUR : Problème lors de la création de la clé privée ${WHITE}/etc/vault.d/vault.key${NC}"
                                        sleep 3
                                        clean_up_error
                                    fi

                                # droit strict sur vault.key
                                sudo chmod 600 /etc/vault.d/vault.key
                                
                                # === CREATION CSR ===
                                # /etc/vault.d/vault.csr

                                # Commande de création du CSR avec redirection des logs
                                sudo openssl req -new -key /etc/vault.d/vault.key -out /etc/vault.d/vault.csr -config /etc/vault.d/vault_tls.cnf > /dev/null 2>> "$ERROR_LOG" && echo "/etc/vault.d/vault.csr" >> "$INSTALL_LOG"

                                    clear
                                    afficher_bienvenue
                                    
                                    echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                    echo -e "${WHITE}=== Fichier CSR Certificat Vault ===${NC}\n\n"

                                    echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                    echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                    echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                    echo -e " ${GREEN}[√]${NC}${WHITE}Création clé GPG${NC}"
                                    echo -e "    └── ${WHITE}[5]${NC}${YELLOW}Certificat SSL${NC}"
                                    echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier de configuration${NC}"
                                    echo -e "        └── ${GREEN}[√]${NC}${CYAN}Clé Privée${NC}"
                                    echo -e "        └── ${WHITE}[8]${NC}${CYAN}Fichier CSR${NC}"
                                    echo -e "        └── ${WHITE}[9]${NC}${CYAN}Certificat Vault${NC}"
                                    echo -e "        └── ${WHITE}[10]${NC}${CYAN}Signature du Certificat${NC}\n"

                                    echo -e " ${WHITE}[11]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"

                                    echo -e " ${WHITE}[12]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                    echo -e "    └── ${WHITE}[13]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"

                                    sleep 3
                                    
                                    # Test présence CSR
                                    if [ -f /etc/vault.d/vault.csr ]; then
                                        
                                        clear
                                        afficher_bienvenue
                                        echo -e "${GREEN}OK : Fichier ${WHITE}/etc/vault.d/vault.csr${NC}${GREEN} créé avec succés.${NC}"
                                        sleep 4
                                    else
                                        echo -e "${RED}ERREUR : Problème lors de la création du fichier ${WHITE}/etc/vault.d/vault.csr${NC}"
                                        sleep 3
                                        clean_up_error
                                    fi
                                
                                
                                
                                # Demande pour la durée de validitée du certificat de Vault
                                while true; do
                                
                                    clear
                                    afficher_bienvenue
                                    read -p "Veuillez entrer une valeur pour la durée de validité du certificat (Format => jour entre 1 et 365) : " days_vault

                                    if [[ "$days_vault" =~ ^[0-9]+$ ]] && (( days_vault >= 1 && days_vault <= 365 )); then
                                        echo -e "\n${GREEN}OK : Format de la date valide ${NC}"
                                        sleep 2
                                        break
                                    else
                                        echo "Erreur : veuillez entrer un nombre entre 1 et 365 ."
                                    fi
                                done

                                # === Signature certificat ===
                                clear
                                afficher_bienvenue

                                while true; do

                                    # Avertissement
                                    echo -e "${RED}=== Avertissement Sécurité – Clé privée de la CA ===${NC}\n"

                                    echo -e "${WHITE}[!] Signature avec une CA existante :${NC}"
                                    echo -e "   - La signature d’un certificat nécessite que la clé privée de la CA soit"
                                    echo -e "     accessible en clair de manière TEMPORAIRE.\n"

                                    echo -e "Bonnes pratiques:"
                                    echo -e "   - La clé doit être déverrouillée uniquement pour la durée de la signature."
                                    echo -e "   - Ne jamais stocker la clé de la CA en clair de façon permanente."
                                    echo -e "   - Privilégier une CA hors ligne ou une CA intermédiaire dédiée."
                                    echo -e "   - Rechiffrer ou supprimer immédiatement toute clé déchiffrée après usage.\n\n"


                                    echo -e "${YELLOW}Veuillez choisir un mode de CA : ${NC}\n"
                                    
                                    echo -e "-${INVERSE}[1]${NC}- ${WHITE}Certificat auto-signé${NC}" 
                                    echo -e "-${INVERSE}[2]${NC}- ${WHITE}CA Existante${NC}"    
                                    echo -e "-${INVERSE}[3]${NC}- ${WHITE}Sortie Installation${NC}\n"

                                    read -p "Choix CA : " choix_ca

                                    case "$choix_ca" in

                                        # Autosigné
                                        1)
                                        
                                        clear
                                        afficher_bienvenue
                                        
                                        echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                        echo -e "${WHITE}=== Certificat (Auto-signé) Vault ===${NC}\n\n"

                                        echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                        echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                        echo -e " ${GREEN}[√]${NC}${WHITE}Création clé GPG${NC}"
                                        echo -e "    └── ${WHITE}[5]${NC}${YELLOW}Certificat SSL${NC}"
                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier de configuration${NC}"
                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Clé Privée${NC}"
                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier CSR${NC}"
                                        echo -e "        └── ${WHITE}[9]${NC}${CYAN}Certificat Vault${NC}"
                                        echo -e "        └── ${WHITE}[10]${NC}${CYAN}Signature du Certificat${NC}\n"

                                        echo -e " ${WHITE}[11]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"

                                        echo -e " ${WHITE}[12]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                        echo -e "    └── ${WHITE}[13]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"
                                    
                                        sleep 3
                                        
                                        
                                        
                                        clear
                                        afficher_bienvenue
                                        msg="Edition du certificat : auto-signé"
                                            echo -e "\n"
                                            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                            sleep 2
                                            BLA::stop_loading_animation

                                        # Signature certificat auto-signé
                                        sudo openssl x509 -req -in /etc/vault.d/vault.csr -signkey /etc/vault.d/vault.key -out /etc/vault.d/vault.crt -days "$days_vault" -extensions req_ext -extfile /etc/vault.d/vault_tls.cnf > /dev/null 2>> "$ERROR_LOG" && echo "/etc/vault.d/vault.crt" >> "$INSTALL_LOG" 
                                        # Test présence du certificat
                                        if openssl x509 -in /etc/vault.d/vault.crt -noout >/dev/null 2>&1; then
                                            
                                            clear
                                            afficher_bienvenue
                                            echo -e "${GREEN}OK : Certificat =>${NC} ${WHITE}/etc/vault.d/vault.crt${NC} créé avec succès ET valide."
                                            sleep 3
                                            break
                                        else
                                            echo -e "${RED}ERREUR : Problème lors de la création du fichier ${WHITE}/etc/vault.d/vault.crt${NC}"
                                            sleep 3
                                            clean_up_error
                                        fi


                                        ;;

                                        # CA existante
                                        2)

                                        clear
                                        afficher_bienvenue
                                        
                                        echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                        echo -e "${WHITE}=== Certificat (avec CA existant) Vault ===${NC}\n\n"

                                        echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                        echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                        echo -e " ${GREEN}[√]${NC}${WHITE}Création des clés GPG${NC}"
                                        echo -e "    └── ${WHITE}[5]${NC}${YELLOW}Certificat SSL${NC}"
                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier de configuration${NC}"
                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Clé Privée${NC}"
                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier CSR${NC}"
                                        echo -e "        └── ${WHITE}[9]${NC}${CYAN}Certificat Vault${NC}"
                                        echo -e "        └── ${WHITE}[10]${NC}${CYAN}Signature du Certificat${NC}\n"

                                        echo -e " ${WHITE}[11]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"

                                        echo -e " ${WHITE}[12]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                        echo -e "    └── ${WHITE}[13]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"
                                        sleep 3

                                        # CHEMIN .CRT
                                        while true; do
                                            clear
                                            afficher_bienvenue
                                            read -p "Veuillez indiquer le chemin vers le CA existant (chemin absolue vers le fichier .crt + droit correct)" ca_existant_crt

                                            echo -e "Chemin Certificat = ${WHITE}$ca_existant_crt${NC}\n"
                                            read -p "Le Certificat est-il correct ? y/n " validation_crt

                                            if [[ "$validation_crt" =~ ^[yY]$ ]]; then
                                                clear
                                                afficher_bienvenue
                                                echo -e "${GREEN}Certificat confirmé :${NC} $ca_existant_crt"
                                                sleep 3
                                                break

                                            elif [[ "$validation_crt" =~ ^[nN]$ ]]; then
                                                clear
                                                afficher_bienvenue
                                                echo -e "${RED}Recommençons...${NC}"
                                                sleep 2

                                            else
                                                echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                            fi
                                        done

                                        
                                        # CHEMIN .KEY
                                        while true; do
                                            clear
                                            afficher_bienvenue
                                            read -p "Veuillez indiquer le chemin vers la clé privé (chemin absolue vers le fichier .key / .pem)" ca_private_key

                                            echo -e "Chemin Clé Privée = ${WHITE}$ca_private_key${NC}\n"
                                            read -p "Le Certificat est-il correct ? y/n " validation_key

                                            if [[ "$validation_key" =~ ^[yY]$ ]]; then
                                                clear
                                                afficher_bienvenue
                                                echo -e "${GREEN} :${NC} Chemin Clé Privée ${WHITE}$ca_private_key${NC}, Confirmé."
                                                sleep 3
                                                break

                                            elif [[ "$validation_key" =~ ^[nN]$ ]]; then
                                                clear
                                                afficher_bienvenue
                                                echo -e "${RED}Recommençons...${NC}"
                                                sleep 2

                                            else
                                                echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                            fi
                                        done

                                        
                                        # Demande pour durée de validité du certificat
                                        while true; do
                                            read -p "Veuillez entrer une valeur pour la durée de validité du certificat (Format => jour entre 1 et 365)" days_vault

                                            if [[ "$days_vault" =~ ^[0-9]+$ ]] && (( days_vault >= 1 && days_vault <= 365 )); then
                                                break
                                            else
                                                echo "Erreur : veuillez entrer un nombre entre 1 et 365."
                                            fi
                                        done
                                        
                                        # Edition certificat + test de réussite
                                        clear
                                        afficher_bienvenue
                                        
                                        msg="Edition du certificat"
                                            echo -e "\n"
                                            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                            sleep 2
                                            BLA::stop_loading_animation

                                        openssl x509 -req -in "$ca_existant_crt" -signkey "$ca_private_key" -out /etc/vault.d/vault.crt -days "$days_vault" -extensions req_ext -extfile /etc/vault.d/vault_tls.cnf > /dev/null 2>> "$ERROR_LOG" && echo "/etc/vault.d/vault.crt" >> "$INSTALL_LOG"

                                        clear
                                        afficher_bienvenue
                                        
                                        # Test présence du certificat
                                        if openssl x509 -in /etc/vault.d/vault.crt -noout > /dev/null 2>> "$ERROR_LOG"; then
                                            
                                            echo -e "${GREEN}OK : Certificat ${WHITE}/etc/vault.d/vault.crt${NC} créé avec succès et valide.${NC}"
                                            sleep 3
                                            break

                                        else
                                            echo -e "${RED}ERREUR : Problème lors de la création du fichier ${WHITE}/etc/vault.d/vault.crt${NC}${NC}"
                                            sleep 3
                                            clean_up_error
                                        fi
                                        
                                        
                                        
                                        
                                        ;;

                                        3)
                                            clean_up_choice         
                                        ;;

                                        *)
                                            echo -e "${RED}Erreur, Réponse invalide.${NC}"
                                        ;;

                                    esac

                                done



                                # === Sécurisation clé et certificat Vault ===
                                clear
                                afficher_bienvenue
                                
                                # Avertissement
                                echo -e "${WHITE}=== Sécurisation des fichiers SSL ===${NC}\n"

                                echo -e "${RED}Attention : les fichiers clés et certificats sont très sensibles.${NC}\n\n"
                                read -p "Voulez-vous sécuriser tous les fichiers relatif au certificat ssl de Vault maintenant y/n ? " secu_ssl

                                    
                                    while true; do
                                        if [[ "$secu_ssl" =~ ^[yY]$ ]]; then
                                                
                                                days_timer=$((days_vault - 1))
                                                clear
                                                afficher_bienvenue

                                                echo -e "${CYAN_BRIGHT}=== Sécurisation de la clé privée et renouvellement automatique avec Systemd ===${NC}\n\n"

                                                echo -e "  - Le fichier => ${WHITE}/etc/vault.d/vault.csr${NC} est supprimé pour sécurité."
                                                echo -e "  - La clé privée ${WHITE}/etc/vault.d/vault.key${NC} : Permissions appliquées : ${WHITE}chown vault:vault${NC} et ${WHITE}chmod 600${NC} "
                                                echo -e "  - Renouvellement automatique du certificat via Script et Systemd : .Service / .Timer."
                                                echo -e "  - ${YELLOW}**Note**${NC} : Le renouvellement automatique se fera tous les ${WHITE}${days_timer}${NC} jours.\n\n\n"

                                                enter

                                                        # === DROIT ET PERMISSION DU LA CLE ET RENOUVELEMENT VIA TACHE SYSTEMD ===
                                                        clear
                                                        afficher_bienvenue

                                                        echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                                        echo -e "${WHITE}=== Certificat Vault ===${NC}\n\n"

                                                        echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                                        echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                                        echo -e " ${GREEN}[√]${NC}${WHITE}Création clé GPG${NC}"
                                                        echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Certificat SSL${NC}"
                                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier de configuration${NC}"
                                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Clé Privée${NC}"
                                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier CSR${NC}"
                                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Certificat Vault${NC}"
                                                        echo -e "        └── ${GREEN}[√]${NC}${CYAN}Signature du Certificat${NC}\n"

                                                        echo -e " ${WHITE}[11]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"

                                                        echo -e " ${WHITE}[12]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                                        echo -e "    └── ${WHITE}[13]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"

                                                        sleep 4

                                                        clear
                                                        afficher_bienvenue
                                                        echo -e "Suppression de : ${WHITE}/etc/vault.d/vault.csr${NC}"
                                                        sleep 2

                                                        sudo rm /etc/vault.d/vault.csr > /dev/null 2>> "$ERROR_LOG"

                                                        if [ -f /etc/vault.d/vault.csr ]; then
                                                            echo -e "${RED}ERREUR : Lors de la suppression du fichier =>${NC} ${WHITE}/etc/vault.d/vault.csr...${NC}"
                                                            echo -e "Suite à l'installation de G.cert, veuillez supprimer ce fichier." 
                                                            sleep 3
                                                        else
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${GREEN}OK : Suppression réussie de : ${WHITE}/etc/vault.d/vault.csr${NC}"
                                                            sleep 3
                                                        fi

                                                        # Droit et propriétaire vault.key 

                                                        clear
                                                        afficher_bienvenue

                                                        echo -e "${WHITE}Droits et propriétaire de /etc/vault.d/vault.key ${NC}\n"
                                                        sleep 3
                                                        
                                                        sudo chown vault:vault /etc/vault.d/vault.key > /dev/null 2>> "$ERROR_LOG"

                                                        if [[ $(stat -c "%a" /etc/vault.d/vault.key) == "600" && $(stat -c "%U:%G" /etc/vault.d/vault.key) == "vault:vault" ]]; then
                                                            
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${GREEN}OK : le fichier ${WHITE}/etc/vault.d/vault.key${GREEN} est bien sécurisé.${NC}\n"
                                                            echo -e "Avec rw------- vault vault vault.key\n\n " 
                                                            enter
                                                        else
                                                            
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${RED}ERREUR : permissions ou propriétaire incorrects pour ${WHITE}/etc/vault.d/vault.key${NC}"
                                                            echo -e "Veuillez vérifier et corriger les droits du fichier."
                                                            sleep 3
                                                        fi


                                                        # Droit et propriétaire vault_tls.cnf 
                                                        clear
                                                        afficher_bienvenue

                                                        echo -e "${WHITE}Droit et propriétaire vault_tls.cnf ${NC}"
                                                        sleep 2

                                                        # Appliquer les droits
                                                        sudo chmod 640 /etc/vault.d/vault_tls.cnf > /dev/null 2>> "$ERROR_LOG"
                                                        sudo chown root:vault /etc/vault.d/vault_tls.cnf > /dev/null 2>> "$ERROR_LOG"

                                                        # Vérification droit et propriétaire
                                                        if [[ $(stat -c "%a" /etc/vault.d/vault_tls.cnf) == "640" && $(stat -c "%U:%G" /etc/vault.d/vault_tls.cnf) == "root:vault" ]]; then
                                                            
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${GREEN}OK : le fichier ${WHITE}/etc/vault.d/vault_tls.cnf${GREEN} est bien sécurisé.${NC}"
                                                            sleep 3
                                                        else
                                                            
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${RED}ERREUR : permissions ou propriétaire incorrects pour ${WHITE}/etc/vault.d/vault_tls.cnf${NC}"
                                                            echo -e "Veuillez vérifier et corriger les droits du fichier."
                                                            sleep 3
                                                        fi


                                                        # === Tâche Systemd ===
                                                        clear
                                                        afficher_bienvenue

                                                        
                                                        echo -e "${CYAN_BRIGHT}=== Renouvellement du certificat via Systemd ===${NC}\n"
                                                        echo -e "   - Création d'un script pour le renouvellement automatique du certificat Vault."
                                                        echo -e "   - Enregistrement de l'exécution du script dans systemd."
                                                        sleep 4

                                                        # Script de renouvellement

                                                        clear
                                                        afficher_bienvenue

                                                        msg="Création script de renouvellement"
                                                    
                                                        BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"

                                                        sleep 2
                                                        # Effacer la ligne du message dynamique
                                                        echo -ne "\r\033[K"
                                                        BLA::stop_loading_animation

                                                        sudo touch /usr/local/bin/renew_vault_ssl.sh
                                                        sudo chown root:root /usr/local/bin/renew_vault_ssl.sh
                                                        
                                                        sudo bash -c "cat > /usr/local/bin/renew_vault_ssl.sh << 'EOF'
#!/bin/bash
sudo openssl req -new -x509 -days $days_vault -key /etc/vault.d/vault.key -out /etc/vault.d/vault.crt -config /etc/vault.d/vault_tls.cnf
chmod 640 /etc/vault.d/vault.crt
chown root:vault /etc/vault.d/vault.crt
systemctl restart vault
EOF
" 2>> "$ERROR_LOG" && echo "/usr/local/bin/renew_vault_ssl.sh" >> "/tmp/install.log"
                                            
                                                        
                                                        
                                                        
                                                        
                                                        sudo chmod 700 /usr/local/bin/renew_vault_ssl.sh
                                                        

                                                        #service
                                                        clear
                                                        afficher_bienvenue

                                                        msg="Inscription à systemd =>  renew_vault_ssl.service et renew_vault_ssl.timer"
                                                    
                                                        BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"

                                                        sleep 3
                                                        # Effacer la ligne du message dynamique
                                                        echo -ne "\r\033[K"
                                                        BLA::stop_loading_animation

                                                        sudo bash -c "cat > /etc/systemd/system/renew_vault_ssl.service << 'EOF'
[Unit]
Description=Renew Vault SSL Certificates
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/renew_vault_ssl.sh
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
" > /dev/null 2>> "$ERROR_LOG" && echo "/etc/systemd/system/renew_vault_ssl.service" >> "$INSTALL_LOG"
                                                        

                                                        # timer
                                                        days_timer=$((days_vault - 1))
                                                        sudo bash -c "cat > /etc/systemd/system/renew_vault_ssl.timer << EOF
[Unit]
Description=Renew Vault SSL Certificates every ${days_timer} days
Requires=renew_vault_ssl.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=${days_timer}d
Persistent=true

[Install]
WantedBy=timers.target
EOF
" > /dev/null 2>> "$ERROR_LOG" && echo "/etc/systemd/system/renew_vault_ssl.timer" >> "$INSTALL_LOG"

                                                        
                                                        
                                                        # === AUTORISATION ET DEMARRAGE SYSTEMD ===
                                                        
                                                        sudo systemctl daemon-reload > /dev/null 2>&1
                                                        
                                                        # .service
                                                        sudo systemctl enable renew_vault_ssl.service > /dev/null 2>&1
                                                        sudo systemctl start renew_vault_ssl.service > /dev/null 2>&1

                                                        # .timer
                                                        sudo systemctl enable renew_vault_ssl.timer > /dev/null 2>&1
                                                        sudo systemctl start renew_vault_ssl.timer > /dev/null 2>&1


                                                        # === TEST RENOUVELEMENT ACTIF ===

                                                        if [ -f /etc/systemd/system/renew_vault_ssl.service ] && [ -f /etc/systemd/system/renew_vault_ssl.timer ] && systemctl is-active --quiet renew_vault_ssl.timer && systemctl is-active --quiet renew_vault_ssl.service; then
                                                            
                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${GREEN}OK : Fichiers systemd créés, .timer et .service actifs et opérationnels.${NC}\n"
                                                            echo -e "le renouvellement du certificat de vault aura lieu automatiquement tous les ${WHITE}${days_timer}${NC} jours.\n\n"
                                                            
                                                            enter

                                                            clear
                                                            afficher_bienvenue
                                                            echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                                            echo -e "${WHITE}=== Fin de Tache Certificat Vault ===${NC}\n\n"

                                                            echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                                            echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                                            echo -e " ${GREEN}[√]${NC}${WHITE}Création des clés GPG${NC}"
                                                            echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Certificat SSL${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier de configuration${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Clé Privée${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier CSR${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Certificat Vault${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Signature du Certificat${NC}\n"

                                                            echo -e " ${GREEN}[√]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"
                
                                                            echo -e " ${GREEN}[√]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                                            echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"
                                                            
                                                            sleep 3
                                                            break 
                                                        
                                                        else
                                                            echo -e "${RED}ERREUR : Problème avec systemd...${NC}"
                                                            
                                                            # Détails des problèmes
                                                            [ ! -f /etc/systemd/system/renew_vault_ssl.service ] && echo -e "  - ${RED}renew_vault_ssl.service manquant${NC}"
                                                            [ ! -f /etc/systemd/system/renew_vault_ssl.timer ] && echo -e "  - ${RED}renew_vault_ssl.timer manquant${NC}"
                                                            systemctl is-active --quiet renew_vault_ssl.service || echo -e "  - ${RED}service non actif${NC}"
                                                            systemctl is-active --quiet renew_vault_ssl.timer || echo -e "  - ${RED}timer non actif${NC}"
                                                            
                                                            echo -e "\nPour plus d'information voir le fichier : ${WHITE}/var/log/gcert_install/erreur.log${NC}"
                                                            
                                                            echo -e "Le renouvellement du certificat devra être réalisé manuellement..."
                                                            
                                                            enter

                                                            clear
                                                            afficher_bienvenue

                                                            echo -e "${BLUE_BRIGHT}=== Installation et Configuration de Vault ===${NC}\n"
                                                            echo -e "${WHITE}=== Probléme renouvellement auto, Certificat Vault ===${NC}\n\n"

                                                            echo -e " ${GREEN}[√]${NC}${WHITE}Ajout du Dépôt HashiCorp${NC}"
                                                            echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Installation du Paquet Vault${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Vérification de la présence de Vault${NC}\n"

                                                            echo -e " ${GREEN}[√]${NC}${WHITE}Création des clés GPG${NC}"
                                                            echo -e "    └── ${GREEN}[√]${NC}${YELLOW}Certificat SSL${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier de configuration${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Clé Privée${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Fichier CSR${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Certificat Vault${NC}"
                                                            echo -e "        └── ${GREEN}[√]${NC}${CYAN}Signature du Certificat${NC}\n"

                                                            echo -e " ${GREEN}[√]${NC}${WHITE}Sécurisation du fichier Certificat${NC}\n"
                
                                                            echo -e " ${RED}[X]${NC}${WHITE}Clé Privée Certificat => Restrictions des droits${NC}"
                                                            echo -e "    └── ${RED}[X]${NC}${YELLOW}Script pour renouvellement + inscription Systemd${NC}\n"


                                                            enter
                                                            

                                                        fi
                                        elif [[ "$secu_ssl" =~ ^[nN]$ ]]; then
                                            break


                                        else
                                            clear
                                            afficher_bienvenue
                                            echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                        fi
                                        
                                    done
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# =============================== DEPENDENCES via PIPX ===============================
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                                clear
                                afficher_bienvenue
                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"
                               
                                echo -e "${GREEN}[√] Installation des prérequis...${NC}" 
                                echo -e "${GREEN}[√] Installation et configuration de Vault...${NC}"
                                echo -e "-${INVERSE}[3/5]${NC}- Création de l'environnement Python..." 
                                echo -e "-${INVERSE}[4/5]${NC}- Création de la clé GPG et des mots de passe..." 
                                echo -e "-${INVERSE}[5/5]${NC}- Lancement du service G_Cert...\n\n"
                                
                               enter
                        
                        clear
                        afficher_bienvenue
                        echo -e "\n${YELLOW}=== INSTALLATION DEPENDANCES PYTHON DANS UN VENV ===${NC}\n"
                    
                        # Message pour l'animation
                        msg="Veuillez patienter pendant la mise en place des dépendances Python"

                        # Assurer que pipx est installé et accessible + msg avertissement
                        echo -e "\n\n${WHITE}[INFO] Sortie pipx ci-dessous (avertissements normaux possibles)${NC}\n\n" >> "$ERROR_LOG"
                        python3 -m pipx ensurepath > /dev/null 2>> "$ERROR_LOG" 
                        export PATH="$HOME/.local/bin:$PATH"
                        echo -e "\n\n${WHITE}[INFO] Fin de log pipx ci-dessus ${NC}\n\n" >> "$ERROR_LOG"
                            
                            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                            # Supprime toute installation éventuelle passée de gcert pour éviter tout conflit de venv et log
                            rm -rf ~/.local/share/pipx/venvs/gcert > /dev/null 2>> "$ERROR_LOG" && echo "$HOME/.local/share/pipx/venvs/gcert" >> "$INSTALL_LOG"
                            # Pipx force l'installation des prérequis et log
                            pipx install . --force > /dev/null 2>> "$ERROR_LOG" && echo "pipx:gcert" >> "$INSTALL_LOG"
                            BLA::stop_loading_animation
                        

                        # Vérification finale des dépendances
                        for pkg in "${dependencies[@]}"; do
                            
                            # Vérifie si le paquet $pkg est installé via pipx
                            if pipx runpip gcert show "$pkg" >/dev/null 2>&1; then
                                echo -e "${GREEN}$pkg : installée avec succès.${NC}"
                                sleep 1
                            else
                                echo -e "${RED}Dépendance manquante : $pkg${NC}"
                                rm -rf ~/.local/share/pipx/venvs/gcert
                                clean_up_error
                            fi
                        done
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# =============================== CREATION CLE GPG ET MOTS DE PASSE G.CERT ===============================
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Création des mots de passe pour accéder aux différentes options du programme G.Cert

# Menu récapitulatif 

clear
afficher_bienvenue

echo -e "${BLUE_BRIGHT}=== Création Clé GPG et Mots de Passe des Différents Services de G.cert  ===${NC}\n"
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
                                
                                echo -e "${GREEN}[√] Installation des prérequis...${NC}" 
                                echo -e "${GREEN}[√] Installation et configuration de Vault...${NC}"
                                echo -e "${GREEN}[√] Création de l'environnement Python...${NC}" 
                                echo -e "-${INVERSE}[4/5]${NC}- Création de la clé GPG et des mots de passe..." 
                                echo -e "-${INVERSE}[5/5]${NC}- Lancement du service G_Cert...\n\n"
                        
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

                        echo -e "${YELLOW}======================================================================${NC}"
                        echo -e "${WHITE}INFORMATION : Clé GPG pour le gestionnaire de mots de passe 'pass'${NC}"
                        echo -e "${YELLOW}======================================================================${NC}"
                        echo -e "Pour utiliser ${GREEN}pass${NC}, seule une clé ${GREEN}RSA capable de signer et chiffrer${NC} est compatible."
                        echo -e "\nLes options disponibles lors de la création d'une clé GPG :"
                        echo -e "  (1) ${GREEN}RSA and RSA${NC}           => signature et chiffrement compatible avec pass"
                        echo -e "  (2) DSA and Elgamal                  => non compatible"
                        echo -e "  (3) DSA (sign only)                  => non compatible"
                        echo -e "  (4) RSA (sign only)                  => non compatible"
                        echo -e "  (9) ECC (sign and encrypt)           => non compatible (Attention par défaut)"
                        echo -e " (10) ECC (sign only)                  => non compatible"
                        echo -e " (14) Existing key from card           => Clé RSA existante ET RSA chiffrante"
                        echo -e "\n${YELLOW}======================================================================${NC}\n"
                        
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
                echo -e "-${INVERSE}[1]${NC}- ${WHITE}Créer un nouvelle Clé${NC}\n"
                echo -e "-${INVERSE}[2]${NC}- ${WHITE}Entrer un clé existente${NC}\n"
                echo -e "-${INVERSE}[3]${NC}-] ${WHITE}Sortir...${NC}\n"
                                                        
                read -p "Choisissez une option: " choix_gpg_1

                case "$choix_gpg_1" in

                1)
                    # =============================== CREATION NOUVELLE CLE GPG ==============================
                    clear
                    afficher_bienvenue
                    echo -e "${BLUE_BRIGHT}=== Création d'une nouvelle clé GPG ===${NC}\n"
                    echo -e "${WHITE}Génération interactive de la clé avec GnuPG...${NC}\n\n\n"
                    echo -e " ${RED}=> !!! RAPPEL: !!!${NC}  (1) ${GREEN}RSA and RSA${NC}  => compatible avec pass"
                    
                    echo
                    
                    # Génère une nouvelle clé GPG
                    
                    gpg --full-generate-key
                    
                    # Donne la dernière clé GPG créée
                    
                    LAST_CLE=$(gpg --list-keys --keyid-format long | grep -o '[0-9A-Fa-f]\{40\}' | tail -n1)
                    KEY_ID=$LAST_CLE
                    echo "gpg:$KEY_ID" >> "$INSTALL_LOG"

                    # Si pas de clé le script sort
                    [[ -z "$LAST_CLE" ]] && { echo -e "${RED}Aucune clé trouvée, le programme d'installation va quitter...${NC}"; sleep 4; clean_up_error; }

                    # Message pour l'animation       
                    while true; do
                        echo -e "\n\n${YELLOW}Veuillez enregistrer les informations ci-dessus${NC}\n"
                        read -p "Appuyez sur [Entrée] pour continuer : " input

                        if [[ -z "$input" ]]; then
                            break
                        else
                            echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                        fi
                    done


                    clear
                    afficher_bienvenue
                    # Si clé GPG créee message OK
                    echo -e "\n${GREEN}[√] Clé GPG créée.${NC}\n"
                    echo -e "${WHITE}Fingerprint : ${GREEN}${LAST_CLE}${NC}\n"
                    sleep 3
                    break

                ;;

                2)
                     # =============================== ENTRER CLE GPG ==============================
                    while true; do
                        clear
                        afficher_bienvenue
                        echo -e "${BLUE_BRIGHT}=== Entrer une clé GPG existante ===${NC}\n"
                        echo -e " ${RED}=> !!! RAPPEL: !!!${NC}  ${WHITE}Vous devez être en possession de la Pass Phrase de la clé...${NC}"
                        echo
                        
                        # MENU
                        echo -e "-${INVERSE}[1]${NC}- ${WHITE}Entrer un Clé...${NC}"
                        echo -e "-${INVERSE}[2]${NC}- ${WHITE}Sortir...${NC}\n"
                                                        
                        read -p "Choisissez une option: " choix_gpg_2

                        case "$choix_gpg_2" in
                        1)
                            clear
                            afficher_bienvenue
                            echo -e "${RED}Vous devez être en possession de la passphrase de la clé...${NC}\n\n"
                            enter

                            clear
                            afficher_bienvenue

                            # Liste les clés GPG et les affiche numérotées :
                            # =>   1. 0123456789ABCDEF0123456789ABCDEF01234567
                            # =>   2. ABCDEF0123456789ABCDEF0123456789ABCDEF01
                            cle=$(gpg --list-keys --keyid-format long | grep -o '[0-9A-Fa-f]\{40\}' | nl -w2 -s'. ')
                            
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
                
                        2)
                            clean_up_choice
                            ;;
                        *)
                            echo -e "${RED}Erreur, Réponse invalide .${NC}"
                            sleep 2
                        ;;
                        esac

                    done
                ;;
                
                3)
                    clean_up_choice         
                ;;

                *)
                    echo -e "${RED}Erreur, Réponse invalide .${NC}"
                ;;
                esac 

            done
                            
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
                echo -e "${WHITE}Clé GPG:${NC} ${GREEN}${LAST_CLE}${NC}\n"
                read -p "Êtes-vous sûr de vouloir utiliser cette clé ? [y/n] : " Choix_Valide_Cle

                # Si oui, pass init avec la clé choisie et le script continue
                if [[ "$Choix_Valide_Cle" =~ ^[yY]$ ]]; then
                    if pass init "$LAST_CLE" >/dev/null 2>&1; then
                        echo "pass:$LAST_CLE" >> "$INSTALL_LOG"
                        
                        # Vérifie la création du répertoire du Password Store
                        if [[ -d "$HOME/.password-store" ]]; then
                            clear
                            afficher_bienvenue
                            echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${WHITE}[2]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${WHITE}[3]wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            echo -e "\n\n${GREEN}Password Store créé avec succès !${NC}"
                            sleep 3
                            break
                        else
                            echo -e "${RED}Erreur : le répertoire .password-store n'a pas été créé.${NC}"
                            sleep 3
                            clean_up_error
                        fi

                    else
                        echo -e "${RED}Erreur : impossible d’initialiser le Password Store avec la clé ${LAST_CLE}.${NC}"
                        sleep 3
                        clean_up_error
                    fi

                # Si non, le script sort
                elif [[ "$Choix_Valide_Cle" =~ ^[nN]$ ]]; then
                    echo -e "${YELLOW}G.Cert à besoin d'une clé GPG pour le chiffrement des mots de passe...${NC}\n"
                    echo -e "${RED}Le programme d'installation va quitter...${NC}" 
                    enter
                
                    clean_up_error

                else
                    # Si l'utilisateur ne tape pas y/n
                    echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                fi
            done


# =============================== CREATION MOT DE PASSE ===============================
  

                   

                    # === Création de du Wan ===
                    clear
                    afficher_bienvenue
                    
                    echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                    echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Wan ===${NC}\n\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${WHITE}[2]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${WHITE}[3]wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"

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
                            echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                            echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Wan ===${NC}\n\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${WHITE}[2]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${WHITE}[3]wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            
                            # Création du mot de passe wan
                            printf '%s\n' "$Wan" | pass insert -f --multiline gcert/wan > /dev/null 2>> "$ERROR_LOG" && echo "pass:gcert/wan" >> "$INSTALL_LOG" 

                            # Vérification
                            if [[ -f "$HOME/.password-store/gcert/wan.gpg" ]]; then
                                clear
                                afficher_bienvenue
                                echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                                echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Wan ===${NC}\n\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${WHITE}[2]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${WHITE}[3]wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"
                                echo -e "${GREEN}Dossier gcert ET Mot de passe Wan créé avec succès${NC}"
                                sleep 3
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Wan${NC}"
                                sleep 2
                                clean_up_error
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

                    echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                    echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Lan ===${NC}\n\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n" 

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

                            echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                            echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Lan ===${NC}\n\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n" 
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            # Création du mot de passe 
                            

                            printf '%s\n' "$Lan" | pass insert -f --multiline gcert/lan > /dev/null 2>> "$ERROR_LOG" && echo "pass:gcert/lan" >> "$INSTALL_LOG" 

                            # Vérification
                            if [[ -f "$HOME/.password-store/gcert/lan.gpg" ]]; then
                                clear
                                afficher_bienvenue

                                echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                                echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Lan ===${NC}\n\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${WHITE}[4]lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n" 
                                
                                echo -e "${GREEN}Mot de passe Lan créé avec succès${NC}"
                                sleep 2
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Lan${NC}"
                                sleep 2
                                clean_up_error
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
                    
                    echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                    echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Gestion ===${NC}\n\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"

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
                            
                            echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                            echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Gestion ===${NC}\n\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            # Création du mot de passe 
                            

                            printf '%s\n' "$Gestion" | pass insert -f --multiline gcert/gestion > /dev/null 2>> "$ERROR_LOG" && echo "pass:gcert/gestion" >> "$INSTALL_LOG" 

                            # Teste le mot de passe et sa confirmation
                            if [[ -f "$HOME/.password-store/gcert/gestion.gpg" ]]; then
                                clear
                                afficher_bienvenue
                                
                                echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                                echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Gestion ===${NC}\n\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${WHITE}[5]gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"
                                echo -e "${GREEN}Mot de passe Gestion créé avec succès${NC}"
                                sleep 2
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Gestion${NC}"
                                sleep 2
                                clean_up_error
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
                    echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                    echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Logs ===${NC}\n\n"

                    echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                    echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                    echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                    echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"

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
                            echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                            echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Logs ===${NC}\n\n"

                            echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                            echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                            echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                            echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"
                            
                            echo -e "${GREEN}Mots de passe identiques.${NC}"
                            sleep 2
                            # Création du mot de passe 
                            

                            printf '%s\n' "$Logs" | pass insert -f --multiline gcert/logs > /dev/null 2>> "$ERROR_LOG" && echo "pass:gcert/logs" >> "$INSTALL_LOG" 

                            # Vérification
                            if [[ -f "$HOME/.password-store/gcert/logs.gpg" ]]; then
                                clear
                                afficher_bienvenue
                                echo -e "${BLUE_BRIGHT}=== Structure du Password Store G.cert ===${NC}\n"
                                echo -e "${CYAN_BRIGHT}=== Création du Mots de passe Logs ===${NC}\n\n"

                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${WHITE}[6]logs${NC}     - Mot de passe pour le service Logs\n\n"
                                echo -e "${GREEN}Mot de passe Logs créé avec succès${NC}"
                                sleep 2
                                
                                clear
                                afficher_bienvenue
                                
                                echo -e "${GREEN}[√]${NC}${WHITE}Password Store${NC}   - Répertoire local où pass stocke tous les mots de passe"
                                echo -e "└── ${GREEN}[√]${NC}${YELLOW}gcert${NC}       - Dossier contenant les Mots de passe"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}wan${NC}      - Mot de passe pour le service WAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}lan${NC}      - Mot de passe pour le service LAN"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}gestion${NC}  - Mot de passe pour le service Gestion"
                                echo -e "    └── ${GREEN}[√]${NC}${WHITE}logs${NC}     - Mot de passe pour le service Logs\n\n"
                                sleep 3
                            
                            else
                                echo -e "${RED}Problème lors de la création du Mot de passe Logs${NC}"
                                sleep 2
                                clean_up_error
                            fi 

                            break  # Sort de la boucle de saisie
                        else
                            echo -e "${RED}Erreur : les deux mots de passe ne correspondent pas.${NC}"
                            echo "Veuillez réessayer."
                        fi
                    done
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# =============================== LANCEMENT DU SCRIPT PYTHON ===============================
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                            clear
                                afficher_bienvenue

                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"
                              
                                echo -e "${GREEN}[√] Installation des prérequis...${NC}" 
                                echo -e "${GREEN}[√] Installation et configuration de Vault...${NC}"
                                echo -e "${GREEN}[√] Création de l'environnement Python...${NC}" 
                                echo -e "${GREEN}[√] Création de la clé GPG et des mote de passe...${NC}" 
                                echo -e "-${INVERSE}[5/5]${NC}- Lancement du service G_Cert...\n\n"
                            
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
                                
                                echo -e "${GREEN}[√] Installation des prérequis...${NC}" 
                                echo -e "${GREEN}[√] Installation et configuration de Vault...${NC}"
                                echo -e "${GREEN}[√] Création de l'environnement Python...${NC}" 
                                echo -e "${GREEN}[√] Création de la clé GPG et des mots de passe...${NC}" 
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
                                    sleep 3
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
                                        sleep 3
                                        clean_up_error
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
                                    sleep 3
                                    clean_up_error
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
                            clean_up_choice   
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
