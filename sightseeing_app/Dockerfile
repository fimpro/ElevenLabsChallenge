FROM fischerscode/flutter-sudo:3.24.3 AS builder

WORKDIR /app
RUN git config --global --add safe.directory /home/flutter/flutter-sdk

COPY . .
RUN sudo chown -R flutter:flutter /app
RUN flutter build web --no-tree-shake-icons


FROM caddy:alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /app/build/web/ /usr/share/caddy