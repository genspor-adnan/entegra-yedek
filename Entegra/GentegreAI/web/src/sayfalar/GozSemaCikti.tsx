import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat, gunNokta, yasMetni } from '../bilesenler/bicim';
import { SemaZemini } from '../bilesenler/goz/gozSemaZemini';
import type { GozCizimCiktisi } from '../api/uclar/goz';

/**
 * GÖZ ŞEMASI ÇIKTISI (705) — mockup `Ekranlar/Goz/goz_semasi.html`
 * "Yazdır / rapora ekle".
 *
 * Çizim ekranından AYRI sayfa, çünkü işi başka: orada palet, araç ve geri al
 * var; burada kurum anteti, hasta kimliği, şema ve işaret dökümü. Aynı ekranı
 * yazdırmaya zorlamak kâğıda damga paletini basmak olurdu.
 *
 * Yazdırma tarayıcının kendi diyalogudur ("PDF olarak kaydet" de orada);
 * ayrı bir PDF üreticisi YOK — aynı çıktının iki üretim yolu, birinin
 * ötekinden sessizce sapması demektir (radyoloji/lab çıktılarıyla aynı karar).
 */
const CINSIYET: Record<number, string> = { 1: 'Erkek', 2: 'Kadın' };

export function GozSemaCikti() {
  const { id } = useParams();
  const git = useNavigate();
  const [veri, setVeri] = useState<GozCizimCiktisi | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    void (async () => {
      try { setVeri(await api.gozCizimCikti(Number(id))) } catch (h) { setHata(hataMetni(h)) }
    })();
  }, [id]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const m = veri.muayene as Record<string, unknown>;
  const k = (veri.kurum ?? {}) as Record<string, unknown>;
  const damga = (tur: number) => veri.damgalar.find(d => d.tur === tur);
  const semaAd = (tur: number) => veri.semaAdlari.find(s => s.tur === tur)?.ad ?? '';
  const adres = [k.adres, [k.ilce, k.il].filter(Boolean).join(' / ')]
    .filter(x => String(x ?? '').trim() !== '').join(' · ');

  return (
    <div className="sema-cikti">
      {/* Araç çubuğu YAZDIRILMAZ (@media print) - kâğıtta yalnız belge kalır. */}
      <div className="cikti-arac">
        <button className="d bir" onClick={() => window.print()}>🖨 Yazdır</button>
        <button className="d" onClick={() => window.print()}
                title="Tarayıcı yazdırma penceresinde 'PDF olarak kaydet'">📄 PDF</button>
        <button className="d" onClick={() => git(-1)}>← Geri</button>
      </div>

      <div className="cikti-sayfa">
        <div className="cikti-antet">
          <div>
            <b>{String(k.unvan ?? '')}</b>
            {adres && <div className="sonuk">{adres}</div>}
            {k.telefon ? <div className="sonuk">Tel: {String(k.telefon)}</div> : null}
          </div>
          <div className="sag">
            <b>Göz Muayenesi — Şema</b>
            <div className="sonuk">Protokol: {String(m.protokol ?? '')}</div>
            <div className="sonuk">
              Tarih: {m.muayeneTarihi ? tarihSaat(String(m.muayeneTarihi)) : ''}
            </div>
          </div>
        </div>

        <table className="cikti-kimlik">
          <tbody>
            <tr>
              <th>Hasta</th><td>{String(m.hasta ?? '')}</td>
              <th>Hasta No</th><td>{String(m.hastaNo ?? '')}</td>
            </tr>
            <tr>
              <th>T.C. Kimlik</th><td>{String(m.hastaTc ?? '')}</td>
              <th>Doğum / Yaş</th>
              <td>
                {m.dogumTarihi ? gunNokta(String(m.dogumTarihi)) : '—'}
                {m.dogumTarihi ? ` · ${yasMetni(String(m.dogumTarihi))}` : ''}
                {m.cinsiyet ? ` · ${CINSIYET[Number(m.cinsiyet)] ?? ''}` : ''}
              </td>
            </tr>
            <tr>
              <th>Hekim</th><td>{String(m.hekim ?? '')}</td>
              <th>Dilatasyon</th>
              <td>
                {Number(m.dilate) === 1
                  ? `Yapıldı${m.dilatasyonIlac ? ` · ${String(m.dilatasyonIlac)}` : ''}`
                  : 'Yok'}
              </td>
            </tr>
          </tbody>
        </table>

        {veri.semalar.length === 0 && (
          <div className="cikti-bos">Bu muayenede çizim yok.</div>
        )}

        {/* ŞEMA TÜRÜ BAŞINA BİR BLOK, içinde iki göz: kâğıtta da hekim
            OD/OS'yi karşılaştırarak okur. */}
        {[...new Set(veri.semalar.map(s => s.semaTuru))].sort().map(tur => {
          const gozler = veri.semalar.filter(s => s.semaTuru === tur);
          return (
            <div key={tur} className="cikti-blok">
              <h3>{semaAd(tur)}</h3>
              <div className="cikti-tuvaller">
                {[1, 2].map(goz => {
                  const sema = gozler.find(s => s.goz === goz);
                  const isaret = veri.isaretler
                    .filter(i => i.goz === goz && i.semaTuru === tur);
                  return (
                    <div key={goz} className="cikti-goz">
                      <div className="gb">
                        <span className={goz === 1 ? 'od' : 'os'}>
                          {goz === 1 ? 'OD · Sağ' : 'OS · Sol'}
                        </span>
                        <span className="sp">
                          {sema ? `${isaret.length} işaret · v${sema.surum}` : 'çizim yok'}
                        </span>
                      </div>
                      <svg viewBox="0 0 320 320" className="cikti-sema">
                        <SemaZemini semaTuru={tur} goz={goz} />
                        {isaret.map((i, sira) => {
                          if (i.sekil === 2 || i.yol) {
                            return <path key={sira} d={i.yol} fill="none"
                                         stroke={i.renk || '#1f2d3a'} strokeWidth="2.2" />;
                          }
                          return (
                            <text key={sira} x={(i.x ?? 0) * 320} y={(i.y ?? 0) * 320 + 4}
                                  fontSize="14" textAnchor="middle"
                                  fill={i.renk || damga(i.tur)?.renk || '#b3261e'}>
                              {damga(i.tur)?.simge ?? '●'}
                            </text>
                          );
                        })}
                      </svg>
                    </div>
                  );
                })}
              </div>

              {/* İŞARET DÖKÜMÜ: çizim fotokopide soluyor, tablo solmuyor.
                  Kâğıda basılan belgenin okunur kalması buna bağlı. */}
              <table className="cikti-isaret">
                <thead>
                  <tr><th>Göz</th><th>İşaret</th><th>Saat</th><th>Boyut (DD)</th><th>Not</th></tr>
                </thead>
                <tbody>
                  {veri.isaretler.filter(i => i.semaTuru === tur).map((i, sira) => (
                    <tr key={sira}>
                      <td className={i.goz === 1 ? 'od' : 'os'}>{i.goz === 1 ? 'OD' : 'OS'}</td>
                      <td>{damga(i.tur)?.ad ?? 'İşaret'}</td>
                      <td className="orta">{i.saat ?? '—'}</td>
                      <td className="orta">{i.boyutDd ?? '—'}</td>
                      <td>{i.aciklama}</td>
                    </tr>
                  ))}
                  {veri.isaretler.filter(i => i.semaTuru === tur).length === 0 && (
                    <tr><td colSpan={5} className="sonuk">İşaret yok.</td></tr>
                  )}
                </tbody>
              </table>

              {gozler.filter(s => s.uretilenMetin).map(s => (
                <p key={s.id} className="cikti-metin">
                  <b className={s.goz === 1 ? 'od' : 'os'}>{s.goz === 1 ? 'OD' : 'OS'}:</b>{' '}
                  {s.uretilenMetin}
                </p>
              ))}
            </div>
          );
        })}

        <div className="cikti-imza">
          <div>
            <div className="cizgi" />
            {String(m.hekim ?? '')}
            <div className="sonuk">Çizimi yapan hekim</div>
          </div>
          <div className="sonuk sag">
            Çizim bir ölçüm kaydı değildir; görme, göz içi basıncı ve
            refraksiyon değerleri muayene raporunda yer alır.
          </div>
        </div>
      </div>
    </div>
  );
}
