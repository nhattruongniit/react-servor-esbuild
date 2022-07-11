# Node app
FROM node:18 as build-stage

# Set to a non-root built-in user `node`
USER node

# Create app directory (with user `node`)
RUN mkdir -p /home/node/app

WORKDIR /home/node/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY --chown=node package*.json ./

RUN npm install

# Bundle app source code
COPY --chown=node . .

WORKDIR /home/node/app

RUN npm run build

WORKDIR /home/node/app
# Bundle app source
FROM nginx:alpine

COPY --from=build-stage /home/node/app/public /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/conf.d
EXPOSE 80
CMD cp /usr/share/nginx/html/config/config.js /usr/share/nginx/html/config.js; \
    nginx -g 'daemon off;'
