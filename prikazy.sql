/1 HK: D1*/
SELECT o.id_osoba, o.jmeno, o.prijmeni, o.vek
FROM osoby o
JOIN poradatele p
ON o.id_osoba = p.id_osoba
WHERE o.vek > 30;

/*2 HK: D2*/
SELECT z.nazev, o.jmeno, o.prijmeni, o.vek
FROM zavody z
JOIN osoby o
ON z.id_zavodu = o.zavod_id
WHERE o.jmeno IS NULL AND z.datum > '2022-01-01';
 
/*3 HK: D3 Tento příkaz uděluje uživateli oprávnění ke čtení dat z tabulky "adresy", vkládání nových dat do tabulky, aktualizaci existujících dat v tabulce a mazání dat z tabulky. */
GRANT SELECT, INSERT, UPDATE, DELETE ON adresy TO <user>;
/*4 HK: D4* Tento příkaz uděluje uživateli oprávnění ke čtení dat ze všech tabulek v databázi, vkládání nových dat do všech tabulek, aktualizaci existujících dat ve všech tabulkách a mazání dat ze všech tabulek. /
GRANT SELECT, INSERT, UPDATE, DELETE ON * TO <user>;


/*5 HK: D5*/
SELECT *
FROM osoby
JOIN adresy USING (id_osoba);

/*6 HK: D6*/
SELECT *
FROM osoby
JOIN adresy ON osoby.id_osoba = adresy.id_osoba;

/*7 HK: D7*/
SELECT *
FROM osoby
NATURAL JOIN adresy;

/*8 HK: D8*/
SELECT *
FROM osoby
CROSS JOIN adresy;

/*9 HK: D9*/
SELECT *
FROM osoby
LEFT OUTER JOIN adresy ON osoby.id_osoba = adresy.id_osoba;

/*10 HK: D10*/
SELECT *
FROM osoby
RIGHT OUTER JOIN adresy ON osoby.id_osoba = adresy.id_osoba;

/*11 HK: D11*/
SELECT *
FROM osoby
FULL OUTER JOIN registrace_závodu ON osoby.id_osoba = registrace_závodu.id_osoba;

/*12 HK: D12*/
SELECT jmeno, přijmeni
FROM osoby
WHERE vek > (SELECT AVG(vek)
             FROM osoby);


/*13 HK: D13 Tento dotaz vrátí jméno, příjmení a startovní číslo všech osob, které se zaregistrovaly na určitý závod */
SELECT o.jmeno, o.prijmeni, r.startovni_cislo
FROM osoby o,
  (SELECT r.osoba_id_osoba, r.startovni_cislo
   FROM registrace_zavodu r
   WHERE r.zavod_id_zavod = 1) r
WHERE o.id_osoba = r.osoba_id_osoba;

/*14 HK: D14 Tento dotaz vybere jméno, příjmení a startovní číslo pro všechny osoby, které se zaregistrovaly na závod po 1. lednu 2022.
Vnořený dotaz v klauzuli WHERE vybírá všechny závody, které se konají po 1. lednu 2022, a používá je jako filtr pro výběr osob.*/
SELECT o.jmeno, o.prijmeni, r.startovni_cislo
FROM osoby o
JOIN registrace_zavodu r
ON o.id_osoba = r.osoba_id_osoba
WHERE r.zavod_id_zavod IN (
  SELECT z.id_zavod
  FROM zavody z
  WHERE z.datum > '2022-01-01'
)

/*15 HK: D15 Tento dotaz vybere jméno a příjmení pro všechny osoby, které se zaregistrovaly na nějaký závod.
 Vnořený dotaz v klauzuli WHERE testuje, zda existuje alespoň jedna registrace pro každou osobu v tabulce osoby.*/
SELECT o.jmeno, o.prijmeni
FROM osoby o
WHERE EXISTS (
  SELECT 1
  FROM registrace_zavodu r
  WHERE r.osoba_id_osoba = o.id_osoba
)
/*15 Vnořený dotaz v klauzuli WHERE testuje, zda neexistuje žádný řádek pro každou osobu v tabulce poradatele.*/
SELECT o.jmeno, o.prijmeni
FROM osoby o
WHERE NOT EXISTS (
  SELECT 1
  FROM poradatele p
  WHERE p.id_osoba = o.id_osoba
)

/*16 HK: D16 Seznam všech adres z databáze a id osob k nim přiřazených*/
SELECT adresa, id_osoba FROM osoby
UNION
SELECT adresa, id_osoba FROM registrace_zavodu
ORDER BY ADRESA;

/*17 HK: D17 Tento dotaz vrátí jméno, příjmení a ID pro všechny osoby s ID 1, 3 nebo 5, ale ne s ID 2 nebo 4.*/
SELECT id_osoba, jmeno, prijmeni
FROM osoby
WHERE id_osoba IN (1, 2, 3, 4, 5)

MINUS

