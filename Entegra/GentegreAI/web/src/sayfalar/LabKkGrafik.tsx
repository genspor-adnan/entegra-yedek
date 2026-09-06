import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from '../bilesenler/bicim';

/**
 * LEVEY-JENNINGS GRAFİĞİ (442, mockup: Ekranlar/Lab/lab_kalite_kontrol.html).
 *
 * <b>Grafiğin işi kaymayı göstermektir.</b> Tek ölçüme bakan bir kontrol
 * rastgele hatayı yakalar; asıl tehlike olan sistematik kayma ancak seri
 * hâlinde görülür - bu yüzden ±1/2/3 SD bantları ve ardışık noktalar.
 *
 * <b>Z skoru sunucudan gelir</b>, burada hesaplanmaz: ölçüm anındaki
 * hedef/SD ile hesaplanıp satırla saklandı. Ekranda yeniden hesaplansaydı
 * hedef güncellendiğinde geçmiş noktalar yerinden oynardı.
 *
 * <b>Cihaz olayları grafiğin altında</b>: kalibrasyon ve reaktif lot
 * değişimi kaymanın nedenidir; ayrı ekranda dursaydı bağ kurulamazdı.
 */

type Satir = Record<string, unknown>;

const OLAY: Record<number, string> = {
  1: 'Kalibrasyon', 2: 'Bakım', 3: 'Reaktif lot değişimi', 4: 'Arıza',
  5: 'KK ret sonrası tekrar', 9: 'Diğer',
};

const DURUM_RENK: Record<number, string> = {
  1: '#2e9e5b',   // kabul
  2: '#d8a418',   // uyarı
  3: '#c0392b',   // ret
};

const sayi = (v: unknown, b = 2): string => {
  if (v === null || v === undefined) return '—';
  const s = Number(v);
  return Number.isFinite(s) ? s.toLocaleString('tr-TR', { maximumFractionDigits: b }) : '—';
};

