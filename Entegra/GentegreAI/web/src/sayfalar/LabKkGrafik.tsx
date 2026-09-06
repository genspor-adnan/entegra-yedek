import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from '../bilesenler/bicim';
import { sayi } from '../bilesenler/labKodlari';

/**
 * KALİTE KONTROL — LEVEY-JENNINGS (442, mockup Ekranlar/Lab/lab_kalite_kontrol.html).
 *
 * <b>Bu bir ÇALIŞMA EKRANIDIR, rapor değil.</b> Mockup'ta da öyle: üstte
 * cihaz/test/materyal/kural şeridi, altında solda grafik, sağda ölçümler ve
 * cihaz olayları. Kâğıt görünümlü bir "rapor sayfası" olarak çizmek, günde
 * onlarca kez bakılan bir ekranı belgeye çevirirdi.
 *
 * <b>Grafiğin işi kaymayı göstermektir.</b> Tek ölçüme bakan bir kontrol
 * rastgele hatayı yakalar; asıl tehlike olan sistematik kayma ancak seri
 * hâlinde görülür - bu yüzden ±1/2/3 SD bantları ve ardışık noktalar.
 * Bantlar mockup'taki gibi DOLGU: nokta hangi bölgede diye çizgi saymak
 * yerine renge bakılır.
 *
 * <b>Z skoru sunucudan gelir</b>, burada hesaplanmaz: ölçüm anındaki
 * hedef/SD ile hesaplanıp satırla saklandı. Ekranda yeniden hesaplansaydı
 * hedef güncellendiğinde geçmiş noktalar yerinden oynardı.
 *
 * <b>Cihaz olayları grafiğin yanında</b>: kalibrasyon ve reaktif lot
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

  /** Bant DOLGUSU (mockup): iki z değeri arasını boyar. */
  const bant = (ust: number, alt: number, sinif: string) => (
    <rect key={`${sinif}${ust}`} x={solBosluk} y={zY(ust)} width={cizimG}
          height={Math.max(0, zY(alt) - zY(ust))} className={sinif} />
  );

  const noktalar = seri.map((s, i) => ({ x: nX(i), y: zY(Number(s.z ?? 0)), s }));
  const yol = noktalar.map((n, i) => `${i === 0 ? 'M' : 'L'} ${n.x} ${n.y}`).join(' ');

  const gecerli = Boolean(t.gecerli);
  const son = seri.length > 0 ? seri[seri.length - 1] : null;
  const retSayisi = seri.filter(s => Number(s.durum) === 3).length;
  const uyariSayisi = seri.filter(s => Number(s.durum) === 2).length;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Kalite Kontrol — {String(t.kod ?? '')} {String(t.ad ?? '')}</h1>
          <span className="yol">Laboratuvar › Kalite Kontrol › Levey-Jennings</span>
        </div>
        <div className="basarac">
          {[15, 30, 60, 90].map(g => (
            <button key={g} className={`d${g === gun ? ' bir' : ''}`}
                    onClick={() => setGun(g)}>{g} gün</button>
          ))}
          <button className="d" onClick={() => window.print()}>🖨 Yazdır</button>
          {/* KK GEÇERLİLİĞİ oto-onayı doğrudan etkiler: rozet burada
              görünsün ki teknisyen "sonuçlar niye onaylanmıyor" diye
              aramasın. */}
          <span className={`rozet ${gecerli ? 'olumlu' : 'hata'}`}>
            {gecerli ? 'KK geçerli — oto-onay açık' : 'KK RET — oto-onay kapalı'}
          </span>
          <button className="d" onClick={() => git(-1)}>✖ Kapat</button>
        </div>
      </div>

      <div className="sahne kk-basim">
        {/* Mockup .hdr k4: cihaz/test · materyal · hedef/SD · kural seti */}
        <div className="kagrup">
          <div className="lab-alanlar dort">
            <div className="fld">
              <label>Test</label>
              <div className="deger buyuk">
                {String(t.kod ?? '')} · {String(t.ad ?? '')}
              </div>
            </div>
            <div className="fld">
              <label>Kontrol materyali</label>
              <div className="deger">
                {son ? `${String(son.materyal ?? '')} · lot ${String(son.lot ?? '')}` : '—'}
              </div>
            </div>
            <div className="fld">
              <label>Hedef ± SD</label>
              <div className="deger">
                {son ? `${sayi(son.hedef, 3)} ± ${sayi(son.sd, 3)}` : '—'}
                {String(t.birim ?? '') ? ` ${String(t.birim)}` : ''}
              </div>
            </div>
            <div className="fld">
              <label>Ölçüm (son {gun} gün)</label>
              <div className="deger">
                {seri.length} ölçüm · {retSayisi} ret · {uyariSayisi} uyarı
              </div>
            </div>
          </div>
        </div>

        <div className="lab-ikili">
          {/* --------------------------------------------- grafik */}
          <div className="kagrup">
            <h6>
              Levey-Jennings
              <span className="sp">yeşil ±1SD · sarı ±2SD · kırmızı ±3SD</span>
            </h6>
            {seri.length === 0 ? (
              <div className="bos">Bu dönemde kontrol ölçümü yok.</div>
            ) : (
              <div style={{ padding: 10 }}>
                <svg viewBox={`0 0 ${G} ${Y}`} className="lj-grafik" role="img"
                     aria-label="Levey-Jennings grafiği">
                  {bant(4, 3, 'lj-bant-ret')}{bant(-3, -4, 'lj-bant-ret')}
                  {bant(3, 2, 'lj-bant-uy')}{bant(-2, -3, 'lj-bant-uy')}
                  {bant(2, -2, 'lj-bant-ok')}

                  {/* Hedef çizgisi: ortadaki kesikli çizgi (mockup). */}
                  <line x1={solBosluk} x2={G - sagBosluk} y1={zY(0)} y2={zY(0)}
                        stroke="#8fa3b8" strokeWidth={1.2} strokeDasharray="5 4" />

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
              </div>
            )}
            <div className="ic sonuk">
              Westgard: 1₃ₛ tek ölçüm ±3 SD dışında (rastgele hata) · 2₂ₛ ardışık
              iki ölçüm aynı yönde ±2 SD dışında (sistematik hata) · R₄ₛ aynı
              çalışmada iki seviye arası 4 SD açıklık · 4₁ₛ ve 10ₓ kayma uyarıları.
              Ret hâlinde düzeltici faaliyet ve etkilenen hasta sonuçlarının
              gözden geçirilmesi zorunludur (TS EN ISO 15189).
            </div>
          </div>

          {/* --------------------------------------------- ölçümler */}
          <div>
            <div className="kagrup">
              <h6>KK ölçümleri <span className="sp">yeniden eskiye</span></h6>
              <div className="detay-kaydir">
                <table className="detay-tablo">
                  <thead>
                    <tr>
                      <th className="orta">Tarih</th><th className="orta">Sev.</th>
                      <th className="sag">Sonuç</th><th className="sag">Z</th>
                      <th className="orta">Kural</th><th className="orta">Kaynak</th>
                      <th className="orta">Onay</th><th>Düzeltici faaliyet</th>
                    </tr>
                  </thead>
                  <tbody>
                    {[...seri].reverse().map((s, i) => (
                      <tr key={i} className={Number(s.durum) === 3 ? 'panik' : ''}>
                        <td className="orta">{tarihSaat(s.zaman)}</td>
                        <td className="orta">{String(s.seviye ?? '')}</td>
                        <td className="sag">{sayi(s.deger, 3)}</td>
                        <td className="sag">
                          {Number(s.z ?? 0) > 0 ? '+' : ''}{sayi(s.z, 2)}
                        </td>
                        <td className="orta">
                          {(s.ihlaller as string[] | undefined)?.length
                            ? <span className={Number(s.durum) === 3
                                ? 'rozet hata' : 'rozet uyari'}>
                                {(s.ihlaller as string[]).join(' · ')}
                              </span>
                            : '—'}
                        </td>
                        <td className="orta not">
                          {Number(s.kaynak) === 1 ? `cihaz ${String(s.cihazKod ?? '')}`
                                                  : 'elle'}
                        </td>
                        <td className="orta">
                          <span className={Number(s.durum) === 3 ? 'rozet hata'
                                         : Number(s.durum) === 2 ? 'rozet uyari'
                                         : 'rozet olumlu'}>
                            {Number(s.durum) === 3 ? 'ret'
                              : Number(s.durum) === 2 ? 'uyarı' : 'kabul'}
                          </span>
                        </td>
                        {/* RET ama aksiyon boşsa denetimde açık kalır:
                            tabloda açıkça "kaydedilmedi" yazar. */}
                        <td className={Number(s.durum) === 3 && !String(s.aksiyon ?? '').trim()
                                         ? 'vurgu' : ''}>
                          {String(s.aksiyon ?? '').trim()
                            || (Number(s.durum) === 3 ? 'KAYDEDİLMEDİ' : '—')}
                        </td>
                      </tr>
                    ))}
                    {seri.length === 0 && (
                      <tr><td colSpan={8} className="not">Ölçüm yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="kagrup">
              <h6>Cihaz olayları <span className="sp">aynı dönem</span></h6>
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th className="orta">Zaman</th><th>Cihaz</th><th>Olay</th>
                    <th className="orta">Lot</th><th>Açıklama</th>
                  </tr>
                </thead>
                <tbody>
                  {veri.olaylar.map((o, i) => (
                    <tr key={i}>
                      <td className="orta not">{tarihSaat(o.zaman)}</td>
                      <td>{String(o.cihaz ?? '—')}</td>
                      <td>{OLAY[Number(o.olay ?? 1)] ?? '—'}</td>
                      <td className="orta">{String(o.lot ?? '') || '—'}</td>
                      <td className="not">{String(o.aciklama ?? '')}</td>
                    </tr>
                  ))}
                  {veri.olaylar.length === 0 && (
                    <tr><td colSpan={5} className="not">
                      Bu dönemde kalibrasyon / lot değişimi kaydı yok.
                    </td></tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Mockup .statusbar */}
        <div className="lab-durum-serit">
          <span>Son {gun} gün: <b>{seri.length}</b> ölçüm · <b>{retSayisi}</b> ret ·{' '}
            <b>{uyariSayisi}</b> uyarı</span>
          <span className="sp">
            KK geçersizken o testin hasta sonuçları oto-onaya girmez
            (<code>lab_kk_olcum.durum</code>)
          </span>
        </div>
      </div>
    </>
  );
}
