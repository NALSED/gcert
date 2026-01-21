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
PREREQUIS=(curl cron gnupg gum python3 python3-pip pipx python3.13-venv pass tmux)

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

# VAULT 

repo_vault() {
    sudo apt -qq update -y > /dev/null && sudo apt install -y gnupg wget lsb-release > /dev/null 2>&1
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null 2>&1
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null 2>&1
    sudo apt -qq update -y > /dev/null 2>&1 && sudo apt install -qq vault -y > /dev/null 2>&1
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
            echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
        fi
    done
}

# Message Logs

log() {
    error_log_redirection="2>> /var/log/gcert_install/erreur.log"
    
    # Exécution de la commande avec redirection de stdout vers /dev/null et stderr vers erreur.log
    "$@" > /dev/null $error_log_redirection
}



# === FONCTIONNEMENT SCRIPT ===

# Flag pour arrêter une répétition dans une boucle for.
stop=false

# Flag instalation paquet
all_installed=true 

# =============================== DEBUT SCRIPT INSTALLATION =============================== 


clear
afficher_bienvenue        
        
        

        # Vérification de l'interactivité du shell et de la présence de sudo et connexion réseau
        if [ -t 0 ]; then

            if dpkg -s "sudo" >/dev/null 2>&1; then

                clear
                afficher_bienvenue
                
                echo -e "\n\n${YELLOW}=== Redirections des logs ===${NC}"
                echo -e "Création du dossier de logs, pour l'installation de gcert"
                echo -e "   - Les erreurs sont redirigées vers ${WHITE}/var/log/gcert_install/erreur.log${NC}, avec un préfixe [ERROR]."
                

                enter

                sudo mkdir /var/log/gcert_install           
                sudo chown $USER:$USER /var/log/gcert_install/
                sudo chmod 755 /var/log/gcert_install/
    
                # Vérification de la création du répertoire /var/log/gcert_install/

                    echo -e "${GREEN}OK : Le répertoire ${WHITE}/var/log/gcert_install${GREEN}créé avec succès.${NC}"
                    sleep 2
                else
                    echo -e "${RED}ERREUR : Probléme lor de la création du répertoire ${WHITE}/var/log/gcert_install${RED}.${NC}"
                    echo -e "Veuillez créer le répertoire avec la commande : sudo mkdir /var/log/gcert_install"
                    sleep 3
                fi

                # Vérification de la propriété du répertoire
                if [[ $(stat -c "%U:%G" /var/log/gcert_install) == "$USER:$USER" ]]; then
                    echo -e "${GREEN}OK : Le propriétaire du répertoire ${WHITE}/var/log/gcert_install${GREEN} est correct : $USER.${NC}"
                    sleep 2
                else
                    echo -e "${RED}ERREUR : Le propriétaire du répertoire ${WHITE}/var/log/gcert_install${RED} est incorrect.${NC}"
                    echo -e "Veuillez corriger la propriété avec la commande : sudo chown $USER:$USER /var/log/gcert_install"
                    sleep 3
                fi

                # Vérification des permissions du répertoire
                if [[ $(stat -c "%a" /var/log/gcert_install) == "755" ]]; then
                    echo -e "${GREEN}OK : Les permissions du répertoire ${WHITE}/var/log/gcert_install${GREEN} sont correctes :${NC} ${WHITE}755 ${NC}"
                    sleep 2
                else
                    echo -e "${RED}ERREUR : Les permissions du répertoire ${WHITE}/var/log/gcert_install${RED} sont incorrectes.${NC}"
                    echo -e "Veuillez corriger les permissions avec la commande : sudo chmod 755 /var/log/gcert_install"
                    sleep 3
                fi

                clear
                afficher_bienvenue

                echo -e "${YELLOW}=== Informations en cas de problème ===${NC}"
                echo -e "   - Si un problème survient lors de l'exécution du script, un message d'erreur sera affiché."
                echo -e "   - Le script quittera immédiatement en cas d'erreur, mais les logs seront disponibles."
                echo -e "   - Les erreurs seront enregistrées dans ${WHITE}/var/log/gcert_install/erreur.log${NC}."
                echo -e "   - Pour les sorties standard, consultez ${WHITE}/var/log/gcert_install/normal.log${NC}.\n"

                enter        
                # Test WAN
                
                clear
                afficher_bienvenue
                
                msg="Test de la connexion WAN en cours "
            
                # Démarrer l'animation
                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                sleep 3
                
                # Effectuer le ping
                if log ping -c 1 "1.1.1.1" ; then
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
                                
                                echo -e "[1/5] Installation des prérequis...\n" 
                                echo -e "[2/5] Installation et configuration de Vault"
                                echo -e "[3/5] Création de l'environnement Python...\n" 
                                echo -e "[4/5] Création de la clé GPG et du mot de passe...\n" 
                                echo -e "[5/5] Lancement du service G_Cert...\n\n"
                                
                                enter

                        clear
                        afficher_bienvenue
                        
                        echo -e "${YELLOW}Vous avez choisi de lancer le programme d'installation.${NC}\n\n"
                        echo -e "${YELLOW}=== Installation des prérequis pour G.cert  ===${NC}\n"
                        echo -e "${WHITE}Avant de commencer, G.cert nécessite quelques programmes et bibliothèques :${NC}\n"

                        echo -e "${WHITE}• curl :${NC} pour récupérer des fichiers depuis Internet."
                        echo -e "${WHITE}• gnupg :${NC} pour générer vos clés RSA et chiffrer vos mots de passe."
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
                                for pkg in "${PREREQUIS[@]}"; do
                                    if log dpkg -s "$pkg"; then
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


