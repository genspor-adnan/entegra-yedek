import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';

/**
 * SEÇİLİ TETKİK paneli (492) - Tetkik Kataloğu listesinin sağında.
 * Mockup: Ekranlar/Lab/lab_tetkik_katalogu.html (sağ kolon).
 *
 * Katalogda gezerken sorulan sorular kartı açmayı gerektirmeyecek kadar
 * kısadır: "bunun LOINC'i ne", "referans aralıkları neye göre değişiyor",
 * "hangi panellerde var", "şimdi istense sonuç ne zaman çıkar". Panel bunları
 * satır seçilir seçilmez gösterir.
 *
 * HESAP YOK: sonuç zamanı da, referans "kime" cümlesi de sunucudan gelir
 * (fn_lab_tetkik_sonuc_zamani, fn_lab_referans_kime) - aynı cümleyi tetkik
 * kartı da yazıyor, ikisi ayrılmasın.
 */
interface Ozet {
  tetkik: Record<string, unknown>;
  referanslar: Record<string, unknown>[];
  paneller: { id: number; ad: string }[];
  istemAdedi: number;
}

const metin = (v: unknown) => (v === null || v === undefined ? '' : String(v));
const sayiMetni = (v: unknown) => {
  if (v === null || v === undefined || v === '') return '';
  const n = Number(v);
  return Number.isFinite(n) ? n.toLocaleString('tr-TR', { maximumFractionDigits: 6 }) : String(v);
};

/** "2026-09-09T16:00:00" -> "Çar 09.09 16:00". */
function zamanMetni(v: unknown): string {
  const s = metin(v);
  if (!s) return '—';
  const t = new Date(s);
  if (Number.isNaN(t.getTime())) return '—';
  const gunler = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  const p = (n: number) => String(n).padStart(2, '0');
  return `${gunler[(t.getDay() + 6) % 7]} ${p(t.getDate())}.${p(t.getMonth() + 1)} `
       + `${p(t.getHours())}:${p(t.getMinutes())}`;
}

/** 60 dk -> "1 sa", 30240 dk -> "21 gün" (liste kolonuyla aynı dil). */
function tatMetni(dk: unknown): string {
  const n = Number(dk);
  if (!Number.isFinite(n) || n <= 0) return '—';
  if (n < 60) return `${n} dk`;
  if (n < 60 * 48) return `${Math.round(n / 60)} sa`;
  return `${Math.round(n / 1440)} gün`;
}

