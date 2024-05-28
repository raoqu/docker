#/bin/sh
docker container stop web_server && docker container rm web_server
docker image rm web_server
docker buildx build . -t web_server
   
    