# =============================== VAULT ===============================

                                clear
                                afficher_bienvenue

                                # Récapitulation Installation Générale
                                echo -e "Date        : ${YELLOW}${NOW}${NC}"
                                echo -e "Utilisateur : ${YELLOW}${USER_NAME}${NC}"
                                echo -e "Hôte        : ${YELLOW}${HOST_NAME}${NC}\n\n"
                                echo -e "${YELLOW}============================================================${NC}"
                                echo -e "${WHITE}             Récapitulatif des étapes d'installation${NC}"
                                echo -e "${YELLOW}============================================================${NC}\n\n"

                                echo -e "${GREEN}[√] Installation des prérequis...${NC}\n" 
                                echo -e "[2/5] Installation et configuration de Vault"
                                echo -e "[3/5] Création de l'environnement Python...\n" 
                                echo -e "[4/5] Création de la clé GPG et du mot de passe...\n" 
                                echo -e "[5/5] Lancement du service G_Cert...\n\n"

                                enter

                                clear
                                afficher_bienvenue

                                # Récapitulation Installation Vault

                                echo -e "${YELLOW}=== Installation et Initialisation de Vault ===${NC}\n"

                                echo -e "${WHITE}[1] Installation de Vault :${NC}"
                                echo -e "   - Ajout du dépôt HashiCorp et installation du paquet Vault."
                                echo -e "   - Vérification de la présence du binaire vault.\n"

                                echo -e "${WHITE}[2] Clés GPG et Certificats TLS :${NC}"
                                echo -e "   - Création des clés GPG admin et chiffrement des unseal keys/root token."
                                echo -e "   - Génération de la clé TLS et certificat (auto-signé ou CA existante)."
                                

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

                                # Message [1]
                                echo -e "${YELLOW}=== Installation de Vault ===${NC}\n"

                                echo -e "${WHITE}[1] Préparation du système :${NC}"
                                echo -e "   - Mise à jour du système et installation des prérequis.\n"

                                echo -e "${WHITE}[2] Ajout de Vault :${NC}"
                                echo -e "   - Configuration du dépôt officiel HashiCorp.\n"

                                echo -e "${WHITE}[3] Installation :${NC}"
                                echo -e "   - Installation du service Vault sur le système.\n"

                                enter


                                clear
                                afficher_bienvenue

                                msg="Veuillez patienter durant l'installation de Vault"
                               
                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"

                                # Installation
                                repo_vault > /dev/null 2>&1


                                # Effacer la ligne du message dynamique
                                echo -ne "\r\033[K"
                                BLA::stop_loading_animation

                                # test l'installation de Vault
                                if dpkg -s vault >/dev/null 2>&1; then
                                    echo -e "${GREEN}Vault installé avec succès${NC}"
                                    sleep 2
                                else
                                    echo -e "${RED}Problème lors de l'installation de Vault...${NC}\n"
                                    echo -e "Veuillez consulter ${WHITE}/var/log/apt/history.log${NC} et ${WHITE}/var/log/apt/term.log${NC}, pour plus d'information\n"
                                    sleep 4
                                    
                                    clear
                                    afficher_bienvenue
                                    echo -e "Le programme d'installation va quitter"
                                    sleep 2
                                    exit 1
                                fi

