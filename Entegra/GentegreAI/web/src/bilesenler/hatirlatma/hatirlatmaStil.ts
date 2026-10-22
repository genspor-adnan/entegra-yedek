/** Kişisel hatırlatıcı ekranlarının ortak stili (hk- öneki; `.d` tema.css'te düğme sınıfıdır, kullanılmaz). */
export const HATIRLATMA_STIL = `
.hk-govde { padding: 12px 14px; min-height: 300px }
.hk-serit { display: grid; grid-template-columns: 2fr 1fr .8fr 1.4fr; gap: 8px 14px; padding: 10px 14px;
  background: var(--kartzem); border-bottom: 1px solid var(--cizgi) }
@media (max-width: 800px) { .hk-serit { grid-template-columns: 1fr 1fr } .hk-serit .hk-bas { grid-column: 1 / -1 } }
.hk-alan label { display: block; font-size: 11px; color: var(--soluk); margin-bottom: 3px }
.hk-alan input:not([type=checkbox]), .hk-alan select, .hk-alan textarea { width: 100%; box-sizing: border-box }
.hk-bas input { font-weight: 700 }
.hk-form { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px 14px }
.hk-g2 { grid-column: span 2 } .hk-g4 { grid-column: 1 / -1 }
@media (max-width: 800px) { .hk-form { grid-template-columns: 1fr 1fr } .hk-g2 { grid-column: 1 / -1 } }
.hk-sec, .hk-gunler { display: flex; gap: 6px; flex-wrap: wrap; align-items: center }
.hk-sec button, .hk-gunler button, .hk-hizli button { border: 1px solid var(--cizgi); background: var(--yuz); color: var(--yazi);
  border-radius: 3px; padding: 4px 10px; font: inherit; cursor: pointer }
.hk-sec button.on, .hk-hizli button.on { border-color: var(--mor); color: var(--yazi2); font-weight: 700; box-shadow: 0 0 0 1px var(--mor) inset }
.hk-gunler button { width: 34px; padding: 4px 0 }
.hk-gunler button.on { background: var(--mor); border-color: var(--mor); color: #fff; font-weight: 700 }
.hk-sec button:disabled, .hk-gunler button:disabled, .hk-hizli button:disabled { cursor: default; opacity: .7 }
.hk-hizli { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 6px }
@media (max-width: 800px) { .hk-hizli { grid-template-columns: repeat(2, minmax(0, 1fr)) } }
.hk-hizli button { text-align: left; background: var(--kartzem) }
.hk-hizli small { display: block; color: var(--soluk); font-size: 10.5px }
.hk-ozel { display: inline-flex; gap: 4px; align-items: center } .hk-ozel input { width: 70px !important }
.hk-chk { display: flex !important; gap: 8px; align-items: flex-start; padding: 4px 0; color: var(--yazi) !important; font-size: 12px !important; cursor: pointer }
.hk-chk small { display: block; color: var(--soluk) }
.hk-soluk { color: var(--soluk); font-size: 11.5px }
.hk-bilgi { border: 1px solid var(--cizgi); background: var(--kartzem); color: var(--yazi2); border-radius: 4px; padding: 7px 10px; font-size: 12px }
.hk-bilgi-satir { padding: 5px 0 }
.hk-iki { display: grid; grid-template-columns: minmax(0, 1fr) 280px; gap: 12px; align-items: start }
@media (max-width: 800px) { .hk-iki { grid-template-columns: 1fr } }
.hk-kutu { border: 1px solid var(--cizgi); border-radius: 4px; background: var(--yuz); overflow: hidden; margin-bottom: 10px }
.hk-kutu > h6 { margin: 0; padding: 6px 10px; font-size: 12px; color: var(--yazi2); background: var(--kartzem); border-bottom: 1px solid var(--cizgi) }
.hk-ic { padding: 8px 10px }
.hk-kv { display: grid; grid-template-columns: auto 1fr; gap: 5px 12px; font-size: 12px }
.hk-kv > b { color: var(--soluk); font-weight: normal }
.hk-cipler { display: flex; gap: 6px; flex-wrap: wrap; padding: 2px 0 }
.hk-cip { border: 1px solid var(--cizgi); border-radius: 12px; padding: 2px 4px 2px 10px; background: var(--kartzem); display: inline-flex; gap: 4px; align-items: center }
.hk-cip button { border: none; background: none; cursor: pointer; color: var(--soluk) }
.hk-sonuc { display: flex; gap: 4px; flex-wrap: wrap; margin-top: 5px }
.hk-sonuc button { border: 1px dashed var(--cizgi); background: var(--yuz); border-radius: 12px; padding: 2px 10px; cursor: pointer; font: inherit }
.hk-tablo { width: 100%; border-collapse: collapse; font-size: 12px; border: 1px solid var(--cizgi) }
.hk-tablo th { text-align: left; padding: 6px 8px; background: var(--kartzem); border-bottom: 1px solid var(--cizgi); color: var(--yazi2); white-space: nowrap }
.hk-tablo td { padding: 5px 8px; border-bottom: 1px solid var(--cizgi) }
.hk-rz { padding: 1px 9px; border-radius: 10px; font-size: 11px; display: inline-block; border: 1px solid var(--cizgi);
  background: var(--kartzem); color: var(--yazi); white-space: nowrap }
.hk-rz.ok { background: var(--okzem); color: var(--ok); border-color: var(--okkenar) }
.hk-rz.kir { background: var(--hatazem); color: var(--hata); border-color: var(--hatakenar) }
.hk-rz.sari { background: var(--uyarizem); color: var(--uyari); border-color: var(--uyarikenar) }
.hk-rz.mavi { color: var(--mor) }
.hk-durum { display: flex; gap: 14px; padding: 5px 14px; font-size: 11.5px; color: var(--soluk); align-items: center; flex-wrap: wrap }
.hk-ertele-sar { position: relative; display: inline-block }
.hk-menu { position: absolute; bottom: 100%; left: 0; margin-bottom: 4px; background: var(--yuz); border: 1px solid var(--cizgi);
  border-radius: 4px; box-shadow: 0 8px 24px rgba(20,40,70,.2); z-index: 5; min-width: 150px; display: flex; flex-direction: column }
.hk-menu.asagi { top: 100%; bottom: auto; margin: 4px 0 0 }
.hk-menu button { border: none; background: none; text-align: left; padding: 7px 12px; cursor: pointer; font: inherit; color: var(--yazi) }
.hk-menu button:hover { background: var(--kartzem) }
/* açılır uyarılar */
.hk-tostlar { position: fixed; right: 16px; bottom: 70px; z-index: 900; display: flex; flex-direction: column; gap: 10px; max-width: calc(100vw - 32px) }
.hk-tost { width: 360px; max-width: 100%; background: var(--yuz); color: var(--yazi); border: 1px solid var(--cizgi);
  border-left: 5px solid var(--mor); border-radius: 5px; box-shadow: 0 12px 34px rgba(20,40,70,.28); padding: 10px 12px; box-sizing: border-box }
.hk-tost.kir { border-left-color: var(--hata) }
.hk-tost .hk-tu { display: flex; gap: 8px; align-items: center; font-size: 11px; color: var(--soluk) }
.hk-tost .hk-tu .x { margin-left: auto; cursor: pointer; border: none; background: none; color: var(--soluk); font-size: 13px }
.hk-tost b.bs { display: block; font-size: 13px; margin: 4px 0 2px; cursor: pointer }
.hk-tost .eyl { display: flex; gap: 4px; margin-top: 8px; flex-wrap: wrap }
.hk-bag { color: var(--mor); font-size: 11.5px }
/* zil sekmesi */
.hk-zil li.hk-gec .hk-zb { color: var(--hata) }
.hk-zil .hk-eyl { display: flex; gap: 3px; margin-top: 4px; flex-wrap: wrap }
`;
