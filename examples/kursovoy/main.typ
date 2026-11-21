#import "../../src/export.typ": appendix-heading, appendixes, gost, kursovoy-title

#show: gost.with(
  title-template: kursovoy-title,
  department: "информационных технологий и цифровой экономики",
  work-type: "КУРСОВАЯ РАБОТА", // если нужен проект — поменяй на "КУРСОВОЙ ПРОЕКТ"
  discipline: "Методы и средства проектирования информационных систем", // TODO: проверь точное название предмета
  topic: "Разработка информационной системы первичного документооборота и контроля взаиморасчетов с контрагентами",
  student: "М.В. Вераксо",
  course-group: "4/147",
  supervisor: (
    position: "к.т.н., доцент каф. ИТиЦЭ",
    name: "Е.С. Константинов",
  ),
  city: "Иваново",
  year: 2026,
)

#import "numbering.typ": gost-numbering
#show: gost-numbering

#show raw.where(block: true): set text(size: 10pt)

#outline()

#include "chapters/01-vvedenie.typ"
#include "chapters/02-proektirovanie.typ"
#include "chapters/03-realizaciya.typ"
// #include "chapters/04-testirovanie.typ"
// #include "chapters/05-zaklyuchenie.typ"

#bibliography("refs.bib")