# Projectlessen Blok 6 (SoleStore) – uitleg voor de docent

De projectlessen worden in 6 kaarten uitgedeeld als GitHub Issues, door `.github/workflows/kaarten.yml`. Het werkt hetzelfde als in Project Blok 5B, maar zonder thema's (iedereen bouwt SoleStore). Nieuw: bij `/klaar` zet de workflow een **commitoverzicht** op de kaart.

Lesmateriaal voor studenten: `zwsd25ab/blok 6/projectlessen/` in de repository `backend-frontend`.

## Eenmalig instellen

1. Deze repository moet een **template** zijn: **Settings → General → Template repository** aanvinken.
2. Organisatie `Nova-College-Haarlem-Students` (staat al goed vanuit 5B, controleer alleen):
   - Actions-variabele `DOCENTEN` met de GitHub-namen van de docenten, gescheiden door komma's
   - **Settings → Actions → General**: Actions staat aan
   - **Member privileges**: base permissions **No permission** of **Read**, repository creation **Public** aangevinkt

## Overstap (les 2)

Studenten hebben in les 1 een eigen repository gemaakt. Aan het begin van les 2 volgen ze [Overstap naar GitHub-kaarten](https://github.com/NOVA-college-Haarlem/backend-frontend/blob/main/zwsd25ab/blok%206/projectlessen/Overstap%20naar%20GitHub-kaarten.md). Daarna staat **kaart 1** bij Issues.

- Kaart 1 al op papier afgetekend? Sluit hem meteen als **completed**. Kaart 2 verschijnt.
- Nog niet afgetekend? De student typt `/klaar` en komt in je wachtrij.

## Tijdens de projectles

**Je wachtrij** – zet deze zoekopdracht als bladwijzer:

```
https://github.com/issues?q=org:Nova-College-Haarlem-Students+is:issue+is:open+label:aftekenen+sort:created-asc
```

Wie bovenaan staat, wacht het langst.

**Aftekenen** – bekijk de demo, stel een uitlegvraag van de kaart en kijk naar het **commitoverzicht** in de reactie van de workflow:
- *Ander of geen kaartnummer*: commits zonder `K<n>:` of met een ander nummer (bijv. vooruitgewerkt).
- *Grote commits*: meer dan 300 regels toegevoegd in één commit. Vraag hoe die code tot stand is gekomen.

Goed? Sluit de kaart met **Close as completed**. De volgende kaart verschijnt meteen.

**Nog niet goed** – laat een reactie achter en haal het label `aftekenen` weg. De student past aan en typt opnieuw `/klaar`.

**Voortgang** – wie op welke kaart zit:

```
https://github.com/issues?q=org:Nova-College-Haarlem-Students+is:issue+is:open+in:title+Kaart
```

## Hoe het werkt

| Gebeurtenis | Wat de workflow doet |
|-------------|----------------------|
| Student pusht (eerste keer) | Opent kaart 1 |
| Student typt `/klaar` | Zet label `aftekenen`, plaatst het commitoverzicht van deze kaart |
| Docent sluit kaart als completed | Opent de volgende kaart |
| Student sluit kaart zelf | Heropent de kaart |
| Elke push | `commitcheck.yml` controleert of commitberichten met `K<n>:` beginnen |

- Kaartteksten: `.github/kaarten/1.md` t/m `6.md`. De eerste regel is de titel.
- Het commitoverzicht telt de commits sinds de vorige kaart is gesloten. Laravels eigen eerste commit (`Set up a fresh Laravel app`) telt niet mee.
- Wie in `.github` gaat zoeken, kan vooruitlezen. Dat is niet erg.
- Kaart 1 komt niet? Laat de student bij **Actions → Kaarten → Run workflow** de workflow handmatig starten.
