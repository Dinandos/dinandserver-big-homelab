# New version
# 🔒 Veilige Script Download uit Privé Repository

Dit document beschrijft hoe je het `script.sh` bestand direct kunt downloaden en uitvoeren vanaf de `main` branch van deze **privé** repository op een nieuwe Linux machine (zoals een Proxmox LXC), **zonder** de repository openbaar te maken.

Dit proces vereist een **GitHub Personal Access Token (PAT)** met `repo`-leesrechten.

---

## 🛠️ Vereiste: Personal Access Token (PAT)

Je hebt een **GitHub Personal Access Token (PAT)** nodig die bevoegd is om privé-inhoud te lezen.

1.  **Genereer een PAT:** Ga naar [GitHub Settings -> Developer settings -> Personal access tokens (classic)](https://github.com/settings/tokens).
2.  **Toestemmingen:** Zorg ervoor dat de **`repo`** scope is aangevinkt (dit geeft leestoegang tot alle privé repositories).
3.  **Kopieer het Token:** Sla de gegenereerde token **veilig** op. Je zult het later niet meer zien.

---

## 🚀 De Command-reeks

Gebruik de volgende command-reeks in je Linux machine. Dit vervangt `wget` door `curl` om de authenticatieheader met je PAT mee te sturen.

> **⚠️ Let op:** Vervang `JOUW_PAT` door de daadwerkelijke token die je hebt aangemaakt.

```bash
# 1. Stel de variabele in (vervang JOUW_PAT)
PAT="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" 

# 2. Definieer de URL van het raw script
# (Controleer of de ref en path correct zijn voor dit script)
RAW_URL="[https://raw.githubusercontent.com/Dinandos/dinandserver-big-homelab/refs/heads/main/scripts/script.sh](https://raw.githubusercontent.com/Dinandos/dinandserver-big-homelab/refs/heads/main/scripts/script.sh)"

# 3. Download het script met curl en authenticatie
# -L volgt redirects, -H voegt de authenticatieheader toe, -o slaat op als script.sh
curl -L -H "Authorization: token $PAT" $RAW_URL -o script.sh

# 4. Maak het uitvoerbaar en start het script
chmod +x ./script.sh && ./script.sh
```

---
# Old versions
## One-Commandline (all)
`wget -L https://raw.githubusercontent.com/Dinandos/dinandserver-big-homelab/refs/heads/main/scripts/script.sh && chmod +x ./script.sh && ./script.sh`

## One-Commandline (with choices)
#### For all tasks to be executed
`wget -L https://raw.githubusercontent.com/Dinandos/dinandserver-big-homelab/refs/heads/main/scripts/choice-script.sh && chmod +x ./choice-script.sh && ./choice-script.sh -a`