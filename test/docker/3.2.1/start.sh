docker build -t zen3.2.1 .
docker run -i -p 8080:8080 -t zen3.2.1 sh remote_start.sh
