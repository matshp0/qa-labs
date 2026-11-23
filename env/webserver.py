#!/usr/bin/env python3
"""Мінімальний HTTP/1.1 веб-сервер "роутера" для лабораторної 6: UTF-8 сторінка, gzip за Accept-Encoding, keep-alive."""
import gzip
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PAGE = ("<html><head><title>Router</title></head><body><h1>Роутер PC1</h1>"
        "<p>Привіт від веб-сервера PC1! Це тестова сторінка для лабораторної роботи №6.</p></body></html>\n").encode("utf-8")


class H(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"          # дозволяє keep-alive: кілька запитів в одному TCP-з'єднанні

    def do_GET(self):
        body, headers = PAGE, {"Content-Type": "text/html; charset=utf-8"}
        if "gzip" in self.headers.get("Accept-Encoding", ""):
            body = gzip.compress(body); headers["Content-Encoding"] = "gzip"
        self.send_response(200)
        for k, v in headers.items():
            self.send_header(k, v)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Connection", "keep-alive")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *a):
        pass


ThreadingHTTPServer(("10.0.0.1", 80), H).serve_forever()
