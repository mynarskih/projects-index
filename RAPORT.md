# Raport przygotowania — 2026-10-12

Przygotowano osobne kopie projektów do Git w outputs. Oryginalne katalogi, ich .env, dane i działające kontenery pozostają w swoich lokalizacjach. Dla Temp Mail zachowano historię i bieżące zmiany. W pozostałych projektach utworzono nową historię, ponieważ źródła nie miały własnego Git. Infrastruktura stron zachowuje wspólne zasoby; backend ma osobne repozytorium. Nie nadano licencji open source.

## Stan lokalnych kontroli

| Projekt | Wersja | Testy/build | Pozostałe problemy | GitHub/CI |
|---|---|---|---|---|
| server-infra | 0.1.0 | 32/32 testy PASS; Compose Caddy/strona/portfolio PASS. | Zależności obrazów Docker: szczegółowy raport w projects-index/AUDYT-DOCKER.json. | opublikowano prywatnie; szczegóły poniżej |
| velin-whiteboard | 0.1.0 | 59/59 testów PASS; lint PASS; build PASS po poprawkach. E2E i backup/restore nie uruchomione. | braces HIGH (wskazana 3.0.4 niedostępna w npm), esbuild LOW; E2E/restore nie wykonano. | opublikowano prywatnie; szczegóły poniżej |
| voidnas | 0.1.0 | 75 testów PASS; 6 pominiętych testów integracyjnych wymagających bazy. Prisma generate PASS; pełny build obu aplikacji PASS po poprawkach. | 6 testów integracyjnych pominięto; obrazy produkcyjne wymagają osobnej aktualizacji. | opublikowano prywatnie; szczegóły poniżej |
| temp-mail | 0.1.0 | 24/24 testy PASS; lint PASS; TypeScript PASS; build Next.js 16.3.8 PASS po poprawkach. | 19 zgłoszeń w aplikacji (12 HIGH, 7 MODERATE), 1 HIGH w server; dalsze zmiany/migracje narzędzi. | opublikowano prywatnie; szczegóły poniżej |
| serwerbb-backend | 0.1.0 | Python syntax PASS; Docker build serwerbb-backend:github-review PASS. Brak odrębnego zestawu testów w źródłach. | Zależności obrazów Docker: szczegółowy raport w projects-index/AUDYT-DOCKER.json. | opublikowano prywatnie; szczegóły poniżej |

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
- GitHub: aktywne Dependabot alerts, security updates i read-only workflow permissions. Dostępność ochrony gałęzi oraz Secret Protection sprawdzono przez API; wyniki w tabeli poniżej.
- Wszystkie sześć zdalnych repozytoriów jest prywatnych; push, tagi oraz prerelease zostały utworzone. Zgodność SHA gałęzi i tagów potwierdzono. Nie powstały publiczne repozytoria.

## Dostęp do GitHub

GitHub CLI zalogowany jako HMpower1. Prywatność i tożsamość właściciela potwierdzono przez API. Logowanie odbyło się bez przesyłania tokenu do czatu. Polityki wykonywania skryptów PowerShell nie zmieniono.

## Pominięte

Nextcloud AIO zgodnie z poleceniem. Podglądy Velin, instancje restore, bazy, cache i magazyny obiektowe nie są osobnymi projektami. Dane NAS, poczta, bazy, backupy i lokalne sekrety nie należą do repozytoriów. Nie znaleziono sekretów wymagających przepisywania historii; nie wykonywano rotacji rzeczywistych kluczy.

## Finalne commity i skan

Każdy projekt ma logiczne commity źródeł i dokumentacji, tag v0.1.0 oraz PASS skanu dokładnego drzewa finalnego indexu i całej historii --all przez Gitleaks 8.30.1. Zestawy plików i SHA: MANIFESTY.json. Lokalna gałąź Temp Mail pozostaje master, pozostałe projekty main. Zdalna weryfikacja została wykonana; tabela poniżej.

## Potwierdzone repozytoria i CI commita wydania

