@echo off
:: Changez le chemin ci-dessous pour pointer vers l'emplacement de votre script Bash sous WSL
wsl bash -c "./fullPostgresql.sh"

:: Pause pour empêcher la fermeture immédiate de la fenêtre
:: pause

::Success. You can now start the database server using:
::  
::    pg_ctlcluster 12 main start