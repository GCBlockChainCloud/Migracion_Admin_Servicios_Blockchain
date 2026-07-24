FROM node:20-alpine AS dependencies

WORKDIR /app

COPY package.json ./
RUN npm install

COPY hardhat.config.js server.js ./
COPY scripts ./scripts

FROM dependencies AS v1
ENV APP_VERSION=1.0.0
COPY contracts-v1 ./contracts
RUN npm run compile
EXPOSE 8000
CMD ["npm", "run", "serve"]

FROM dependencies AS v2
ENV APP_VERSION=2.0.0
COPY contracts-v2 ./contracts
RUN npm run compile
EXPOSE 8000
CMD ["npm", "run", "serve"]
