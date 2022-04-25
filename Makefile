include .env
export

certs:
	cd ./config/traefik/certs && rm -r *.pem
	cd ./config/traefik/certs && mkcert -key-file imtest.me-key.pem -cert-file imtest.me.pem imtest.me *.imtest.me
	cd ./config/traefik/certs && mkcert -key-file imlocal.me-key.pem -cert-file imlocal.me.pem imlocal.me *.imlocal.me
	cd ./config/traefik/certs && mkcert -key-file lan-key.pem -cert-file lan-cert.pem traefik.lan local.lan *.local.lan
	mkcert -install