# =============================== [2] CLÉS GPG ET CERTIFICATS ===============================

                                # ===== CLEES GPG =====    
                                clear
                                afficher_bienvenue    

                                echo -e "${YELLOW}=== Sécurisation Cryptographique Vault ===${NC}\n"

                                echo -e "${WHITE}[1] Génération des clés GPG :${NC}"
                                echo -e "   - Protection de la clé privée SSL Vault"
                                echo -e "   - Sécurisation des unseal keys et du root token\n"

                                echo -e "${WHITE}[2] Génération des certificats SSL :${NC}"
                                echo -e "   - Configuration OpenSSL"
                                echo -e "   - Clé privée, CSR et CA\n"
    
                                enter

                                msg="Initialisation Clé GPG et Certificats"
                                echo -e "\n"

                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                sleep 2
                                BLA::stop_loading_animation

                                clear
                                afficher_bienvenue

                                
                                
                                # === Clé GPG pour clé privée TLS ===
                                
                                clear
                                afficher_bienvenue
                                
                                echo -e "${YELLOW}=== Génération des clés GPG ===${NC}\n"

                                echo -e "${WHITE}[1] Clé GPG Vault :${NC}"
                                echo -e "   - Création d'une clé GPG dédiée à Vault (unseal keys et root token).\n"

                                echo -e "${WHITE}[2] Clé GPG OpenSSL :${NC}"
                                echo -e "   - Création d'une clé GPG dédiée à la clé privée des certificats SSL.\n"

                                echo -e "   - Les clés seront enregistrées => ${WHITE}/home/$USER/.gnupg${NC}\n"

                                enter

                                msg="nitialisation création clés GPG, afin de protéger la Clée privée du certificat de Vault"
                                echo -e "\n"

                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                sleep 2
                                BLA::stop_loading_animation

                                # Génération
                                clear
                                afficher_bienvenue
                                
                                echo -e "\n${YELLOW}=== Création clé GPG pour la Clé privée OpenSSL  ===${NC}\n"
                                gpg --full-generate-key

                                while true; do
                                    echo -e "\n\nVeuillez enregistrer les informations ci-dessus\n"
                                    read -p "Appuyez sur [Entrée] pour continuer : " input

                                    if [[ -z "$input" ]]; then
                                        break
                                    else
                                        echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                                    fi
                                done

                                # Variable ID clé GPG ==========> Clé privée OpenSSL
                                KEY_PRIVATE_TLS=$(gpg --list-keys --keyid-format long | grep -o '[0-9A-F]\{40\}' | tail -n1)

                                
                                
                                # === Clé GPG pour unseal keys et le root token ===
                                clear
                                afficher_bienvenue
                               
                                msg="Initialisation création clés GPG, afin de protéger les unseal keys et le root token"
                                echo -e "\n"

                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                sleep 2
                                BLA::stop_loading_animation

                                # Génération
                                clear
                                afficher_bienvenue
                                
                                echo -e "\n${YELLOW}=== Création clé GPG pour les unseal keys et le root token de Vault ===${NC}\n"
                                gpg --full-generate-key

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
                                KEY_VAULT=$(gpg --list-keys --keyid-format long | grep -o '[0-9A-F]\{40\}' | tail -n1)


                                # ===== CERTIFICAT OPENSSL POUR VAULT  =====
                                
                                # === FICHIER DE CONFIGURATION ===
                                clear
                                afficher_bienvenue
                                
                                echo -e "${YELLOW}=== Génération du Certificat OpenSSL de Vault ===${NC}\n"

                                echo -e "${WHITE}[1] Configuration OpenSSL :${NC}"
                                echo -e "   - Création du fichier => ${WHITE}/etc/vault/ssl/vault_tls.cnf${NC}."
                                echo -e "   - Définition du domaine : possibilité d'utiliser un domaine existant."
                                echo -e "   - Configuration : CN, DNS1, et IP.\n"

                                echo -e "${WHITE}[2] Clé privée :${NC}"
                                echo -e "   - Génération de la clé privée (RSA / EC) => ${WHITE}/etc/vault/ssl/vault.key${NC}."
                                echo -e "   - Protection par permissions strictes.\n"

                                echo -e "${WHITE}[3] CSR (Certificate Signing Request) :${NC}"
                                echo -e "   - Création du fichier CSR à partir de la clé privée => ${WHITE}/etc/vault/ssl/vault.csr${NC}."
                                echo -e "   - Intégration des extensions (SAN, usage).\n"

                                echo -e "${WHITE}[4] Autorité de Certification (CA) :${NC}"
                                echo -e "   - Utilisation d'un certificat auto-signé ou d'une CA existante."
                                echo -e "   - Création du certificat signé => ${WHITE}/etc/vault/ssl/vault.crt${NC}\n"

                                echo -e "${WHITE}[5] Sécurisation post-CA :${NC}"
                                echo -e "   - Restriction des droits sur clés et certificats."
                                echo -e "   - Stockage sécurisé et sauvegarde chiffrée.\n"


                                enter

                                clear
                                afficher_bienvenue

                                # Choix utilisation nom de domain pour certificat
                                while true; do
                                    
                                    read -p "Voulez-vous utiliser un nom de domaine, pour l'édition du certificat y/n : " choix_domain_ssl

                                    # Avec nom de domaine
                                    if [[ "$choix_domain_ssl" =~ ^[yY]$ ]]; then
                                        clear
                                        afficher_bienvenue
                                        read -p "Veuillez indiquer le nom de domaine (format => FQDN)" domain_ssl

                                        # test si le nom de domaine existe
                                        if nslookup "$domain_ssl" > /dev/null 2>&1; then
                                            echo -e "\n${GREEN}Le domaine '$domain_ssl' existe et résout correctement.${NC}"
                                            sleep 3


                                            # === 1-3) NOM serveur CN ===
                                            clear
                                            afficher_bienvenue

                                            while true; do
                                                
                                                read -p "Veuillez indiquer le Nom principal du serveur (Common Name) : " cn_vault

                                                clear
                                                afficher_bienvenue

                                                echo -e "CN = $cn_vault\n"
                                                read -p "Le CN est-il correct ? y/n : " validation_cn

                                                if [[ "$validation_cn" =~ ^[yY]$ ]]; then
                                                    echo "${GREEN}CN confirmé : $cn_vault${NC}"
                                                    sleep 3
                                                    break
                                                elif [[ "$validation_cn" =~ ^[nN]$ ]]; then
                                                    echo -e "${RED}Recommençons...${NC}"
                                                    sleep 2
                                                else
                                                    echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                            done



                                            # === 2-3) NOM DNS serveur ===
                                            clear
                                            afficher_bienvenue

                                            while true; do
                                               
                                                read -p "Veuillez indiquer Nom DNS utilisé par les clients Vault (format => Nom + FQDN) : " dns_vault

                                                clear
                                                afficher_bienvenue

                                                echo -e "DNS.1 = $dns_vault\n"
                                                read -p "Le DNS.1 est-il correct ? y/n : " validation_dns1

                                                if [[ "$validation_dns1" =~ ^[yY]$ ]]; then
                                                    echo "${GREEN}DNS.1 confirmé : $dns_vault${NC}"
                                                    sleep 3
                                                    break
                                                elif [[ "$validation_dns1" =~ ^[nN]$ ]]; then
                                                    echo -e "${RED}Recommençons...${NC}"
                                                    sleep 2
                                                else
                                                    echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                            done

                                            # === 3-3) IP serveur ===
                                            while true; do
                                                clear
                                                afficher_bienvenue
                                                
                                               
                                                read -p "Veuillez indiquer l'IP du serveur Vault : " ip_vault

                                                # test format IP
                                                if validate_ip "$ip_vault"; then
                                                    echo -e "\n${GREEN}IP valide${NC}"
                                                    sleep 1

                                                    while true; do
                                                        clear
                                                        afficher_bienvenue

                                                        # Confirmation utilisation adresse IP
                                                        echo -e "Adresse IP choisie pour Vault = $ip_vault\n"       
                                                        read -p "L'adresse IP est-elle correcte ? y/n : " validation_ip

                                                        if [[ "$validation_ip" =~ ^[yY]$ ]]; then
                                                            echo "${GREEN}IP confirmée : $ip_vault${NC}"
                                                            sleep 3
                                                            break 2
                                                        elif [[ "$validation_ip" =~ ^[nN]$ ]]; then
                                                            echo -e "${RED}Recommençons...${NC}"
                                                            sleep 2
                                                            break
                                                        else
                                                            echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                            sleep 2
                                                        fi
                                                    done
                                                else
                                                    echo -e "\n${RED}IP invalide${NC}\n"
                                                    echo -e "Recommençons..."
                                                    sleep 2
                                                    sleep 2
                                                fi
                                            done


                                                clear
                                                afficher_bienvenue

                                                msg="Création fichier de configuration"
                                            
                                                BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"

                                                sleep 2

                                                # Effacer la ligne du message dynamique
                                                echo -ne "\r\033[K"
                                                BLA::stop_loading_animation



                                                # création répertoire
                                                sudo mkdir -p /etc/vault/ssl

                                                # Edition fichier certificat vault_tls.cnf
                                                sudo tee /etc/vault/ssl/vault_tls.cnf <<-EOF > /dev/null 2>&1
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
                                        # Si le domaine ne repond pas ou n'existe pas sortie de script
                                        else
                                            echo "Le domaine '$domain_ssl' n'existe pas ou ne résout pas."
                                            echo "Veuillez résoudre le problème avant de poursuivre l'installation"
                                            sleep 1
                                            echo "Le programme d'installation va quitter"
                                            sleep 2
                                            exit 1
                                        fi

                                    # Choix 2 pas de domaine
                                    elif [[ "$choix_domain_ssl" =~ ^[nN]$ ]]; then
                                            
                                           
                                            # === 1-3) NOM serveur CN ===
                                            clear
                                            afficher_bienvenue

                
                                            while true; do
                                            
                                                read -p "Veuillez indiquer le Nom principal du serveur (Common Name)\n" cn_vault

                                                clear
                                                afficher_bienvenue

                                                echo -e "CN = $cn_vault\n"
                                                read -p "Le CN est-il correct ? y/n" validation_cn

                                                if [[ "$validation_cn" =~ ^[yY]$ ]]; then
                                                    echo "CN confirmé : $cn_vault"
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
                                                
                                                
                                                read -p "Veuillez indiquer Nom DNS utilisé par les clients Vault (format => Nom)\n" dns_vault

                                                clear
                                                afficher_bienvenue

                                                echo -e "DNS.1 = $dns_vault\n"
                                                read -p "Le DNS.1 est-il correct ? y/n" validation_dns1

                                                if [[ "$validation_dns1" =~ ^[yY]$ ]]; then
                                                    echo "DNS.1 confirmé : $dns_vault"
                                                    break
                                                elif [[ "$validation_dns1" =~ ^[nN]$ ]]; then
                                                    echo -e "${RED}Recommençons...${NC}"
                                                else
                                                    echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                            done

                                            while true; do
                                                
                                                
                                                # === 3-3) Ip serveur ===
                                                clear
                                                afficher_bienvenue

                                                
                                                read -p "Veuillez indiquer l'IP du serveur Vault \n" ip_vault

                                                # Test IP
                                                if validate_ip "$ip_vault"; then
                                                    echo -e "${GREEN}IP valide${NC}"
                                                    sleep 1

                                                    while true; do
                                                        clear
                                                        afficher_bienvenue

                                                        # Confirmation utilisation adresse IP
                                                        echo -e "Adresse IP choisie pour Vault = $ip_vault\n"       
                                                        read -p "L'adresse IP est-elle correcte ? y/n" validation_ip

                                                        if [[ "$validation_ip" =~ ^[yY]$ ]]; then
                                                            echo "IP confirmée : $ip_vault"
                                                            sleep 1
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
                                                    echo -e "${RED}IP invalide${NC}"
                                                    sleep 2
                                                fi
                                            done
                                            
                                            # création répertoire
                                            sudo mkdir -p /etc/vault/ssl

                                            # Edition fichier certificat vault_tls.cnf
                                            sudo tee /etc/vault/ssl/vault_tls.cnf <<-EOF
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
                                               
                                    
                                    else
                                        clear
                                        afficher_bienvenue 
                                        echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                    fi
                                done

                                # === CLEE PRIVEE CERTIFICAT === 
                                clear
                                afficher_bienvenue
                                
                                echo -e "Génération de la ${WHITE}clé privée TLS${NC} et ${WHITE}CSR${NC}"
                                
                                # Création de la clé privée
                                sudo openssl genrsa -out /etc/vault/ssl/vault.key > /var/log/vault_tls.log 2>&1
                                    
                                    clear
                                    afficher_bienvenue
                                    
                                    # Test presence clé privé
                                    if [ -f /etc/vault/ssl/vault.key ]; then
                                        echo -e "${GREEN}OK : vault.key créé.${NC}"
                                        sleep 2
                                    else
                                        echo -e "${RED}ERREUR : vault.key manquante...${NC}"
                                        echo -e "Pour plus d'information voir le fichier : ${WHITE}/var/log/vault_tls.log${NC}" 
                                        sleep 3
                                        echo -e "Le programme d'installation va quitter"
                                        sleep 1
                                        exit 1
                                    fi

                                # droit strict sur vault.key
                                sudo chmod 600 /etc/vault/ssl/vault.key
                                
                                # === CREATION CSR ===
                                
                                # Commande de cration du CSR avec redirection des logs
                                sudo openssl req -new -key /etc/vault/ssl/vault.key -out /etc/vault/ssl/vault.csr -config /etc/vault/ssl/vault_tls.cnf > /var/log/vault_tls.log 2>&1

                                    clear
                                    afficher_bienvenue
                                    
                                    # Test présence CSR
                                    if [ -f /etc/vault/ssl/vault.csr ]; then
                                        echo -e "${GREEN}OK : vault.csr créé.${NC}"
                                        sleep 2
                                    else
                                        echo -e "${RED}ERREUR : vault.csr manquante...${NC}"
                                        echo -e "Pour plus d'information voir le fichier : ${WHITE}/var/log/vault_tls.log${NC}" 
                                        sleep 3
                                        echo -e "Le programme d'installation va quitter"
                                        sleep 1
                                        exit 1
                                    fi
                                
                                clear
                                afficher_bienvenue
                                
                                # Demande pour la durée de validitée du certificat de Vault
                                while true; do
                                     read -p "Veuillez entrer une valeur pour la durée de validité du certificat (Format => jour entre 1 et 365)" days_vault

                                    if [[ "$days_vault" =~ ^[0-9]+$ ]] && (( days_vault >= 1 && days_vault <= 365 )); then
                                        break
                                    else
                                        echo "Erreur : veuillez entrer un nombre entre 1 et 365."
                                    fi
                                done

                                # === Signature certificat ===
                                clear
                                afficher_bienvenue

                                while true; do

                                    # Avertissement
                                    echo -e "${YELLOW}=== Avertissement Sécurité – Clé privée de la CA ===${NC}\n"

                                    echo -e "${WHITE}[!] Signature avec une CA existante :${NC}"
                                    echo -e "   - La signature d’un certificat nécessite que la clé privée de la CA soit"
                                    echo -e "     accessible en clair de manière TEMPORAIRE."

                                    echo -e "Bonnes pratiques:\n"
                                    echo -e "   - La clé doit être déverrouillée uniquement pour la durée de la signature."
                                    echo -e "   - Ne jamais stocker la clé de la CA en clair de façon permanente."
                                    echo -e "   - Privilégier une CA hors ligne ou une CA intermédiaire dédiée."
                                    echo -e "   - Rechiffrer ou supprimer immédiatement toute clé déchiffrée après usage.\n"


                                    echo -e "${YELLOW}Veuillez choisir un mode de CA : ${NC}\n"
                                    
                                    echo -e "[1] Certificat auto signé" 
                                    echo -e "[2] CA Existante\n\n"    
                                    echo -e "[3]" Sortie Installation

                                    read -p "Choix CA :" choix_ca

                                    case "$choix_ca" in

                                        # Autosigné
                                        1)
                                        
                                        clear
                                        afficher_bienvenue
                                        
                                        echo -e "${WHITE}[1] Certificat auto signé${NC}\n"
                                        
                                        
                                        msg="Edition du certificat"
                                            echo -e "\n"
                                            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                            sleep 2
                                            BLA::stop_loading_animation

                                        # Signature certificat auto-signé
                                        openssl x509 -req -in /etc/vault/ssl/vault.csr -signkey /etc/vault/ssl/vault.key -out /etc/vault/ssl/vault.crt -days "$days_vault" -extensions req_ext -extfile /etc/vault/ssl/vault_tls.cnf >> /var/log/vault_tls.log 2>&1

                                        clear
                                        afficher_bienvenue
                                        # Test présence du certificat
                                        if openssl x509 -in /etc/vault/ssl/vault.crt -noout >/dev/null 2>&1; then
                                            
                                            echo -e "${GREEN}OK : vault.crt créé avec succès et valide.${NC}"
                                            sleep 2
                                        else
                                            echo -e "${RED}ERREUR : vault.csr manquante...${NC}"
                                            echo -e "Pour plus d'information voir le fichier : ${WHITE}/var/log/vault_tls.log${NC}" 
                                            sleep 3
                                            echo -e "Le programme d'installation va quitter"
                                            sleep 1
                                            exit 1
                                        fi


                                        ;;

                                        # CA existante
                                        2)

                                        clear
                                        afficher_bienvenue
                                        
                                        echo -e "${WHITE}[2] CA Existant${NC}"

                                        # Chemin fichier .crt + test
                                        read -p "Veuillez indiquer le chemin vers le CA existant (chemin absolue vers le fichier .crt)" ca_existant_crt

                                        if [ -f "$ca_existant_crt" ]; then
                                            echo -e "${GREEN}OK : le fichier existe.${NC}"
                                            sleep 2
                                        else
                                            echo -e "${RED}ERREUR : dans la récupération du fichier .crt...${NC}"
                                            sleep 2
                                            echo -e "Le programme d'installation va quitter"
                                            sleep 1
                                            exit 1
                                        fi

                                        clear
                                        afficher_bienvenue
                                        
                                        # Chemin fichier .key + test
                                        read -p "Veuillez indiquer le chemin vers la clé privé (chemin absolue vers le fichier .key)" ca_private_key

                                        if [ -f "$ca_private_key" ]; then
                                            echo -e "${GREEN}OK : le fichier existe.${NC}"
                                            sleep 2
                                        else
                                            echo -e "${RED}ERREUR : dans la récupération de la clés privée...${NC}"
                                            sleep 2
                                            echo -e "Le programme d'installation va quitter"
                                            sleep 1
                                            exit 1
                                        fi
                                        
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

                                        openssl x509 -req -in "$ca_existant_crt" -signkey "$ca_private_key" -out /etc/vault/ssl/vault.crt -days "$days_vault" -extensions req_ext -extfile /etc/vault/ssl/vault_tls.cnf >> /var/log/vault_tls.log 2>&1

                                        clear
                                        afficher_bienvenue
                                        # Test présence du certificat
                                        if openssl x509 -in /etc/vault/ssl/vault.crt -noout >/dev/null 2>&1; then
                                            
                                            echo -e "${GREEN}OK : vault.crt créé avec succès et valide.${NC}"
                                            sleep 2
                                        else
                                            echo -e "${RED}ERREUR : vault.csr manquante...${NC}"
                                            echo -e "Pour plus d'information voir le fichier : ${WHITE}/var/log/vault_tls.log${NC}" 
                                            sleep 3
                                            echo -e "Le programme d'installation va quitter"
                                            sleep 1
                                            exit 1
                                        fi
                                        
                                        
                                        
                                        
                                        ;;

                                        3)
                                            clear
                                            afficher_bienvenue
                                            echo -e "${RED}Le programme d'installation va quitter...${NC}" 
                                                                                                        
                                            msg="Veuillez patienter"
                                            echo -e "\n"
                                            BLA::start_loading_animation "$msg" "${BLA_passing_dots[@]}"
                                            sleep 4
                                            BLA::stop_loading_animation
                                                                                
                                            exit 1         
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
                                echo -e "${YELLOW}=== Sécurisation des fichiers SSL ===${NC}\n"

                                echo -e "${WHITE}Attention : les fichiers clés et certificats sont très sensibles.${NC}"
                                read -p "Voulez-vous chiffrer et sécuriser tous les fichiers maintenant ou plus tard y/n ?" secu_ssl

                                    
                                    while true; do
                                        if [[ "$secu_ssl" =~ ^[yY]$ ]]; then

                                            clear
                                            afficher_bienvenue
                                            echo -e "${YELLOW}=== Sécurisation des certificats SSL ===${NC}\n"

                                            echo -e "${WHITE}[1] Suppression du CSR :${NC}"
                                            echo -e "   - Le fichier => ${WHITE}/etc/vault/ssl/vault.csr${NC} est supprimé pour sécurité.\n"

                                            echo -e "${WHITE}[2] Chiffrement de la clé privée :${NC}"
                                            echo -e "   - La clé privée => ${WHITE}/etc/vault/ssl/vault.key${NC} est chiffrée avec une clé GPG.\n"
                                            echo -e "   - Permissions restreintes pour éviter un accès non autorisé.\n"

                                            echo -e "${WHITE}[3] Rappel du certificat :${NC}"
                                            echo -e "   - Le certificat signé reste accessible => ${WHITE}/etc/vault/ssl/vault.crt${NC}\n"

                                            echo -e "${WHITE}[4] Fichier de configuration OpenSSL :${NC}"
                                            echo -e "   - Le fichier => ${WHITE}/etc/vault/ssl/vault_tls.cnf${NC} reste en place."
                                            echo -e "   - Permissions restreintes pour éviter un accès non autorisé.\n"

                                            echo -e "${WHITE}[5] Tache Cron pour renouvelemnt du certificat SSL de Vault :${NC}"
                                                                                    
                                            enter

                                            # Suppression .csr
                                            clear
                                            afficher_bienvenue

                                            echo -e "${WHITE}[1] Suppression du CSR :${NC}"
                                            
                                            sudo rm /etc/vault/ssl/vault.csr

                                            if [ -f /etc/vault/ssl/vault.csr ]; then
                                                echo -e "${RED}ERREUR : Lors de la suppression du fichier =>${NC} ${WHITE}/etc/vault/ssl/vault.csr...${NC}"
                                                echo -e "Suite à l'installation de Gcert, veuillez supprimer ce fichier." 
                                                sleep 3
                                            else
                                                echo -e "${GREEN}OK : Suppression réussie.${NC}"
                                                sleep 2
                                            fi

                                            # Chiffrement .key
                                            clear
                                            afficher_bienvenue
                                            echo -e "${WHITE}[2] Chiffrement et permissions de la clé privée : /etc/vault/ssl/vault.key${NC}\n"

                                            echo -e "Utilisation de la GPG créée précédemment."

                                            # Chiffrement de la clé TLS avec GPG
                                            gpg -e -r $KEY_PRIVATE_TLS /etc/vault/ssl/vault.key

                                                # Vérification que le chiffrement a réussi et le fichier existe au bon endroit.
                                                if [ $? -eq 0 ] && [ -f /etc/vault/ssl/vault.key.gpg ]; then
                                                    
                                                    echo -e "${GREEN}OK : le fichier: ${WHITE}/etc/vault/ssl/vault.key${NC} a bien été chiffré.${NC}"
                                                    echo -e "Le fichier vault.key va être supprimé"
                                                    sleep 2
                                                    
                                                    # Suppression
                                                    sudo rm /etc/vault/ssl/vault.key

                                                    # Vérification de la suppression
                                                    if [ -f /etc/vault/ssl/vault.key ]; then
                                                        echo -e "${RED}ERREUR : Lors de la suppression du fichier =>${NC} ${WHITE}/etc/vault/ssl/vault.key...${NC}"
                                                        echo -e "Suite à l'installation de Gcert, veuillez supprimer ce fichier."
                                                        sleep 3
                                                    else
                                                        echo -e "${GREEN}OK : Suppression réussie.${NC}"
                                                        sleep 2
                                                    fi

                                                else
                                                    echo -e "${RED}ERREUR : Le chiffrement GPG a échoué =>${NC} ${WHITE}/etc/vault/ssl/vault.key${NC}"
                                                    echo -e "La clé privée n'a PAS été supprimée par sécurité."
                                                    sleep 3
                                                fi

                                            clear
                                            afficher_bienvenue

                                            echo -e "   - Droits restreints sur la clé chiffrée : chmod 600 ${WHITE}/etc/vault/ssl/vault.key.gpg${NC}."
                                            echo -e "   - Propriétaire et groupe sécurisés : chown vault:vault ${WHITE}/etc/vault/ssl/vault.key.gpg${NC}.\n"

                                        
                                                chmod 600 /etc/vault/ssl/vault.key.gpg
                                                chown vault:vault /etc/vault/ssl/vault.key.gpg

                                                    if [[ $(stat -c "%a" /etc/vault/ssl/vault.key.gpg) == "600" && $(stat -c "%U:%G" /etc/vault/ssl/vault.key.gpg) == "vault:vault" ]]; then
                                                            echo -e "${GREEN}OK : le fichier ${WHITE}/etc/vault/ssl/vault.key.gpg${GREEN} est bien sécurisé.${NC}"

                                                    else
                                                        echo -e "${RED}ERREUR : permissions ou propriétaire incorrects pour ${WHITE}$FILE${NC}"
                                                        echo -e "Suite à l'installation de Gcert, veuillez résoudre ce probléme."
                                                    fi

                                            clear
                                            afficher_bienvenue

                                            echo -e "   - Droits restreints sur le fichier de configuration : chmod 640 ${WHITE}/etc/vault/ssl/vault_tls.cnf${NC}."
                                            echo -e "   - Propriétaire et groupe sécurisés : chown root:vault ${WHITE}/etc/vault/ssl/vault_tls.cnf${NC}.\n"

                                            # Appliquer les droits
                                            chmod 640 /etc/vault/ssl/vault_tls.cnf
                                            chown root:vault /etc/vault/ssl/vault_tls.cnf

                                            # Vérification droit et proprietaire
                                            if [[ $(stat -c "%a" /etc/vault/ssl/vault_tls.cnf) == "640" && $(stat -c "%U:%G" /etc/vault/ssl/vault_tls.cnf) == "root:vault" ]]; then
                                                echo -e "${GREEN}OK : le fichier ${WHITE}/etc/vault/ssl/vault_tls.cnf${GREEN} est bien sécurisé.${NC}"
                                                sleep 2
                                            else
                                                echo -e "${RED}ERREUR : permissions ou propriétaire incorrects pour ${WHITE}/etc/vault/ssl/vault_tls.cnf${NC}"
                                                echo -e "Veuillez vérifier et corriger les droits du fichier."
                                            fi


                                            # === Tache Cron ===
                                            clear
                                            afficher_bienvenue

                                            while true; do
                                                read -p "Voulez-vous créer une tâche cron afin de renouveler automatiquement le certificat de Vault ? (y/n) : " choix_cron
                                                
                                                if [[ "$choix_cron" =~ ^[yY]$ ]]; then
                                                    echo -e "   - Création d'un script de renouvellement automatique du certificat Vault."
                                                    echo -e "   - Met à jour les permissions et redémarre le service Vault.\n"
                                                    
                                                    # Script de renouvellement
                                                    cat > /usr/local/bin/renew_vault_ssl.sh << EOF
