import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { ArsivGozu, ArsivKaydi, ArsivKutusu } from '../api/uclar/lab';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { gunNokta, tarihSaat } from '../bilesenler/bicim';
import { useOturum } from '../kimlik/OturumBaglami';
import { c as cev } from '../dil/ceviri';

/**
 * NUMUNE ARŞİVİ (890 — KTS denetim maddesi L13).
 *
 * Ekran iki soruyu cevaplar: <b>tüp nerede</b> ve <b>ne zamana kadar
 * duracak</b>. Önceden yalnız serbest metin bir "saklama yeri" vardı; 600
 * tüplük bir dondurucuda o yazı tüpü bulmaya yetmiyordu.
 *
 * <b>Izgara kutunun kendisidir:</b> satır harf (A, B, C…), sütun sayı. Boş
 * göze tıklayıp barkod okutmak yerleştirir; dolu göze tıklamak tüpü gösterir.
 * Kurallar (dolu göz, ızgara dışı, "zaten arşivde") SUNUCUDA - iki yerde
 * yazılsaydı ekranın izin verdiği bir hareketi veritabanı reddederdi.
 *
 * <b>İmhayı sistem yapmaz.</b> Süresi dolanlar listelenir; kaydı kapatan
 * kullanıcıdır ve bu ayrı yetki ister. Otomatik kapatmak, hâlâ dolapta duran
 * tüpü "imha edildi" göstermek olurdu.
 *
 * <b>Yazdır = offline arşiv:</b> kutu dökümü kâğıda basılıp dolabın kapağına
 * asılabilir; elektrik/ağ yokken de tüp bulunur.
 */
const CIKIS_NEDEN: { kod: number; ad: string }[] = [
  { kod: 1, ad: 'Tekrar çalışma' },
  { kod: 2, ad: 'Dış laboratuvara' },
  { kod: 4, ad: 'Devir / iade' },
];

const HARF = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

