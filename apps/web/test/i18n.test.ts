import test, { describe } from 'node:test';
import assert from 'node:assert/strict';
import { translations, SUPPORTED_LANGUAGES, TranslationKey } from '../src/lib/i18n/translations';

describe('Sprint 13 & Feature 2: i18n & 360 Viewer Translations Tests', () => {
  const languages = ['en', 'am', 'om', 'so'] as const;
  const englishKeys = Object.keys(translations.en) as TranslationKey[];

  test('Supported languages include all 4 required Ethiopian languages', () => {
    assert.deepEqual(
      SUPPORTED_LANGUAGES.map((l) => l.code),
      ['en', 'am', 'om', 'so']
    );
    assert.equal(SUPPORTED_LANGUAGES.find((l) => l.code === 'am')?.nativeLabel, 'አማርኛ');
    assert.equal(SUPPORTED_LANGUAGES.find((l) => l.code === 'om')?.nativeLabel, 'Afaan Oromoo');
    assert.equal(SUPPORTED_LANGUAGES.find((l) => l.code === 'so')?.nativeLabel, 'Af Soomaali');
  });

  languages.forEach((lang) => {
    test(`Language ${lang} has all ${englishKeys.length} required translation keys`, () => {
      const langDict = translations[lang];
      assert.ok(langDict, `Dictionary for ${lang} must exist`);

      englishKeys.forEach((key) => {
        const val = langDict[key];
        assert.ok(val !== undefined, `Missing key "${key}" in language "${lang}"`);
        assert.equal(typeof val, 'string');
        assert.ok(val.trim().length > 0, `Empty translation for key "${key}" in language "${lang}"`);
      });
    });
  });

  test('View 360° button label is accurately translated in all 4 languages', () => {
    assert.equal(translations.en['design.view_360'], 'View 360°');
    assert.equal(translations.am['design.view_360'], '360° እይታ');
    assert.equal(translations.om['design.view_360'], 'Ilaalcha 360°');
    assert.equal(translations.so['design.view_360'], 'Aragtida 360°');
  });

  test('Translations contain parameters correctly formatted ({count}, {total}, {price})', () => {
    languages.forEach((lang) => {
      const dict = translations[lang];
      assert.ok(dict['catalog.showing_count'].includes('{count}'));
      assert.ok(dict['catalog.showing_count'].includes('{total}'));
      assert.ok(dict['catalog.currency'].includes('{price}'));
      assert.ok(dict['viewer360.counter'].includes('{current}'));
      assert.ok(dict['viewer360.counter'].includes('{total}'));
    });
  });
});
