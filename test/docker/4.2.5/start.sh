docker build -t zen4.2.5 .
docker run -i -p 8080:8080 -t zen4.2.5 sh remote_start.sh
