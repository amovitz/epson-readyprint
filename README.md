# Epson ReadyPrint service proxy

Have you somehow found yourself with an Epson ReadyPrint printer but no subscription?

This will create a man-in-the-middle proxy and tell the printer it's allowed to print!


## How it works

`mitmproxy` does most of the heavy lifting. At it's core we just replace a couple registration variable booleans to basically set `isTotallyLegitPayingUser=Yes`.

```JSON
"isHalt": true    ->   "isHalt": false
"isOptIn": false  ->   "isOptIn": true
```


## Setup

First clone this repository.

```bash
# Install the dependencies
sudo apt install mitmproxy

# Start the proxy
cd epson-readyprint
bash run-proxy.sh
```

Then set the printer's proxy with your IP address and the port 8080.

Settings > General Settings > Network Settings > Advanced > Proxy


## Service

Since this needs to be running any time the printer checks into epson, it's convenient to install this as a service.

```bash
# Set the service's working directory
cd epson-readyprint
sed -i "s|/opt/epson-readyprint|$(pwd)|g" epson-readyprint-proxy.service

# Enable the service
sudo cp epson-readyprint-proxy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable epson-readyprint-proxy.service
sudo systemctl start epson-readyprint-proxy.service
```


## Docker

Prefer to run it in a docker or pod?

```bash
# Build the container
docker build -t epson-readyprint-proxy .

# Start the service
docker run -d \
  --name epson-readyprint-proxy \
  -p 8080:8080 \
  -v epson-readyprint-ca:/app/ca \
  --restart unless-stopped \
  --replace \
  epson-readyprint-proxy

# View the logs
docker logs -f epson-readyprint-proxy
```


## What else?

That's it. It's one find and replace to defeat this service locked printer.

If you get a warning that's ok - just Python's Cryptography module complaining but it still works.

```bash
/usr/lib/python3/dist-packages/mitmproxy/certs.py:103: CryptographyDeprecationWarning: Properties that return a naïve datetime object have been deprecated. Please switch to not_valid_after_utc.
  return datetime.datetime.utcnow() > self._cert.not_valid_after
Loading script epson-readyprint.py
Proxy server listening at *:8080
192.168.1.58:43298: client connect
192.168.1.58:43298: server connect remote-services-readyprint.epson.biz:443 (18.154.101.13:443)
Response(200, application/json; charset=utf-8, 32b)
192.168.1.58:43298: GET https://remote-services-readyprint.epson.biz/s/date
                 << 200 OK 32b
192.168.1.58:43298: client disconnect
192.168.1.58:43298: server disconnect remote-services-readyprint.epson.biz:443 (18.154.101.13:443)
192.168.1.58:43300: client connect
192.168.1.58:43300: server connect remote-services-readyprint.epson.biz:443 (18.154.101.35:443)
Response(200, application/json; charset=utf-8, 76b)
192.168.1.58:43300: POST https://remote-services-readyprint.epson.biz/s/devices/statuses
                 << 200 OK 76b
192.168.1.58:43300: client disconnect
192.168.1.58:43300: server disconnect remote-services-readyprint.epson.biz:443 (18.154.101.35:443)
192.168.1.58:43302: client connect
192.168.1.58:43302: server connect epsonpfu.ebz.epson.net:443 (23.47.200.125:443)
192.168.1.58:43302: GET https://epsonpfu.ebz.epson.net/FY20_KJ_00/UPDATE.INF
                 << 200 OK 172b
192.168.1.58:43302: server disconnect epsonpfu.ebz.epson.net:443 (23.47.200.125:443)
192.168.1.58:43302: client disconnect
```
