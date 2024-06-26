# syntax=docker/dockerfile:1.3
FROM --platform=$BUILDPLATFORM node:18-alpine as dev

ARG APP_SHELL_VERSION=next

RUN mkdir -p /app
WORKDIR /app

COPY spa-build-config.json .
COPY config.json .
COPY /assets /app/assets

ARG CACHE_BUST
RUN npm install @swc/core swc-loader --save-dev
RUN npx --legacy-peer-deps openmrs@${APP_SHELL_VERSION:-next} assemble --manifest --mode config --config spa-build-config.json --target ./spa
RUN npx --legacy-peer-deps openmrs@${APP_SHELL_VERSION:-next} build --build-config spa-build-config.json --target ./spa

# Copying required files
RUN echo "Copying required files ..." && \
    cp ./assets/login-icon.svg ./spa && \
    cp ./assets/primary-navigation.png ./spa && \
    cp ./assets/favicon.ico ./spa && \
    cp config.json ./spa

# Check build result
RUN if [ ! -f ./spa/index.html ]; then echo 'Build failed. Please check the logs above for details. This may have happened because of an update to a library that OpenMRS depends on.'; exit 1; fi

# Modify page title
RUN sed -i 's/<title>.*<\/title>/<title>SSEMR<\/title>/' ./spa/index.html

FROM nginx:1.23-alpine

RUN apk update && \
    apk upgrade && \
    # add more utils for sponge to support our startup script
    apk add --no-cache moreutils

# clear any default files installed by nginx
RUN rm -rf /usr/share/nginx/html/*

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

COPY nginx.conf /etc/nginx/nginx.conf

COPY --from=dev /app/spa /usr/share/nginx/html

CMD ["/usr/local/bin/startup.sh"]
