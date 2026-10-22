import { Fragment, useState } from 'react';
import { DokumanGalerisi } from '../DokumanGalerisi';
import { tarihYaz } from '../bicim';

/**
 * PERSONEL KARTI "BELGELER" SEKMESİNİN ÜSTÜ (1135-1136, mockup
 * Ekranlar/IK/personel_belge_takibi.html). Kullanıcı 22.10.2026 "tek olsun":
 * Belge Durumu ayrı sekme değil - burada özet + şablondaki belgeler listesi;
 * satıra tıklayınca o belgenin dosyaları (dokuman 'personel-belge', kaynak_id
 * = personel_belge.id) altta açılır. Belge kaydı sekmenin altındaki gridde
 * girilir; eksik satırdaki "＋ Ekle" gride o türde yeni satır açar.
 */

const ROZET: Record<number, string> = { 1: 'hata', 2: 'hata', 3: 'uyari', 4: 'ok' };

export function PersonelBelgePaneli({ durumlar, saltOkunur, onEkle }: {
  /** v_personel_belge_durum satırları (kart detayı "belgeDurumu"). */
  durumlar: Record<string, unknown>[];
  saltOkunur: boolean;
  /** Gride bu türde yeni belge satırı aç. */
  onEkle(belgeTuruId: number): void;
}) {
  const [seciliId, setSeciliId] = useState<number | null>(null);
  // Galeride yükleme / silme sonrası sayı: listedeki sayı kart açılışındaki değerdir.
  const [sayilar, setSayilar] = useState<Record<number, number>>({});

  const zorunlu = durumlar.filter(d => Number(d.zorunlu) === 1);
  const say = (f: (d: Record<string, unknown>) => boolean) => durumlar.filter(f).length;
  const tamam = zorunlu.filter(d => Number(d.durum) >= 3).length;
  const yuzde = zorunlu.length ? Math.round(100 * tamam / zorunlu.length) : 100;
  const secili = durumlar.find(d => Number(d.belgeId) === seciliId);

  if (durumlar.length === 0)
    return (
      <div style={{ padding: '8px 14px', color: 'var(--soluk)' }}>
        Bu personele zorunlu belge tanımlı değil (İK › Belge Takibi › Belge Türleri › Kime zorunlu).
        Elindeki belgeleri aşağıya girebilirsiniz.
      </div>
    );

  let sonGrup = '';
  return (
    <div style={{ margin: '10px 14px 0', border: '1px solid var(--cizgi)', borderRadius: 4 }}>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, alignItems: 'center', padding: '8px 10px',
                    background: 'var(--grupzem)', color: 'var(--grupyazi)' }}>
        <b>Özlük dosyası %{yuzde}</b>
        <span className="rozet bilgi">Zorunlu {zorunlu.length}</span>
        <span className="rozet ok">Tamam {tamam}</span>
        <span className="rozet hata">Eksik {say(d => Number(d.zorunlu) === 1 && Number(d.durum) === 1)}</span>
        <span className="rozet hata">Süresi doldu {say(d => Number(d.durum) === 2)}</span>
        <span className="rozet uyari">Yaklaşan {say(d => Number(d.durum) === 3)}</span>
      </div>
      <table className="grid">
        <thead>
          <tr>
            <th>Belge</th><th className="hiza-orta">Zorunlu</th><th>Durum</th><th>Belge tarihi</th>
            <th>Geçerlilik</th><th className="hiza-sag">Kalan</th><th className="hiza-orta">Dosya</th><th />
          </tr>
        </thead>
        <tbody>
          {durumlar.map(d => {
            const grup = String(d.grupAdi ?? '');
            const baslik = grup !== sonGrup;
            sonGrup = grup;
            const belgeId = Number(d.belgeId ?? 0);
            const dosya = belgeId > 0 ? (sayilar[belgeId] ?? Number(d.dosyaSayisi ?? 0)) : 0;
            const kalan = d.kalanGun == null || d.kalanGun === '' ? '' : `${d.kalanGun} gün`;
            return (
              <Fragment key={String(d.id)}>
                {baslik && <tr className="grup-bas"><td colSpan={8}>{grup}</td></tr>}
                <tr className={belgeId > 0 && belgeId === seciliId ? 'secili' : undefined}
                    style={{ cursor: belgeId > 0 ? 'pointer' : undefined }}
                    title={belgeId > 0 ? 'Dosyalarını göster' : undefined}
                    onClick={() => belgeId > 0 && setSeciliId(belgeId === seciliId ? null : belgeId)}>
                  <td>{String(d.belge ?? '')}</td>
                  <td className="hiza-orta">{Number(d.zorunlu) === 1 ? '✔' : ''}</td>
                  <td><span className={`rozet ${ROZET[Number(d.durum)] ?? 'gri'}`}>{String(d.durumAdi ?? '')}</span></td>
                  <td>{d.belgeTarihi ? tarihYaz(String(d.belgeTarihi)) : '—'}</td>
                  <td>{d.gecerlilikTarihi ? tarihYaz(String(d.gecerlilikTarihi)) : belgeId > 0 ? 'süresiz' : '—'}</td>
                  <td className="hiza-sag">{kalan}</td>
                  <td className="hiza-orta">{belgeId > 0 ? (dosya > 0 ? `📎 ${dosya}` : '—') : ''}</td>
                  <td className="hiza-sag">
                    {!saltOkunur && belgeId === 0 && (
                      <button type="button" className="d" onClick={e => { e.stopPropagation(); onEkle(Number(d.belgeTuruId)); }}>
                        ＋ Ekle
                      </button>
                    )}
                  </td>
                </tr>
              </Fragment>
            );
          })}
        </tbody>
      </table>
      {secili && (
        <div style={{ borderTop: '1px solid var(--cizgi)' }}>
          <div style={{ padding: '6px 10px', fontWeight: 700 }}>📎 {String(secili.belge ?? '')} - dosyalar</div>
          <DokumanGalerisi key={seciliId!} kartAdi="personelBelge" kaynakId={seciliId!} saltOkunur={saltOkunur}
                           onSayi={n => setSayilar(o => o[seciliId!] === n ? o : { ...o, [seciliId!]: n })} />
        </div>
      )}
    </div>
  );
}
