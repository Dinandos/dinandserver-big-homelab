# Gitea & Gitea Runner met Docker Compose

Deze setup bevat zowel de **Gitea** server als de **Gitea Runner (act_runner)** om CI/CD (Gitea Actions) mogelijk te maken binnen je eigen infrastructuur.

## 🛠️ Voorbereiding

Voordat je de containers opstart, moet je de volgende mappen aanmaken op je host-systeem om data persistentie te garanderen:

```bash
mkdir -p /opt/gitea/runner/data

```

## 📝 Configuratie

### 1. Activeren van Actions in Gitea

Zorg ervoor dat Actions zijn ingeschakeld in je Gitea-configuratie (`app.ini`). Als je Gitea voor het eerst installeert, kun je dit later toevoegen aan `/opt/gitea/gitea/conf/app.ini`:

```ini
[actions]
ENABLED = true

```

### 2. Omgevingsvariabelen (.env)

Maak een bestand aan genaamd `.env` in dezelfde map als je `docker-compose.yml` en vul je gegevens in:

```env
INSTANCE_URL=http://gitea:3000
REGISTRATION_TOKEN=JE_TOKEN_HIER
RUNNER_NAME=gitea-runner
RUNNER_LABELS=ubuntu-latest:docker://node:16-bullseye,debian-latest:docker://debian:bullseye

```

> **Tip:** Je vindt de `REGISTRATION_TOKEN` in Gitea onder:
> *Site Administration -> Actions -> Runners -> Registration Token*

---

## 🚀 Docker Compose

Gebruik het onderstaande bestand (`docker-compose.yml`):

```yaml
services:
  gitea:
    image: gitea/gitea:latest
    container_name: gitea
    restart: unless-stopped
    ports:
      - 3001:3000 # Web GUI
      - 2221:22   # SSH
    volumes:
      - /opt/gitea:/data
    networks:
      - proxy

  runner:
    image: gitea/act_runner:latest
    container_name: gitea_runner
    restart: unless-stopped
    depends_on:
      - gitea
    environment:
      - GITEA_INSTANCE_URL=${INSTANCE_URL}
      - GITEA_RUNNER_REGISTRATION_TOKEN=${REGISTRATION_TOKEN}
      - GITEA_RUNNER_NAME=${RUNNER_NAME}
      - GITEA_RUNNER_LABELS=${RUNNER_LABELS}
    volumes:
      - /opt/gitea/runner/data:/data
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - proxy

networks:
  proxy:
    external: true

```

---

## 🏗️ Installatie stappen

1. **Netwerk aanmaken:** Zorg dat het externe netwerk bestaat:
```bash
docker network create proxy

```


2. **Containers starten:**
```bash
docker compose up -d

```


3. **Verificatie:**
Controleer in het Gitea beheerderspaneel of de runner als "Idle" (groen) verschijnt.

## ⚠️ Belangrijke opmerkingen

* **Docker Socket:** De runner koppelt `/var/run/docker.sock`. Dit geeft de runner permissies om Docker containers op te starten op je host. Gebruik dit alleen in vertrouwde omgevingen.
* **Netwerk:** Omdat beide containers in het `proxy` netwerk zitten, kan de runner de server bereiken via de interne DNS-naam `http://gitea:3000`.
