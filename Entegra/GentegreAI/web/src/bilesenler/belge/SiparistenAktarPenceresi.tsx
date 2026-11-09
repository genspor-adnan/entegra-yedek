import { useEffect, useMemo, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { type AcikSatir, type Kosul, type ListeSatiri, hataMetni } from '../../api/sozlesme';
import { gunNokta, hamSayi as sayi, para } from '../bicim';
import { c } from '../../dil/ceviri';
import { gorunenBelgeNo } from '../../sayfalar/belgeKartiKurallari';

/** Kaynaktan karta alınacak açık satır + kullanıcının seçtiği miktar. */
export type SiparisSatiri = AcikSatir & { secilenMiktar: string };

/** Sol listedeki çipler: açık (hiç aktarılmamış) · kısmi · tümü (kapananlar da, gri). */
type Cip = 'acik' | 'kismi' | 'tumu';

/** Sepet kaydı: hangi kaynak belgenin hangi satırı, ne kadar. */
interface Secim { belgeId: number; miktar: string }

/** Kaynak türü -> ekran adları (sekme başlığı, boş durum metinleri). */
export function kaynakAdlari(tur: number) {
  const teklifMi = tur === 18;
  const irsaliyeMi = tur === 14 || tur === 10;
  return {
    teklifMi, irsaliyeMi,
    ad: teklifMi ? 'Teklif' : irsaliyeMi ? 'İrsaliye' : 'Sipariş',
    baslik: teklifMi ? 'Tekliften Aktar' : irsaliyeMi ? 'İrsaliyeden Aktar' : 'Siparişten Aktar',
    den: teklifMi ? 'tekliften' : irsaliyeMi ? 'irsaliyeden' : 'siparişten',
    liste: teklifMi ? 'kabul edilmiş teklifi' : irsaliyeMi ? (tur === 10 ? 'alış irsaliyesi' : 'satış irsaliyesi')
         : tur === 9 ? 'alış siparişi' : 'satış siparişi',
  };
}

/**
 * Sol listenin süzgeci: tür + (cari) + (teklifte KABUL) + çip. "Tümü" kapananları da getirir (gri, seçilemez);
 * öbür çipler kapanma koduyla (0 açık · 1 kısmi) daraltır. Saf - test edilir.
 */
export function kaynakListeSuzgeci(tur: number, tarafId: number | null | undefined, cip: Cip): Kosul {
  const kosullar: Kosul[] = [{ alan: 'tur', op: 'esit', deger: tur }];
  if (tarafId) kosullar.push({ alan: 'tarafId', op: 'esit', deger: tarafId });
  if (tur === 18) kosullar.push({ alan: 'teklifDurum', op: 'esit', deger: 3 });
  if (cip === 'acik') kosullar.push({ alan: 'kapanmaDurum', op: 'esit', deger: 0 });
  else if (cip === 'kismi') kosullar.push({ alan: 'kapanmaDurum', op: 'esit', deger: 1 });
  else kosullar.push({ alan: 'durum', op: 'esitDegil', deger: 2 });
  return { op: 'and', kosullar };
}

/** Metin araması (belge no, açıklama, cari) istemcide - liste zaten carinin yüz-iki yüz belgesi. */
export function kaynakAramaUyar(b: ListeSatiri, metin: string): boolean {
  const q = metin.trim().toLocaleLowerCase('tr-TR');
  if (!q) return true;
  return [b.belgeNo, b.aciklama, b.tarafUnvan, b.teklifKonusu]
    .some(v => String(v ?? '').toLocaleLowerCase('tr-TR').includes(q));
}

/**
 * KAYNAKTAN AKTAR (kullanıcı 07.11.2026 "yeni kart açıp siparişten buraya aktarmak isterim"; 09.11.2026 "şu anki çok
 * genel.. o cariye ait aktarılmamış siparişleri ve içeriklerini görüp seçebilmem lazım" - mockup
 * Ekranlar/ERP/kaynaktan_aktar.html).
 *
 * TEK PENCERE, İKİ BÖLME: solda carinin açık kaynak belgeleri (çip: açık / kısmi / tümü, metin araması), sağda
 * tıklanan belgenin AÇIK satırları (kutucuk + "Bu Belgeye" miktarı, varsayılan kalan). Başka belgeye geçince seçimler
 * kaybolmaz: altta "Aktarılacaklar" sepeti birden çok belgeden toplanan satırları gösterir. Seçilenler karta
 * `kaynakSatirId` ile satır olur; kaydedilince sunucu kaynak bağını (kaynak_tur 30) yazar, kaynağın kapatılan miktarı
 * tetikle ilerler. Fiyat / iskonto / KDV kaynaktan gelir, burada değişmez. Lot: siparişten aktarımda sonra sorulur
 * (BelgeKartiModallari lot kuyruğu), irsaliyeden aynen taşınır (belgeKalem.siparisSatirlari).
 */
export function SiparistenAktarPenceresi({ siparisTuru, tarafId, cariUnvan, hedefAdi, kartta, onSec, onKapat }: {
  /** Kaynak belge türü: 19 satış / 9 alış siparişi (irsaliye kartı), 18 teklif (sipariş kartı, yalnız KABUL = 3),
      14 / 10 irsaliye (fiş · fatura · tahakkuk kartı). */
  siparisTuru: number;
  /** Kartın carisi (seçiliyse yalnız onun belgeleri). */
  tarafId?: number | null;
  cariUnvan?: string | null;
  /** Hedef kartın adı (başlık: "Hedef: Satış İrsaliyesi"). */
  hedefAdi?: string | null;
  /** KARTTA ZATEN OLAN kaynak satırlar (kaynakSatirId -> karttaki miktar toplamı). Kayıt öncesi sunucu "kalan"ı
      bilmez; aynı siparişi ikinci kez açınca satır yine tam kalanla geliyordu (kullanıcı 07.11.2026: "aynı siparişten
      2 defa aktarım yapabiliyorum"). Karttaki miktar kalandan düşülür, sıfıra inen satır seçilemez. */
  kartta?: Record<number, number>;
  /** Seçilen satırlar (birden çok kaynak belgeden olabilir) + ilgili kaynak belgeler (ilki carisiz kartın carisi olur). */
  onSec(kaynaklar: ListeSatiri[], satirlar: SiparisSatiri[]): void;
  onKapat(): void;
}) {
  const adlar = kaynakAdlari(siparisTuru);
  const [cip, setCip] = useState<Cip>('acik');
  const [arama, setArama] = useState('');
  const [belgeler, setBelgeler] = useState<ListeSatiri[] | null>(null);
  const [listeHata, setListeHata] = useState<string | null>(null);
  const [acikId, setAcikId] = useState<number | null>(null);
  /** Belge id -> açık satırları (bir kez yüklenir; sepet başka belgeye geçince de bunlardan okur). */
  const [satirlarMap, setSatirlarMap] = useState<Record<number, AcikSatir[]>>({});
  const [yukleniyor, setYukleniyor] = useState<number | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  /** satirId -> seçim (belge + miktar). satirId belge_satir kimliği: belgeler arası tektir. */
  const [secim, setSecim] = useState<Record<number, Secim>>({});
  const [sepetAcik, setSepetAcik] = useState(true);

  // SOL LİSTE: çip / tür / cari değişince yeniden.
  useEffect(() => {
    let iptal = false;
    setBelgeler(null); setListeHata(null);
    api.liste('belge', { sayfa: 1, boyut: 200, sirala: [{ alan: 'belgeTarihi', yon: 'desc' }, { alan: 'id', yon: 'desc' }],
                         filtre: kaynakListeSuzgeci(siparisTuru, tarafId, cip) })
      .then(y => { if (!iptal) setBelgeler(y.satirlar) })
      .catch(h => { if (!iptal) { setBelgeler([]); setListeHata(hataMetni(h)) } });
    return () => { iptal = true };
  }, [siparisTuru, tarafId, cip]);

  // SAĞ BÖLME: tıklanan belgenin açık satırları (önbellekli).
  useEffect(() => {
    if (acikId == null || satirlarMap[acikId]) return;
    let iptal = false;
    setYukleniyor(acikId); setHata(null);
    api.belgeAcikSatirlar(acikId)
      .then(s => { if (!iptal) setSatirlarMap(m => ({ ...m, [acikId]: s })) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) })
      .finally(() => { if (!iptal) setYukleniyor(null) });
    return () => { iptal = true };
  }, [acikId, satirlarMap]);

  /** Etkin kalan: sunucu kalanı - kartta bekleyen (kaydedilmemiş) miktar. */
  const kalan = (r: AcikSatir) => Math.max(0, Number(r.kalanMiktar) - (kartta?.[r.satirId] ?? 0));
  const gorunenler = useMemo(() => (belgeler ?? []).filter(b => kaynakAramaUyar(b, arama)), [belgeler, arama]);
  const acikBelge = acikId != null ? (belgeler ?? []).find(b => Number(b.id) === acikId) ?? null : null;
  const acikSatirlar = acikId != null ? satirlarMap[acikId] ?? null : null;
  const belgeSatiriSec = (r: AcikSatir, belgeId: number, ac: boolean) => setSecim(s => {
    const yeni = { ...s };
    if (ac) yeni[r.satirId] = { belgeId, miktar: String(kalan(r)) }; else delete yeni[r.satirId];
    return yeni;
  });
  const belgeninHepsi = (belgeId: number, ac: boolean) => {
    const satirlar = satirlarMap[belgeId] ?? [];
    setSecim(s => {
      const yeni = { ...s };
      for (const r of satirlar) {
        if (ac && kalan(r) > 0) yeni[r.satirId] = { belgeId, miktar: String(kalan(r)) };
        if (!ac) delete yeni[r.satirId];
      }
      return yeni;
    });
  };
  const belgedeSecili = (belgeId: number) => Object.values(secim).filter(x => x.belgeId === belgeId).length;

  // SEPET: seçimler satır nesneleriyle birleşir (sıra: belge tıklanma sırası değil, satirId - kararlı).
  const sepet = useMemo(() => Object.entries(secim).map(([id, s]) => {
    const r = (satirlarMap[s.belgeId] ?? []).find(x => x.satirId === Number(id));
    return r ? { r, belgeId: s.belgeId, miktar: s.miktar } : null;
  }).filter((x): x is { r: AcikSatir; belgeId: number; miktar: string } => !!x), [secim, satirlarMap]);
  const gecersiz = sepet.some(x => sayi(x.miktar) <= 0 || sayi(x.miktar) > kalan(x.r));
  const lotSoracak = adlar.irsaliyeMi ? 0 : sepet.filter(x => Number(x.r.izleme ?? 0) > 0 && (x.r.satirTur ?? 1) === 1).length;
  const sepetBelgeler = Array.from(new Set(sepet.map(x => x.belgeId)));
  const belgeNo = (b: ListeSatiri | undefined) => b ? gorunenBelgeNo(String(b.belgeNo ?? '')) || `#${b.id}` : '';
  const aktar = () => {
    const kaynaklar = sepetBelgeler.map(id => (belgeler ?? []).find(b => Number(b.id) === id)).filter((b): b is ListeSatiri => !!b);
    onSec(kaynaklar, sepet.map(x => ({ ...x.r, secilenMiktar: x.miktar })));
  };

  const baslik = `${c(adlar.baslik)}${hedefAdi ? ` — ${c('Hedef')}: ${hedefAdi}` : ''}${cariUnvan ? ` · ${cariUnvan}` : ''}`;
  return (
    <Modal baslik={baslik} onKapat={onKapat} enUst ekSinif="kaynak-aktar"
      alt={
        <>
          <span className="ka-ozet">
            <span>{c('Seçili satır')}: <b>{sepet.length}</b></span>
            <span>{c('Belge')}: <b>{sepetBelgeler.length}</b></span>
            {lotSoracak > 0 && <span className="ka-lot">◆ {lotSoracak} {c('satır lot soracak')}</span>}
          </span>
          <button className="d bir" disabled={sepet.length === 0 || gecersiz}
                  title={gecersiz ? c('Miktar 0 ile kalan arasında olmalı.') : ''} onClick={aktar}>
            ✔ {c('Seçilenleri Aktar')}{sepet.length > 0 ? ` (${sepet.length})` : ''}
          </button>
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
        </>
      }
    >
      <div className="ka-bolme">
        {/* SOL: carinin kaynak belgeleri */}
        <div className="ka-sol">
          <div className="ka-arama">
            <input value={arama} onChange={e => setArama(e.target.value)} autoFocus
                   placeholder={c('Belge no, açıklama…')} />
          </div>
          <div className="ka-cipler">
            {([['acik', 'Açık'], ['kismi', 'Kısmen aktarılmış'], ['tumu', 'Tümü']] as [Cip, string][]).map(([k, ad]) => (
              <button key={k} type="button" className={`cip${cip === k ? ' on' : ''}`} onClick={() => setCip(k)}>{c(ad)}</button>
            ))}
          </div>
          <div className="ka-liste">
            {listeHata && <div className="hata-kutusu">{listeHata}</div>}
            {belgeler === null && <div className="yukleniyor">{c('Yükleniyor…')}</div>}
            {belgeler !== null && gorunenler.length === 0 && (
              <div className="bos">{arama ? c('Aramaya uyan belge yok.') : c(`Bu carinin açık ${adlar.liste} yok.`)}</div>
            )}
            {gorunenler.map(b => {
              const id = Number(b.id);
              const kapali = Number(b.kapanmaDurum ?? 0) === 2;
              const satirlar = satirlarMap[id];
              const acikSayi = satirlar ? satirlar.filter(r => kalan(r) > 0).length : null;
              const sec = belgedeSecili(id);
              return (
                <div key={id} className={`ka-belge${acikId === id ? ' sec' : ''}${kapali ? ' kapali' : ''}`}
                     onClick={() => setAcikId(id)} data-testid="ka-belge">
                  <div className="ka-no">{belgeNo(b)}</div>
                  <div className="ka-tar">{gunNokta(b.belgeTarihi)}</div>
                  <div className="ka-ack">
                    <span className={`rozet ${kapali ? 'gri' : Number(b.kapanmaDurum ?? 0) === 1 ? 'uyari' : 'ok'}`}>
                      {String(b.kapanmaAdi ?? (kapali ? 'Kapandı' : Number(b.kapanmaDurum ?? 0) === 1 ? 'Kısmi' : 'Açık'))}
                    </span>
                    {acikSayi !== null && <span className="sonuk">{acikSayi}/{satirlar!.length} {c('satır açık')}</span>}
                    {!tarafId && <span className="sonuk">{String(b.tarafUnvan ?? '')}</span>}
                  </div>
                  <div className="ka-alt">
                    <span className="sonuk">{String(b.aciklama ?? b.teklifKonusu ?? '')}</span>
                    <span className="ka-tutar">{para.format(Number(b.genelToplam ?? 0))}</span>
                  </div>
                  {sec > 0 && <span className="ka-secili">✔ {sec} {c('seçili')}</span>}
                </div>
              );
            })}
          </div>
          <div className="ka-sol-alt sonuk">{belgeler ? `${gorunenler.length} ${c('belge')}` : ''}</div>
        </div>

        {/* SAĞ: seçili belgenin açık satırları */}
        <div className="ka-sag">
          {hata && <div className="hata-kutusu">{hata}</div>}
          {!acikBelge && (
            <div className="ka-bos">
              <b>{c(`Soldan bir ${adlar.ad.toLocaleLowerCase('tr-TR')} seçin`)}</b>
              {c('Satırları burada görünür; birden çok belgeden satır toplayabilirsiniz.')}
            </div>
          )}
          {acikBelge && (
            <>
              <div className="ka-baslik">
                <div><label>{adlar.ad} No</label><b>{belgeNo(acikBelge)}</b></div>
                <div><label>{c('Tarih')}</label><b>{gunNokta(acikBelge.belgeTarihi)}</b></div>
                <div><label>{c('Cari')}</label><b>{String(acikBelge.tarafUnvan ?? '')}</b></div>
                <div><label>{c('Belge Toplamı')}</label><b>{para.format(Number(acikBelge.genelToplam ?? 0))}</b></div>
              </div>
              <div className="ka-arac">
                <button type="button" className="d" disabled={!acikSatirlar?.some(r => kalan(r) > 0)}
                        onClick={() => belgeninHepsi(acikId!, true)}>☑ {c('Tümünü seç (kalanların hepsi)')}</button>
                <button type="button" className="d" disabled={belgedeSecili(acikId!) === 0}
                        onClick={() => belgeninHepsi(acikId!, false)}>☐ {c('Bu belgenin seçimini kaldır')}</button>
                <span className="sonuk">{c(`Fiyat, iskonto ve KDV ${adlar.den} gelir; miktar kalana kadar değiştirilebilir.`)}</span>
                <span className="rozet mor ka-sag-rozet">
                  {adlar.irsaliyeMi ? c('Lotlar aynen taşınır') : c('Lot takipli satırlar aktarım sonrası sorulur')}
                </span>
              </div>
              <div className="ka-grid">
                <table className="detay-tablo secilebilir">
                  <thead>
                    <tr>
                      <th style={{ width: 28 }} />
                      <th style={{ width: 100 }}>Kod</th>
                      <th>{c('Stok / Hizmet')}</th>
                      <th className="hiza-sag" style={{ width: 76 }}>Miktar</th>
                      <th className="hiza-sag" style={{ width: 76 }}>{c('Dönüşen')}</th>
                      <th className="hiza-sag" style={{ width: 76 }}>Kalan</th>
                      <th className="hiza-sag" style={{ width: 90 }}>{c('Br. Fiyat')}</th>
                      <th className="hiza-sag" style={{ width: 96 }}>{c('Bu Belgeye')}</th>
                      <th style={{ width: 70 }}>{c('İzlem')}</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(acikSatirlar ?? []).map(r => {
                      const kl = kalan(r);
                      const s = secim[r.satirId];
                      const isaretli = !!s;
                      const hatali = isaretli && (sayi(s.miktar) <= 0 || sayi(s.miktar) > kl);
                      return (
                        <tr key={r.satirId} className={`${kl === 0 ? 'kapali' : ''}${isaretli ? ' secili' : ''}`}
                            onClick={() => kl > 0 && belgeSatiriSec(r, acikId!, !isaretli)}>
                          <td className="hiza-orta" onClick={e => e.stopPropagation()}>
                            <input type="checkbox" checked={isaretli} disabled={kl === 0}
                                   onChange={e => belgeSatiriSec(r, acikId!, e.target.checked)} />
                          </td>
                          <td><code>{r.kalemKodu ?? r.stokKodu ?? ''}</code></td>
                          <td>
                            {r.kalemAdi || r.stokAdi || r.aciklama}
                            {(kartta?.[r.satirId] ?? 0) > 0 && (
                              <span className="rozet gri" style={{ marginLeft: 6 }}
                                    title={c('Bu kartta kaydedilmemiş miktar var; kalandan düşüldü')}>
                                {c('kartta')} {kartta![r.satirId].toLocaleString('tr-TR')}
                              </span>
                            )}
                          </td>
                          <td className="hiza-sag">{Number(r.miktar).toLocaleString('tr-TR')}</td>
                          <td className="hiza-sag sonuk">
                            {Number(r.kapatilanMiktar) > 0 ? Number(r.kapatilanMiktar).toLocaleString('tr-TR') : '—'}
                          </td>
                          <td className="hiza-sag"><b>{kl.toLocaleString('tr-TR')}</b></td>
                          <td className="hiza-sag">{para.format(Number(r.birimFiyat))}</td>
                          <td className="hiza-sag" onClick={e => e.stopPropagation()}>
                            <input className={`hiza-sag ka-miktar${hatali ? ' hata' : ''}`} disabled={!isaretli}
                                   value={isaretli ? s.miktar : kl > 0 ? String(kl) : ''}
                                   title={hatali ? `0 – ${kl}` : ''}
                                   onChange={e => setSecim(x => ({ ...x, [r.satirId]: { belgeId: acikId!, miktar: e.target.value } }))} />
                          </td>
                          <td>
                            {Number(r.izleme ?? 0) > 0
                              ? <span className="rozet mor">{Number(r.izleme) === 2 ? c('Seri') : 'Lot'}</span>
                              : <span className="sonuk">—</span>}
                          </td>
                        </tr>
                      );
                    })}
                    {acikSatirlar && acikSatirlar.length === 0 && (
                      <tr><td colSpan={9} className="bos">{c(`Bu ${adlar.den.replace(/ten$|den$/, 'te').replace('işten', 'işte')} açık (aktarılmamış) satır yok.`)}</td></tr>
                    )}
                  </tbody>
                </table>
                {yukleniyor === acikId && <div className="yukleniyor">{c('Yükleniyor…')}</div>}
              </div>
            </>
          )}
        </div>
      </div>

      {/* SEPET: farklı belgelerden toplananlar */}
      <div className="ka-sepet">
        <button type="button" className="ka-sepet-baslik" onClick={() => setSepetAcik(a => !a)}>
          {sepetAcik ? '▾' : '▸'} {c('Aktarılacaklar')} <span className="rozet mor">{sepet.length}</span>
          <span className="sonuk">— {c('farklı belgelerden seçilen satırlar burada birikir')}</span>
        </button>
        {sepetAcik && (
          <table className="detay-tablo ka-sepet-tablo">
            <thead>
              <tr>
                <th style={{ width: 150 }}>{c('Kaynak')}</th><th style={{ width: 100 }}>Kod</th><th>{c('Stok / Hizmet')}</th>
                <th className="hiza-sag" style={{ width: 90 }}>Miktar</th><th className="hiza-sag" style={{ width: 96 }}>{c('Br. Fiyat')}</th>
                <th style={{ width: 110 }}>{c('İzlem')}</th><th style={{ width: 34 }} />
              </tr>
            </thead>
            <tbody>
              {sepet.length === 0 && <tr><td colSpan={7} className="bos">{c('Henüz satır seçilmedi.')}</td></tr>}
              {sepet.map(x => (
                <tr key={x.r.satirId}>
                  <td><b>{adlar.ad}</b> {belgeNo((belgeler ?? []).find(b => Number(b.id) === x.belgeId))}</td>
                  <td><code>{x.r.kalemKodu ?? x.r.stokKodu ?? ''}</code></td>
                  <td>{x.r.kalemAdi || x.r.stokAdi || x.r.aciklama}</td>
                  <td className="hiza-sag"><b>{x.miktar}</b></td>
                  <td className="hiza-sag">{para.format(Number(x.r.birimFiyat))}</td>
                  <td>
                    {Number(x.r.izleme ?? 0) > 0 && (
                      <span className="rozet mor">
                        {adlar.irsaliyeMi ? (x.r.izlemler?.map(l => l.lotNo || l.seriNo).filter(Boolean).join(', ') || 'Lot')
                                          : c('Lot sorulacak')}
                      </span>
                    )}
                  </td>
                  <td className="hiza-orta">
                    <button type="button" className="ka-sil" title={c('Sepetten çıkar')}
                            onClick={() => setSecim(s => { const y = { ...s }; delete y[x.r.satirId]; return y })}>✕</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </Modal>
  );
}
