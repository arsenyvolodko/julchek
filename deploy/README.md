# Деплой julchek.ru

Сайт раздаётся контейнером `julchek` (docker-compose, порт хоста `4400`),
а системный nginx на сервере проксирует домен `julchek.ru` на этот порт.

## 1. DNS

В панели регистратора домена `julchek.ru` создай A-записи на IP сервера:

```
julchek.ru        A   <IP_сервера>
www.julchek.ru    A   <IP_сервера>
```

Подожди, пока записи разъедутся (`ping julchek.ru` должен показывать твой IP).

## 2. Запустить контейнер на сервере

```bash
cd /path/to/julchek
docker compose up -d --build
curl -I http://127.0.0.1:4400      # должно быть HTTP 200
```

## 3. Подключить nginx + получить HTTPS-сертификат

В репозитории лежит готовый конфиг `deploy/julchek.ru.nginx.conf`, но он уже
содержит SSL-блок Certbot. Сертификата ещё нет, поэтому подключаем в два шага.

**Шаг A — временный конфиг только на 80 порту**, чтобы Certbot прошёл проверку:

```bash
sudo tee /etc/nginx/sites-available/julchek.ru >/dev/null <<'EOF'
server {
    listen 80;
    server_name julchek.ru www.julchek.ru;

    location / {
        proxy_pass http://127.0.0.1:4400;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/julchek.ru /etc/nginx/sites-enabled/julchek.ru
sudo nginx -t && sudo systemctl reload nginx
```

**Шаг B — выпустить сертификат и включить HTTPS** (Certbot сам перепишет конфиг,
добавит 443-блок и редирект с 80 — получится то же, что в `julchek.ru.nginx.conf`):

```bash
sudo certbot --nginx -d julchek.ru -d www.julchek.ru
sudo nginx -t && sudo systemctl reload nginx
```

Открой https://julchek.ru — должен открыться сайт.

> Альтернатива: если сертификат уже выпущен, можно сразу положить
> `deploy/julchek.ru.nginx.conf` в `/etc/nginx/sites-available/julchek.ru`
> и сделать symlink — он уже в финальном виде.

## Обновление сайта

После изменений в коде или папке `photos/`:

```bash
docker compose up -d --build
```

Системный nginx трогать не нужно.
