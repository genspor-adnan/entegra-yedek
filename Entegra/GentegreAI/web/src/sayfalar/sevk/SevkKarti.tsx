import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { SevkOzet } from '../../api/uclar/sevk';
import type { SekmeParcalari } from '../../bilesenler/kartSekmeleri';
import type { Deger } from '../../bilesenler/kartAlanCizim';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';
import { MuayeneHastaBandi, useMuayeneHastaBilgisi } from '../../bilesenler/MuayeneSekmesiz';

/**
 * SEVK KARTI (1110) - mockup Ekranlar/Muayene/sevk_karti_v2.html (sade, tek panel).
 *
 * Altı alan: tür, nereye (kurum dışı: tesis + klinik · kurum içi / yatış: bölüm), neden,
 * ulaşım, not, ekler (otomatik, gösterim). Hasta / hekim / tanı muayeneden, şeritte.
 * Taslak kartın kaydıyla; "İmzala ve gönder" önce kaydeder, sonra gönder ucunu çağırır
 * (durum yalnız uçta değişir). Gönderilmiş sevk salt okunur.
 */

const TUR: Record<number, string> = { 1: 'Kurum dışı', 2: 'Kurum içi', 3: 'Yatış' };
const ULASIM: Record<number, string> = { 1: 'Kendi', 2: 'Ambulans', 3: '112' };
export const SEVK_DURUM: Record<number, string> = { 1: 'Taslak', 2: 'Gönderildi', 3: 'Sonuç döndü', 9: 'Gönderilemedi', 0: 'İptal' };
export const sevkDurumSinif = (d: number) => d === 1 ? 'uyari' : d === 2 ? 'mavi' : d === 3 ? 'olumlu' : d === 9 ? 'hata' : 'gri';

const sayi = (v: unknown) => Number(v ?? 0);
/** Kartın yazdığı alanlar (gönderden önce kaydedilir). */
const YAZILAN = ['tur', 'tesisKodu', 'tesisAd', 'klinikId', 'hedefBolumId', 'neden', 'ulasim', 'notu'] as const;