export function LabKkGrafik() {
  const [param] = useSearchParams();
  const git = useNavigate();
  const tetkikId = Number(param.get('tetkik') ?? 0);
  const lotId = param.get('lot') ? Number(param.get('lot')) : undefined;
  const seviye = param.get('seviye') ? Number(param.get('seviye')) : undefined;
  const [gun, setGun] = useState(30);
  const [veri, setVeri] = useState<{
    tetkik: Satir | null; seri: Satir[]; olaylar: Satir[];
  } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { setVeri(await api.labKkLj(tetkikId, { lotId, seviye, gun }) as never) }
    catch (h) { setHata(hataMetni(h)) }
  }, [tetkikId, lotId, seviye, gun]);

  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const t = veri.tetkik ?? {};
  const seri = veri.seri;

  // Çizim alanı: z ekseni −4 … +4 SD. Ölçüm bu aralığın dışındaysa
  //   kırpılır ama noktanın rengi ve etiketi gerçeği söyler.
  const G = 900, Y = 260, solBosluk = 46, sagBosluk = 12, ustBosluk = 14, altBosluk = 28;
  const cizimG = G - solBosluk - sagBosluk;
  const cizimY = Y - ustBosluk - altBosluk;
  const zY = (z: number) => ustBosluk + cizimY / 2 - (Math.max(-4, Math.min(4, z)) / 4)
                            * (cizimY / 2);
  const nX = (i: number) => seri.length <= 1
    ? solBosluk + cizimG / 2
    : solBosluk + (i * cizimG) / (seri.length - 1);

  const bant = (z: number, renk: string, kalin = false) => (
    <line key={`b${z}`} x1={solBosluk} x2={G - sagBosluk} y1={zY(z)} y2={zY(z)}
          stroke={renk} strokeWidth={kalin ? 1.4 : 1}
          strokeDasharray={z === 0 ? '' : '4 3'} />
  );

  const noktalar = seri.map((s, i) => ({
    x: nX(i), y: zY(Number(s.z ?? 0)), s,
  }));
  const yol = noktalar.map((n, i) => `${i === 0 ? 'M' : 'L'} ${n.x} ${n.y}`).join(' ');

  const gecerli = Boolean(t.gecerli);
  const hedef = seri.length > 0 ? seri[seri.length - 1].hedef : null;
  const sd = seri.length > 0 ? seri[seri.length - 1].sd : null;

  return (
    <div className="rapor-cikti">
      <div className="cikti-arac">
        <button className="d bir" onClick={() => window.print()}>🖨 Yazdır</button>
        {[15, 30, 60, 90].map(g => (
          <button key={g} className={`d${g === gun ? ' bir' : ''}`}
                  onClick={() => setGun(g)}>{g} gün</button>
        ))}
        <span style={{ marginLeft: 'auto' }} />
        {/* KK GEÇERLİLİĞİ oto-onayı doğrudan etkiler: rozet burada da
            görünsün ki teknisyen "sonuçlar niye onaylanmıyor" diye
            aramasın. */}
        <span className={`rozet ${gecerli ? 'olumlu' : 'uyari'}`}
              style={{ marginRight: 8 }}>
          {gecerli ? 'KK geçerli — oto-onay açık' : 'KK RET — oto-onay kapalı'}
        </span>
        <button className="d" onClick={() => git(-1)}>✖ Kapat</button>
      </div>

      <div className="cikti-sayfa">
        <div className="rapadi">
          Levey-Jennings · {String(t.kod ?? '')} — {String(t.ad ?? '')}
        </div>

        <div className="kimlik">
          <div><span className="et">Hedef ± SD</span>
               <span className="dg">
                 {hedef !== null ? `${sayi(hedef, 3)} ± ${sayi(sd, 3)}` : '—'}
                 {String(t.birim ?? '') ? ` ${t.birim}` : ''}
               </span></div>
          <div><span className="et">Ölçüm sayısı</span>
               <span className="dg">{seri.length} (son {gun} gün)</span></div>
          <div><span className="et">Kontrol materyali</span>
               <span className="dg">
                 {seri.length > 0
                   ? `${String(seri[0].materyal ?? '')} · lot ${String(seri[0].lot ?? '')}`
                   : '—'}
               </span></div>
          <div><span className="et">Ret / uyarı</span>
               <span className="dg">
                 {seri.filter(s => Number(s.durum) === 3).length} ret ·{' '}
                 {seri.filter(s => Number(s.durum) === 2).length} uyarı
               </span></div>
        </div>

        {seri.length === 0 ? (
          <p className="not" style={{ marginTop: 12 }}>
            Bu dönemde kontrol ölçümü yok.
          </p>
        ) : (
          <svg viewBox={`0 0 ${G} ${Y}`} className="lj-grafik" role="img"
               aria-label="Levey-Jennings grafiği">
            {/* ±3 SD kırmızı, ±2 SD sarı, ±1 SD yeşil, orta çizgi hedef */}
            {bant(3, '#e2b4ae')}{bant(-3, '#e2b4ae')}
            {bant(2, '#e6d3a3')}{bant(-2, '#e6d3a3')}
            {bant(1, '#bfe0cb')}{bant(-1, '#bfe0cb')}
            {bant(0, '#8fa3b8', true)}

            {[3, 2, 1, 0, -1, -2, -3].map(z => (
              <text key={`e${z}`} x={solBosluk - 8} y={zY(z) + 3} textAnchor="end"
                    className="lj-eksen">
                {z > 0 ? `+${z}s` : z === 0 ? 'hedef' : `${z}s`}
              </text>
            ))}

            <path d={yol} fill="none" stroke="#4d8fd6" strokeWidth={1.2} />

            {noktalar.map((n, i) => (
              <g key={i}>
                <circle cx={n.x} cy={n.y} r={Number(n.s.durum) === 1 ? 3.5 : 4.5}
                        fill={DURUM_RENK[Number(n.s.durum ?? 1)]} />
                {/* İHLAL ETİKETİ: hangi kuralın tetiklendiği noktanın
                    üstünde yazar - grafiğe bakan kişi tabloyu açmadan
                    "neden ret" sorusunu cevaplayabilmeli. */}
                {(n.s.ihlaller as string[] | undefined)?.length ? (
                  <text x={n.x} y={n.y - 8} textAnchor="middle" className="lj-ihlal">
                    {(n.s.ihlaller as string[]).join('·')}
                  </text>
                ) : null}
              </g>
            ))}

            {/* Tarih ekseni: ilk, orta ve son nokta yeter - her noktaya
                tarih yazmak grafiği okunmaz yapıyor. */}
            {[0, Math.floor((seri.length - 1) / 2), seri.length - 1]
              .filter((v, i, a) => a.indexOf(v) === i && v >= 0)
              .map(i => (
                <text key={`t${i}`} x={nX(i)} y={Y - 8} textAnchor="middle"
                      className="lj-eksen">
                  {String(seri[i].zaman ?? '').slice(8, 10)}.
                  {String(seri[i].zaman ?? '').slice(5, 7)}
                </text>
              ))}
          </svg>
        )}

        <div className="bolum">
          <h3>Ölçümler</h3>
          <table className="cikti-tablo">
            <thead>
              <tr>
                <th>Tarih</th><th>Sev.</th><th>Sonuç</th><th>Z</th>
                <th>Kural</th><th>Kaynak</th><th>Durum</th><th>Düzeltici faaliyet</th>
              </tr>
            </thead>
            <tbody>
              {[...seri].reverse().map((s, i) => (
                <tr key={i} className={Number(s.durum) === 3 ? 'panik' : ''}>
                  <td>{tarihSaat(s.zaman)}</td>
                  <td>{String(s.seviye ?? '')}</td>
                  <td className="sag">{sayi(s.deger, 3)}</td>
                  <td className="sag">
                    {Number(s.z ?? 0) > 0 ? '+' : ''}{sayi(s.z, 2)}
                  </td>
                  <td>{(s.ihlaller as string[] | undefined)?.join(' · ') || '—'}</td>
                  <td>{Number(s.kaynak) === 1 ? `Cihaz ${String(s.cihazKod ?? '')}`
                                              : 'Elle'}</td>
                  <td>
                    {Number(s.durum) === 3 ? 'RET'
                      : Number(s.durum) === 2 ? 'Uyarı' : 'Kabul'}
                  </td>
                  {/* RET ama aksiyon boşsa denetimde açık kalır: tabloda
                      açıkça "kaydedilmedi" yazar. */}
                  <td className={Number(s.durum) === 3 && !String(s.aksiyon ?? '').trim()
                                   ? 'vurgu' : ''}>
                    {String(s.aksiyon ?? '').trim()
                      || (Number(s.durum) === 3 ? 'KAYDEDİLMEDİ' : '—')}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {veri.olaylar.length > 0 && (
          <div className="bolum">
            <h3>Cihaz olayları (aynı dönem)</h3>
            <table className="cikti-tablo">
              <thead>
                <tr><th>Zaman</th><th>Cihaz</th><th>Olay</th><th>Lot</th>
                    <th>Açıklama</th></tr>
              </thead>
              <tbody>
                {veri.olaylar.map((o, i) => (
                  <tr key={i}>
                    <td>{tarihSaat(o.zaman)}</td>
                    <td>{String(o.cihaz ?? '—')}</td>
                    <td>{OLAY[Number(o.olay ?? 1)] ?? '—'}</td>
                    <td>{String(o.lot ?? '') || '—'}</td>
                    <td>{String(o.aciklama ?? '')}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <div className="dipnot">
          Westgard kuralları: 1₃ₛ tek ölçüm ±3 SD dışında (rastgele hata) ·
          2₂ₛ ardışık iki ölçüm aynı yönde ±2 SD dışında (sistematik hata) ·
          R₄ₛ aynı çalışmada iki seviye arası 4 SD açıklık · 4₁ₛ ve 10ₓ kayma
          uyarıları. Ret hâlinde düzeltici faaliyet ve etkilenen hasta
          sonuçlarının gözden geçirilmesi zorunludur (TS EN ISO 15189).
        </div>
      </div>
    </div>
  );
}
