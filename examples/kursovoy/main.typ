#import "../../src/export.typ": appendix-heading, appendixes, gost, kursovoy-title

#show: gost.with(
  title-template: kursovoy-title,
  department: "информационных технологий и цифровой экономики",
  work-type: "КУРСОВАЯ РАБОТА",
  discipline: "Методы и средства проектирования информационных систем",
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
#show figure.where(kind: table): set block(breakable: false)

#set raw(theme: none)
#show raw.where(block: true): set text(font: ("Courier New", "DejaVu Sans Mono"), size: 9.5pt, fill: black)
#show raw.where(block: true): set par(leading: 0.55em)
#show raw.where(block: true): set block(above: 1.2em, below: 1.2em)
#outline()
#show table: it => {
  show raw: set text(font: ("Courier New", "DejaVu Sans Mono"), size: 9.5pt)
  it
}

#include "chapters/01-vvedenie.typ"
#include "chapters/02-proektirovanie.typ"
#include "chapters/03-realizaciya.typ"
#include "chapters/04-testirovanie.typ"
#include "chapters/05-zaklyuchenie.typ"

#bibliography("refs.bib")

#show: appendixes

#appendix-heading("справочное")[SQL-скрипт создания таблиц локальной базы данных]

```sql
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS organizations (
  id TEXT PRIMARY KEY,
  legal_form TEXT NOT NULL DEFAULT 'ООО',
  name TEXT NOT NULL,
  inn TEXT NOT NULL,
  kpp TEXT DEFAULT '',
  ogrn TEXT DEFAULT '',
  address TEXT DEFAULT '',
  bank_name TEXT DEFAULT '',
  bank_bik TEXT DEFAULT '',
  bank_corr TEXT DEFAULT '',
  bank_account TEXT DEFAULT '',
  director TEXT DEFAULT '',
  accountant TEXT DEFAULT '',
  next_invoice_number INTEGER NOT NULL DEFAULT 1,
  is_active INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS counterparties (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  inn TEXT NOT NULL,
  kpp TEXT DEFAULT '',
  ogrn TEXT DEFAULT '',
  address TEXT DEFAULT '',
  basis TEXT DEFAULT 'Без договора',
  bases TEXT DEFAULT '[]',
  signer TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS invoices (
  id TEXT PRIMARY KEY,
  counterparty_id TEXT NOT NULL,
  number TEXT NOT NULL,
  date TEXT NOT NULL,
  due_date TEXT,
  paid_at TEXT,
  vat_type TEXT NOT NULL DEFAULT 'none',
  status TEXT NOT NULL DEFAULT 'sent',
  total TEXT NOT NULL DEFAULT '0.00',
  vat_amount TEXT NOT NULL DEFAULT '0.00',
  total_with_vat TEXT NOT NULL DEFAULT '0.00',
  service_month INTEGER,
  service_year INTEGER,
  FOREIGN KEY (counterparty_id) REFERENCES counterparties(id)
);

CREATE TABLE IF NOT EXISTS invoice_positions (
  id TEXT PRIMARY KEY,
  invoice_id TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 1,
  name TEXT NOT NULL,
  quantity TEXT NOT NULL DEFAULT '1',
  unit TEXT NOT NULL DEFAULT 'шт.',
  price TEXT NOT NULL DEFAULT '0.00',
  amount TEXT NOT NULL DEFAULT '0.00',
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
);
```

#appendix-heading("справочное")[Листинг моста IPC и функции расчета итогов с НДС]

Ниже приведен фрагмент скрипта `desktop/preload.js`, обеспечивающего изолированный доступ клиентского приложения к нативным возможностям операционной системы через `contextBridge`.

```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  saveFile: (payload) => ipcRenderer.invoke('save-file', payload),
  selectFolder: () => ipcRenderer.invoke('select-folder'),
  generatePdf: (html, filename) =>
    ipcRenderer.invoke('generate-pdf', { html, filename }),
  printHtml: (html) => ipcRenderer.invoke('print-html', html),
  getHwid: () => ipcRenderer.invoke('get-hwid'),
  getTrialCount: () => ipcRenderer.invoke('get-trial-count'),
  incrementTrialCount: () => ipcRenderer.invoke('increment-trial-count'),
});
```

Ниже приведен фрагмент модуля расчета итоговых сумм счета и НДС (`client/src/core/calculations/vat.ts`).

```typescript
export type VatMode = 'none' | 'top_10' | 'top_20' | 'inc_10' | 'inc_20';

export function calculateTotals(
  positions: Array<{ quantity: string; price: string }>,
  mode: VatMode
) {
  const subtotal = positions.reduce((acc, item) => {
    const q = Number(item.quantity.replace(',', '.')) || 0;
    const p = Number(item.price.replace(',', '.')) || 0;
    return acc + Math.round(q * p * 100) / 100;
  }, 0);

  const rate = mode.endsWith('20') ? 20 : mode.endsWith('10') ? 10 : 0;
  let vatAmount = 0;
  let totalWithVat = subtotal;

  if (mode.startsWith('top_')) {
    vatAmount = Math.round(subtotal * rate) / 100;
    totalWithVat = Math.round((subtotal + vatAmount) * 100) / 100;
  } else if (mode.startsWith('inc_')) {
    vatAmount = Math.round((subtotal * rate * 100) / (100 + rate)) / 100;
    totalWithVat = subtotal;
  }

  return {
    total: subtotal.toFixed(2),
    vatAmount: vatAmount.toFixed(2),
    totalWithVat: totalWithVat.toFixed(2),
  };
}
```