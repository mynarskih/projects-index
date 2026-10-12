# Poradnik GitHub i Docker â€” Windows / PowerShell

## 1. Gdzie sÄ… projekty

DokĹ‚adne Ĺ›cieĹĽki zawiera [INWENTARYZACJA.md](INWENTARYZACJA.md). OryginaĹ‚y w Documents/Codex z 23 wrzeĹ›nia, 25 wrzeĹ›nia i 2 paĹşdziernika nadal zasilajÄ… kontenery. Przygotowane repozytoria znajdujÄ… siÄ™ obok tego indeksu w katalogu outputs z 12 paĹşdziernika. To osobne kopie: zmiana jednej nie aktualizuje automatycznie drugiej ani dziaĹ‚ajÄ…cego obrazu Docker.

Docelowe repozytoria HMpower1: temp-mail, velin-whiteboard, voidnas, serwerbb-backend, server-infra, projects-index. PoniĹĽsze polecenia klonowania zadziaĹ‚ajÄ… dopiero po potwierdzonym utworzeniu prywatnych repozytoriĂłw. Obecny stan publikacji sprawdĹş w RAPORT.md; adresy nie sÄ… dowodem wykonania push.

## 2. NarzÄ™dzia i dostÄ™p

Zainstaluj Git i Docker Desktop. Docker powinien korzystaÄ‡ z kontenerĂłw Linux. W PowerShell sprawdĹş:

```powershell
git --version
docker version
docker compose version
node --version
```

Node.js musi mieÄ‡ co najmniej 22.13. Dla VoidNAS i Velin uĹĽywamy pnpm 11.19.0; dla Temp Mail npm. Compose z plikami `!override` wymaga wersji 2.24.4+. Python 3.13 potrzebny jest tylko do backendu uruchamianego poza Dockerem.

Logowanie do GitHub w ChatGPT nie oznacza automatycznego zalogowania Git ani GitHub CLI. Nie wysyĹ‚aj mi tokenu. W tym katalogu jest LOGOWANIE.ps1 uruchamiajÄ…cy pobrany, zweryfikowany GitHub CLI; sam wykonaj logowanie w przeglÄ…darce:

```powershell
.\LOGOWANIE.ps1
```

JeĹ›li masz wĹ‚asny GitHub CLI:

```powershell
gh auth login --hostname github.com --git-protocol https --web
gh auth status
```

UĹĽyj konta HMpower1. Nie dodawaj tokenu do adresu remote, skryptu ani .env.example. Nie wybieraj publicznej widocznoĹ›ci.

## 3. Klonowanie i uruchamianie

Po publikacji wybierz nowy, pusty katalog, np. C:\Projekty:

```powershell
New-Item -ItemType Directory -Path C:\Projekty -Force
Set-Location C:\Projekty
git clone https://github.com/HMpower1/velin-whiteboard.git
Set-Location .\velin-whiteboard
node scripts/init-env.mjs
```

Generator Velin odmawia nadpisania istniejÄ…cego .env. W nowym .env ustaw APP_URL, AUTH_URL i NEXT_PUBLIC_APP_URL na http://localhost:8091 oraz NEXT_PUBLIC_WS_URL na ws://localhost:8091/ws. NastÄ™pnie:

```powershell
docker compose -p velin-dev -f docker-compose.yml -f docker-compose.local.yml config --quiet
docker compose -p velin-dev -f docker-compose.yml -f docker-compose.local.yml up -d --build
docker compose -p velin-dev -f docker-compose.yml -f docker-compose.local.yml ps
```

OtwĂłrz http://localhost:8091. Na tym komputerze dziaĹ‚a podglÄ…d Velin, ktĂłry moĹĽe zajmowaÄ‡ ten port; wybierz wolny port i dostosuj oba pliki konfiguracyjne oraz URL. Nie uruchamiaj komendy na oryginalnym katalogu produkcji bez planu wdroĹĽenia.

Dla VoidNAS:

```powershell
Set-Location C:\Projekty
git clone https://github.com/HMpower1/voidnas.git
Set-Location .\voidnas
if (!(Test-Path .env)) { Copy-Item .env.example .env }
# UzupeĹ‚nij .env wedĹ‚ug README.md; nie uĹĽywaj pustych sekretĂłw.
docker compose -p voidnas-dev -f docker-compose.yml -f docker-compose.local.yml config --quiet
docker compose -p voidnas-dev -f docker-compose.yml -f docker-compose.local.yml up -d --build
```

