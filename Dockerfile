FROM node:lts as builder

ARG PUBLIC_URL
ENV PUBLIC_URL=$PUBLIC_URL
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

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]
RUN env |grep 'PUBLIC\|REACT\|REDIRECT' > .env

RUN npm run build

FROM nginx:stable-alpine
COPY --from=builder /usr/src/app/build /usr/share/nginx/html
RUN apk add --no-cache bash
RUN sed -i '/index  index.html index.htm/c\        try_files \$uri \$uri/ /index.html;' /etc/nginx/conf.d/default.conf
EXPOSE ${PORT}

CMD ["nginx", "-g", "daemon off;"]

