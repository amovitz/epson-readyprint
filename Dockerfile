FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends mitmproxy ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY epson-readyprint.py /app/epson-readyprint.py

RUN mkdir -p /app/ca

EXPOSE 8080

ENTRYPOINT ["mitmdump", "--set", "confdir=ca", "-s", "epson-readyprint.py", "--listen-port", "8080"]
