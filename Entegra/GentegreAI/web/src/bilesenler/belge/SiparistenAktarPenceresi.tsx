import { useEffect, useState } from 'react';
import { Modal } from '../Modal';
import { GenGrid } from '../GenGrid';
import { api } from '../../api/istemci';
import { type AcikSatir, type ListeSatiri, hataMetni } from '../../api/sozlesme';
import { hamSayi as sayi, para } from '../bicim';
import { c } from '../../dil/ceviri';
import { gorunenBelgeNo } from '../../sayfalar/belgeKartiKurallari';

/** Siparişten karta alınacak açık satır + kullanıcının seçtiği miktar. */
export type SiparisSatiri = AcikSatir & { secilenMiktar: string };

/**
 * SİPARİŞTEN AKTAR (kullanıcı 07.11.2026: "yeni kart açıp siparişten buraya aktarmak isterim").
 *
 * İki adım: (1) sipariş seçilir - carisi belli kartta yalnız o carinin siparişleri; (2) siparişin AÇIK satırları
 * listelenir, kullanıcı satır ve miktar seçer (varsayılan kalan). Seçilenler karta `kaynakSatirId` ile satır olur;
 * kaydedilince sunucu kaynak bağını (kaynak_tur 30) yazar, siparişin kapatılan miktarı tetikle ilerler ve belge
 * siparişin "Belgeye Dönüşüm" listesinde görünür - dönüşüm penceresiyle aynı sonuç, yalnız yön ters (hedef karttan).
 */
