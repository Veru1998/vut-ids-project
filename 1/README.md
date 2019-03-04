# Datový model (ERD) a model případů užití

Datový model (ER diagram) zachycující strukturu dat, resp. požadavky na data
v databázi, vyjádřený jako diagram tříd v notaci UML nebo jako ER diagram
v tzv. Crow's Foot notaci a model případů užití vyjádřený jako diagram
případů užití v notaci UML reprezentující požadavky na poskytovanou
funkcionalitu aplikace používající databázi navrženého datového modelu.
Datový model musí obsahovat alespoň jeden vztah generalizace/specializace
(tedy nějakou entitu/třídu a nějakou její specializovanou entitu/podtřídu
spojené vztahem generalizace/specializace; vč. použití správné notace vztahu
generalizace/specializace v diagramu).

### Zadání z IUS - 49. Bug Tracker
Vytvořte informační systém pro hlášení a správů chyb a zranitelností systému.
Systém umožňuje uživatelům hlásit bugy, jejich závažnosti a moduly, ve kterých
se vyskytly, ve formě tiketů. Tikety mohou obsahovat hlášení o více než jednom
bugu a stejný bug může být zahlášen více uživateli. Bug může (ale nemusí) být
zranitelností a v tomto případě zaevidujeme i potenciální míru nebezpečí
zneužití této zranitelnosti. V případě zahlášení bugů, odešle systém
upozornění programátorovi, který zodpovídá za daný modul, přičemž může
odpovídat za více modulů. Programátor pak daný tiket zabere, přepne jeho stav
na "V řešení" a začne pracovat na opravě ve formě Patche. Patch je
charakterizován datem vydání a musí být schválen programátorem zodpovědným
za modul, které mohou být v různých programovacích jazycích. Jeden Patch může
řešit více bugů a současně řešit více tiketů a vztahuje se na několik modulů.
Samotní uživatelé mohou rovněž tvořit patche. Takové patche však musí projít
silnější kontrolou než jsou zavedeny do systému. Kromě data vytvoření patche
rovněž evidujte datum zavedení patche do ostrého provozu. Každý uživatel a
programátor je charakterizován základními informacemi (jméno, věk, apod.),
ale současně i jazyky, kterými disponuje, apod. V případě opravení bugů,
mohou být uživatele upozorněni na danou opravu a případně být odměněni peněžní
hodnotou (podle závažnosti bugu či zranitelnosti).
