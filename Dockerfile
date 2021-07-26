# bullion

# Extend from the official Elixir image
FROM elixir:latest

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY ./bullion /app
WORKDIR /app

# Install hex package manager
# By using --force, we don’t need to type “Y” to confirm the installation
RUN mix local.hex --force

ARG secret_key
ENV SECRET_KEY_BASE=${secret_key}

ARG mix_env
ENV MIX_ENV=${mix_env} 

RUN mix local.rebar --force
ARG deps_postfix
RUN mix deps.get ${deps_postfix}

RUN npm run deploy --prefix ./assets
RUN mix do compile

RUN mix phx.digest

CMD mix phx.server
