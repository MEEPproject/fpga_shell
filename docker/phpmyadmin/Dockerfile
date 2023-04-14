FROM phpmyadmin/phpmyadmin

# Create a volume for the config file
VOLUME /etc/phpmyadmin/config.user.inc.php

# Set environment variables for database connection
ENV PMA_HOST=db
ENV PMA_USER=root
ENV PMA_PASSWORD=my-secret-pw

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start the phpMyAdmin server
CMD ["apache2-foreground"]