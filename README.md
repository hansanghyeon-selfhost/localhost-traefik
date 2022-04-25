## Local https

```
brew install mkcert
```

mkcert를 첫 설치하였다면 아래 명령어를 실행하십시오.

```
mkcert -install
```

도메인 "*.lan" 도메인에 대한 인증서 생성 (와일드카드)

```
mkcert -cert-file config/traefik/certs/local-cert.pem -key-file config/traefik/certs/local-key.pem "*.lan"
```

traefik 동적 구성으로 추가

```
tls:
  certificates:
    - certFile: "/etc/certs/local-cert.pem"
      keyFile: "/etc/certs/local-key.pem"
```

traefik 라우터, 서비스에 적용

```
services:
  app:
    labels:
      - traefik.http.routers.{service}.tls=true
```

## Local Development with Wildcard DNS

### Dnsmasq

Dnsmasq는 로컬에서 실행할 수 있는 아주 작고 인기 있는 DNS 서버이며 아주 적은 구성으로 와일드 카드 도메인을 지원합니다.

```
brew install dnsmasq
```

이제 구성 디렉토리를 설정

> `*.dev` 개발을 위해 및 `*.local` 도메인을 피하십시오 `.dev`는 ICANN 루트에 실제 TLD로 존재합니다. `*.local`은 macOS Bonjour 서비스에서 사용됩니다. `*.lan`을 사용하는것은 어떤가요?

```
mkdir -pv $(brew --prefix)/etc/

cat >$(brew --prefix)/etc/dnsmasq.conf <<<EOD
# 여기에 IP 주소에 강제 적용하려는 도메인을 추가합니다.
# 아래 예는 *.lan에 있는 모든 호스트를 로컬로 보냅니다.
address=/lan/127.0.0.1

# /etc/resolv.conf 또는 기타 구성 파일을 읽지 마십시오.
no-resolv
# 일반 이름을 전달하지 마십시오(점 또는 도메인 부분 제외).
domain-needed
# 라우팅되지 않은 주소 공간에서 주소를 전달하지 마십시오.
bogus-priv
EOD
```

그런 다음 지금 구성을 `launched` 시작 하고 시작시 다시 시작합니다.

```
sudo brew services start dnsmasq
```

마지막으로 다음을 실행 `dnsmasq`하여 서버가 모든 하위 도메인에 응답하도록 구성되었는지 확인합니다.

```
dig test.lan @127.0.0.1
```

<img width="1011" alt="스크린샷 2022-04-25 오전 9 17 33" src="https://user-images.githubusercontent.com/42893446/165003060-0b7f5e10-dfec-40cd-a24d-6c48f8b088ec.png">


### Integration using `/etc/resolver`

이 시점에서 DNS 서버가 작동하지만 macOS는 도메인 확인에 DNS 서버를 사용하지 않기 떄문에 의미가 없습니다.

`/etc/resolver`에 구성파일을 추가하여 이를 변경할 수 있습니다.

```
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/lan'
```

`dnsmasq`에 구성한 도메인은 `/etc/resolver`에 추가해야합니다.

```
scutil --dns

...
resolver #8
  domain   : lan
  nameserver[0] : 127.0.0.1
  flags    : Request A records, Request AAAA records
  reach    : 0x00030002 (Reachable,Local Address,Directly Reachable Address)
...

```

### Final

새 구성을 테스트하는 것은 쉽습니다. ping 확인을 사용하여 이제 로컬 하위 도메인을 확인할 수 있습니다.

```
ping -c1 www.google.com
```

이 구성은 특히 마이크로서비스 개발자에게 유용합니다. 오케스트레이션 플랫폼은 호스트 이름을 동적으로 생성할 수 있으므로 `/etc/hosts` 파일에 대해 다시 걱정할 필요가 없습니다.
