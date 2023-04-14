# Instructions

Run, from this directory:

 docker build -t grafana-server . #Note the dot, which is the path to the Dockerfile

 docker run -d --name=grafana-server -p 3000:3000 grafana/grafana; #Grafana container
# Now, grafana can be accessed through the browser, http://localhost:3000

# First login credentials are admin/admin

# You will need to update the credentials
# Go to configuration -> data source -> MySQL
# Get the IP of the data base container:

docker inspect \
  -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_db_name_or_id

# Use the ouput as the host to connect to, with port 3306, by default