| Projekt | Repozytorium prywatne | Wersja / wydanie | CI commita wydania | Ochrona gałęzi | Secret Scanning |
|---|---|---|---|---|---|
| server-infra | [server-infra](https://github.com/HMpower1/server-infra) | [0.1.0 prerelease](https://github.com/HMpower1/server-infra/releases/tag/v0.1.0) | [success](https://github.com/HMpower1/server-infra/actions/runs/38306971047) | Upgrade to GitHub Pro or make this repository public to enable this feature. | niedostępne |
| serwerbb-backend | [serwerbb-backend](https://github.com/HMpower1/serwerbb-backend) | [0.1.0 prerelease](https://github.com/HMpower1/serwerbb-backend/releases/tag/v0.1.0) | [success](https://github.com/HMpower1/serwerbb-backend/actions/runs/38307014568) | Upgrade to GitHub Pro or make this repository public to enable this feature. | niedostępne |
| velin-whiteboard | [velin-whiteboard](https://github.com/HMpower1/velin-whiteboard) | [0.1.0 prerelease](https://github.com/HMpower1/velin-whiteboard/releases/tag/v0.1.0) | [failure](https://github.com/HMpower1/velin-whiteboard/actions/runs/38307054665) | Upgrade to GitHub Pro or make this repository public to enable this feature. | niedostępne |
| voidnas | [voidnas](https://github.com/HMpower1/voidnas) | [0.1.0 prerelease](https://github.com/HMpower1/voidnas/releases/tag/v0.1.0) | [success](https://github.com/HMpower1/voidnas/actions/runs/38307098182) | Upgrade to GitHub Pro or make this repository public to enable this feature. | niedostępne |
| temp-mail | [temp-mail](https://github.com/HMpower1/temp-mail) | [0.1.0 prerelease](https://github.com/HMpower1/temp-mail/releases/tag/v0.1.0) | [failure](https://github.com/HMpower1/temp-mail/actions/runs/38307144176) | Upgrade to GitHub Pro or make this repository public to enable this feature. | niedostępne |
| projects-index | [projects-index](https://github.com/HMpower1/projects-index) | [0.1.0 prerelease](https://github.com/HMpower1/projects-index/releases/tag/v0.1.0) | [success](https://github.com/HMpower1/projects-index/actions/runs/38307188072) | Upgrade to GitHub Pro or make this repository public to enable this feature. | niedostępne |

CI w Velin i Temp Mail ma niepowodzenie na kontroli HIGH zależności. Skany sekretów przechodzą. Lokalne testy i buildy poprawionych kopii przeszły; nie przedstawia się pominiętych późniejszych etapów jobu GitHub jako przeprowadzonych przez GitHub. VoidNAS, backend, infrastruktura i indeks mają udane runy wydania. Status finalnych commitów dokumentacji jest sprawdzany oddzielnie i zapisany w STATUS-GITHUB.json.

Alerty Dependabot i aktualizacje bezpieczeństwa potwierdzono odczytem API. Secret scanning jest niedostępne dla tych prywatnych repozytoriów (odpowiedź GitHub: Secret scanning is not available for this repository). Nie zmieniano widoczności na publiczną i nie wykupywano planu. Ochrona gałęzi ma osobną odpowiedź API w tabeli; nie traktuje się samej obecności workflow jako ochrony gałęzi. Dependabot może otwierać PR automatycznie; nie scalano niezweryfikowanych aktualizacji i nie wdrażano ich na produkcji.

Wydanie v0.1.0 pozostaje przypięte do pierwotnego przeskanowanego commita. Kolejny commit na głównej gałęzi aktualizuje tylko opis rzeczywistych wyników. Ich różne SHA są zamierzone; lokalne/zdalne SHA obu referencji sprawdzono osobno. Manifesty dokładnych plików wydania: MANIFESTY.json.

## Dokumentacja po publikacji

W poradniku sprawdzono polskie znaki w UTF-8 i bezpośrednie polecenie logowania, działające bez zmiany polityki .ps1. STATUS-GITHUB.json w repo opisuje stan obserwowany przed ostatnim commitem indeksu. Końcowy wynik dokładnych SHA jest dostępny również jako załącznik STATUS-GITHUB.json do wydania indeksu — bez zapisywania własnego SHA w jego commicie.
