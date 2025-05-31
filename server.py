import http.server
import socketserver

PORT = 8000
IP = "192.168.137.1"

Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer((IP, PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()

