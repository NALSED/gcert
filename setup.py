from setuptools import setup, find_packages
    
"""Ce fichier setup.py, gére l'implémentation de la doc et du fichier json dans gcert, ainsi qu'un entrypoint
"""

setup(
    name="gcert",
    version="0.1.0",
    py_modules=["main"],
    # Recherche automatique des packages (dossiers contenant __init__.py)
    packages=find_packages(),
    package_data={
    "my_package": [
        "script/doc.md",
        "script/auth_config.json"
    ],
    },
    include_package_data=True,
    # Python pipx installation
    install_requires=[
        "pyfiglet",     # Affichage ASCII
        "psutil",       # Informations système
        "cryptography", # Gestion de la cryptographie
        "python-nmap",  # Scan de ports
        "termcolor",    # Couleurs dans le terminal
        "colorlog",     # Logs colorés
        "tabulate",     # Tableaux formatés
        "rich"          # Rich text = Doc.md
    ],
    # Création d'une commande CLI
    entry_points={
        "console_scripts": [
            "gcert=main:cli", # Tapez `gcert` pour lancer la fonction cli() dans main.py
        ],
    },
    python_requires=">=3.10",
    author="Landès Martin",
    description="Gestionnaire de certificats SSL",
)