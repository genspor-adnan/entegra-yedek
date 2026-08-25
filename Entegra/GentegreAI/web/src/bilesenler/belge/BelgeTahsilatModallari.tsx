import { GenForm } from '../GenForm';
import { KasaIslemKarti } from '../../sayfalar/KasaIslemKarti';
import type { useBelgeTahsilat } from '../../sayfalar/belgeTahsilat';

/**
 * Belge kartinin ustunde acilan TAHSILAT pencereleri.
 *
 * Uc ayri acilis yolu var ve ucu de ayni yere baglanir (kasa_islem.belge_id):
 *   1) duzeltme  - mevcut kasa islemi kayit kimligiyle acilir,
 *   2) cek/senet - once jenerik kiymet karti, kaydedilince ona BAGLI kasa islemi,
 *   3) dogrudan  - nakit/banka/POS icin kasa islemi.
 *
 * Durum BelgeKarti'da degil `belgeTahsilat.ts` hook'unda; burasi yalnizca cizer.
 */
export function BelgeTahsilatModallari({ tahsilat, cari, genelToplam }: {
  tahsilat: ReturnType<typeof useBelgeTahsilat>;
  cari: { id: number; unvan: string } | null;
  /** Belgenin dip toplami - tahsilat tutari onyuklu gelsin. */
  genelToplam?: unknown;
}) {
  const {
    cekTuru, setCekTuru, tahsilatAcilis, setTahsilatAcilis,
    tahsilatAcik, setTahsilatAcik, tahsilatKayitId, setTahsilatKayitId,
    tazele, cekKartKaydedildi,
  } = tahsilat;
  const senetMi = cekTuru?.tur === 24 || cekTuru?.tur === 34;

  return (
    <>
      {/* MEVCUT tahsilati duzeltme (cift tik / ✎): kasa karti kayit kimligiyle
          acilir. Gerceklesmis islemi kart zaten salt gorunum yapar. */}
      {tahsilatKayitId !== null && (
        <KasaIslemKarti
          kayitIdProp={tahsilatKayitId}
          onKapat={() => { setTahsilatKayitId(null); tazele() }}
        />
      )}

      {/* CEK/SENET: jenerik kiymet karti (kasa listesindeki akisla ayni).
          Cari ve tutar belgeden onyuklenir - kullanici ayni bilgiyi ikinci
          kez girmesin. */}
      {cekTuru !== null && (
        <GenForm
          kaynak="cek-senet"
          id="yeni"
          baslik={senetMi ? 'Senet' : 'Çek'}
          yeniKayitVarsayilanlari={{
            tur: senetMi ? 2 : 1,
            yon: cekTuru.tur === 33 || cekTuru.tur === 34 ? 2 : 1,
            ...(cari ? { tarafId: cari.id } : {}),
            ...(genelToplam ? { tutar: Number(genelToplam) } : {}),
          }}
          onKapat={() => setCekTuru(null)}
          onKaydedildi={csId => { void cekKartKaydedildi(cekTuru.tur, cekTuru.belgeId, csId) }}
        />
      )}

      {tahsilatAcilis !== null && (
        <KasaIslemKarti
          acilis={tahsilatAcilis}
          onKapat={() => { setTahsilatAcilis(null); tazele() }}
        />
      )}

      {tahsilatAcik !== null && (
        <KasaIslemKarti
          acilis={{
            tur: tahsilatAcik,
            tarafId: cari?.id,
            tarafUnvan: cari?.unvan,
            belgeId: tahsilat.belgeId,
            tutar: String(genelToplam ?? ''),
          }}
          onKapat={() => { setTahsilatAcik(null); tazele() }}
        />
      )}
    </>
  );
}
