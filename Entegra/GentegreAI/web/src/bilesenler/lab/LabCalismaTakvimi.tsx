import { Fragment, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { yerelAnMetni } from '../bicim';

/**
 * ÇALIŞMA TAKVİMİ ve SONUÇ ÖNİZLEMESİ (487).
 *
 * Tetkik kartının "Çalışma Zamanları" sekmesinde, alanların altında: haftalık
 * çalışma tablosu ve üç özet kutusu (şimdi istenirse · kabul son saatinden
 * sonra · acil istenirse).
 *
 * HESAP SUNUCUDA. Bileşen düzeni parametre olarak gönderir, saatleri sunucu
 * söyler (`fn_lab_calisma_sonuc_zamani`). Aynı kural kaydedilmiş tetkik için
 * istem ekranında da çalışıyor; burada ikinci bir hesap yazmak, ekranın
 * söylediği saat ile laboratuvarın planını ayırırdı.
 *
 * KAYDETMEDEN GÜNCELLENİR: kullanıcı düzeni değiştirdikçe önizleme yenilenir -
 * "bu ayarla sonuç ne zaman çıkar" sorusu kaydetmeden cevaplanmalı.
 */
const GUNLER = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

interface Hucre { acik: boolean; sonuc?: string | null }
interface Satir { saat: string; kabulSon: string; gunler: Hucre[] }
interface Yanit {
  duzen: number;
  hafta: Satir[];
  ozet: { simdiKabul: string; simdi: string | null;
          kacirilan: string | null; acil: string | null };
}

export interface CalismaDuzeni {
  calismaDuzeni?: unknown;
  calismaGunleri?: unknown;
  calismaSaatleri?: unknown;
  kabulSonDk?: unknown;
  hedefTatDk?: unknown;
  acilTatDk?: unknown;
  acilBeklemez?: unknown;
}

const sayi = (v: unknown, varsayilan = 0) => {
  const n = Number(v);
  return Number.isFinite(n) ? n : varsayilan;
};

/** "2026-09-09T13:00:00" -> "Çar 09.09 13:00". Boşsa "—". */
function zamanMetni(iso: string | null | undefined): string {
  if (!iso) return '—';
  const t = new Date(iso);
  if (Number.isNaN(t.getTime())) return '—';
  const p = (n: number) => String(n).padStart(2, '0');
  return `${GUNLER[(t.getDay() + 6) % 7]} ${p(t.getDate())}.${p(t.getMonth() + 1)} `
       + `${p(t.getHours())}:${p(t.getMinutes())}`;
}

/** Kabulden sonuca kaç saat/gün geçiyor - "26 sa sonra". */
function farkMetni(bas: string, son: string | null | undefined): string {
  if (!son) return '';
  const dk = (new Date(son).getTime() - new Date(bas).getTime()) / 60000;
  if (!Number.isFinite(dk) || dk < 0) return '';
  if (dk < 60) return `${Math.round(dk)} dk sonra`;
  if (dk < 60 * 48) return `${Math.round(dk / 60)} sa sonra`;
  return `${Math.round(dk / 1440)} gün sonra`;
}

export function LabCalismaTakvimi({ deger }: { deger: CalismaDuzeni }) {
  const [yanit, setYanit] = useState<Yanit | null>(null);
  const [hata, setHata] = useState('');

  const duzen   = sayi(deger.calismaDuzeni);
  const gunler  = sayi(deger.calismaGunleri);
  const saatler = String(deger.calismaSaatleri ?? '');
  const kabulSonDk = sayi(deger.kabulSonDk, 0);
  const tatDk   = sayi(deger.hedefTatDk);
  const acilTat = sayi(deger.acilTatDk);
  // Mantık alanı sunucudan 0/1, ekranda true/false gelebilir.
  const acilBeklemez = deger.acilBeklemez === true || sayi(deger.acilBeklemez, 1) === 1 ? 1 : 0;

  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.labCalismaTakvimi({
          duzen, gunler, saatler, kabulSonDk, tatDk, acilTatDk: acilTat, acilBeklemez,
          kabul: yerelAnMetni(new Date()),
        });
        if (!iptal) { setYanit(y as Yanit); setHata('') }
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
    })();
    return () => { iptal = true };
  }, [duzen, gunler, saatler, kabulSonDk, tatDk, acilTat, acilBeklemez]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!yanit) return null;

  const o = yanit.ozet;
  return (
    <>
      {/* TAKVİM yalnız SERİ düzeninde anlamlı: sürekli çalışan tetkikte
          gösterilecek bir gün/saat yok, kutu boş bir tablo olurdu. */}
      {yanit.hafta.length > 0 && (
        <div className="kagrup">
          <h6>Haftalık takvim
            <span className="sonuk" style={{ marginLeft: 8, fontWeight: 'normal' }}>
              ▲ kabul son saati · sonuç saati çalışma + TAT
            </span>
          </h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th style={{ width: 150 }}>Saat</th>
                  {GUNLER.map(g => <th key={g} className="orta">{g}</th>)}
                </tr>
              </thead>
              <tbody>
                {/* HER SERİ ÜÇ SATIR (mockup): kabul son saati · çalışma ·
                    sonuç. Tek satırda gösterilince "hangi saatte numune
                    verilebilir" ile "sonuç kaçta çıkar" aynı hücreye
                    sıkışıyordu - oysa kullanıcının sorduğu iki ayrı sorudur. */}
                {yanit.hafta.map((s, si) => (
                  <Fragment key={s.saat}>
                    <tr>
                      <td><span className="sonuk">▲ kabul son</span> <b>{s.kabulSon}</b></td>
                      {s.gunler.map((h, i) => (
                        <td key={i} className="orta">
                          {h.acik ? <span className="rozet uyari">son</span>
                                  : <span className="sonuk">—</span>}
                        </td>
                      ))}
                    </tr>
                    <tr>
                      <td><span className="sonuk">çalışma</span> <b>{s.saat}</b></td>
                      {s.gunler.map((h, i) => (
                        <td key={i} className="orta">
                          {h.acik ? <span className="rozet mavi">{si + 1}. seri</span>
                                  : <span className="sonuk">—</span>}
                        </td>
                      ))}
                    </tr>
                    <tr>
                      <td><span className="sonuk">sonuç</span>{' '}
                        <b>{s.gunler.find(g => g.acik)?.sonuc ?? '—'}</b></td>
                      {s.gunler.map((h, i) => (
                        <td key={i} className="orta">
                          {h.acik ? <span className="rozet ok">çıkar</span>
                                  : <span className="sonuk">—</span>}
                        </td>
                      ))}
                    </tr>
                  </Fragment>
                ))}
              </tbody>
            </table>
        </div>
      )}

      <div className="kagrup">
        <h6>Sonuç ne zaman çıkar
          <span className="sonuk" style={{ marginLeft: 8, fontWeight: 'normal' }}>
            kabul {zamanMetni(o.simdiKabul)} varsayılarak
          </span>
        </h6>
        <div className="lab-ozet">
          <div className="lab-ozet-kutu bilgi">
            <div className="b">Şimdi istenirse</div>
            <div className="d">{zamanMetni(o.simdi)}</div>
            <div className="sonuk">{farkMetni(o.simdiKabul, o.simdi)}</div>
          </div>
          <div className="lab-ozet-kutu bilgi">
            <div className="b">Kabul son saatinden sonra</div>
            <div className="d">{zamanMetni(o.kacirilan)}</div>
            <div className="sonuk">bir sonraki seriye kalır</div>
          </div>
          <div className="lab-ozet-kutu bilgi">
            <div className="b">Acil istenirse</div>
            <div className="d">{zamanMetni(o.acil)}</div>
            <div className="sonuk">
              {acilBeklemez ? 'düzen beklenmez' : 'düzeni bekler'}
            </div>
          </div>
        </div>
        <div className="not" style={{ padding: '6px 10px' }}>
          Sonuç saati <b>hesaplanır, elle yazılmaz</b>: numunenin kabul zamanı →
          takvimdeki ilk uygun çalışma → çalışma + TAT. Kabul son saatini bir dakika
          geçen numune bir sonraki seriye kalır; hastaya söylenen saat de o an değişir.
          {o.simdi === null && (
            <> <b>Tanım eksik:</b> seri düzeninde gün ve saat verilmeden sonuç
            zamanı hesaplanamaz.</>
          )}
        </div>
      </div>
    </>
  );
}
