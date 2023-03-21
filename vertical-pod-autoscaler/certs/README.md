#### Create certificates:
```bash
rm -vf ./*.pem ./*.srl ./*.csr && \
openssl genrsa -out ./caKey.pem 2048 && \
openssl genrsa -out ./serverKey.pem 2048 && \
openssl req -x509 -new -nodes -key ./caKey.pem -days 100000 -out ./caCert.pem -subj "/CN=vpa_webhook_ca" -addext "subjectAltName = DNS:vpa_webhook_ca" && \
openssl req -new -key ./serverKey.pem -out ./server.csr -subj "/CN=vpa-webhook.kube-system.svc" -config ./server.conf -addext "subjectAltName = DNS:vpa-webhook.kube-system.svc" && \
openssl x509 -req -in ./server.csr -CA ./caCert.pem -CAkey ./caKey.pem -CAcreateserial -out ./serverCert.pem -days 100000 -extensions SAN -extensions v3_req -extfile ./server.conf
```
