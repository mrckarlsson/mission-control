# 🚀 Mission Control – Bloggdashboard

**Mission Control** är ett terminal-baserat kontrollcenter för att övervaka och styra arbetsflödet kring [christiankarlsson.xyz](https://christiankarlsson.xyz). Skriptet samlar data från WordPress, MailPoet, GitHub och lokala Obsidian-filer för att ge en snabb statusuppdatering direkt i terminalen.

## ✨ Funktioner

* **Skrivprojekt:** Listar aktiva artiklar från Obsidian med status, kategori, manusstopp och direktlänkar (`obsidian://`).
* **Idéer:** Slumpar fram sparade ämnen för att motverka skrivkramp.
* **Nyhetsbrev:** Visar prenumeranter (MailPoet & Jetpack) samt statistik för senaste utskicket (öppningsgrad, klick, studsar).
* **Interaktion:** Hämtar röstresultat från CrowdSignal och bekräftar att Metricool-trackern är aktiv.
* **Systemhälsa:** Kontrollerar SSL-status, domänutgångsdatum och laddningstider för anslutna domäner.
* **Utveckling:** Visar senaste GitHub-commit och repo-statistik.

## 🛠 Installation & Setup

### 1. Förutsättningar
Du behöver följande installerat på din maskin:
* `jq` (för JSON-hantering)
* `curl` (för API-anrop)
* `whois` (för domänkoll)
* `openssl` (för SSL-koll)

### 2. Konfiguration
Projektet använder en separat konfigurationsfil för att hålla lösenord säkra.
Skapa filen `config.sh` i projektmappen:

\`\`\`bash
WP_USER="ditt_användarnamn"
RAW_PASS="ditt_app_lösenord"
GH_REPO="användarnamn/repo"
# Se bloggkoll.sh för fullständiga variabler
\`\`\`

**Viktigt:** `config.sh` är exkluderad via `.gitignore` för att inte läcka känslig data till GitHub.

### 3. Kör skriptet
Gör skriptet körbart och kör det:
\`\`\`bash
chmod +x mission-control.sh
./mission-control.sh
\`\`\`

## 📂 Struktur
* `mission-control.sh`: Huvudskriptet (motorn).
* `config.sh`: Lokala inställningar och hemligheter (ignorerad av Git).
* `.gitignore`: Säkerställer att känslig data inte laddas upp.

## 📝 Licens
Detta projekt är skapat för personligt bruk.
