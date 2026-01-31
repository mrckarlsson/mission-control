# 🚀 Mission Control – Bloggdashboard

**Mission Control** är ett terminal-baserat kontrollcenter för att övervaka och styra arbetsflödet kring [christiankarlsson.xyz](https://christiankarlsson.xyz). 

> **Min Mission:** Från skyddsombud till politisk röst. Jag ägnar min tid åt det fackliga samtalet, arbetsmiljön och att belysa vardagen för dem som bygger landet. Genom analys och opinionsbildning överbryggar jag klyftan mellan stad och land.

## ✨ Funktioner
* **Skrivprojekt:** Listar aktiva artiklar från Obsidian med status, deadline och direktlänkar.
* **Nyhetsbrev:** Visar statistik för MailPoet-listor och senaste utskicket.
* **Webbhälsa:** Kontrollerar SSL-status och svarstider för anslutna domäner.
* **Säkerhet:** Alla commits i detta repo är GPG-signerade för verifierat ursprung.

## 🛠 Installation & Setup

### 1. Förutsättningar
Du behöver följande installerat:
* `jq`, `curl`, `whois`, `openssl`

### 2. Konfiguration
Projektet använder en separat konfigurationsfil för att hålla dina hemligheter säkra.

1. Kopiera mallen:
   \`\`\`bash
   cp config.sh.example config.sh
   \`\`\`
2. Öppna `config.sh` och fyll i dina uppgifter:
   \`\`\`bash
   nano config.sh
   \`\`\`

**Viktigt:** `config.sh` laddas aldrig upp till GitHub då den ingår i projektets `.gitignore`.

### 3. Kör skriptet
Gör skriptet körbart och starta dashboarden:
\`\`\`bash
chmod +x mission-control.sh
./mission-control.sh
\`\`\`

## 📂 Filstruktur
* `mission-control.sh`: Huvudmotorn för dashboarden.
* `config.sh.example`: Mall för inställningar (laddas upp).
* `config.sh`: Din lokala, hemliga konfiguration (ignorerad).
* `.gitignore`: Skyddar dina API-nycklar och lösenord.

## 📝 Licens
Detta projekt är skapat för personligt bruk och opinionsbildning.
