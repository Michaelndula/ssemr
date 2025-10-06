# syntax=docker/dockerfile:1.3
#--------------------------------------------
# Dev Stage - Assembles and Builds Frontend
#--------------------------------------------
FROM --platform=$BUILDPLATFORM node:lts-alpine as dev

ARG APP_SHELL_VERSION=next

RUN mkdir -p /app
WORKDIR /app

RUN echo "//repo.repsy.io/npm/intellisoftdev/ssemr/:_authToken=rdt-7xHrEKenpn_hrmZXRqb827dWwpZinFk1zhcOoaOIikM" > .npmrc && \
    echo "@ssemrapp:registry=https://repo.repsy.io/npm/intellisoftdev/ssemr/" >> .npmrc && \
    echo "registry=https://registry.npmjs.org/" >> .npmrc

COPY spa-assemble-config.json .
COPY spa-build-config.json .
COPY /assets /app/assets

ARG CACHE_BUST
RUN npm install -g npm@latest
RUN npx --legacy-peer-deps openmrs@${APP_SHELL_VERSION:-next} assemble --manifest --mode config --config spa-assemble-config.json --target ./spa
RUN npx --legacy-peer-deps openmrs@${APP_SHELL_VERSION:-next} build --build-config spa-build-config.json --target ./spa

# Copying required files
RUN echo "Copying required files ..." && \
    cp ./assets/login-icon.png ./spa && \
    cp ./assets/primary-navigation.png ./spa && \
    cp ./assets/favicon.ico ./spa && \
    cp spa-build-config.json ./spa

# Check build result
RUN if [ ! -f ./spa/index.html ]; then echo 'Build failed. Please check the logs above for details. This may have happened because of an update to a library that OpenMRS depends on.'; exit 1; fi

# Modify page title
RUN sed -i 's/<title>.*<\/title>/<title>SSEMR<\/title>/' ./spa/index.html

FROM nginx:1.23-alpine

RUN apk update && \
    apk upgrade && \
    # add more utils for sponge and envsubst
    apk add --no-cache moreutils

# clear any default files installed by nginx
RUN rm -rf /usr/share/nginx/html/*

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

COPY nginx.conf /etc/nginx/nginx.conf

COPY --from=dev /app/spa /usr/share/nginx/html
COPY config.json /usr/share/nginx/html

CMD ["/usr/local/bin/startup.sh"]
