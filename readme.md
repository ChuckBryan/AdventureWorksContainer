### Repository Description

This Docker container image provides a Microsoft SQL Server 2017 environment with the preloaded AdventureWorksLT2017 sample database. It leverages a two-stage build process: 

1. **Build Stage**: In the first stage, the SQL Server instance is started, and a provided backup file (`AdventureWorksLT2017.bak`) is restored using a SQL script (`restore-backup.sql`).

2. **Release Stage**: In the second stage, a clean SQL Server 2017 image is used, and the restored database files are copied from the build stage to create a slim and ready-to-use image.
### AdventureWorks Backup File
The backup file used is the AdventureWorksLT2017.bak file, a sample database provided by Microsoft. Currently, the backup file is available for download at
https://github.com/microsoft/sql-server-samples/releases/tag/adventureworks. Other versions of the database are available and this sample could be modified to use them.

The download-adventureworks.ps1 script was used to download the backup file:
```powershell
$url = "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2017.bak"
$outputPath = "AdventureWorksLT2017.bak"

Invoke-WebRequest -Uri $url -OutFile $outputPath

Write-Host "Download completed. File saved to $outputPath"
```
It can be executed from a PowerShell Prompt: `.\download-adventureworks.ps1`
### Restore Backup Sql
This command was copied saved to a file called restore-backup.sql:
```sql
RESTORE DATABASE [AdventureWorks] FROM  DISK = '/tmp/AdventureWorksLT2017.bak' 
        WITH  FILE = 1
        ,  MOVE 'AdventureWorksLt2012_Data' TO '/var/opt/mssql/data/AdventureWorks.mdf'
        ,  MOVE 'AdventureWorksLt2012_Log' TO '/var/opt/mssql/data/AdventureWorks.ldf'
        ,  NOUNLOAD,  REPLACE,  STATS = 5
GO
```
#### Dockerfile
The dockerfile was a multi-stage file. The first stage was used to restore the backup file. The second stage was used to copy the restored files to a clean SQL Server 2017 image.
```dockerfile
FROM mcr.microsoft.com/mssql/server:2017-latest as build
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=Pwd12345!

WORKDIR /tmp
COPY AdventureWorksLT2017.bak .
COPY restore-backup.sql .

RUN /opt/mssql/bin/sqlservr --accept-eula & sleep 10 \
    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Pwd12345!" -i /tmp/restore-backup.sql \
    && pkill sqlservr

FROM mcr.microsoft.com/mssql/server:2017-latest as release
ENV ACCEPT_EULA=Y
COPY --from=build /var/opt/mssql/data /var/opt/mssql/data
```
### How to Use
1. **Pull the Image**:
```
docker pull <your-docker-hub-username>/<image-name>:<tag>
```
2. **Run the Container**:
```
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourPassword" -p 1433:1433 <your-docker-hub-username>/<image-name>:<tag>
```
3. **Connect to the Database**: Once the container is running, you can connect to SQL Server using tools like SQL Server Management Studio or Azure Data Studio, using the following credentials:
   - Server: `localhost,1433` or your Docker host IP
   - Login: `SA`
   - Password: The password you specified in the `docker run` command
