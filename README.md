# JauheJampan KaluPakki

![Kuvakaappaus](https://gdurl.com/EvOK)

Jauhejampan Kalupakki on graafinen työkalulajitelma suunniteltu helpottamaan ja nopeuttamaan jauheensäkittäjän rutiininomaisia toimia. Osa toiminnoista on itsenäisiä ohjelmia, osa skriptejä jotka ovat riippuvaisia emo-ohjelmasta.

## Tarra-Aparaatti

Tarra-Aparaatti tulostaa nimensä mukaisesti jauhesäkkien näytetarrat. Skripti kysyy montako tarraa käyttäjä haluaa ja hoitaa loput koneellisesti. Turvaominaisuuksina:
- Liian suuren/pienen inputin esto
- Emo-ohjelman tilan lukeminen ja tarvittaessa saattaminen haluttuun tilaan jotta skripti voidaan suorittaa

## SäkkiAjastin

![Kuvakaappaus](https://gdurl.com/tqaF)

KaluPakin kruununjalokivi, SäkkiAjastin, kellottaa nimensä mukaisesti seuraavaan säkinvaihtoon kuluvan ajan. Käyttäjältä ajastin kysyy tällä hetkellä säkissä olevan jauheen määrän ja ajastin näyttää siitä eteenpäin reaaliajassa säkkiin tippuneen jauheen määrän, kuinka paljon säkki on vajaa täydestä, kyseisen säkin täyttöön jo kuluneen ajan ja jäljellä olevan ajan sekä arvion säkin valmistumiskellonajasta. Reaaliaikaisen lukujen näyttämisen lisäksi ajastimeen on mahdollisuus asettaa hälytys laskurin päästessä lukuun x, jolloin ajastin hälyttää piippaamalla sekä tarvittaessa pomppaamalla päällimmäiseksi ikkunaksi. Turvaominaisuuksina:
- Liian suuren/pienen inputin esto
- Äänenvoimakkuuden tarkistus ajastimen käynnistyessä

## LavaLappuLatoja

Lavalappulatoja tulostaa eräajona lavalaput samaan tyyliin kuin TarraAparaatti tulostaa näytetarrat. Skripti kysyy montako lappua käyttäjä haluaa ja hoitaa loput koneellisesti. Turvaominaisuutena emo-ohjelman tilan lukeminen ja tarvittaessa saattaminen haluttuun tilaan että skripti voidaan suorittaa.

## Asetukset

![Kuvakaappaus](https://gdurl.com/y3bj)

Asetuksissa voit säätää KaluPakin toiminnallisuutta. TarraAparaatin, SäkkiAjastimen ja LavaLappuLatojan oletuksena olevia starttiarvoja voi optimoida omaan makuun sekä SäkkiAjastimen toimintaa säätää tarkemmin.

## Loki ja hätäseis

Jos KaluPakin toimet herättävät epäilystä tai jos esim. ohjelma ei jostain syystä toimi, voi sen kokoamia lokitietoja tarkastella KaluPakin hakemistosta löytyvästä log-tiedostosta. Tähän tiedostoon ohjelma kirjaa kaikki tekemänsä toimet. Samoin jos ohjelma tekee omiaan tai lakkaa kokonaan toimimasta, saa missä tahansa vaiheessa ESC-näppäimen painalluksella ohjelman terminoitua.