SELECT id_osoba, jmeno, prijmeni
FROM osoby
WHERE id_osoba IN (2, 4)

/*18 HK: D18 Tento dotaz vrátí jméno, příjmení a ID pro všechny osoby s ID 2 nebo 4.*/
SELECT id_osoba, jmeno, prijmeni
FROM osoby
WHERE id_osoba IN (1, 2, 3, 4, 5)

INTERSECT

SELECT id_osoba, jmeno, prijmeni
FROM osoby
WHERE id_osoba IN (2, 4, 6, 8)

/*19 HK: D19 Tento dotaz vrátí velká písmena pro jména osob, délku příjmení, první tři čísla telefonního čísla, pozici, na které se v ulici vyskytuje slovo "náměstí", celé jméno osoby (jméno a příjmení spojené mezerou) a město bez mezer na začátku a konci.*/
SELECT UPPER(jmeno) AS "VELKE JMENO",
       LENGTH(prijmeni) AS "DELKA PRIJMENI",
       SUBSTR(telefonni_cislo, 1, 3) AS "PRVNI TRI CISLA",
       INSTR(ulice, 'náměstí') AS "NAMESTI?",
       CONCAT(jmeno, ' ', prijmeni) AS "CELÉ JMÉNO",
       TRIM(mesto) AS "MESTO BEZ MEZER"
FROM osoby

/*20 HK: D20 Tento dotaz vrátí průměrný věk osob, součet startovních čísel, nejrychlejší a nejpomalejší čas v cíli, počet registrací, průměrný čas s 2 desetinnými místy, absolutní hodnotu -100 a zbytek po celočíselném dělení 10, 3.*/
SELECT AVG(vek) AS "PRUMERNY VEK",
       SUM(startovni_cislo) AS "SOUCET STARTOVNICH CISEL",
       MIN(cas) AS "NEJRYCHLEJSÍ CAS",
       MAX(cas_v_cili) AS "NEJPOMALEJSÍ CAS V CILI",
       COUNT(*) AS "POCET REGISTRACI",
       ROUND(AVG(cas), 2) AS "PRUMERNY CAS S 2 DESETINNYMI MIESTY",
       ABS(-100) AS "ABSOLUTNI HODNOTA",
       MOD(10, 3) AS "ZBYTEK PO CELOCISELNEM DELENI"
FROM registrace_zavodu

/*21 HK: D21 Sloupec "AKTUALNI CAS" obsahuje aktuální datum a čas pomocí funkce CURRENT_TIMESTAMP.
Sloupec "PRED ROKEM" obsahuje datum a čas, které jsou posunuté o 1 rok zpět od aktuálního data a času pomocí funkce DATEADD.
Sloupec "POCET LET OD 2022" obsahuje počet let od data "2022-01-01" do aktuálního data pomocí funkce DATEDIFF.
Sloupec "AKTUALNI MESIC" obsahuje aktuální měsíc pomocí funkce EXTRACT a funkce CURRENT_TIMESTAMP.
Sloupec "AKTUALNI CAS V TEXTU" obsahuje aktuální datum a čas ve formátu "den.měsíc.rok hodiny:minuty:sekundy AM/PM" pomocí funkce DATE_FORMAT a funkce CURRENT_TIMESTAMP.*/
SELECT CURRENT_DATE AS "DNESNI DATUM",
       CURRENT_TIMESTAMP AS "DNESNI CAS",
        DATEADD(YEAR, -1, CURRENT_TIMESTAMP) AS "PRED ROKEM",
       DATEDIFF(YEAR, '2022-01-01', CURRENT_TIMESTAMP) AS "POCET LET OD 2022",
       EXTRACT(MONTH FROM CURRENT_TIMESTAMP) AS "AKTUALNI MESIC",
       DATE_FORMAT(CURRENT_TIMESTAMP, '%d. %M %Y %h:%i:%s %p') AS "AKTUALNI CAS V TEXTU"

/*22 HK: D22 Tento dotaz vrátí dnešní datum, aktuální čas, aktuální datum a čas, datum narození osob o 30 dní později, datum narození osob o 6 měsíců dříve, počet dnů od narození osob, měsíc narození osob a rok narození osob.*/
SELECT CURDATE() AS "DNESNI DATUM",
       CURTIME() AS "AKTUALNI CAS",
       NOW() AS "DATUM A CAS NYNÍ",
       DATE_ADD(datum_narozeni, INTERVAL 30 DAY) AS "DATUM NAROZENI + 30 DNU",
       DATE_SUB(datum_narozeni, INTERVAL 6 MONTH) AS "DATUM NAROZENI - 6 MESICU",
       DATEDIFF(datum_narozeni, NOW()) AS "POCET DNU OD NAROZENI",
       MONTH(datum_narozeni) AS "MESIC NAROZENI",
       YEAR(datum_narozeni) AS "ROK NAROZENI"
FROM osoby