export function LabArsiv() {
  const { aksiyonVar } = useOturum();
  const [kutular, setKutular] = useState<ArsivKutusu[]>([]);
  const [kutu, setKutu] = useState<ArsivKutusu | null>(null);
  const [gozler, setGozler] = useState<ArsivGozu[]>([]);
  const [barkod, setBarkod] = useState('');
  const [secilenGoz, setSecilenGoz] = useState('');
  const [bulunan, setBulunan] = useState<
    { numune: Record<string, unknown>; kayitlar: ArsivKaydi[] } | null>(null);
  const [imha, setImha] = useState<ArsivKaydi[]>([]);
  const [secili, setSecili] = useState<number[]>([]);
  const [sekme, setSekme] = useState<'kutu' | 'imha'>('kutu');
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      const k = await api.labArsivKutular();
      setKutular(k.kutular ?? []);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  const kutuAc = useCallback(async (konumId: number) => {
    await guvenli(async () => {
      const y = await api.labArsivKutu(konumId);
      setKutu(y.kutu); setGozler(y.gozler ?? []); setSecilenGoz('');
      setSekme('kutu');
    });
  }, []);

  const imhaYukle = useCallback(async () => {
    await guvenli(async () => {
      const y = await api.labArsivImhaBekleyen();
      setImha(y.satirlar ?? []); setSecili([]);
    });
  }, []);

  const dolu = (goz: string) => gozler.find(g => g.goz === goz);

  const bul = async () => {
    if (!barkod.trim()) return;
    await guvenli(async () => {
      const y = await api.labArsivBul(barkod.trim());
      setBulunan(y);
      // ARŞİVDEYSE KUTUSUNU AÇ: "nerede" sorusunun cevabı, ızgarada
      //   işaretli bir gözdür - metin olarak söylemek yetmez.
      const aktif = (y.kayitlar ?? []).find(k => k.durum === 1);
      if (aktif?.konumId) { await kutuAc(aktif.konumId); setSecilenGoz(aktif.goz ?? '') }
    });
  };

  const koy = async () => {
    if (!kutu || !secilenGoz) { mesaj('Önce kutudan boş bir göz seçin.'); return }
    if (!barkod.trim()) { mesaj('Numune barkodunu okutun.'); return }
    await guvenli(async () => {
      const y = await api.labArsivKoy({
        barkod: barkod.trim(), konumId: kutu.konumId, goz: secilenGoz });
      mesaj(y.mesaj);
      setBarkod(''); setSecilenGoz(''); setBulunan(null);
      await kutuAc(kutu.konumId); await yukle();
    });
  };

  const cikar = async (numuneId: number, neden: number) => {
    await guvenli(async () => {
      const y = await api.labArsivCikar({ numuneId, neden });
      mesaj(y.mesaj);
      if (kutu) await kutuAc(kutu.konumId);
      await yukle();
      if (bulunan) { const b = await api.labArsivBul(String(bulunan.numune.barkod ?? '')); setBulunan(b) }
    });
  };

  const imhaEt = async () => {
    if (secili.length === 0) { mesaj('İmha edilecek numune seçin.'); return }
    // İMHA GERİ ALINAMAZ: onay metni kaç tüp olduğunu söyler.
    if (!await onay(`${secili.length} numune imha edildi olarak kapatılacak. `
                  + 'Bu işlem geri alınamaz. Fiziksel imha yapıldı mı?')) return;
    await guvenli(async () => {
      const y = await api.labArsivImha(secili);
      mesaj(y.mesaj);
      await imhaYukle(); await yukle();
      if (kutu) await kutuAc(kutu.konumId);
    });
  };

  return (
    <div className="sayfa">
      <div className="sayfa-baslik">
        <h3>🧊 {cev('Numune Arşivi')}</h3>
        <div className="sp">
          {kutular.length} {cev('kutu')} ·{' '}
          {kutular.reduce((t, k) => t + k.dolu, 0)} {cev('tüp arşivde')}
        </div>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}

      {/* BARKOD ŞERİDİ: arşiv işi barkodla yapılır - önce tüp okutulur,
          sonra yeri seçilir. Okutma alanı hep üstte ve odakta durur. */}
      <div className="kagrup">
        <div className="ds-sr">
          <input value={barkod} onChange={e => setBarkod(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter') void bul() }}
                 placeholder={cev('Numune barkodu okutun…')} style={{ minWidth: 220 }} />
          <button type="button" className="d" onClick={() => void bul()}>
            🔎 {cev('Bul')}
          </button>
          <button type="button" className="b" onClick={() => void koy()}
                  disabled={!kutu || !secilenGoz}>
            📥 {cev('Seçili göze yerleştir')}
            {secilenGoz ? ` (${secilenGoz})` : ''}
          </button>
        </div>

        {bulunan && (
          <div className="ds-ic" style={{ marginTop: 8 }}>
            <b>{String(bulunan.numune.barkod ?? '')}</b>
            {' · '}{String(bulunan.numune.hasta ?? '')}
            {' · '}{cev('istem')} {String(bulunan.numune.istemNo ?? '')}
            {bulunan.numune.saklamaGun
              ? <span className="sonuk"> · {cev('saklama')} {String(bulunan.numune.saklamaGun)} {cev('gün')}</span>
              : <span className="sonuk"> · {cev('saklama süresi tanımlı değil')}</span>}
            <table className="detay-tablo" style={{ marginTop: 6 }}>
              <thead><tr>
                <th>{cev('Konum')}</th><th className="orta">{cev('Göz')}</th>
                <th className="orta">{cev('Giriş')}</th><th className="orta">{cev('İmha hedefi')}</th>
                <th className="orta">{cev('Durum')}</th><th />
              </tr></thead>
              <tbody>
                {bulunan.kayitlar.map(k => (
                  <tr key={k.id}>
                    <td>{k.konum}</td>
                    <td className="orta"><b>{k.goz}</b></td>
                    <td className="orta">{k.girisZamani ? tarihSaat(k.girisZamani) : '—'}</td>
                    <td className="orta">
                      {k.imhaHedef ? gunNokta(k.imhaHedef) : '—'}
                      {typeof k.kalanGun === 'number' && k.durum === 1 && (
                        <span className={k.kalanGun <= 0 ? 'rozet hata' : 'not'}>
                          {' '}{k.kalanGun <= 0 ? cev('süre doldu') : `${k.kalanGun} ${cev('gün')}`}
                        </span>
                      )}
                    </td>
                    <td className="orta">
                      {k.durum === 1 ? <span className="rozet olumlu">{cev('Arşivde')}</span>
                       : k.durum === 3 ? <span className="rozet hata">{cev('İmha edildi')}</span>
                       : <span className="rozet gri">{cev('Çıkarıldı')}</span>}
                    </td>
                    <td className="sag">
                      {k.durum === 1 && CIKIS_NEDEN.map(n => (
                        <button key={n.kod} type="button" className="d kucuk"
                                onClick={() => void cikar(k.numuneId ?? 0, n.kod)}>
                          {n.ad}
                        </button>
                      ))}
                    </td>
                  </tr>
                ))}
                {bulunan.kayitlar.length === 0 && (
                  <tr><td colSpan={6} className="not">
                    {cev('Bu numune hiç arşivlenmemiş.')}
                  </td></tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div className="ds-sr" style={{ marginTop: 8 }}>
        <button type="button" className={sekme === 'kutu' ? 'b' : 'd'}
                onClick={() => setSekme('kutu')}>🗄️ {cev('Kutular')}</button>
        <button type="button" className={sekme === 'imha' ? 'b' : 'd'}
                onClick={() => { setSekme('imha'); void imhaYukle() }}>
          ⏳ {cev('Süresi dolanlar')}
        </button>
      </div>

      {sekme === 'kutu' && (
        <div className="lab-ikili" style={{ marginTop: 8 }}>
          <div className="kagrup">
            <h6>{cev('Kutular')}</h6>
            <div className="ds-dg"><table>
              <thead><tr>
                <th>{cev('Konum')}</th><th className="orta">°C</th>
                <th className="sag">{cev('Dolu')}</th><th className="sag">{cev('Boş')}</th>
              </tr></thead>
              <tbody>
                {kutular.map(k => (
                  <tr key={k.konumId}
                      className={kutu?.konumId === k.konumId ? 'secili' : undefined}
                      onClick={() => void kutuAc(k.konumId)} style={{ cursor: 'pointer' }}>
                    <td>{k.yol}</td>
                    <td className="orta">{k.sicaklik ?? '—'}</td>
                    <td className="sag"><b>{k.dolu}</b></td>
                    <td className="sag">{k.bos}</td>
                  </tr>
                ))}
                {kutular.length === 0 && (
                  <tr><td colSpan={4} className="not">
                    {cev('Kutu tanımlı değil - Laboratuvar › Ayarlar › Arşiv Konumları.')}
                  </td></tr>
                )}
              </tbody>
            </table></div>
          </div>

          <div className="kagrup">
            <h6>
              {kutu ? kutu.yol : cev('Kutu seçin')}
              {kutu && <span className="sp">
                {kutu.satir}×{kutu.sutun} · {kutu.dolu}/{kutu.gozSayisi} {cev('dolu')}
              </span>}
              {kutu && (
                <button type="button" className="d kucuk" style={{ float: 'right' }}
                        onClick={() => window.print()}>🖨️ {cev('Döküm')}</button>
              )}
            </h6>
            {kutu && (
              <div className="ds-izgara" style={{
                display: 'grid',
                gridTemplateColumns: `repeat(${kutu.sutun}, minmax(28px, 1fr))`,
                gap: 4,
              }}>
                {Array.from({ length: kutu.satir }).flatMap((_, s) =>
                  Array.from({ length: kutu.sutun }).map((__, t) => {
                    const goz = `${HARF[s]}${t + 1}`;
                    const d = dolu(goz);
                    const gecmis = typeof d?.kalanGun === 'number' && d.kalanGun <= 0;
                    return (
                      <button key={goz} type="button"
                        className={`ds-goz${d ? ' dolu' : ''}${gecmis ? ' gecmis' : ''}`
                                   + (secilenGoz === goz ? ' secili' : '')}
                        title={d ? `${d.barkod} · ${d.hasta ?? ''}`
                                 + (d.imhaHedef ? ` · ${cev('imha')} ${gunNokta(d.imhaHedef)}` : '')
                                 : `${goz} · ${cev('boş')}`}
                        onClick={() => {
                          setSecilenGoz(goz);
                          if (d) setBarkod(d.barkod);
                        }}>
                        {d ? '●' : goz}
                      </button>
                    );
                  }))}
              </div>
            )}
            {kutu && (
              <div className="not" style={{ marginTop: 6 }}>
                {cev('Dolu göze tıklayınca barkod yukarı gelir; boş göz seçip barkod okutarak yerleştirin.')}
              </div>
            )}
          </div>
        </div>
      )}

      {sekme === 'imha' && (
        <div className="kagrup" style={{ marginTop: 8 }}>
          <h6>
            {cev('Saklama süresi dolan numuneler')}
            <span className="sp">{imha.length} {cev('tüp')}</span>
            {aksiyonVar('lab.arsiv.imha') && (
              <button type="button" className="b kucuk" style={{ float: 'right' }}
                      onClick={() => void imhaEt()} disabled={secili.length === 0}>
                🗑️ {cev('Seçilenleri imha et')} ({secili.length})
              </button>
            )}
          </h6>
          <div className="ds-dg"><table>
            <thead><tr>
              <th className="orta">
                <input type="checkbox"
                       checked={secili.length > 0 && secili.length === imha.length}
                       onChange={e => setSecili(e.target.checked
                         ? imha.map(x => x.numuneId ?? 0) : [])} />
              </th>
              <th className="orta">{cev('Barkod')}</th><th>{cev('Hasta')}</th>
              <th>{cev('Konum')}</th><th className="orta">{cev('Göz')}</th>
              <th className="orta">{cev('İmha hedefi')}</th>
              <th className="sag">{cev('Gecikme')}</th>
            </tr></thead>
            <tbody>
              {imha.map(k => (
                <tr key={k.numuneId}>
                  <td className="orta">
                    <input type="checkbox" checked={secili.includes(k.numuneId ?? 0)}
                           onChange={e => setSecili(s => e.target.checked
                             ? [...s, k.numuneId ?? 0]
                             : s.filter(x => x !== k.numuneId))} />
                  </td>
                  <td className="orta">{k.barkod}</td>
                  <td>{k.hasta}</td>
                  <td>{k.konum}</td>
                  <td className="orta"><b>{k.goz}</b></td>
                  <td className="orta">{k.imhaHedef ? gunNokta(k.imhaHedef) : '—'}</td>
                  <td className="sag">
                    <span className="rozet hata">
                      {Math.abs(Number(k.kalanGun ?? 0))} {cev('gün')}
                    </span>
                  </td>
                </tr>
              ))}
              {imha.length === 0 && (
                <tr><td colSpan={7} className="not">
                  {cev('Süresi dolan numune yok.')}
                </td></tr>
              )}
            </tbody>
          </table></div>
          {!aksiyonVar('lab.arsiv.imha') && (
            <div className="not" style={{ marginTop: 6 }}>
              {cev('İmha kaydını kapatma yetkiniz yok - liste yalnız bilgi amaçlı.')}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
