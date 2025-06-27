"""Send a reply from the proxy without sending any data to the remote server."""

from mitmproxy import http


def response(flow: http.HTTPFlow) -> None:
    if "remote-services-readyprint.epson.biz" in flow.request.pretty_url:
        if flow.response and flow.response.content:
            flow.response.content = flow.response.content.replace(
                b'"isHalt": true', b'"isHalt": false'
            ).replace(b'"isOptIn": false', b'"isOptIn": true')
            print(flow.response)
