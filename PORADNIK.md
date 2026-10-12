# Poradnik GitHub i Docker — Windows / PowerShell

## 1. Gdzie są projekty

Dokładne ścieżki zawiera [INWENTARYZACJA.md](INWENTARYZACJA.md). Oryginały w Documents/Codex z 23 września, 25 września i 2 października nadal zasilają kontenery. Przygotowane repozytoria znajdują się obok tego indeksu w katalogu outputs z 12 października. To osobne kopie: zmiana jednej nie aktualizuje automatycznie drugiej ani działającego obrazu Docker.

Docelowe repozytoria HMpower1: temp-mail, velin-whiteboard, voidnas, serwerbb-backend, server-infra, projects-index. Prywatne repozytoria zostały utworzone i sprawdzone; poniższe polecenia wymagają dostępu zalogowanego właściciela. Obecny stan publikacji sprawdź w RAPORT.md; prywatność i push potwierdzono przez API.

## 2. Narzędzia i dostęp

Zainstaluj Git i Docker Desktop. Docker powinien korzystać z kontenerów Linux. W PowerShell sprawdź:

```powershell
git --version
docker version
docker compose version
node --version
```

Node.js musi mieć co najmniej 22.13. Dla VoidNAS i Velin używamy pnpm 11.19.0; dla Temp Mail npm. Compose z plikami `!override` wymaga wersji 2.24.4+. Python 3.13 potrzebny jest tylko do backendu uruchamianego poza Dockerem.

Logowanie do GitHub w ChatGPT nie oznacza automatycznego zalogowania Git ani GitHub CLI. Nie wysyłaj mi tokenu. Możesz uruchomić pobrany i zweryfikowany program bez pliku .ps1 i bez zmiany polityki PowerShell:

```powershell
& 'C:\Users\hmpow\Documents\Codex\2026-10-12\uporz-dkuj-i-umie-na-github\work\tools\cli\bin\gh.exe' auth login --hostname github.com --git-protocol https --web
```

Jeśli masz własny GitHub CLI:

```powershell
gh auth login --hostname github.com --git-protocol https --web
gh auth status
```

Użyj konta HMpower1. Nie dodawaj tokenu do adresu remote, skryptu ani .env.example. Nie wybieraj publicznej widoczności.

## 3. Klonowanie i uruchamianie

Po publikacji wybierz nowy, pusty katalog, np. C:\Projekty:

```powershell
New-Item -ItemType Directory -Path C:\Projekty -Force
Set-Location C:\Projekty
git clone https://github.com/HMpower1/velin-whiteboard.git
Set-Location .\velin-whiteboard
node scripts/init-env.mjs
```

Generator Velin odmawia nadpisania istniejącego .env. W nowym .env ustaw APP_URL, AUTH_URL i NEXT_PUBLIC_APP_URL na http://localhost:8091 oraz NEXT_PUBLIC_WS_URL na ws://localhost:8091/ws. Następnie:

```powershell
docker compose -p velin-dev -f docker-compose.yml -f docker-compose.local.yml config --quiet
docker compose -p velin-dev -f docker-compose.yml -f docker-compose.local.yml up -d --build
docker compose -p velin-dev -f docker-compose.yml -f docker-compose.local.yml ps
```

Otwórz http://localhost:8091. Na tym komputerze działa podgląd Velin, który może zajmować ten port; wybierz wolny port i dostosuj oba pliki konfiguracyjne oraz URL. Nie uruchamiaj komendy na oryginalnym katalogu produkcji bez planu wdrożenia.

Dla VoidNAS:

```powershell
Set-Location C:\Projekty
git clone https://github.com/HMpower1/voidnas.git
Set-Location .\voidnas
if (!(Test-Path .env)) { Copy-Item .env.example .env }
# Uzupełnij .env według README.md; nie używaj pustych sekretów.
docker compose -p voidnas-dev -f docker-compose.yml -f docker-compose.local.yml config --quiet
docker compose -p voidnas-dev -f docker-compose.yml -f docker-compose.local.yml up -d --build
```

