FROM node:lts-alpine as builder

ARG PUBLIC_URL
ENV PUBLIC_URL=$PUBLIC_URL
ARG HOST
ENV HOST=$HOST
ARG PORT
ENV PORT=$PORT
ARG REACT_APP_BEE_HOSTS
ENV REACT_APP_BEE_HOSTS=$REACT_APP_BEE_HOSTS
ARG REACT_APP_GATEWAY_URL
ENV REACT_APP_GATEWAY_URL=$REACT_APP_GATEWAY_URL
ARG DIRECT_DOWNLOAD_URL
ENV DIRECT_DOWNLOAD_URL=$DIRECT_DOWNLOAD_URL

WORKDIR /usr/src/app

COPY ["package.json", "package-lock.json*", "./"]

RUN npm ci
COPY . .
RUN npm run build

RUN echo $PUBLIC_URL >> .env && \
    echo $HOST >> .env  &&\
    echo $PORT >> .env  &&\
    echo $REACT_APP_BEE_HOSTS >> .env  &&\
    echo $REACT_APP_GATEWAY_URL >> .env  &&\
    echo $RDIRECT_DOWNLOAD_URL >> .env

FROM nginx:stable-alpine
COPY --from=builder /usr/src/app/build /usr/share/nginx/html
RUN apk add --no-cache bash
RUN sed -i '/index  index.html index.htm/c\        try_files \$uri \$uri/ /index.html;' /etc/nginx/conf.d/default.conf
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

