# Use the official MySQL 8.0.20 image as the base image
FROM mysql/mysql-server:8.0.20

# Set the root password
ENV MYSQL_ROOT_PASSWORD=123

# Expose port 3306
EXPOSE 3306/tcp

# Create a volume for storing the MySQL data
VOLUME /var/lib/mysql

# Start the MySQL server
CMD ["mysqld"]

# Set the entrypoint to start the MySQL client
# ENTRYPOINT ["mysql", "-u", "root", "-p"]
