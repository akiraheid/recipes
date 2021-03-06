FROM node:10-alpine

RUN apk add --no-cache python make g++

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app

EXPOSE 3000
CMD ["node", "app.js"]

COPY --chown=node:node package*.json ./

USER node
ENV NODE_ENV production
RUN npm ci

COPY --chown=node:node . .
