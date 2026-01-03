### Commands voor basis auth
`docker exec -it caddy-full caddy hash-password --plaintext 'wachtwoord'`

### Config Options
Kies 1 van de onderstaande configs voor de *handlers*.

#### Optie 1: IP adressen
``` handle @media {
        handle /radarr* { reverse_proxy 192.168.178.100:7878 }
        handle /sonarr* { reverse_proxy 192.168.178.100:8989 }
        handle /bazarr* { reverse_proxy 192.168.178.100:6767 }
        handle /prowlarr* { reverse_proxy 192.168.178.100:9696 }
        handle { reverse_proxy 192.168.178.100:8096 }
    }

    handle @codeserver { reverse_proxy 192.168.178.100:8680 }
    handle @seafile { reverse_proxy 192.168.178.100:8082 }
    handle @authentik { reverse_proxy 192.168.178.100:9000 }
    handle @docmost { reverse_proxy 192.168.178.100:3000 }
    handle @gitea { reverse_proxy 192.168.178.100:3001 }
```

#### Optie 2: Container voor de services (proxy netwerk)
``` handle @media {
        handle /radarr* { reverse_proxy radarr:7878 }
        handle /sonarr* { reverse_proxy sonarr:8989 }
        handle /bazarr* { reverse_proxy bazarr:6767 }
        handle /prowlarr* { reverse_proxy prowlarr:9696 }
        handle { reverse_proxy emby:8096 }
    }
    
    handle @codeserver { reverse_proxy codeserver:8680 }
    handle @seafile { reverse_proxy seafile:8082 }
    handle @authentik { reverse_proxy authentik:9000 }
    handle @docmost { reverse_proxy docmost:3000 }
    handle @gitea { reverse_proxy gitea:3001 }
```