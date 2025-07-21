FROM node:22.15.1-alpine3.20

RUN mkdir -p /app
WORKDIR /app

COPY . .

RUN npm install

CMD [ "npm", "start" ]