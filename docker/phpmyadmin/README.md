# Run:
docker run --name mk-phpmyadmin -v phpmyadmin-volume:/etc/phpmyadmin/config.user.inc.php --link mysql-server:db -p 82:80 -d my-phpmyadmin

The --link option is used to create a network link between two containers in Docker, allowing them to communicate with each other.

Docker will automatically set up the necessary network configuration to allow the two containers to communicate with each other. The --link option creates a network link named db between the mk-phpmyadmin and mysql-server containers.