DomyĹ›lny lokalny adres: http://localhost:8090. MoĹĽe byÄ‡ zajÄ™ty przez oryginalne wdroĹĽenie. STORAGE_HOST_PATH musi wskazywaÄ‡ osobny katalog danych testowych, a nie istniejÄ…cy NAS. Osobna nazwa Compose rozdziela wolumeny, ale sama nie rozdziela bind mountĂłw, portĂłw ani zewnÄ™trznych sieci.

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
# UzupeĹ‚nij konfiguracjÄ™ poczty i bazy w deploy/.env.
docker compose --env-file deploy/.env -p temp-mail-dev -f deploy/compose.home.yaml config --quiet
docker compose --env-file deploy/.env -p temp-mail-dev -f deploy/compose.home.yaml up -d --build
```

Compose domowy zakĹ‚ada istniejÄ…cÄ… bramÄ™ Caddy, sieÄ‡ caddy_default i domenÄ™. Bez bramy moĹĽesz uruchomiÄ‡ sam frontend komendÄ… `npm run dev` (http://localhost:5173), ale peĹ‚ny odbiĂłr poczty wymaga skonfigurowanego serwera i DNS/Mailgun. Alias temp-mail-web wspĂłĹ‚dzielony z produkcjÄ… moĹĽe powodowaÄ‡ konflikt routingu; nie wĹ‚Ä…czaj kopii do sieci produkcyjnej bez dostosowania aliasĂłw. deploy/Dockerfile.web korzysta z wczeĹ›niej wygenerowanego `.next/standalone`, dlatego `npm run build` jest konieczny przed budowÄ… obrazu. Baza poczty uĹĽywa tmpfs i jest nietrwaĹ‚a. Nie uruchamiaj testowych webhookĂłw na produkcji.

Dla backendu:

```powershell
Set-Location C:\Projekty
git clone https://github.com/HMpower1/serwerbb-backend.git
Set-Location .\serwerbb-backend
docker build -t serwerbb-backend:dev .
docker run --rm -p 127.0.0.1:18081:8080 --tmpfs /data:uid=65534,gid=65534,mode=0700 serwerbb-backend:dev
```

Testowe dane z tmpfs zniknÄ… po zamkniÄ™ciu. Oryginalny compose.yaml jest zwiÄ…zany z sieciami caddy_default i voidnas_public oraz konkretnymi nazwami kontenerĂłw.

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

To konfiguracja istniejÄ…cego serwera, a nie gotowe izolowane Ĺ›rodowisko developerskie. Caddy uĹĽywa portĂłw 80/443, domen i zewnÄ™trznych sieci, takĹĽe integracji z pominiÄ™tym Nextcloud. Nie restartuj go na Ĺ›lepo. DDNS korzysta z lokalnego pliku `ddns/secrets/cloudflare_api_token.txt`; token ma minimalne uprawnienia do wĹ‚aĹ›ciwej strefy DNS i pozostaje poza Git. Backend klonuje siÄ™ osobno; jego compose uruchamiaj w jego katalogu, a nie przez brakujÄ…cy server-infra/backend.

## 4. Bezpieczny .env

.env.example opisuje nazwy i przykĹ‚adowe ustawienia. .env przechowuje lokalne wartoĹ›ci. UĹĽywaj niezaleĹĽnych kluczy dla sesji, CSRF, usĹ‚ug i baz. Sekrety moĹĽna generowaÄ‡ lokalnie bez drukowania wartoĹ›ci:

```powershell
$secretBytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($secretBytes)
$newSecret = -join ($secretBytes | ForEach-Object { $_.ToString('x2') })
# Wstaw $newSecret do lokalnego .env, bez wypisywania go i bez komendy git add.
$rng.Dispose()
```

Nie zmieniaj hasĹ‚a istniejÄ…cego PostgreSQL samÄ… edycjÄ… POSTGRES_PASSWORD: istniejÄ…cy wolumen zachowuje poprzednie hasĹ‚o i wymaga kontrolowanej zmiany w bazie. DATABASE_URL musi zgadzaÄ‡ siÄ™ z konfiguracjÄ… bazy. Zmiana kluczy sesji moĹĽe wylogowaÄ‡ uĹĽytkownikĂłw. Prefiksy NEXT_PUBLIC_ oraz VITE_ oznaczajÄ… wartoĹ›ci trafiajÄ…ce do przeglÄ…darki: nigdy nie wkĹ‚adaj tam prywatnych kluczy.

```powershell
git check-ignore .env
git ls-files .env
git ls-files -ci --exclude-standard
```

JeĹ›li .env jest Ĺ›ledzony, .gitignore nie usuwa go z Git. Wycofaj tylko Ĺ›ledzenie przez `git rm --cached -- .env`, pozostawiajÄ…c plik na dysku, dopiero po przeglÄ…dzie staged diff. JeĹ›li sekret byĹ‚ w commicie, samo usuniÄ™cie pliku nie czyĹ›ci historii.

## 5. Codzienna praca

Najpierw sprawdĹş repo i zmiany; dodawaj konkretne pliki:

```powershell
git status --short
git diff
git add -- README.md
git diff --cached --stat
git diff --cached
git commit -m "docs: popraw instrukcjÄ™ uruchomienia"
git pull --ff-only
git push
```

Diff moĹĽe pokazaÄ‡ sekret, jeĹĽeli go przypadkiem wpisaĹ‚eĹ› â€” oglÄ…daj lokalnie i nie kopiuj do czatu. Przed commitem i push uĹĽyj lokalnego Gitleaks z peĹ‚nÄ… redakcjÄ…. `pull --ff-only` odmĂłwi rozbieĹĽnej historii; wtedy przerwij i rozwiÄ…ĹĽ rozbieĹĽnoĹ›Ä‡ na branchu. Nie uĹĽywaj force push, reset --hard ani masowego add bez przeglÄ…du. Commit obejmuje wyĹ‚Ä…cznie staged pliki, push wysyĹ‚a takĹĽe wszystkie osiÄ…galne wczeĹ›niejsze commity.

## 6. Branche i pull requesty

```powershell
git switch main # Temp Mail zachowuje istniejącą gałąź master: użyj git switch master
git pull --ff-only
git switch -c feature/opis-zmiany
# ZmieĹ„ kod i wykonaj testy odpowiednie dla projektu.
git add -- src/plik.ts
git diff --cached
git commit -m "feat: opisz faktycznÄ… zmianÄ™"
git push -u origin feature/opis-zmiany
gh pr create --base main --title "Opis zmiany" --body "Co zmieniono i jakie kontrole wykonano"
```

Plik src/plik.ts to przykĹ‚ad: uĹĽyj rzeczywistej Ĺ›cieĹĽki ze swojego repo. Poczekaj na CI, przejrzyj diff i dopiero potem scal. Workflow nie uĹĽywa sekretĂłw i nie uruchamia pull_request_target. Nie dodawaj poĹ›wiadczeĹ„ do testĂłw.

## 7. Wersje, tagi i wydania

Obecna wersja gĹ‚Ăłwnych projektĂłw to 0.1.0, przygotowana jako prerelease. temp-mail/server ma wĹ‚asnÄ… istniejÄ…cÄ… wersjÄ™ 1.0.0 â€” zachowano jÄ…. Nie nadpisuj istniejÄ…cych tagĂłw. Po faktycznej poprawce przykĹ‚adowe kolejne wydanie:

```powershell
git switch -c release/0.1.1
# Uaktualnij VERSION, odpowiedni package.json i CHANGELOG.md.
# Zachowaj lock przez wĹ‚aĹ›ciwy manager, bez mieszania npm z pnpm.
git add -- VERSION package.json CHANGELOG.md
git commit -m "chore: przygotuj wersjÄ™ 0.1.1"
# PrzeprowadĹş review/PR i kontrole, scal, nastÄ™pnie:
git switch main # Temp Mail zachowuje istniejącą gałąź master: użyj git switch master
git pull --ff-only
git tag -a v0.1.1 -m "0.1.1: opisz faktyczne zmiany"
git push origin main
git push origin v0.1.1
gh release create v0.1.1 --verify-tag --prerelease --title "0.1.1" --notes-file RELEASE_NOTES.md
```

Backend i indeks nie majÄ… package.json; dodawaj tylko istniejÄ…ce pliki. Dla aplikacji z package-lock.json uĹĽyj npm, dla pnpm-lock.yaml â€” pnpm. OdĹ›wieĹĽ plik lock po zmianie wersji. W RELEASE_NOTES.md opisz konkretne zmiany, ograniczenia i wyniki kontroli. Tag to znacznik commita; GitHub Release to opis wydania powiÄ…zany z tagiem. Nie oznaczaj 1.0.0 bez zweryfikowanej stabilnoĹ›ci.

## 8. Bezpieczny powrĂłt do wczeĹ›niejszej wersji

Do obejrzenia starego kodu bez naruszenia bieĹĽÄ…cego katalogu:

```powershell
git worktree add --detach ..\velin-0.1.0 v0.1.0
```

Do cofniÄ™cia bĹ‚Ä™dnego commita z zachowaniem historii:

```powershell
git status
git switch -c fix/cofniecie
git log --oneline -10
# ZastÄ…p <SHA> wybranym identyfikatorem; nawiasĂłw nie wpisuj.
git revert <SHA>
git push -u origin fix/cofniecie
```

Nie cofaj migracji bazy przez samÄ… zmianÄ™ kodu. PrzywrĂłcenie wdroĹĽenia wymaga zgodnego obrazu, konfiguracji i backupu danych. Najpierw wykonaj backup i test odtwarzania w odrÄ™bnych wolumenach. Nigdy nie uĹĽywaj `docker compose down -v` do aktualizacji lub cofniÄ™cia produkcji â€” usuwa wolumeny.

## 9. Czego nie wysyĹ‚aÄ‡

Nie wysyĹ‚aj .env, haseĹ‚, tokenĂłw Cloudflare/Mailgun, prywatnych kluczy, cookie i sesji, baz, kontaktĂłw, poczty, zawartoĹ›ci NAS, backupĂłw, prywatnych danych S3, logĂłw z danymi osobowymi ani zrzutĂłw produkcji. node_modules, .next, dist, build, cache i raporty sÄ… odtwarzalne. ĹąrĂłdĹ‚a, potrzebne publiczne zasoby, migracje oraz pliki lock naleĹĽy zachowaÄ‡. Prywatne repo nadal wymaga ochrony sekretĂłw.

## 10. Ujawnienie klucza

Najpierw uniewaĹĽnij ujawniony klucz u dostawcy i utwĂłrz nowy z minimalnymi uprawnieniami. Zaktualizuj lokalnÄ… konfiguracjÄ™ i sprawdĹş logi dostÄ™pu. Zatrzymaj push projektu. Ustal plik, commit i zakres ekspozycji, nie kopiuj wartoĹ›ci sekretu. UsuniÄ™cie z ostatniego commita nie wystarcza, jeĹĽeli klucz pozostaĹ‚ w historii, PR, logu lub cache. Przygotuj plan usuniÄ™cia z caĹ‚ej historii, kopii i klonĂłw, skonsultuj go z wĹ‚aĹ›cicielem i uzyskaj zgodÄ™ przed przepisaniem historii. W tym zadaniu nie wolno stosowaÄ‡ force push; ewentualne odzyskanie wymaga osobno uzgodnionej procedury z GitHub Support. Nigdy nie zakĹ‚adaj, ĹĽe samo prywatne repo uniewaĹĽnia wyciek.

## 11. Git nie zastÄ™puje backupu

Repo przechowuje kod i jego historiÄ™. Nie przechowuje wykluczonych danych, .env, wolumenĂłw Docker, bazy uĹĽytkownikĂłw, NAS ani obiektĂłw S3. Potrzebujesz oddzielnego, szyfrowanego backupu konfiguracji i danych, kopii poza komputerem oraz sprawdzonego odtwarzania. Temp Mail celowo korzysta z nietrwaĹ‚ej poczty â€” nie dorabiaj backupu treĹ›ci bez Ĺ›wiadomej zmiany polityki.

## 12. Zabezpieczenia GitHub

Po publikacji zweryfikuj `visibility=private`, SHA gaĹ‚Ä™zi i tagu oraz wynik Actions. WĹ‚Ä…cz dostÄ™pne Dependabot alerts, security updates i ochronÄ™ gĹ‚Ăłwnej gaĹ‚Ä™zi. Ochrona prywatnych repo i Secret Protection mogÄ… zaleĹĽeÄ‡ od planu konta; status ustal z odpowiedzi API lub ustawieĹ„, nie z samej obecnoĹ›ci YAML. Nie kupuj dodatkĂłw ani nie wĹ‚Ä…czaj wersji prĂłbnej bez decyzji wĹ‚aĹ›ciciela. Lokalny Gitleaks i workflow pozostajÄ… potrzebne niezaleĹĽnie od pĹ‚atnych funkcji. Aktualny stan aktywacji jest zapisany w RAPORT.md.
