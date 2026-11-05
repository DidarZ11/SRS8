FROM node:20-alpine
WORKDIR /app
RUN npm install -g json-server@0.17.4
COPY db.json /app/seed/db.json
COPY middleware.js /app/middleware.js
EXPOSE 3000
# При каждом старте контейнера база сбрасывается к исходным данным.
CMD cp /app/seed/db.json /app/db.json && \
    json-server /app/db.json --host 0.0.0.0 --port 3000 --delay ${API_DELAY_MS:-400} \
      --middlewares /app/middleware.js
