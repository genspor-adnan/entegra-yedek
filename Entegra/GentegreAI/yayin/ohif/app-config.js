/**
 * OHIF VIEWER (v3) YAPILANDIRMASI - Gentegre AI (kullanıcı 11.11.2026: "ClearCanvas ImageServer + OHIF").
 *
 * Veri kaynağı "dicomjson": çalışma manifesti ve görüntüler Gentegre API'den gelir
 *   (GET /api/dicom/manifest/{studyUid}?t=…  →  instances[].url = dicomweb:{API}/api/dicom/wado?…&t=…),
 *   API de ClearCanvas'a C-FIND (104) ve WADO-URI (1000) ile gider. OHIF ClearCanvas'ı doğrudan görmez.
 * Açılış adresi: {OHIF}/viewer/dicomjson?url={manifest} - Gentegre "🖼 Görüntüle" düğmesi bunu üretir.
 * Çalışma listesi yok (showStudyList: false): PACS tarama Gentegre'den yapılır.
 */
window.config = {
  routerBasename: '/',
  showStudyList: false,
  extensions: [],
  modes: [],
  customizationService: {},
  showWarningMessageForCrossOrigin: false,
  showCPUFallbackMessage: true,
  showLoadingIndicator: true,
  strictZSpacingForVolumeViewport: true,
  investigationalUseDialog: { option: 'never' },
  defaultDataSourceName: 'dicomjson',
  dataSources: [
    {
      namespace: '@ohif/extension-default.dataSourcesModule.dicomjson',
      sourceName: 'dicomjson',
      configuration: {
        friendlyName: 'Gentegre (ClearCanvas)',
        name: 'json',
      },
    },
  ],
};