export function SevkKartGovdesi({ kartId, deger, parcalar, onGonderildi, bantYok }: {
  kartId: number | 'yeni'; deger: Record<string, Deger>; parcalar?: SekmeParcalari;
  /** Gönderilince (pencere kapanır / liste tazelenir). */
  onGonderildi?(): void;
  /** Muayenenin içinden açılan pencerede hasta bandı çizilmez. */
  bantYok?: boolean;
}) {
  const id = kartId === 'yeni' ? null : kartId;
  const durum = sayi(deger.durum) || 1;
  const duzenlenir = durum === 1;
  const [ozet, setOzet] = useState<SevkOzet | null>(null);
  const [gonderiyor, setGonderiyor] = useState(false);
  useEffect(() => {
    if (id === null) return;
    let iptal = false;
    api.sevkOzet(id).then(y => { if (!iptal) setOzet(y) }).catch(() => { if (!iptal) setOzet(null) });
    return () => { iptal = true };
  }, [id, durum]);

  const alanlar = parcalar?.altGrupAlanlari('Sevk') ?? [];
  const kodlar = (ad: string) => Object.entries(alanlar.find(a => a.ad === ad)?.kodlar ?? {});
  const yaz = (ad: string, v: Deger) => { if (duzenlenir) parcalar?.alanDegistir(ad, v) };
  const tur = sayi(deger.tur) || 1;
  const ulasim = sayi(deger.ulasim) || 1;
  const notu = String(deger.notu ?? '');

  const gonder = () => {
    if (id === null) { parcalar?.kaydet(); return }
    if (!notu.trim()) { mesaj(c('Karşı hekime notu yazın.')); return }
    void guvenli(async () => {
      setGonderiyor(true);
      try {
        // Önce taslağı kaydet (güncel sürümle), sonra gönder - durum yalnız uçta değişir.
        const k = await api.kartOku('sevk', id);
        await api.kartGuncelle('sevk', id, {
          surum: k.kart.surum as string,
          kart: Object.fromEntries(YAZILAN.map(a => [a, deger[a] ?? null])),
        });
        const y = await api.sevkGonder(id);
        mesaj(y.mesaj);
        onGonderildi?.();
      } finally { setGonderiyor(false) }
    });
  };

  // HASTA BANDI (kullanıcı 15.10.2026: "yeni sevk ve konsültasyon kartı başına sekmesiz muayenedeki
  //   hasta bandını getir"): sevkin açıldığı muayenenin bandı - ad, yaş, kurum, alerji, uyarılar.
  //   PENCEREDE YOK (muayenenin içinden açılınca muayene bandı zaten üstte - kullanıcı); listeden
  //   açılan kartta muayeneden, yoksa hastanın son muayenesinden.
  const bant = useMuayeneHastaBilgisi(bantYok ? 0 : Number(deger.muayeneId ?? 0), 0, bantYok ? 0 : Number(deger.tarafId ?? 0));
  return (
    <div className="svk-kart">
      {!bantYok && bant && <MuayeneHastaBandi bilgi={bant} />}
      {ozet && (
        <div className="svk-serit">
          <span><b>{ozet.hasta}</b>{ozet.cinsiyetYas && ` · ${ozet.cinsiyetYas}`}{ozet.hastaKod && <span className="not"> · {ozet.hastaKod}</span>}</span>
          {ozet.hekim && <span>{ozet.hekim}{ozet.bolum && ` · ${ozet.bolum}`}</span>}
          {ozet.tani && <span>{ozet.tani}</span>}
          <span className="svk-no">{ozet.no}</span>
          <span className={`rozet ${sevkDurumSinif(durum)}`}>{c(SEVK_DURUM[durum] ?? '')}</span>
        </div>
      )}
      {/* Kart içi hasta seçimi YOK (kullanıcı): yeni kart önce hasta aramasıyla açılır (ListeKarti). */}

      <div className="svk-alanlar">
        <span className="etiket">{c('Tür')} *</span>
        <div className="svk-secim">
          {[1, 2, 3].map(t => (
            <button key={t} type="button" disabled={!duzenlenir} className={tur === t ? 'on' : ''}
                    onClick={() => yaz('tur', t)}>{c(TUR[t])}</button>
          ))}
        </div>

        <span className="etiket">{c('Nereye')} *</span>
        {tur === 1 ? (
          <div className="svk-nereye">
            <input placeholder={c('Tesis (kurum adı)')} value={String(deger.tesisAd ?? '')} disabled={!duzenlenir} maxLength={160}
                   onChange={e => yaz('tesisAd', e.target.value)} />
            <select value={String(deger.klinikId ?? '')} disabled={!duzenlenir}
                    onChange={e => yaz('klinikId', e.target.value ? Number(e.target.value) : null)}>
              <option value="">{c('— klinik —')}</option>
              {kodlar('klinikId').map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
            </select>
          </div>
        ) : (
          <select value={String(deger.hedefBolumId ?? '')} disabled={!duzenlenir}
                  onChange={e => yaz('hedefBolumId', e.target.value ? Number(e.target.value) : null)}>
            <option value="">{c(tur === 3 ? '— servis / bölüm —' : '— bölüm —')}</option>
            {kodlar('hedefBolumId').map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
          </select>
        )}

        <span className="etiket">{c('Neden')} *</span>
        <select value={String(deger.neden ?? '')} disabled={!duzenlenir}
                onChange={e => yaz('neden', Number(e.target.value))}>
          {kodlar('neden').map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
        </select>

        <span className="etiket">{c('Ulaşım')}</span>
        <div className="svk-secim">
          {[1, 2, 3].map(u => (
            <button key={u} type="button" disabled={!duzenlenir} className={ulasim === u ? 'on' : ''}
                    onClick={() => yaz('ulasim', u)}>{c(ULASIM[u])}</button>
          ))}
        </div>

        <span className="etiket">{c('Not (karşı hekime)')} *</span>
        <div>
          <textarea rows={3} maxLength={500} value={notu} disabled={!duzenlenir}
                    onChange={e => yaz('notu', e.target.value)} />
          <span className="not">{notu.length} / 500</span>
        </div>

        <span className="etiket">{c('Ekler')}</span>
        <div className="svk-ekler">
          {ozet?.epikriz && <span>📄 {c('Epikriz')}</span>}
          {(ozet?.lab ?? 0) > 0 && <span>🧪 {c('Lab')} ({ozet!.lab})</span>}
          {(ozet?.goruntuleme ?? 0) > 0 && <span>📈 {c('Görüntüleme')} ({ozet!.goruntuleme})</span>}
          <span className="not">{c('otomatik eklenir')}</span>
        </div>
      </div>

      {durum === 1 && (
        <div className="svk-araclar">
          <span style={{ flex: 1 }} />
          <button type="button" className="d" onClick={() => parcalar?.kaydet()}>💾 {c('Taslak')}</button>
          <button type="button" className="d bir" disabled={gonderiyor} onClick={gonder}>✍ {c('İmzala ve gönder')}</button>
        </div>
      )}
      {durum !== 1 && ozet?.medulaSevkNo && <p className="not ic">{c('Medula sevk no')}: {ozet.medulaSevkNo}</p>}
    </div>
  );
}
