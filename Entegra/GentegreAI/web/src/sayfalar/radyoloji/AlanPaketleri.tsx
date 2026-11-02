import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import type { AlanPaketi } from '../../api/uclar/radyolojiTanim';
import { Modal } from '../../bilesenler/Modal';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';

/**
 * HAZIR YAPISAL ALAN PAKETLERİ (1217) - iki giriş:
 *   AlanPaketiCubugu  şablon kartı "Yapılandırılmış alanlar" sekmesinin üstü: paket seç, bu şablona ekle
 *                     (şablon adına uyan paket ⭐ ile önde).
 *   AlanPaketiDugmesi şablon listesinin araç çubuğu: paketler + desene uyan şablon sayısı; eşleşenlere ya da
 *                     işaretli şablonlara toplu uygula.
 * Uygulama şablonda aynı kodlu alanı atlar (iki kez basmak alanı çoğaltmaz).
 */

export function AlanPaketiCubugu({ sablonId, salt, kartiKaydet, kartiTazele }: {
  sablonId: number; salt: boolean; kartiKaydet(): Promise<boolean>; kartiTazele(): void;
}) {
  const [paketler, setPaketler] = useState<AlanPaketi[]>([]);
  const [secili, setSecili] = useState(0);
  useEffect(() => {
    api.radAlanPaketleri(sablonId).then(y => {
      const l = [...y.paketler].sort((a, b) => Number(b.onerilen) - Number(a.onerilen));
      setPaketler(l);
      setSecili(l[0]?.onerilen ? l[0].id : 0);
    }).catch(() => setPaketler([]));
  }, [sablonId]);
  if (salt || paketler.length === 0) return null;
  const ekle = () => void guvenli(async () => {
    if (!secili) return;
    if (!(await kartiKaydet())) return;
    const y = await api.radAlanPaketiUygula(secili, [sablonId]);
    mesaj(y.alan > 0 ? `${y.alan} ${c('alan eklendi.')}` : c('Paketin bütün alanları bu şablonda zaten var.'));
    kartiTazele();
  });
  return (
    <div className="rt-arac ap-cubuk">
      <span>📚 {c('Hazır alan paketi')}:</span>
      <select value={secili} onChange={e => setSecili(Number(e.target.value))}>
        <option value={0}>— {c('seçiniz')} —</option>
        {paketler.map(p => (
          <option key={p.id} value={p.id}>{p.onerilen ? '⭐ ' : ''}{p.ad} · {p.alan} {c('alan')}</option>
        ))}
      </select>
      <button type="button" className="d bir" disabled={!secili} onClick={ekle}>＋ {c('Paketten ekle')}</button>
      <span className="sonuk">{paketler.find(p => p.id === secili)?.gruplar ?? ''}</span>
    </div>
  );
}

export function AlanPaketiDugmesi({ isaretli, onUygulandi }: { isaretli: ListeSatiri[]; onUygulandi(): void }) {
  const [acik, setAcik] = useState(false);
  const [paketler, setPaketler] = useState<AlanPaketi[] | null>(null);
  const yukle = () => api.radAlanPaketleri().then(y => setPaketler(y.paketler)).catch(() => setPaketler([]));
  useEffect(() => { if (acik) void yukle() }, [acik]);
  const uygula = (p: AlanPaketi, idler?: number[]) => void guvenli(async () => {
    const hedef = idler ? `${idler.length} ${c('işaretli şablona')}` : `${p.eslesen} ${c('eşleşen şablona')}`;
    if (!(await onay(`"${p.ad}" ${c('paketi')} ${hedef} ${c('uygulansın mı? Şablonda zaten olan alanlar atlanır.')}`))) return;
    const y = await api.radAlanPaketiUygula(p.id, idler);
    mesaj(`${y.sablon} ${c('şablona')} ${y.alan} ${c('alan eklendi.')}`);
    void yukle();
    onUygulandi();
  });
  const isaretliIdler = isaretli.map(r => Number(r.id)).filter(x => x > 0);
  return (
    <>
      <button type="button" className="d" onClick={() => setAcik(true)}
              title={c('Hazır yapılandırılmış alan paketlerini şablonlara uygula')}>📚 {c('Alan paketleri')}</button>
      {acik && (
        <Modal baslik={c('Hazır yapılandırılmış alan paketleri')} dar buyutmeYok onKapat={() => setAcik(false)}
               alt={<button type="button" className="d" onClick={() => setAcik(false)}>✖ {c('Kapat')}</button>}>
          <div className="ap-liste">
            <div className="sonuk" style={{ marginBottom: 8 }}>
              {c('Paket, şablon adına göre eşleşir (ör. "SAĞ DİZ MR" → Diz MR). Uygulanan alanlar rapor ekranında form olarak çıkar; "Metne ekle" cümle olarak Bulgular\'a yazar.')}
            </div>
            {paketler === null && <div className="sonuk">{c('yükleniyor')}…</div>}
            {paketler?.map(p => (
              <div className="ap-paket" key={p.id}>
                <div className="ap-bas"><b>{p.ad}</b><span className="sonuk">{p.alan} {c('alan')} · {p.gruplar}</span></div>
                <div className="sonuk ap-aciklama">{p.aciklama}</div>
                <div className="ap-alt">
                  <span>{c('Eşleşen şablon')}: <b>{p.eslesen}</b> · {c('uygulanmış')}: <b>{p.uygulanmis}</b></span>
                  <span style={{ flex: 1 }} />
                  {isaretliIdler.length > 0 && (
                    <button type="button" className="d" onClick={() => uygula(p, isaretliIdler)}>
                      {c('İşaretli')} {isaretliIdler.length} {c('şablona uygula')}</button>)}
                  <button type="button" className="d bir" disabled={p.eslesen === 0 || p.eslesen === p.uygulanmis}
                          onClick={() => uygula(p)}>{c('Eşleşenlere uygula')}</button>
                </div>
              </div>
            ))}
          </div>
        </Modal>
      )}
    </>
  );
}
