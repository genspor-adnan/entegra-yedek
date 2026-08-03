# Hetzner PostgreSQL Test Kurulumu

Amaç: EXE bu bilgisayarda çalışsın, `ekspert` PostgreSQL DB Hetzner Linux server üzerinde olsun.

Önerilen güvenli mimari:

```text
Senin PC -> WireGuard VPN -> Hetzner Linux -> PostgreSQL
```

PostgreSQL `5432` portu internete açılmamalı. Bağlantı sadece VPN üzerinden yapılmalı.

## 1. Hetzner Server

- Ubuntu 24.04 LTS
- CX33
- SSH key ile giriş
- Hetzner Firewall:
  - `22/tcp`: sadece senin public IP
  - `51820/udp`: WireGuard
  - `5432/tcp`: kapalı

## 2. Linux Temel Güvenlik

```bash
apt update && apt upgrade -y
apt install -y ufw fail2ban unattended-upgrades
```

UFW:

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow from SENIN_IP to any port 22 proto tcp
ufw allow 51820/udp
ufw enable
```

## 3. WireGuard

VPN örnek IP planı:

- Server: `10.10.0.1`
- Bu PC: `10.10.0.2`

PostgreSQL bağlantısı bu IP üzerinden yapılacak.

## 4. PostgreSQL

```bash
apt install -y postgresql postgresql-contrib
```

`postgresql.conf`:

```conf
listen_addresses = '10.10.0.1,localhost'
```

`pg_hba.conf`:

```conf
host    ekspert    gentegre    10.10.0.2/32    scram-sha-256
```

DB ve kullanıcı:

```sql
CREATE USER gentegre WITH PASSWORD 'güçlü_şifre';
CREATE DATABASE ekspert OWNER gentegre;
```

Servisi yeniden başlat:

```bash
systemctl restart postgresql
```

## 5. DB Aktarım

Local dump:

```bash
pg_dump -h localhost -p 5433 -U postgres -Fc -d ekspert -f ekspert.dump
```

Hetzner restore:

```bash
pg_restore -h 10.10.0.1 -p 5432 -U gentegre -d ekspert --clean --if-exists ekspert.dump
```

## 6. Delphi Bağlantısı

PG bağlantı bilgisi:

- Server: `10.10.0.1`
- Port: `5432`
- Database: `ekspert`
- User: `gentegre`
- Password: uygulama kullanıcısının şifresi

Delphi tarafı:

- Şifre exe içine gömülmemeli.
- INI kullanılacaksa şifre Windows DPAPI ile şifrelenmeli.
- `LoginTimeout` ve connection timeout verilmeli.
- Remote DB için uzun transaction açık bırakılmamalı.
- Grid/listelerde limitsiz `select *` azaltılmalı.
- Query parametreli kullanılmalı.
- Hata mesajlarında connection string/şifre gösterilmemeli.
- Uygulama `postgres` kullanıcısıyla bağlanmamalı.

## 7. Yedek

Günlük dump için örnek:

```bash
mkdir -p /backup
pg_dump -U postgres -Fc ekspert > /backup/ekspert_$(date +%F).dump
```

Önerilen sıra:

1. Server güvenliği
2. WireGuard
3. PostgreSQL
4. DB restore
5. Delphi bağlantı testi
