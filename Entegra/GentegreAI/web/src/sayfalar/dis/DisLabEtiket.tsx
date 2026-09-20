import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import type { DisLabEtiketi } from '../../api/uclar/dis';
import { hataMetni } from '../../api/sozlesme';
import { code128Desen } from '../../bilesenler/barkod128';
import { gunNokta, tarihYaz } from '../../bilesenler/bicim';
import { c as cev } from '../../dil/ceviri';

/**
 * PROTEZ İŞ EMRİ BARKOT ETİKETİ (874 — KTS denetim maddesi D1).
 *
 * <b>Etiket ölçü kabının üstünde laboratuvara gider.</b> İş geri geldiğinde
 * kanban'daki okutma kutusundan okutulur ve aşama ilerler; listede iş aramak
 * gerekmez. Denetimin sorduğu "protez süreçlerinde barkotlama" budur.
 *
 * <b>Barkod gövdesi iş emri numarasının kendisidir</b> (LB-yyyy/nnnn). İkinci
 * bir numara üretmek, laboratuvara giden kâğıtta bir numara sistemde başka
 * numara bırakırdı - kaybolan işin izini bu ikilik siler.
 *
 * <b>Etiket tüp etiketinden büyük (70×40 mm)</b>: ölçü kabı kavanoz boyunda,
 * üstünde diş numaraları, malzeme ve renk okunabilir olmalı. Hasta adı da tam
 * yazılır - etiket klinik ile lab arasında dolaşır, tüp gibi banko etiketi
 * değildir.
 */
type Durum = { etiket: DisLabEtiketi; kurum: { unvan: string; adres: string; telefon: string } | null };

/** Code 128 desenini SVG çubuklarına çevirir (LabEtiket ile aynı çizim). */
function Barkod({ metin, yukseklik = 40, modul = 1.5 }:
                { metin: string; yukseklik?: number; modul?: number }) {
  const desen = code128Desen(metin);
  if (!desen) return null;
  const cubuklar: { x: number; g: number }[] = [];
  let x = 0;
  for (let i = 0; i < desen.length;) {
    let n = 1;
    while (i + n < desen.length && desen[i + n] === desen[i]) n++;
    if (desen[i] === '1') cubuklar.push({ x, g: n * modul });
    x += n * modul;
    i += n;
  }
  return (
    <svg className="etiket-barkod" width={desen.length * modul} height={yukseklik}
         viewBox={`0 0 ${desen.length * modul} ${yukseklik}`}
         shapeRendering="crispEdges" role="img" aria-label={`Barkod ${metin}`}>
      {cubuklar.map((c, i) => <rect key={i} x={c.x} y={0} width={c.g} height={yukseklik} fill="#000" />)}
    </svg>
  );
}

export function DisLabEtiket() {
  const [param] = useSearchParams();
  const git = useNavigate();
  const id = Number(param.get('isemri') ?? 0);
  const [veri, setVeri] = useState<Durum | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [kopya, setKopya] = useState(2);

  const yukle = useCallback(async () => {
    if (!id) { setHata('İş emri belirtilmedi.'); return }
    try { setVeri(await api.disLabEtiket(id)); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { void yukle() }, [yukle]);

  // BASIM SAYILIR: yazdırma kutusu açıldıktan SONRA işaretlenir; sayaç
  //   "kaç kez bastık"ı tutar, tekrar basım kaybolan etiketin izidir.
  const bas = async () => {
    window.print();
    try { await api.disLabEtiketBasildi(id); await yukle() } catch { /* basım kaydı isteğe bağlı */ }
  };

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">{cev('Yükleniyor…')}</div>;
  const e = veri.etiket;

  return (
    <div className="etiket-sayfa">
      <div className="cikti-arac">
        <button className="d bir" onClick={() => void bas()}>🏷 {cev('Etiketi Bas')}</button>
        <span className="not">{cev('Kopya:')}</span>
        {[1, 2, 3].map(n => (
          <button key={n} className={`d${n === kopya ? ' bir' : ''}`} onClick={() => setKopya(n)}>{n}×</button>
        ))}
        <span className="not">
          {e.isemriNo} · {e.hasta}
          {e.etiketBasim > 0 ? ` · daha önce ${e.etiketBasim} kez basıldı` : ''}
        </span>
        <span style={{ marginLeft: 'auto' }} />
        <button className="d" onClick={() => git(-1)}>{cev('✖ Kapat')}</button>
      </div>

      <div className="etiketler">
        {Array.from({ length: kopya }, (_, k) => (
          <div className="protez-etiket" key={k}>
            <div className="pe-ust">
              <b>{e.isemriNo}</b>
              <span className="pe-lab">{e.lab}</span>
            </div>
            <Barkod metin={e.isemriNo} />
            <div className="barkod-metin">{e.isemriNo}</div>
            <div className="pe-hasta">
              {e.hasta}
              {gunNokta(e.dogumTarihi) ? <span className="pe-sonuk"> · {gunNokta(e.dogumTarihi)}</span> : null}
            </div>
            <div className="pe-is">
              🦷 {e.disNolar || '—'} · {e.isTuru || '—'}
              {e.malzeme ? ` · ${e.malzeme}` : ''}{e.renk ? ` · ${e.renk}` : ''}
            </div>
            <div className="pe-alt">
              {e.hekim || '—'}
              {e.olcuTipi ? ` · ${e.olcuTipi}` : ''}
              <span className="pe-sag">
                {e.beklenen ? `bekl. ${tarihYaz(e.beklenen)}` : e.gonderim ? tarihYaz(e.gonderim) : ''}
              </span>
            </div>
            {veri.kurum && <div className="pe-kurum">{veri.kurum.unvan}{veri.kurum.telefon ? ` · ${veri.kurum.telefon}` : ''}</div>}
          </div>
        ))}
      </div>

      <div className="not yazdirma" style={{ marginTop: 8 }}>
        {cev('Etiket ölçü kabına yapıştırılır; iş geri geldiğinde Lab panosundaki okutma kutusundan okutulur.')}
      </div>
    </div>
  );
}
