ARG USER=node
ARG WORKSPACE=/home/$USER/app
ARG DUMB_INIT=/usr/local/bin/dumb-init
ARG DUMB_INIT_URL=https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64

FROM node:16-alpine AS base

ARG WORKSPACE
ARG DUMB_INIT
ARG DUMB_INIT_URL

WORKDIR $WORKSPACE

COPY . $WORKSPACE

# A minimal init system for Linux containers
ADD $DUMB_INIT_URL $DUMB_INIT

RUN chmod +x $DUMB_INIT
RUN npm cache verify && \
    npm install --production --silent --progress=false && \
    npm prune --production

FROM node:16-alpine

ARG USER
ARG WORKSPACE
ARG DUMB_INIT

RUN npm install -g npm@latest

ENV NODE_PATH=.

WORKDIR $WORKSPACE

RUN chown $USER:$USER $WORKSPACE

COPY --chown=$USER:$USER --from=base $WORKSPACE $WORKSPACE
COPY --chown=$USER:$USER --from=base $DUMB_INIT $DUMB_INIT

USER $USER

EXPOSE 3000

ENTRYPOINT [ "dumb-init" ]

CMD [ "npm", "run", "start" ]