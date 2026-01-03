
# 🏗️ Homeserver GitOps & Automatisering Handboek

In deze repository kan je alles vinden en soort van backups voor mijn homeserver. Iedereen mag dit gebruiken, maar voor de meeste heeft dit allemaal geen nut. Want de configuatie geldt alleen op mijn situatie's zoals "volumes"
Dit document bevat de volledige blauwdruk van de server-architectuur. Het systeem is gebaseerd op het **GitOps Push-Model**, waarbij Gitea de "Source of Truth" is en wijzigingen automatisch naar de server worden uitgerold via een beveiligde runner-account.

---

## 📖 1. Het Concept

* **Geen handmatige acties:** Je logt niet meer in op de server via SSH om containers te starten. Alles gebeurt via `git push`.
* **Beveiligde Runner:** We gebruiken een aparte Debian-gebruiker (`gitea_runner`) met beperkte rechten voor de uitvoering.
* **Branch-beveiliging:**
* `main` / `ontwikkel`: Hier test je code. Validatie-workflows controleren je Caddyfile, maar de server blijft ongewijzigd.
* `server`: De productie-branch. Alleen pushes naar deze branch triggeren de daadwerkelijke uitrol naar de hardware.



---

## 📁 2. Mappenstructuur

Houd je repository georganiseerd volgens **Optie B (Losse mappen)**. Docker Compose wordt in elke submap apart aangeroepen.

```text
/ (Root van de Repo)
├── .gitea/workflows/       # Alle automatisering (.yaml bestanden)
├── caddy-full/             # Caddy configuratie
│   ├── Caddyfile           # Het bestand dat gevalideerd wordt
│   └── docker-compose.yml
├── app-1-authentik/        # Voorbeeld app map
│   └── docker-compose.yml
├── app-2-plex/             # Voorbeeld app map
│   └── docker-compose.yml
├── .gitignore              # Voorkomt dat data/logs in Git komen
└── README.md               # Dit handboek

```

---

## 🛠️ 3. Eenmalige Server Setup (Stap-voor-stap)

### A. De Runner-gebruiker aanmaken

Maak een geïsoleerd profiel aan voor de automatisering:

```bash
sudo adduser gitea_runner
sudo usermod -aG docker gitea_runner

```

### B. SSH-Sleutels genereren

Genereer een sleutelpaar zonder wachtwoord voor de runner:

```bash
sudo -u gitea_runner ssh-keygen -t ed25519 -f /home/gitea_runner/.ssh/id_ed25519
sudo -u gitea_runner cp /home/gitea_runner/.ssh/id_ed25519.pub /home/gitea_runner/.ssh/authorized_keys
sudo -u gitea_runner chmod 600 /home/gitea_runner/.ssh/authorized_keys

```

* **Actie:** Kopieer de private key (`sudo cat /home/gitea_runner/.ssh/id_ed25519`) naar Gitea Secrets als `SSH_KEY`.

### C. Sudo-rechten configureren

Zorg dat de runner Docker en Git kan gebruiken zonder om een wachtwoord te vragen.

1. Typ: `sudo visudo`
2. Voeg onderaan toe:

```text
gitea_runner ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/git

```

---

## 🤖 4. De Workflows (.gitea/workflows/)

Zorg dat deze drie bestanden in je repo staan:

### I. `validate.yaml` (Caddy Check)

Deze draait op **elke branch** om typefouten in je Caddyfile te vangen.

```yaml
name: "6. Caddy Validation"
on: [push]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate Caddyfile
        run: |
          docker run --rm \
            -v $(pwd)/caddy-full:/etc/caddy \
            caddy:latest caddy validate --adapter caddyfile --config /etc/caddy/Caddyfile

```

### II. `deploy.yaml` (Het Push Model)

Draait **alleen** op de `server` branch.

```yaml
name: "GitOps Deploy"
on:
  push:
    branches: [server]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH naar Server
        uses: https://github.com/appleboy/ssh-action@master
        with:
          host: ${{ secrets.SSH_HOST }}
          username: gitea_runner
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/jouw-repo-map
            sudo git fetch origin
            sudo git reset --hard origin/server
            # Zoek alle compose files en start ze
            find . -maxdepth 2 -name "docker-compose.yml" -o -name "compose.yml" | while read file; do
              dir=$(dirname "$file")
              cd "$dir"
              sudo docker compose up -d --remove-orphans
              cd - > /dev/null
            done

```

### III. `maintenance.yaml` (Schoonmaak & SSL)

Draait wekelijks op de achtergrond.

```yaml
name: "1 & 4. Maintenance"
on:
  schedule:
    - cron: '0 4 * * 0'
jobs:
  maintenance:
    runs-on: ubuntu-latest
    steps:
      - uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SSH_HOST }}
          username: gitea_runner
          key: ${{ secrets.SSH_KEY }}
          script: |
            sudo docker system prune -af
            curl -vI https://jouw-domein.nl 2>&1 | grep "expire date"

```

---

## 🛡️ 5. De `.gitignore` (Cruciaal)

Plaats dit bestand in de root van je repo. Het voorkomt dat je server-specifieke databasebestanden of logs naar Gitea pusht (wat je repo traag maakt en wachtwoorden kan lekken).

```text
# Negeer alle data mappen van containers
**/data/
**/db/
**/database/
**/config/
**/logs/

# Negeer omgevingsvariabelen met wachtwoorden
.env
*.env

# Negeer OS specifieke rommel
.DS_Store

```

---

## 🔄 6. Werkwijze (Hoe gebruik je dit?)

1. **Nieuwe App:** Maak een map aan (bijv. `uptimekuma`), zet je `docker-compose.yml` erin.
2. **Caddy Aanpassen:** Bewerk `/caddy-full/Caddyfile` om de nieuwe app bereikbaar te maken.
3. **Push naar Main:** `git push origin main`.
* *De Caddyfile wordt gecontroleerd. Als er een fout in zit, zie je een rood kruisje in Gitea.*


4. **Live zetten:** Merge je code naar de `server` branch.
* *Zodra de push op `server` binnenkomt, springt de runner aan, logt in op de server, doet een `git pull` en start de nieuwe container op.*



---

## 🆘 7. Probleemoplossing (Troubleshooting)

* **Caddy Validatie Faalt:** Check je haakjes `{ }` en paden in de `Caddyfile`. De Gitea Action log vertelt je precies op welke regel de fout zit.
* **Permission Denied op server:** Check of `gitea_runner` eigenaar is van de map in `/opt/`: `sudo chown -R gitea_runner:gitea_runner /opt/repo-naam`.
* **Sudo vraagt wachtwoord:** Controleer je `visudo` instellingen uit stap 3C.

---

**Succes met je geautomatiseerde Homelab!**