Domyślny lokalny adres: http://localhost:8090. Może być zajęty przez oryginalne wdrożenie. STORAGE_HOST_PATH musi wskazywać osobny katalog danych testowych, a nie istniejący NAS. Osobna nazwa Compose rozdziela wolumeny, ale sama nie rozdziela bind mountów, portów ani zewnętrznych sieci.

Dla Temp Mail:

```powershell
Set-Location C:\Projekty
git clone https://github.com/HMpower1/temp-mail.git
Set-Location .\temp-mail
npm ci
npm ci --prefix server
npm test
npm run lint
npm run typecheck
npm run build
if (!(Test-Path deploy/.env)) { Copy-Item deploy/.env.example deploy/.env }
# Uzupełnij konfigurację poczty i bazy w deploy/.env.
docker compose --env-file deploy/.env -p temp-mail-dev -f deploy/compose.home.yaml config --quiet
docker compose --env-file deploy/.env -p temp-mail-dev -f deploy/compose.home.yaml up -d --build
```

Compose domowy zakłada istniejącą bramę Caddy, sieć caddy_default i domenę. Bez bramy możesz uruchomić sam frontend komendą `npm run dev` (http://localhost:5173), ale pełny odbiór poczty wymaga skonfigurowanego serwera i DNS/Mailgun. Alias temp-mail-web współdzielony z produkcją może powodować konflikt routingu; nie włączaj kopii do sieci produkcyjnej bez dostosowania aliasów. deploy/Dockerfile.web korzysta z wcześniej wygenerowanego `.next/standalone`, dlatego `npm run build` jest konieczny przed budową obrazu. Baza poczty używa tmpfs i jest nietrwała. Nie uruchamiaj testowych webhooków na produkcji.

Dla backendu:

```powershell
Set-Location C:\Projekty
git clone https://github.com/HMpower1/serwerbb-backend.git
Set-Location .\serwerbb-backend
docker build -t serwerbb-backend:dev .
docker run --rm -p 127.0.0.1:18081:8080 --tmpfs /data:uid=65534,gid=65534,mode=0700 serwerbb-backend:dev
```

Testowe dane z tmpfs znikną po zamknięciu. Oryginalny compose.yaml jest związany z sieciami caddy_default i voidnas_public oraz konkretnymi nazwami kontenerów.

Infrastruktura stron:

```powershell
Set-Location C:\Projekty
git clone https://github.com/HMpower1/server-infra.git
Set-Location .\server-infra
node --test tests/*.test.mjs
docker compose -f portfolio/compose.yaml config --quiet
docker compose -f strona/compose.yaml config --quiet
docker compose -f caddy/compose.yaml config --quiet
```

To konfiguracja istniejącego serwera, a nie gotowe izolowane środowisko developerskie. Caddy używa portów 80/443, domen i zewnętrznych sieci, także integracji z pominiętym Nextcloud. Nie restartuj go na ślepo. DDNS korzysta z lokalnego pliku `ddns/secrets/cloudflare_api_token.txt`; token ma minimalne uprawnienia do właściwej strefy DNS i pozostaje poza Git. Backend klonuje się osobno; jego compose uruchamiaj w jego katalogu, a nie przez brakujący server-infra/backend.

## 4. Bezpieczny .env

.env.example opisuje nazwy i przykładowe ustawienia. .env przechowuje lokalne wartości. Używaj niezależnych kluczy dla sesji, CSRF, usług i baz. Sekrety można generować lokalnie bez drukowania wartości:

```powershell
$secretBytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($secretBytes)
$newSecret = -join ($secretBytes | ForEach-Object { $_.ToString('x2') })
# Wstaw $newSecret do lokalnego .env, bez wypisywania go i bez komendy git add.
$rng.Dispose()
```

Nie zmieniaj hasła istniejącego PostgreSQL samą edycją POSTGRES_PASSWORD: istniejący wolumen zachowuje poprzednie hasło i wymaga kontrolowanej zmiany w bazie. DATABASE_URL musi zgadzać się z konfiguracją bazy. Zmiana kluczy sesji może wylogować użytkowników. Prefiksy NEXT_PUBLIC_ oraz VITE_ oznaczają wartości trafiające do przeglądarki: nigdy nie wkładaj tam prywatnych kluczy.

```powershell
git check-ignore .env
git ls-files .env
git ls-files -ci --exclude-standard
```

Jeśli .env jest śledzony, .gitignore nie usuwa go z Git. Wycofaj tylko śledzenie przez `git rm --cached -- .env`, pozostawiając plik na dysku, dopiero po przeglądzie staged diff. Jeśli sekret był w commicie, samo usunięcie pliku nie czyści historii.

## 5. Codzienna praca

Najpierw sprawdź repo i zmiany; dodawaj konkretne pliki:

```powershell
git status --short
git diff
git add -- README.md
git diff --cached --stat
git diff --cached
git commit -m "docs: popraw instrukcję uruchomienia"
git pull --ff-only
git push
```

Diff może pokazać sekret, jeżeli go przypadkiem wpisałeś — oglądaj lokalnie i nie kopiuj do czatu. Przed commitem i push użyj lokalnego Gitleaks z pełną redakcją. `pull --ff-only` odmówi rozbieżnej historii; wtedy przerwij i rozwiąż rozbieżność na branchu. Nie używaj force push, reset --hard ani masowego add bez przeglądu. Commit obejmuje wyłącznie staged pliki, push wysyła także wszystkie osiągalne wcześniejsze commity.

## 6. Branche i pull requesty

```powershell
git switch main
git pull --ff-only
git switch -c feature/opis-zmiany
# Zmień kod i wykonaj testy odpowiednie dla projektu.
git add -- src/plik.ts
git diff --cached
git commit -m "feat: opisz faktyczną zmianę"
git push -u origin feature/opis-zmiany
gh pr create --base main --title "Opis zmiany" --body "Co zmieniono i jakie kontrole wykonano"
```

Plik src/plik.ts to przykład: użyj rzeczywistej ścieżki ze swojego repo. Poczekaj na CI, przejrzyj diff i dopiero potem scal. Workflow nie używa sekretów i nie uruchamia pull_request_target. Nie dodawaj poświadczeń do testów.

## 7. Wersje, tagi i wydania

Obecna wersja głównych projektów to 0.1.0, przygotowana jako prerelease. temp-mail/server ma własną istniejącą wersję 1.0.0 — zachowano ją. Nie nadpisuj istniejących tagów. Po faktycznej poprawce przykładowe kolejne wydanie:

```powershell
git switch -c release/0.1.1
# Uaktualnij VERSION, odpowiedni package.json i CHANGELOG.md.
# Zachowaj lock przez właściwy manager, bez mieszania npm z pnpm.
git add -- VERSION package.json CHANGELOG.md
git commit -m "chore: przygotuj wersję 0.1.1"
# Przeprowadź review/PR i kontrole, scal, następnie:
git switch main
git pull --ff-only
git tag -a v0.1.1 -m "0.1.1: opisz faktyczne zmiany"
git push origin main
git push origin v0.1.1
gh release create v0.1.1 --verify-tag --prerelease --title "0.1.1" --notes-file RELEASE_NOTES.md
```

Backend i indeks nie mają package.json; dodawaj tylko istniejące pliki. Dla aplikacji z package-lock.json użyj npm, dla pnpm-lock.yaml — pnpm. Odśwież plik lock po zmianie wersji. W RELEASE_NOTES.md opisz konkretne zmiany, ograniczenia i wyniki kontroli. Tag to znacznik commita; GitHub Release to opis wydania powiązany z tagiem. Nie oznaczaj 1.0.0 bez zweryfikowanej stabilności.

## 8. Bezpieczny powrót do wcześniejszej wersji

Do obejrzenia starego kodu bez naruszenia bieżącego katalogu:

```powershell
git worktree add --detach ..\velin-0.1.0 v0.1.0
```

Do cofnięcia błędnego commita z zachowaniem historii:

```powershell
git status
git switch -c fix/cofniecie
git log --oneline -10
# Zastąp <SHA> wybranym identyfikatorem; nawiasów nie wpisuj.
git revert <SHA>
git push -u origin fix/cofniecie
```

Nie cofaj migracji bazy przez samą zmianę kodu. Przywrócenie wdrożenia wymaga zgodnego obrazu, konfiguracji i backupu danych. Najpierw wykonaj backup i test odtwarzania w odrębnych wolumenach. Nigdy nie używaj `docker compose down -v` do aktualizacji lub cofnięcia produkcji — usuwa wolumeny.

## 9. Czego nie wysyłać

Nie wysyłaj .env, haseł, tokenów Cloudflare/Mailgun, prywatnych kluczy, cookie i sesji, baz, kontaktów, poczty, zawartości NAS, backupów, prywatnych danych S3, logów z danymi osobowymi ani zrzutów produkcji. node_modules, .next, dist, build, cache i raporty są odtwarzalne. Źródła, potrzebne publiczne zasoby, migracje oraz pliki lock należy zachować. Prywatne repo nadal wymaga ochrony sekretów.

## 10. Ujawnienie klucza

Najpierw unieważnij ujawniony klucz u dostawcy i utwórz nowy z minimalnymi uprawnieniami. Zaktualizuj lokalną konfigurację i sprawdź logi dostępu. Zatrzymaj push projektu. Ustal plik, commit i zakres ekspozycji, nie kopiuj wartości sekretu. Usunięcie z ostatniego commita nie wystarcza, jeżeli klucz pozostał w historii, PR, logu lub cache. Przygotuj plan usunięcia z całej historii, kopii i klonów, skonsultuj go z właścicielem i uzyskaj zgodę przed przepisaniem historii. W tym zadaniu nie wolno stosować force push; ewentualne odzyskanie wymaga osobno uzgodnionej procedury z GitHub Support. Nigdy nie zakładaj, że samo prywatne repo unieważnia wyciek.

## 11. Git nie zastępuje backupu

Repo przechowuje kod i jego historię. Nie przechowuje wykluczonych danych, .env, wolumenów Docker, bazy użytkowników, NAS ani obiektów S3. Potrzebujesz oddzielnego, szyfrowanego backupu konfiguracji i danych, kopii poza komputerem oraz sprawdzonego odtwarzania. Temp Mail celowo korzysta z nietrwałej poczty — nie dorabiaj backupu treści bez świadomej zmiany polityki.

## 12. Zabezpieczenia GitHub

Po publikacji zweryfikuj `visibility=private`, SHA gałęzi i tagu oraz wynik Actions. Włącz dostępne Dependabot alerts, security updates i ochronę głównej gałęzi. Ochrona prywatnych repo i Secret Protection mogą zależeć od planu konta; status ustal z odpowiedzi API lub ustawień, nie z samej obecności YAML. Nie kupuj dodatków ani nie włączaj wersji próbnej bez decyzji właściciela. Lokalny Gitleaks i workflow pozostają potrzebne niezależnie od płatnych funkcji. Aktualny stan aktywacji jest zapisany w RAPORT.md.

## Gałęzie i prywatne repozytoria

Temp Mail zachowuje istniejącą gałąź master; w poleceniach PR, pull, tag/push użyj master zamiast main. Pozostałe repozytoria używają main. Przygotowane kopie mają dodatkowy remote github; Temp Mail zachowuje także origin wskazujący źródło lokalnego klonu. Upstream ustawiono na github. Nowy klon z GitHub ma standardowy remote origin. Aby Git w PowerShell korzystał z zalogowanego CLI, uruchom gh auth setup-git.