#!/bin/bash
openssl req -new -x509 -days $days_vault -key /etc/vault/ssl/vault.key -out /etc/vault/ssl/vault.crt -config /etc/vault/ssl/vault_tls.cnf
chmod 640 /etc/vault/ssl/vault.crt
chown root:vault /etc/vault/ssl/vault.crt
systemctl restart vault
EOF
        
                                                    chmod +x /usr/local/bin/renew_vault_ssl.sh
                                                    
                                                    # Ajouter au cron (renouvellement automatique avant expiration)
                                                    (crontab -l 2>/dev/null | grep -v "renew_vault_ssl.sh"; echo "0 0 */$(($days_vault - 1)) * * /usr/local/bin/renew_vault_ssl.sh") | crontab -
                                                    
                                                    echo -e "${GREEN} Tâche cron configurée avec succès${NC}"
                                                    break
                                                    
                                                elif [[ "$choix_cron" =~ ^[nN]$ ]]; then
                                                    break
                                                    
                                                else
                                                    clear
                                                    afficher_bienvenue
                                                    echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
                                                fi
                                            done



                                        elif [[ "$secu_ssl" =~ ^[nN]$ ]]; then
                                            break


                                        else
                                            clear
                                            afficher_bienvenue
                                            echo -e "${RED}Réponse invalide. Tapez y ou n.${NC}"
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
                                echo -e "${GREEN}[√] Installation et configuration de Vault${NC}"
                                echo -e "[3/5] Création de l'environnement Python...\n" 
                                echo -e "[4/5] Création de la clé GPG et du mot de passe...\n" 
                                echo -e "[5/5] Lancement du service G_Cert...\n\n"
                                
                                while true; do
                                    read -p "Appuyez sur [Entrée] pour continuer : " input

                                    if [[ -z "$input" ]]; then
                                        break
                                    else
                                        echo -e "\n${RED}Erreur : appuyez uniquement sur Entrée.${NC}\n"
                                    fi
                                done
                        
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
                                echo -e "${GREEN}[√] Installation et configuration de Vault${NC}"
                                echo -e "${GREEN}[√] Création de l'environnement Python...${NC}\n" 
                                echo -e "[4/5] Création de la clé GPG et du mot de passe...\n" 
                                echo -e "[5/5] Lancement du service G_Cert...\n\n"
                        
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
                                echo -e "${GREEN}[√] Installation et configuration de Vault${NC}\n"
                                echo -e "[5/5] Lancement du service G_Cert...\n\n"
                            
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
