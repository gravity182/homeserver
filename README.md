# Home Media Server

## Description

This repo will get you your own home server with a lot of useful self-hosted software. This stack is well-built and will serve you reliably.

All of the services are optional (except core ones, Authentik and cert-manager) and can be enabled/disabled anytime. Detailed list:
- Media:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/radarr-light.png"> [Radarr](https://github.com/Radarr/Radarr) - Movies management
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/sonarr.png"> [Sonarr](https://github.com/Sonarr/Sonarr) - TV Series management
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/lidarr.png"> [Lidarr](https://github.com/Lidarr/Lidarr) - Music management
    - <img width="15" height="15" src="https://github.com/Whisparr/Whisparr/blob/develop/Logo/128.png?raw=true"> [Whisparr](https://github.com/Whisparr/Whisparr) - Adult videos management
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/prowlarr.png"> [Prowlarr](https://github.com/Prowlarr/Prowlarr) - Indexers management. Allows you to sync your torrent/usenet indexers across all of the *arr stack
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/bazarr.png"> [Bazarr](https://github.com/morpheus65535/bazarr) - Companion application to Radarr and Sonarr. It manages and downloads subtitles based on your requirements
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/plex.png"> [Plex](https://www.plex.tv/) - Media server for watching downloaded movies and series from any of your devices (PC, Android, iOS, iPad, TV)
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/jellyfin.png"> [Jellyfin](https://github.com/jellyfin/jellyfin) - Open-source alternative to Plex
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/jellyseerr.png"> [Jellyseerr](https://github.com/Fallenbagel/jellyseerr) - Media request platform, which you can share with your friends for automatic movie/series downloading. Companion application to Radarr/Sonarr and Plex/Jellyfin
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/autobrr.png"> [Autobrr](https://github.com/autobrr/autobrr) - Download automation for torrents and Usenet. Monitors indexers' IRC channels and grabs a release as soon as it's announced
- Downloaders:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/qbittorrent.png"> [qBittorrent](https://github.com/qbittorrent/qBittorrent) - Torrent downloader
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/sabnzbd.png"> [SABnzbd](https://github.com/sabnzbd/sabnzbd) - Usenet downloader
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/pinchflat.png"> [Pinchflat](https://github.com/kieraneglin/pinchflat) - YouTube downloader based on yt-dlp
- Books:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/calibre-web.png"> [Calibre-Web Automated](https://github.com/crocodilestick/Calibre-Web-Automated) - Calibre-Web but automated
    - 📚 [Calibre-Web-Automated-Book-Downloader](https://github.com/calibrain/calibre-web-automated-book-downloader) - A web interface for searching and downloading books from Anna's Archive
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/openbooks.png"> [Openbooks](https://github.com/evan-buss/openbooks) - A web interface for searching and downloading books from IRCHighWay
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/kavita.png"> [Kavita](https://github.com/Kareadita/Kavita) - Books reader
- Utilities:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/miniflux-light.png"> [Miniflux](https://github.com/dysosmus/miniflux) - RSS feed reader
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/stirling-pdf.png"> [Stirling PDF](https://github.com/Stirling-Tools/Stirling-PDF) - PDF Manipulation Tool
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/the-lounge.png"> [The Lounge](https://github.com/thelounge/thelounge) - IRC Client
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/convertx.png"> [Convertx](https://github.com/C4illin/ConvertX) - File conversion
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/mealie.png"> [Mealie](https://github.com/mealie-recipes/mealie) - Cooking recipe manager
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/librechat.png"> [Librechat](https://github.com/danny-avila/LibreChat) - Self-hosted ChatGPT clone, supporting multiple local & remote AI providers (Ollama, OpenRouter, OpenAI, Groq, and others)
- Notification:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/apprise.png"> [Apprise](https://github.com/caronc/apprise-api) - Send notifications to many popular services like Telegram, Discord, Slack, Gotify, and others
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/gotify.png"> [Gotify](https://github.com/gotify/server) - Self-hosted push notification service
- Monitoring:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/myspeed.png"> [MySpeed](https://github.com/gnmyt/myspeed) - Speed test tracker. Monitors your download & upload speed over time
- Authentication:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/authentik.png"> [Authentik](https://github.com/goauthentik/authentik) - SSO (Single-Sign On) Authentication. Protects your homeserver from unathenticated access. Allows you to sign in only once and use any of the services without the hassle of remembering a credentials for each service
- Security:
    - <img width="15" height="15" src="https://github.com/cert-manager/cert-manager/blob/master/logo/logo-small.png?raw=true"> [cert-manager](https://github.com/cert-manager/cert-manager) - Automatically provision, manage, and renew TLS certificates
- Backups:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/backrest.png"> [Backrest](https://github.com/garethgeorge/backrest) - a web-accessible backup solution built on top of restic

---

## Features

Chart features:
- Great chart customization - important service settings are controlled through Helm values
- SSO authentication powered by [Authentik](https://github.com/goauthentik/authentik)
- Automatic TLS certificates provisioning powered by [cert-manager](https://github.com/cert-manager/cert-manager)
- Scheduled server backups powered by [Backrest](https://github.com/garethgeorge/backrest)
- VPN support - every service can route its traffic through a WireGuard VPN. This is especially important for such services as qBitTorrent for smooth Linux ISO downloading
- Proper file permissions handling - you will never encounter permission issues
- Follows best security practices - containers are running as a non-root user and with a read-only filesystem

---

## Quickstart / Documentation

Please see [Installation](Installation.md).

---

## TODO

1. Move sensitive values to Kubernetes secrets
2. Add hardware decoding support to Plex & Jellyfin

---

## Credits

I want to thank these amazing resources which I heavily used during the development:
- <https://trash-guides.info>
- <https://wiki.servarr.com>
- a bunch of random questions on r/SelfHosted

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Disclaimer

This code is provided for informational purposes only and should not be used for illegal activities. I am not responsible for any actions performed by the users of this code.