export function SiparistenAktarPenceresi({ siparisTuru, tarafId, kartta, onSec, onKapat }: {
  /** Kaynak belge türü: 19 satış / 9 alış siparişi (irsaliye kartı), 18 teklif (sipariş kartı, yalnız KABUL = 3). */
  siparisTuru: number;
  /** Kartın carisi (seçiliyse yalnız onun belgeleri). */
  tarafId?: number | null;
  /** KARTTA ZATEN OLAN kaynak satırlar (kaynakSatirId -> karttaki miktar toplamı). Kayıt öncesi sunucu "kalan"ı
      bilmez; aynı siparişi ikinci kez açınca satır yine tam kalanla geliyordu (kullanıcı 07.11.2026: "aynı siparişten
      2 defa aktarım yapabiliyorum"). Karttaki miktar kalandan düşülür, sıfıra inen satır listelenmez. */
  kartta?: Record<number, number>;
  onSec(siparis: ListeSatiri, satirlar: SiparisSatiri[]): void;
  onKapat(): void;
}) {
  const [siparis, setSiparis] = useState<ListeSatiri | null>(null);
  const [satirlar, setSatirlar] = useState<AcikSatir[]>([]);
  const [secili, setSecili] = useState<Record<number, string>>({});
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    if (!siparis) return;
    let iptal = false;
    setYukleniyor(true); setHata(null);
    api.belgeAcikSatirlar(Number(siparis.id))
      .then(s => { if (iptal) return; setSatirlar(s); setSecili({}) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) })
      .finally(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [siparis]);

  /** Etkin kalan: sunucu kalanı - kartta bekleyen (kaydedilmemiş) miktar. */
  const kalan = (r: AcikSatir) => Math.max(0, Number(r.kalanMiktar) - (kartta?.[r.satirId] ?? 0));
  const acikSatirlar = satirlar.filter(r => kalan(r) > 0);
  const karttaOlan = satirlar.length - acikSatirlar.length;
  const isaretle = (r: AcikSatir) => setSecili(s => {
    const yeni = { ...s };
    if (yeni[r.satirId] !== undefined) delete yeni[r.satirId];
    else yeni[r.satirId] = String(kalan(r));
    return yeni;
  });
  const hepsi = acikSatirlar.length > 0 && acikSatirlar.every(r => secili[r.satirId] !== undefined);
  const secilenler: SiparisSatiri[] = acikSatirlar
    .filter(r => secili[r.satirId] !== undefined)
    .map(r => ({ ...r, secilenMiktar: secili[r.satirId] }));
  const gecersiz = secilenler.find(r => sayi(r.secilenMiktar) <= 0 || sayi(r.secilenMiktar) > kalan(r));
  // Önizleme toplamı YOK (inceleme 07.11.2026): para hesabı tek yerde (fn_belge_diptoplam / BelgeHesap); kart zaten gösterir.

  const teklifMi = siparisTuru === 18;
  const irsaliyeMi = siparisTuru === 14 || siparisTuru === 10;
  const kaynakAdi = teklifMi ? 'Teklif' : irsaliyeMi ? 'İrsaliye' : 'Sipariş';
  // 1. ADIM: kaynak belge seçimi (jenerik liste; carisi belli kartta o carinin belgeleri). Teklifte yalnız KABUL (3) -
  //   dönüşüm penceresiyle aynı kural (sunucu da doğrular).
  if (!siparis) {
    const kosullar = [{ alan: 'tur', op: 'esit' as const, deger: siparisTuru }];
    if (tarafId) kosullar.push({ alan: 'tarafId', op: 'esit' as const, deger: tarafId });
    if (teklifMi) kosullar.push({ alan: 'teklifDurum', op: 'esit' as const, deger: 3 });
    return (
      <Modal baslik={c(teklifMi ? 'Kabul Edilmiş Teklif Seç'
                       : irsaliyeMi ? (siparisTuru === 10 ? 'Alış İrsaliyesi Seç' : 'Satış İrsaliyesi Seç')
                       : siparisTuru === 9 ? 'Alış Siparişi Seç' : 'Satış Siparişi Seç')} onKapat={onKapat} enUst
             alt={<button className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>}>
        <GenGrid kaynak="belge" gomulu seritGizli boyut={25}
                 sabitFiltre={{ op: 'and', kosullar }}
                 onSatirAc={r => setSiparis(r)} />
      </Modal>
    );
  }

  // 2. ADIM: açık satırlar + miktar.
  const no = gorunenBelgeNo(String(siparis.belgeNo ?? '')) || `#${siparis.id}`;
  return (
    <Modal
      baslik={`${c(teklifMi ? 'Tekliften Aktar' : irsaliyeMi ? 'İrsaliyeden Aktar' : 'Siparişten Aktar')} — ${no} · ${String(siparis.tarafUnvan ?? '')}`}
      onKapat={onKapat} enUst
      alt={
        <>
          <button className="d ana" disabled={secilenler.length === 0 || !!gecersiz}
                  title={gecersiz ? 'Miktar 0 ile kalan arasında olmalı.' : ''}
                  onClick={() => onSec(siparis, secilenler)}>
            ✔ {c('Seçilenleri Aktar')}{secilenler.length > 0 ? ` (${secilenler.length})` : ''}
          </button>
          <button className="d" onClick={() => { setSiparis(null); setSatirlar([]) }}>‹ {c(`Başka ${kaynakAdi.toLocaleLowerCase('tr-TR')}`)}</button>
          <span className="ayrac" />
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
        </>
      }
    >
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="kagrup">
        <div className="not" style={{ margin: '6px 10px' }}>
          {c(`Fiyat, iskonto ve KDV ${teklifMi ? 'tekliften' : irsaliyeMi ? 'irsaliyeden' : 'siparişten'} gelir; miktar kalana kadar değiştirilebilir. Kaydedilince kaynak satır bu miktar kadar kapanır.`)}
        </div>
        <table className="detay-tablo secilebilir">
          <thead>
            <tr>
              <th style={{ width: 28 }}>
                <input type="checkbox" checked={hepsi} disabled={!acikSatirlar.length} title={c('Tümünü seç')}
                       onChange={e => setSecili(e.target.checked
                         ? Object.fromEntries(acikSatirlar.map(r => [r.satirId, String(kalan(r))])) : {})} />
              </th>
              <th style={{ width: 110 }}>Kod</th>
              <th>{c('Stok / Hizmet')}</th>
              <th className="hiza-sag" style={{ width: 80 }}>Miktar</th>
              <th className="hiza-sag" style={{ width: 80 }}>{c('Dönüşen')}</th>
              <th className="hiza-sag" style={{ width: 80 }}>Kalan</th>
              <th className="hiza-sag" style={{ width: 90 }}>{c('Br. Fiyat')}</th>
              <th className="hiza-sag" style={{ width: 100 }}>{c('Bu Belgeye')}</th>
            </tr>
          </thead>
          <tbody>
            {acikSatirlar.map(r => {
              const isaretli = secili[r.satirId] !== undefined;
              return (
                <tr key={r.satirId} className={isaretli ? 'secili' : ''} onClick={() => isaretle(r)}>
                  <td className="hiza-orta" onClick={e => e.stopPropagation()}>
                    <input type="checkbox" checked={isaretli} onChange={() => isaretle(r)} />
                  </td>
                  <td><code>{r.kalemKodu ?? r.stokKodu ?? ''}</code></td>
                  <td>{r.kalemAdi || r.stokAdi || r.aciklama}</td>
                  <td className="hiza-sag">{Number(r.miktar).toLocaleString('tr-TR')}</td>
                  <td className="hiza-sag sonuk">
                    {Number(r.kapatilanMiktar) > 0 ? Number(r.kapatilanMiktar).toLocaleString('tr-TR') : '—'}
                  </td>
                  <td className="hiza-sag"><b>{kalan(r).toLocaleString('tr-TR')}</b></td>
                  <td className="hiza-sag">{para.format(Number(r.birimFiyat))}</td>
                  <td className="hiza-sag" onClick={e => e.stopPropagation()}>
                    {isaretli && (
                      <input className="hiza-sag" style={{ width: 80 }} value={secili[r.satirId]}
                             onChange={e => setSecili(s => ({ ...s, [r.satirId]: e.target.value }))} />
                    )}
                  </td>
                </tr>
              );
            })}
            {!yukleniyor && acikSatirlar.length === 0 && (
              <tr><td colSpan={8} className="bos">
                {karttaOlan > 0
                  ? c('Bu belgenin açık satırlarının tamamı zaten bu kartta.')
                  : c(`Bu ${teklifMi ? 'teklifte' : irsaliyeMi ? 'irsaliyede' : 'siparişte'} açık (aktarılmamış) satır yok.`)}
              </td></tr>
            )}
            {!yukleniyor && acikSatirlar.length > 0 && karttaOlan > 0 && (
              <tr><td colSpan={8} className="sonuk" style={{ fontSize: 11 }}>
                {karttaOlan} {c('satır zaten bu kartta (listelenmedi).')}
              </td></tr>
            )}
          </tbody>
        </table>
        {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}
      </div>
    </Modal>
  );
}
