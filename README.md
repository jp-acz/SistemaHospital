# Como ejecutar
codespace > en la terminal:

cd /workspaces/SistemaHospital/Backend

rm -rf node_modules package-lock.json

npm cache clean --force

npm install

docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=unaClav3Segura!" \
  -p 1433:1433 --name sqlserver-hospital -d mcr.microsoft.com/mssql/server:2022-latest

npm start

-----------
tocar en el boton de abrir en el navegador 
