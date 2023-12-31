FROM alpine:3.16

# configure supervisord
RUN apk add --update supervisor openjdk17-jdk parallel nginx nodejs npm git maven && rm  -rf /tmp/* /var/cache/apk/*
ADD supervisord.conf /etc/

#configure bytebin
RUN mkdir /opt/bytebin
ADD https://ci.lucko.me/job/bytebin/lastSuccessfulBuild/artifact/target/bytebin.jar /opt/bytebin
ADD services/bytebin/config.json /opt/bytebin/config.json
ADD services/bytebin/bytebin-service.conf /etc/supervisor/conf.d/bytebin-service.conf

#configure bytesocks
RUN mkdir /opt/bytesocks
RUN git clone --recursive https://github.com/lucko/bytesocks.git /tmp/bytesocks
RUN cd /tmp/bytesocks && mvn --no-transfer-progress -B package && cp /tmp/bytesocks/target/bytesocks*.jar /opt/bytesocks/bytesocks.jar && rm -rf /tmp/bytesocks
ADD services/bytesocks/config.json /opt/bytesocks/config.json
ADD services/bytesocks/bytesocks-service.conf /etc/supervisor/conf.d/bytesocks-service.conf

#configure nginx
ADD services/nginx/nginx-service.conf /etc/supervisor/conf.d/nginx-service.conf
ADD services/nginx/nginx.conf /etc/nginx/http.d/web.conf

#configure luckperms web
RUN git clone --recursive https://github.com/lucko/LuckPermsWeb.git /opt/LuckPermsWeb && rm -rf /opt/LuckPermsWeb/config.json
ADD services/luckpermsweb/config.json /opt/LuckPermsWeb/config.json
RUN mkdir -p /opt/web && cd /opt/LuckPermsWeb && npm install && npm run build && cp -r dist/* /opt/web && rm -rf /opt/LuckPermsWeb

RUN apk del nodejs npm git maven && rm  -rf /tmp/* /var/cache/apk/*

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
