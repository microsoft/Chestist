FROM node:14

COPY ./ .

RUN yarn install

EXPOSE 3000

RUN ["chmod", "+x", "startup.sh"]

CMD ["/bin/bash", "startup.sh"]