-- Migration 014: Rename categories
-- 1. "Men's Suit" -> "Couples" ("የጥንዶች ልብስ")
-- 2. "Casual" -> "Satin" ("ሳቲን")
-- 3. "Formal" -> "Abaya" ("አባያ")

UPDATE categories
SET name_en = 'Couples',
    name_am = 'የጥንዶች ልብስ',
    name_om = 'Uffata Jaalalloo',
    name_so = 'Dhar Lamaan'
WHERE name_en = 'Men''s Suit';

UPDATE categories
SET name_en = 'Satin',
    name_am = 'ሳቲን',
    name_om = 'Satiin',
    name_so = 'Satiin'
WHERE name_en = 'Casual';

UPDATE categories
SET name_en = 'Abaya',
    name_am = 'አባያ',
    name_om = 'Abaayaa',
    name_so = 'Cabaayad'
WHERE name_en = 'Formal';
