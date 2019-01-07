FROM alpine:latest as builder
RUN apk update && apk upgrade && apk add --no-cache \
  make \
  g++ \
  python \
  nodejs \
  yarn
WORKDIR /tmp/catapult-rest
COPY ./catapult-sdk ./catapult-sdk
COPY ./rest ./rest
RUN cd catapult-sdk && yarn install && yarn build && yarn install --prod
RUN cd rest && yarn install && yarn build && yarn install --prod
RUN yarn cache clean
RUN rm -rf catapult-sdk/test/ catapult-sdk/src/
RUN rm -rf rest/test/ rest/src/

FROM alpine:latest as runner
RUN apk update && apk upgrade && apk add --no-cache \
  nodejs
COPY --from=builder /tmp/catapult-rest /opt/catapult-rest
WORKDIR /opt/catapult-rest/rest
CMD ["ash","-c","node _build/index.js resources/rest.json /userconfig/rest.json"]