/*23 HK: D23 Tento dotaz vrátí průměrný věk pro každý typ osoby, ale zobrazí pouze typy, u kterých je průměrný věk vyšší než 30.*/
SELECT typ_osoby, AVG(vek) AS "PRUMERNY VEK"
FROM osoby
GROUP BY typ_osoby
HAVING AVG(vek) > 30

/*24 HK: D24 Všechny tři formulace produkují stejný výsledek. Liší se pouze umístěním klauzule HAVING nebo WHERE.*/
Formulace 1:
SELECT typ_osoby, mesto, COUNT(*) AS "POCET OSOB"
FROM osoby
GROUP BY typ_osoby, mesto
HAVING COUNT(*) > 2
Formulace 2:
SELECT typ_osoby, mesto, COUNT(*) AS "POCET OSOB"
FROM osoby
GROUP BY typ_osoby, mesto
WHERE COUNT(*) > 2
Formulace 3:
SELECT typ_osoby, mesto, COUNT(*) AS "POCET OSOB"
FROM osoby
WHERE COUNT(*) > 2
GROUP BY typ_osoby, mesto

/*25 HK: D25 Tento dotaz vybere jméno, příjmení a název kategorie pro všechny osoby, které jsou starší než 30 let, a které se zúčastnily alespoň jedné závodu.
Výsledky jsou seskupeny podle jména, příjmení a názvu kategorie a vráceny pouze pro ty kategorie, u kterých se zúčastnilo více než jedna osoba.*/
SELECT osoby.jmeno, osoby.prijmeni, typy_kategorii.nazev
FROM osoby
JOIN registrace_zavodu ON osoby.id_osoba = registrace_zavodu.osoba_id_osoba
JOIN typy_kategorii ON registrace_zavodu.typ_kat_id_kategorie = typy_kategorii.id_kategorie
WHERE osoby.vek > 30
GROUP BY osoby.jmeno, osoby.prijmeni, typy_kategorii.nazev
HAVING

/*26 HK: D26 Tento dotaz vytváří pohled s názvem "zavodnici", který obsahuje jméno, příjmení, startovní číslo a název kategorie pro všechny osoby, které se zúčastnily alespoň jedné závodu. Pohled vytvoří vnitřní spojení (JOIN) mezi tabulkami osoby, registrace_zavodu a typy_kategorii pomocí klauzule ON, která specifikuje, že se mají použít sloupce id_osoby a osoba_id_osoba z tabulek osoby a registrace_zavodu a sloupce typ_kat_id_kategorie a id_kategorie z tabulek registrace_zavodu a typy_kategorii.*/
CREATE VIEW zavodnici AS
SELECT osoby.jmeno, osoby.prijmeni, registrace_zavodu.startovni_cislo, typy_kategorii.nazev
FROM osoby
JOIN registrace_zavodu ON osoby.id_osoba = registrace_zavodu.osoba_id_osoba
JOIN typy_kategorii ON registrace_zavodu.typ_kat_id_kategorie =

/*27 HK: D27 Tento dotaz vrátí všechny sloupce z pohledu "zavodnici" pro všechny ženy ve věku nad 30 let. Podmínka vek > 30 omezuje výsledky na ženy starší než 30 let a podmínka nazev = 'Ženy' omezuje výsledky pouze na ženy.*/
SELECT * FROM zavodnici WHERE vek > 30 AND nazev = 'Ženy'

/*28 HK: D28 Tento dotaz vloží nové řádky do tabulky osoby z tabulky nove_osoby. Vložené řádky obsahují hodnoty sloupců jmeno, prijmeni, datum_narozeni, telefonni_cislo a vek, které jsou vybrány z tabulky nove_osoby. Sloupec typ_osoby je vložen s hodnotou 'O' pro všechny řádky. Vek je vypočítán pomocí funkce YEAR z aktuálního data a data narození z tabulky nove_osoby.*/
INSERT INTO osoby (jmeno, prijmeni, datum_narozeni, telefonni_cislo, typ_osoby, vek)
SELECT jmeno, prijmeni, datum_narozeni, telefonni_cislo, 'O', (YEAR(CURRENT_DATE) - YEAR(datum_narozeni))
FROM nove_osoby

/*29 HK: D29 Tento dotaz aktualizuje sloupec vek v tabulce osoby pro všechny řádky, kde id_osoba je obsažena v tabulce nove_osoby. Nová hodnota veku je vypočítána pomocí funkce YEAR z aktuálního data a data narození z tabulky osoby.*/
UPDATE osoby
SET vek = (YEAR(CURRENT_DATE) - YEAR(datum_narozeni))
WHERE id_osoba IN (SELECT id_osoba FROM nove_osoby)

/*30 HK: D30 Tento dotaz odstraní všechny řádky z tabulky osoby, kde id_osoba je obsažena v tabulce nove_osoby.*/
DELETE FROM osoby
WHERE id_osoba IN (SELECT id_osoba FROM nove_osoby)
