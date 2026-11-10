import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { AkisDenemeAdimi } from '../../api/uclar/onay';
import { hataMetni } from '../../api/sozlesme';
import { GenGrid } from '../GenGrid';
import { tutarOku } from '../bicim';
import { c } from '../../dil/ceviri';

/**
 * ONAY AKIŞI KARTI PARÇALARI (mockup Ekranlar/Onay/onay_akis_karti.html, kullanıcı 10.11.2026 "onay akış listesi ve
 * kartına aktar"):
 *  · AkisZincirOnizleme - Basamaklar sekmesinin altında: örnek ölçü + bayraklarla hangi basamakların doğacağı
 *    ("Akışı Dene" kuru çalıştırması, kayıt üretmez). Önceden yalnız listedeki aksiyon iki soru penceresiyle
 *    metin dökümü veriyordu; kartta basamaklar düzenlenirken anında denenebilsin.
 *  · YuruyenOnaylarSekmesi - bu akışla açık onaylar (Onayımdakiler listesi akış koduna süzülmüş).
 *  · AkisGecmisSekmesi - akış ve basamak tanımındaki değişiklikler (islem_log; tablo 1295 kart, 1296 basamak).
 */

/** Deneme sonucu satırının rozet metni - saf, test edilir. */
export function adimOzeti(a: AkisDenemeAdimi, rolAdi: (rol: number) => string): string {
  const kime = a.sahipTuru === 2 ? c('kullanıcı') : a.sahipTuru === 3 ? c('âmir') : a.sahipTuru === 4 ? c('kayıt sahibi') : rolAdi(a.rol);
  // Eşik 0 = koşulsuz (her kayıtta) - "≥ 0" yazmak yanıltır.
  const kosul = a.esikAlt != null && Number(a.esikAlt) > 0 ? ` ≥ ${Number(a.esikAlt).toLocaleString('tr-TR')}` : a.bayrak ? ` ⚑ ${a.bayrak}` : '';
  return `${a.sira}. ${a.ad} (${kime})${kosul}`;
}

const ROL_ADI: Record<number, string> = {
  1: 'Birim sorumlusu', 2: 'Satınalma', 3: 'Başhekim / Müdür', 4: 'Mali işler', 5: 'Üst yönetim',
};

/** Bayrak metnini (virgül / boşluk ayraçlı) kümeye çevirir - saf. */
export const bayraklariAyir = (metin: string): string[] =>
  metin.split(/[,\s]+/).map(x => x.trim()).filter(Boolean);

export function AkisZincirOnizleme({ akisId, olcuAdi, tanimliBasamak }: {
  akisId: number;
  olcuAdi: string;
  /** Karttaki basamak sayısı - değişince deneme yenilenir (kaydedilmiş basamaklar üzerinden). */
  tanimliBasamak: number;
}) {
  const [olcu, setOlcu] = useState('0');
  const [bayrak, setBayrak] = useState('');
  const [sonuc, setSonuc] = useState<{ adimlar: AkisDenemeAdimi[]; tanimliBasamak: number; uyarilar: string[] } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let iptal = false;
    const z = setTimeout(() => {
      api.onayAkisDene(akisId, tutarOku(olcu), bayraklariAyir(bayrak))
        .then(y => { if (!iptal) { setSonuc(y); setHata(null) } })
        .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    }, 300);
    return () => { iptal = true; clearTimeout(z) };
  }, [akisId, olcu, bayrak, tanimliBasamak]);

  return (
    <div className="oak-oniz" data-testid="akis-onizleme">
      <div className="oak-oniz-bas">
        <b>{c('Zincir önizlemesi')}</b>
        <label>{olcuAdi || c('Ölçü')}
          <input value={olcu} onChange={e => setOlcu(e.target.value)} style={{ width: 110 }} className="hiza-sag" />
        </label>
        <label>{c('Bayraklar')}
          <input value={bayrak} onChange={e => setBayrak(e.target.value)} placeholder="butce, butce_asildi" style={{ width: 200 }} />
        </label>
        <span className="sonuk">{c('yalnız deneme - kayıt üretmez')}</span>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {sonuc && (
        <div className="oak-zincir">
          {sonuc.adimlar.length === 0 && <span className="rozet uyari">{c('Bu ölçüde hiçbir basamak doğmuyor - kayıt imzasız geçer.')}</span>}
          {sonuc.adimlar.map((a, i) => (
            <span key={a.sira} className="oak-adim">
              <span className="rozet mor" title={a.sureGun > 0 ? `${a.sureGun} ${c('gün')}` : undefined}>
                {adimOzeti(a, r => ROL_ADI[r] ?? `rol ${r}`)}{a.eImza === 1 ? ' · e-imza' : ''}
              </span>
              {i < sonuc.adimlar.length - 1 && <span className="sonuk"> › </span>}
            </span>
          ))}
          <span className="sonuk" style={{ marginLeft: 8 }}>
            {sonuc.adimlar.length} / {sonuc.tanimliBasamak} {c('basamak')}
          </span>
          {sonuc.uyarilar.map(u => <div key={u} className="rozet uyari" style={{ marginTop: 4 }}>{u}</div>)}
        </div>
      )}
    </div>
  );
}

export function YuruyenOnaylarSekmesi({ akisKod }: { akisKod: string }) {
  if (!akisKod) return <div className="bilgi-kutusu">{c('Akış kaydedilince yürüyen onaylar burada listelenir.')}</div>;
  return (
    <GenGrid kaynak="onayKutusu" gomulu seritGizli boyut={50}
             sabitFiltre={{ op: 'and', kosullar: [{ alan: 'akisKod', op: 'esit', deger: akisKod }] }}
             gizliKolonlar={['akisAd', 'akisKod']} />
  );
}

/** Akış (1295) ve basamak (1296, üst kayıt akış) logları tek listede. */
export function AkisGecmisSekmesi({ akisId }: { akisId: number }) {
  return (
    <GenGrid kaynak="islem-log" gomulu seritGizli boyut={50}
             sabitFiltre={{ op: 'or', kosullar: [
               { op: 'and', kosullar: [{ alan: 'tabloId', op: 'esit', deger: 1295 }, { alan: 'kayitId', op: 'esit', deger: akisId }] },
               { op: 'and', kosullar: [{ alan: 'ustTabloKod', op: 'esit', deger: 1295 }, { alan: 'ustKayitId', op: 'esit', deger: akisId }] },
             ] }}
             gizliKolonlar={['modul', 'kod', 'ad', 'ip', 'kayitId']} />
  );
}
