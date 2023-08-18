# Use SQL Server 2017 as the base image
FROM mcr.microsoft.com/mssql/server:2017-latest as build

# Set environment variables
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=Pwd12345!

# Set the working directory
WORKDIR /tmp

# Copy the backup and the SQL script
COPY AdventureWorksLT2017.bak .
COPY restore-backup.sql .

# Restore the database
RUN /opt/mssql/bin/sqlservr --accept-eula & sleep 10 \
    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $SA_PASSWORD -i /tmp/restore-backup.sql \
    && pkill sqlservr

# Create the release image
FROM mcr.microsoft.com/mssql/server:2017-latest as release

# Copy the database files from the build stage
COPY --from=build /var/opt/mssql/data /var/opt/mssql/data
