# Raport przygotowania — 2026-10-12

Przygotowano osobne kopie projektów do Git w outputs. Oryginalne katalogi, ich .env, dane i działające kontenery pozostają w swoich lokalizacjach. Dla Temp Mail zachowano historię i bieżące zmiany. W pozostałych projektach utworzono nową historię, ponieważ źródła nie miały własnego Git. Infrastruktura stron zachowuje wspólne zasoby; backend ma osobne repozytorium. Nie nadano licencji open source.

## Stan lokalnych kontroli

| Projekt | Wersja | Testy/build | Pozostałe problemy | GitHub/CI |
|---|---|---|---|---|
| server-infra | 0.1.0 | 32/32 testy PASS; Compose Caddy/strona/portfolio PASS. | Zależności obrazów Docker: szczegółowy raport w projects-index/AUDYT-DOCKER.json. | zablokowane: uwierzytelnienie |
| velin-whiteboard | 0.1.0 | 59/59 testów PASS; lint PASS; build PASS po poprawkach. E2E i backup/restore nie uruchomione. | braces HIGH (wskazana 3.0.4 niedostępna w npm), esbuild LOW; E2E/restore nie wykonano. | zablokowane: uwierzytelnienie |
| voidnas | 0.1.0 | 75 testów PASS; 6 pominiętych testów integracyjnych wymagających bazy. Prisma generate PASS; pełny build obu aplikacji PASS po poprawkach. | 6 testów integracyjnych pominięto; obrazy produkcyjne wymagają osobnej aktualizacji. | zablokowane: uwierzytelnienie |
| temp-mail | 0.1.0 | 24/24 testy PASS; lint PASS; TypeScript PASS; build Next.js 16.3.8 PASS po poprawkach. | 19 zgłoszeń w aplikacji (12 HIGH, 7 MODERATE), 1 HIGH w server; dalsze zmiany/migracje narzędzi. | zablokowane: uwierzytelnienie |
| serwerbb-backend | 0.1.0 | Python syntax PASS; Docker build serwerbb-backend:github-review PASS. Brak odrębnego zestawu testów w źródłach. | Zależności obrazów Docker: szczegółowy raport w projects-index/AUDYT-DOCKER.json. | zablokowane: uwierzytelnienie |

## Obrazy istniejącego wdrożenia

Lokalny Trivy 0.75.0, oficjalny obraz przypięty do digestu sha256:af6acf9a6b85dfe389a1941505c0ce9efef52a4719635e1a962f022a3d855daa. Skaner pobrał bazę CVE; kod nie został wysłany do zewnętrznego skanera. Poniżej liczby zgłoszeń (nie liczby unikalnych CVE). Exit 0 Trivy oznacza wykonanie skanu, nie brak podatności.

| Obraz lokalny | Krytyczne | Wysokie | Średnie | Niskie | Skaner |
|---|---:|---:|---:|---:|---|
| `serwerbb-backend:github-review` | 0 | 4 | 3 | 0 | wykonano |
| `home-caddy-ratelimit:local` | 0 | 10 | 14 | 5 | wykonano |
| `nginx:alpine` | 0 | 3 | 3 | 0 | wykonano |
| `favonia/cloudflare-ddns:1` | 0 | 4 | 7 | 1 | wykonano |
| `postgres:17-alpine` | 1 | 24 | 28 | 3 | wykonano |
| `redis:8-alpine` | 0 | 0 | 1 | 0 | wykonano |
| `dxflrs/garage:v2.3.0` | 0 | 0 | 0 | 0 | wykonano |
| `velin-whiteboard:latest` | 4 | 71 | 123 | 83 | wykonano |
| `voidnas-api` | 32 | 528 | 2851 | 1555 | wykonano |
| `voidnas-web` | 6 | 81 | 79 | 41 | wykonano |
| `temp-mail-web` | 1 | 17 | 16 | 3 | wykonano |
| `temp-mail-receiver` | 0 | 11 | 10 | 1 | wykonano |

Szczegóły: [AUDYT-DOCKER.json](AUDYT-DOCKER.json). Nie przebudowano ani nie wymieniono produkcyjnych obrazów. Bezpieczna aktualizacja wymaga backupu, nowego builda, skanu jego digestu, testów kompatybilności i kontrolowanego wdrożenia. Nie wolno automatycznie podnosić głównych wersji PostgreSQL/Redis/Garage ani modyfikować wolumenów.

## Zabezpieczenia: wykonane i niewykonane

- Lokalnie: .gitignore, .dockerignore, szablony .env.example, Gitleaks źródeł i historii, audyt npm/pnpm, Trivy, testy/build, dokumentacja po polsku.
- Przygotowane pliki CI: przypięte checkout/setup-node, contents: read, persist-credentials: false, brak sekretów i pull_request_target, osobny skan historii przed zależnościami, testy i odpowiednie buildy. Kontrola HIGH będzie celowo nieprzechodząca w projektach z nierozwiązanymi podatnościami.
- GitHub: nie aktywowano jeszcze niczego; nie potwierdzono planu ani dostępności branch protection/Secret Protection. Nie wolno przedstawiać przygotowanego workflow jako działającego CI.
- Zdalne prywatne repozytoria, push, tagi zdalne, Releases i zgodność SHA: do wykonania po uwierzytelnieniu. Nie powstały publiczne repozytoria.

## Dostęp do GitHub

Połączenie GitHub w ChatGPT zostało zgłoszone przez użytkownika i instalacja jest widoczna, lecz narzędzia zapisu GitHub nie zostały udostępnione bieżącej sesji. CLI nie było zalogowane w ostatniej potwierdzonej kontroli. Polityka Windows PowerShell blokuje pliki .ps1; nie zmieniono jej.

Uruchom bezpośrednio zweryfikowany program:

```powershell
& 'C:\Users\hmpow\Documents\Codex\2026-10-12\uporz-dkuj-i-umie-na-github\work\tools\cli\bin\gh.exe' auth login --hostname github.com --git-protocol https --web
```

Zaloguj się jako HMpower1 i poinformuj o ukończeniu; nie przesyłaj tokenu. Po tym agent może dokończyć tworzenie prywatnych repozytoriów, bez zmiany istniejących remote i bez force push.

## Pominięte

Nextcloud AIO zgodnie z poleceniem. Podglądy Velin, instancje restore, bazy, cache i magazyny obiektowe nie są osobnymi projektami. Dane NAS, poczta, bazy, backupy i lokalne sekrety nie należą do repozytoriów. Nie znaleziono sekretów wymagających przepisywania historii; nie wykonywano rotacji rzeczywistych kluczy.

## Finalne commity i skan

Każdy projekt ma logiczne commity źródeł i dokumentacji, tag v0.1.0 oraz PASS skanu dokładnego drzewa finalnego indexu i całej historii --all przez Gitleaks 8.30.1. Zestawy plików i SHA: MANIFESTY.json. Lokalna gałąź Temp Mail pozostaje master, pozostałe projekty main. Zdalna weryfikacja zostanie dopisana po publikacji.
