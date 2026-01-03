
# 🏗️ Het Ultieme GitOps Homeserver Handboek

Dit document beschrijft hoe je van een lege server naar een volledig geautomatiseerd Push-Model GitOps systeem gaat.

---

## 📖 1. Het Concept in het kort

1. Je werkt lokaal op je laptop op de **`main`** branch.
2. Bij een push naar `main` controleert Gitea je configuratie (Caddyfile).
3. Ben je tevreden? Dan merge je `main` naar de **`server`** branch.
4. Gitea pusht de wijzigingen naar de server, waar de `gitea_runner` gebruiker de containers updatet.

---

## 🛠️ 2. Fase 1: De Server Voorbereiden (Eenmalig handmatig)

Voer deze stappen uit op je Debian server om de omgeving klaar te maken voor de Runner.

### A. Runner-gebruiker en Docker toegang

```bash
sudo adduser gitea_runner
sudo usermod -aG docker gitea_runner

```

### B. SSH-sleutels genereren voor de Runner

```bash
sudo -u gitea_runner ssh-keygen -t ed25519 -f /home/gitea_runner/.ssh/id_ed25519 -N ""
sudo -u gitea_runner cp /home/gitea_runner/.ssh/id_ed25519.pub /home/gitea_runner/.ssh/authorized_keys

```

* **Gitea Secret:** Kopieer de private key (`sudo cat /home/gitea_runner/.ssh/id_ed25519`) naar Gitea onder `Settings > Actions > Secrets > SSH_KEY`.

### C. Sudo rechten zonder wachtwoord

Typ `sudo visudo` en voeg onderaan toe:

```text
gitea_runner ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/git

```

### D. De Repository "Landingsplek" maken

De runner heeft een bestaande map nodig om in te werken.

```bash
sudo mkdir -p /opt/mijn-homelab
sudo chown gitea_runner:gitea_runner /opt/mijn-homelab
cd /opt/mijn-homelab

# Clone de repo als de runner-gebruiker
sudo -u gitea_runner git clone https://jouw-gitea-url.nl/gebruiker/repo.git .

# Maak de server-branch aan (als deze nog niet bestaat in de cloud, push die dan eerst vanaf je laptop!)
sudo -u gitea_runner git checkout server

```

---

## 🤖 3. Fase 2: De Workflows (.gitea/workflows/)

Zorg dat deze bestanden in je repository staan op je laptop en push ze naar `main`.

### `validate.yaml` (De Scheidsrechter)

```yaml
name: "Validatie"
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check Caddy
        run: docker run --rm -v $(pwd)/caddy-full:/etc/caddy caddy:latest caddy validate --adapter caddyfile --config /etc/caddy/Caddyfile

```

### `deploy.yaml` (De Uitvoerder)

```yaml
name: "GitOps Deploy"
on:
  push:
    branches: [server]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Push naar Server
        uses: https://github.com/appleboy/ssh-action@master
        with:
          host: ${{ secrets.SSH_HOST }}
          username: gitea_runner
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/mijn-homelab
            sudo git fetch origin
            sudo git reset --hard origin/server
            find . -maxdepth 2 -name "docker-compose.yml" -o -name "compose.yml" | while read file; do
              dir=$(dirname "$file")
              cd "$dir"
              sudo docker compose up -d --remove-orphans
              cd - > /dev/null
            done

```

---

## 🔄 4. Fase 3: Dagelijks Gebruik (Workflow op je Laptop)

Wanneer je een nieuwe app wilt toevoegen of een instelling wilt wijzigen:

1. **Pas je code aan** in de `main` branch op je laptop.
2. **Commit en Push naar main:**
```bash
git add .
git commit -m "Nieuwe app toegevoegd"
git push origin main

```


3. **Check Gitea:** Kijk of het groene vinkje verschijnt (Validatie geslaagd).
4. **Merge naar Server (Productie):**
```bash
git checkout server
git merge main
git push origin server

```


5. **Klaar:** De server wordt nu automatisch bijgewerkt. Ga weer terug naar je werk-branch:
```bash
git checkout main

```



---

## 🛡️ 5. De `.gitignore`

Zorg dat dit bestand in je root staat om database-vervuiling in Git te voorkomen:

```text
**/data/
**/db/
**/config/
**/logs/
.env
*.db

```

---

## 🆘 Troubleshooting

* **SSH Fail?** Controleer of poort 22 open staat en of het IP in `SSH_HOST` klopt.
* **Docker Compose Fail?** Check de logs in Gitea Actions; vaak is het een typefout in je YAML indentatie.
* **Bestanden niet geüpdatet?** Controleer of `gitea_runner` nog steeds eigenaar is van `/opt/mijn-homelab`.

---

**Tip:** Als je de `server` branch nog niet hebt, maak deze dan nu aan op je laptop met `git checkout -b server` en `git push origin server` voordat je de handmatige clone op de server doet!
