FROM node:12

ADD . /piloto_s3s
WORKDIR /piloto_s3s


RUN yarn add global yarn \
&& yarn install \
&& yarn cache clean


EXPOSE 8080

CMD ["yarn", "start"]
