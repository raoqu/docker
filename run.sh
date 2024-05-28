docker container stop web_server && docker container rm web_server
docker run -d --name web_server  \
    -p 3306:3306 -p 6379:6379 -p 5001:5000 -v ~/mylab/webapps:/opt/tomcat1/webapps \
    -it web_server:latest