export function LabTetkikOzeti({ id }: { id: number | null }) {
  const [veri, setVeri] = useState<Ozet | null>(null);
  const [hata, setHata] = useState('');

  // BAYAT YANIT YAZMASIN: listede satirdan satira hizli gecilince birden fazla
  //   istek ucusta olur; once baslayan sonra donerse panel artik SECILI OLMAYAN
  //   tetkigi gosterirdi. Etki temizligi cevabi gecersiz kilar.
  useEffect(() => {
    if (!id) { setVeri(null); setHata(''); return }
    let iptal = false;
    void (async () => {
      try {
        const y = await api.labTetkikOzeti(id);
        if (!iptal) { setVeri(y); setHata('') }
      } catch (h) { if (!iptal) { setHata(hataMetni(h)); setVeri(null) } }
    })();
    return () => { iptal = true };
  }, [id]);

  // Satir secili degilken de kutu cizilir: panel kaybolunca grid genisleyip
  //   her secimde yeniden daralir - ekran zipliyor gorunurdu.
  if (!id)
    return (
      <div className="lab-detay">
        <div className="kagrup"><h6>Seçili Tetkik</h6>
          <div className="sonuk" style={{ padding: 12 }}>
            Ayrıntı için listeden bir tetkik seçin.
          </div>
        </div>
      </div>
    );

  if (hata) return <div className="lab-detay"><div className="hata-kutusu">{hata}</div></div>;
  if (!veri) return null;

  const t = veri.tetkik;
  const birim = metin(t.birim);
  const aralik = (alt: unknown, ust: unknown) => {
    const a = sayiMetni(alt), u = sayiMetni(ust);
    if (!a && !u) return '—';
    return `${a || '…'} — ${u || '…'}${birim ? ` ${birim}` : ''}`;
  };
  const panik = () => {
    const a = sayiMetni(t.panikAlt), u = sayiMetni(t.panikUst);
    if (!a && !u) return '—';
    return [a ? `< ${a}` : '', u ? `> ${u}` : ''].filter(Boolean).join(' · ')
         + (birim ? ` ${birim}` : '');
  };

  return (
    <div className="lab-detay">
      <div className="kagrup">
        <h6>Seçili Tetkik</h6>
        <div style={{ padding: '8px 10px' }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--vurgu)' }}>
            {metin(t.ad)}
          </div>
          <div className="sonuk" style={{ margin: '2px 0 8px' }}>
            {[metin(t.kod), metin(t.kisaAd), metin(t.bolumAdi)].filter(Boolean).join(' · ')}
          </div>
          <div className="lab-alanlar">
            <div className="fld"><label>LOINC / SKRS</label>
              <div className="deger">
                {[metin(t.loinc), metin(t.skrsKod)].filter(Boolean).join(' · ') || '—'}
              </div></div>
            <div className="fld"><label>Ölçülebilir aralık</label>
              <div className="deger">{aralik(t.olculebilirAlt, t.olculebilirUst)}</div></div>
            <div className="fld"><label>Panik değer</label>
              <div className="deger">{panik()}</div></div>
            <div className="fld"><label>Yöntem</label>
              <div className="deger">{metin(t.yontem) || '—'}</div></div>
          </div>
        </div>
      </div>

      <div className="kagrup">
        <h6>Referans Aralıkları
          <span className="sp">{veri.referanslar.length} kural</span>
        </h6>
        <table className="detay-tablo">
          <tbody>
            {veri.referanslar.map((r, i) => (
              <tr key={i}>
                <td style={{ width: 110 }}>
                  <b>{metin(r.metin) || aralik(r.alt, r.ust)}</b>
                </td>
                <td className="sonuk">{metin(r.kime)}</td>
              </tr>
            ))}
            {veri.referanslar.length === 0 && (
              /* Referansi olmayan tetkik BAYRAK URETEMEZ - listedeki
                 "Referans" kolonu da bu eksigi gosteriyor. */
              <tr><td className="sonuk" style={{ padding: 8 }}>
                Referans aralığı tanımlı değil — sonuçlar bayraksız çıkar.
              </td></tr>
            )}
          </tbody>
        </table>
      </div>

      <div className="kagrup">
        <h6>Sonuç Ne Zaman Çıkar
          <span className="sp">şimdi istenirse</span>
        </h6>
        <div className="lab-ozet" style={{ padding: 8 }}>
          <div className="lab-ozet-kutu bilgi">
            <div className="b">Normal</div>
            <div className="d">{zamanMetni(t.sonucZamani)}</div>
            <div className="sonuk">TAT {tatMetni(t.hedefTatDk)}</div>
          </div>
          <div className="lab-ozet-kutu bilgi">
            <div className="b">Acil TAT</div>
            <div className="d">{tatMetni(t.acilTatDk)}</div>
            <div className="sonuk">acil istemde hedef</div>
          </div>
        </div>
      </div>

      <div className="kagrup">
        <h6>Nerede Kullanılıyor</h6>
        <table className="detay-tablo">
          <tbody>
            {veri.paneller.map(p => (
              <tr key={p.id}><td>📦 {p.ad}</td></tr>
            ))}
            {veri.paneller.length === 0 && (
              <tr><td className="sonuk">Hiçbir panelde yok</td></tr>
            )}
            <tr><td className="sonuk">
              Son 30 günde <b>{veri.istemAdedi.toLocaleString('tr-TR')}</b> istem
            </td></tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}
