from setuptools import setup, find_packages

setup(
    name="gcert",
    version="0.1.0",
    py_modules=["main"],
    packages=find_packages(),
    install_requires=[
        "pyfiglet",
        "psutil",
        "cryptography",
        "python-nmap",
        "termcolor",
        "colorlog"
    ],
    entry_points={
    "console_scripts": [
        "gcert=main:cli",
    ],
    },
    python_requires=">=3.10",
    author="Landès Martin",
    description="Gestionnaire de certificats SSL",
)
