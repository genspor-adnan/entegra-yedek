// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://efatura.izibiz.com.tr:2443/EFaturaOIB?wsdl
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?wsdl>0
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=9
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=6
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=7
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=8
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=5
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=4
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=3
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=1
//  >Import : https://efatura.izibiz.com.tr:2443/EFaturaOIB?xsd=2
// Encoding : UTF-8
// Version  : 1.0
// (03/04/2014 17:37:11 - - $Rev: 52705 $)
// ************************************************************************ //

unit EFaturaOIB;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_UNQL = $0008;
  IS_ATTR = $0010;
  IS_TEXT = $0020;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:decimal         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:normalizedString - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:anyURI          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:token           - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:anyType         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:date            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:long            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:dateTime        - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:language        - "http://www.w3.org/2001/XMLSchema"[Gbl]

  SendInvoiceResponseWithServerSignResponse2 = class;   { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  SendInvoiceResponseResponse2 = class;         { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  LoadInvoiceResponse2 = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  GetInvoiceStatusResponse2 = class;            { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  SendInvoiceResponseWithServerSignResponse = class;   { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  SendInvoiceResponseResponse = class;          { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  LoadInvoiceResponse  = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  GetInvoiceStatusResponse = class;             { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  AmountType           = class;                 { "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"[GblCplx] }
  MeasureType          = class;                 { "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"[GblCplx] }
  IdentifierType       = class;                 { "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"[GblCplx] }
  CHANGE_INFOType      = class;                 { "http://schemas.i2i.com/ei/common"[GblCplx] }
  ATTRIBUTESTYPE       = class;                 { "http://schemas.i2i.com/ei/common"[GblCplx] }
  BinaryObjectType     = class;                 { "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"[GblCplx] }
  CodeType             = class;                 { "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"[GblCplx] }
  base64Binary         = class;                 { "http://www.w3.org/2005/05/xmlmime"[GblCplx] }
  hexBinary            = class;                 { "http://www.w3.org/2005/05/xmlmime"[GblCplx] }
  GIBUSER              = class;                 { "http://schemas.i2i.com/ei/wsdl"[GblCplx] }
  REQUEST_RETURNType   = class;                 { "http://schemas.i2i.com/ei/entity"[GblCplx] }
  CancelUserResponse   = class;                 { "http://schemas.i2i.com/ei/wsdl"[GblElm] }
  ProcessUserResponse  = class;                 { "http://schemas.i2i.com/ei/wsdl"[GblElm] }
  RequestFault         = class;                 { "http://schemas.i2i.com/ei/wsdl"[Flt][GblElm] }
  REQUEST_ERRORType    = class;                 { "http://schemas.i2i.com/ei/entity"[GblCplx] }
  REQUEST              = class;                 { "http://schemas.i2i.com/ei/entity"[GblCplx] }
  GetInvoiceStatusRequest2 = class;             { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  GetInvoiceStatusRequest = class;              { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  CheckUserRequest2    = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  CheckUserRequest     = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  SendInvoiceResponseRequest2 = class;          { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  SendInvoiceResponseRequest = class;           { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  REQUEST_HEADERType   = class;                 { "http://schemas.i2i.com/ei/entity"[GblCplx] }
  GetUserListRequest2  = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  GetUserListAsCSVRequest = class;              { "http://schemas.i2i.com/ei/wsdl"[GblElm] }
  GetUserListRequest   = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  QuantityType         = class;                 { "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"[GblCplx] }
  SENDER               = class;                 { "http://schemas.i2i.com/ei/wsdl"[Cplx] }
  RECEIVER             = class;                 { "http://schemas.i2i.com/ei/wsdl"[Cplx] }
  UserRequest          = class;                 { "http://schemas.i2i.com/ei/wsdl"[GblCplx] }
  PrepareProcessUserRequest = class;            { "http://schemas.i2i.com/ei/wsdl"[GblElm] }
  CancelUserRequest    = class;                 { "http://schemas.i2i.com/ei/wsdl"[GblElm] }
  PrepareCancelUserRequest = class;             { "http://schemas.i2i.com/ei/wsdl"[GblElm] }
  ProcessUserRequest   = class;                 { "http://schemas.i2i.com/ei/wsdl"[GblElm] }
  SendInvoiceResponse2 = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  SendInvoiceResponse  = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  MarkInvoiceRequest2  = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  MarkInvoiceRequest   = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  MarkInvoiceResponse2 = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  MarkInvoiceResponse  = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  GetInvoiceRequest2   = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  GetInvoiceRequest    = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  MARK                 = class;                 { "http://schemas.i2i.com/ei/wsdl"[Cplx] }
  SendInvoiceRequest2  = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  SendInvoiceRequest   = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  PrepareInvoiceResponseRequest2 = class;       { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  PrepareInvoiceResponseRequest = class;        { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  LoadInvoiceRequest2  = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  LoadInvoiceRequest   = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  SendInvoiceResponseWithServerSignRequest2 = class;   { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  SendInvoiceResponseWithServerSignRequest = class;   { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  INVOICE_SEARCH_KEY   = class;                 { "http://schemas.i2i.com/ei/wsdl"[Cplx] }
  INVOICE              = class;                 { "http://schemas.i2i.com/ei/wsdl"[GblCplx] }
  INVOICE_STATUS       = class;                 { "http://schemas.i2i.com/ei/wsdl"[Cplx] }
  HEADER               = class;                 { "http://schemas.i2i.com/ei/wsdl"[Cplx] }
  TextType             = class;                 { "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"[GblCplx] }
  NameType             = class;                 { "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"[GblCplx] }
  LoginRequest2        = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  LoginRequest         = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  USERCONTENT          = class;                 { "http://schemas.i2i.com/ei/wsdl"[GblCplx] }
  LoginResponse2       = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  LoginResponse        = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  LogoutRequest2       = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  LogoutRequest        = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }
  LogoutResponse2      = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  LogoutResponse       = class;                 { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }

  {$SCOPEDENUMS ON}
  { "urn:un:unece:uncefact:codelist:specification:IANAMIMEMediaType:2003"[GblSmpl] }
  BinaryObjectMimeCodeContentType = (
      application_CSTAdata_xml, 
      application_EDI_Consent, 
      application_EDI_X12, 
      application_EDIFACT, 
      application_activemessage, 
      application_andrew_inset, 
      application_applefile, 
      application_atomicmail, 
      application_batch_SMTP, 
      application_beep_xml, 
      application_cals_1840, 
      application_cnrp_xml, 
      application_commonground, 
      application_cpl_xml, 
      application_csta_xml, 
      application_cybercash, 
      application_dca_rft, 
      application_dec_dx, 
      application_dialog_info_xml, 
      application_dicom, 
      application_dns, 
      application_dvcs, 
      application_epp_xml, 
      application_eshop, 
      application_fits, 
      application_font_tdpfr, 
      application_http, 
      application_hyperstudio, 
      application_iges, 
      application_im_iscomposing_xml, 
      application_index, 
      application_index_cmd, 
      application_index_obj, 
      application_index_response, 
      application_index_vnd, 
      application_iotp, 
      application_ipp, 
      application_isup, 
      application_kpml_request_xml, 
      application_kpml_response_xml, 
      application_mac_binhex40, 
      application_macwriteii, 
      application_marc, 
      application_mathematica, 
      application_mbox, 
      application_mikey, 
      application_mpeg4_generic, 
      application_msword, 
      application_news_message_id, 
      application_news_transmission, 
      application_ocsp_request, 
      application_ocsp_response, 
      application_octet_stream, 
      application_oda, 
      application_ogg, 
      application_parityfec, 
      application_pdf, 
      application_pgp_encrypted, 
      application_pgp_keys, 
      application_pgp_signature, 
      application_pidf_xml, 
      application_pkcs10, 
      application_pkcs7_mime, 
      application_pkcs7_signature, 
      application_pkix_cert, 
      application_pkix_crl, 
      application_pkix_pkipath, 
      application_pkixcmp, 
      application_postscript, 
      application_prs_alvestrand_titrax_sheet, 
      application_prs_cww, 
      application_prs_nprend, 
      application_prs_plucker, 
      application_qsig, 
      application_rdf_xml, 
      application_reginfo_xml, 
      application_remote_printing, 
      application_resource_lists_xml, 
      application_riscos, 
      application_rls_services_xml, 
      application_rtf, 
      application_samlassertion_xml, 
      application_samlmetadata_xml, 
      application_sbml_xml, 
      application_sdp, 
      application_set_payment, 
      application_set_payment_initiation, 
      application_set_registration, 
      application_set_registration_initiation, 
      application_sgml, 
      application_sgml_open_catalog, 
      application_shf_xml, 
      application_sieve, 
      application_simple_filter_xml, 
      application_simple_message_summary, 
      application_slate, 
      application_soap_xml, 
      application_spirits_event_xml, 
      application_timestamp_query, 
      application_timestamp_reply, 
      application_tve_trigger, 
      application_vemmi, 
      application_vnd_3M_Post_it_Notes, 
      application_vnd_3gpp_pic_bw_large, 
      application_vnd_3gpp_pic_bw_small, 
      application_vnd_3gpp_pic_bw_var, 
      application_vnd_3gpp_sms, 
      application_vnd_FloGraphIt, 
      application_vnd_Kinar, 
      application_vnd_Mobius_DAF, 
      application_vnd_Mobius_DIS, 
      application_vnd_Mobius_MBK, 
      application_vnd_Mobius_MQY, 
      application_vnd_Mobius_MSL, 
      application_vnd_Mobius_PLC, 
      application_vnd_Mobius_TXF, 
      application_vnd_Quark_QuarkXPress, 
      application_vnd_RenLearn_rlprint, 
      application_vnd_accpac_simply_aso, 
      application_vnd_accpac_simply_imp, 
      application_vnd_acucobol, 
      application_vnd_acucorp, 
      application_vnd_adobe_xfdf, 
      application_vnd_aether_imp, 
      application_vnd_amiga_ami, 
      application_vnd_anser_web_certificate_issue_initiation, 
      application_vnd_anser_web_funds_transfer_initiation, 
      application_vnd_audiograph, 
      application_vnd_blueice_multipass, 
      application_vnd_bmi, 
      application_vnd_businessobjects, 
      application_vnd_canon_cpdl, 
      application_vnd_canon_lips, 
      application_vnd_cinderella, 
      application_vnd_claymore,
      application_vnd_commerce_battelle, 
      application_vnd_commonspace, 
      application_vnd_contact_cmsg, 
      application_vnd_cosmocaller, 
      application_vnd_criticaltools_wbs_xml, 
      application_vnd_ctc_posml, 
      application_vnd_cups_postscript, 
      application_vnd_cups_raster, 
      application_vnd_cups_raw, 
      application_vnd_curl, 
      application_vnd_cybank, 
      application_vnd_data_vision_rdz, 
      application_vnd_dna, 
      application_vnd_dpgraph, 
      application_vnd_dreamfactory, 
      application_vnd_dxr, 
      application_vnd_ecdis_update, 
      application_vnd_ecowin_chart, 
      application_vnd_ecowin_filerequest, 
      application_vnd_ecowin_fileupdate, 
      application_vnd_ecowin_series, 
      application_vnd_ecowin_seriesrequest, 
      application_vnd_ecowin_seriesupdate, 
      application_vnd_enliven, 
      application_vnd_epson_esf, 
      application_vnd_epson_msf, 
      application_vnd_epson_quickanime, 
      application_vnd_epson_salt, 
      application_vnd_epson_ssf, 
      application_vnd_ericsson_quickcall, 
      application_vnd_eudora_data, 
      application_vnd_fdf, 
      application_vnd_ffsns, 
      application_vnd_fints, 
      application_vnd_framemaker, 
      application_vnd_fsc_weblaunch, 
      application_vnd_fujitsu_oasys, 
      application_vnd_fujitsu_oasys2, 
      application_vnd_fujitsu_oasys3, 
      application_vnd_fujitsu_oasysgp, 
      application_vnd_fujitsu_oasysprs, 
      application_vnd_fujixerox_ddd, 
      application_vnd_fujixerox_docuworks, 
      application_vnd_fujixerox_docuworks_binder, 
      application_vnd_fut_misnet, 
      application_vnd_genomatix_tuxedo, 
      application_vnd_grafeq, 
      application_vnd_groove_account, 
      application_vnd_groove_help, 
      application_vnd_groove_identity_message, 
      application_vnd_groove_injector,
      application_vnd_groove_tool_message, 
      application_vnd_groove_tool_template, 
      application_vnd_groove_vcard, 
      application_vnd_hbci, 
      application_vnd_hcl_bireports, 
      application_vnd_hhe_lesson_player, 
      application_vnd_hp_HPGL, 
      application_vnd_hp_PCL, 
      application_vnd_hp_PCLXL, 
      application_vnd_hp_hpid, 
      application_vnd_hp_hps, 
      application_vnd_httphone, 
      application_vnd_hzn_3d_crossword, 
      application_vnd_ibm_MiniPay, 
      application_vnd_ibm_afplinedata, 
      application_vnd_ibm_electronic_media, 
      application_vnd_ibm_modcap, 
      application_vnd_ibm_rights_management, 
      application_vnd_ibm_secure_container, 
      application_vnd_informix_visionary, 
      application_vnd_intercon_formnet, 
      application_vnd_intertrust_digibox, 
      application_vnd_intertrust_nncp, 
      application_vnd_intu_qbo, 
      application_vnd_intu_qfx, 
      application_vnd_ipunplugged_rcprofile, 
      application_vnd_irepository_package_xml, 
      application_vnd_is_xpr, 
      application_vnd_japannet_directory_service, 
      application_vnd_japannet_jpnstore_wakeup, 
      application_vnd_japannet_payment_wakeup, 
      application_vnd_japannet_registration, 
      application_vnd_japannet_registration_wakeup, 
      application_vnd_japannet_setstore_wakeup, 
      application_vnd_japannet_verification, 
      application_vnd_japannet_verification_wakeup, 
      application_vnd_jisp, 
      application_vnd_kde_karbon, 
      application_vnd_kde_kchart, 
      application_vnd_kde_kformula, 
      application_vnd_kde_kivio, 
      application_vnd_kde_kontour, 
      application_vnd_kde_kpresenter, 
      application_vnd_kde_kspread, 
      application_vnd_kde_kword, 
      application_vnd_kenameaapp, 
      application_vnd_kidspiration, 
      application_vnd_koan, 
      application_vnd_liberty_request_xml, 
      application_vnd_llamagraphics_life_balance_desktop, 
      application_vnd_llamagraphics_life_balance_exchange_xml,
      application_vnd_lotus_1_2_3, 
      application_vnd_lotus_approach, 
      application_vnd_lotus_freelance, 
      application_vnd_lotus_notes, 
      application_vnd_lotus_organizer, 
      application_vnd_lotus_screencam, 
      application_vnd_lotus_wordpro, 
      application_vnd_mcd, 
      application_vnd_mediastation_cdkey, 
      application_vnd_meridian_slingshot, 
      application_vnd_mfmp, 
      application_vnd_micrografx_flo, 
      application_vnd_micrografx_igx, 
      application_vnd_mif, 
      application_vnd_minisoft_hp3000_save, 
      application_vnd_mitsubishi_misty_guard_trustweb, 
      application_vnd_mophun_application, 
      application_vnd_mophun_certificate, 
      application_vnd_motorola_flexsuite, 
      application_vnd_motorola_flexsuite_adsi, 
      application_vnd_motorola_flexsuite_fis, 
      application_vnd_motorola_flexsuite_gotap, 
      application_vnd_motorola_flexsuite_kmr, 
      application_vnd_motorola_flexsuite_ttc, 
      application_vnd_motorola_flexsuite_wem, 
      application_vnd_mozilla_xul_xml, 
      application_vnd_ms_artgalry, 
      application_vnd_ms_asf, 
      application_vnd_ms_excel, 
      application_vnd_ms_lrm, 
      application_vnd_ms_powerpoint, 
      application_vnd_ms_project, 
      application_vnd_ms_tnef, 
      application_vnd_ms_works, 
      application_vnd_ms_wpl, 
      application_vnd_mseq, 
      application_vnd_msign, 
      application_vnd_music_niff, 
      application_vnd_musician, 
      application_vnd_nervana, 
      application_vnd_netfpx, 
      application_vnd_noblenet_directory, 
      application_vnd_noblenet_sealer, 
      application_vnd_noblenet_web, 
      application_vnd_nokia_landmark_wbxml, 
      application_vnd_nokia_landmark_xml, 
      application_vnd_nokia_landmarkcollection_xml, 
      application_vnd_nokia_radio_preset, 
      application_vnd_nokia_radio_presets, 
      application_vnd_novadigm_EDM, 
      application_vnd_novadigm_EDX,
      application_vnd_novadigm_EXT, 
      application_vnd_obn, 
      application_vnd_omads_email_xml, 
      application_vnd_omads_file_xml, 
      application_vnd_omads_folder_xml, 
      application_vnd_osa_netdeploy, 
      application_vnd_palm, 
      application_vnd_paos_xml, 
      application_vnd_pg_format, 
      application_vnd_pg_osasli, 
      application_vnd_picsel, 
      application_vnd_powerbuilder6, 
      application_vnd_powerbuilder6_s, 
      application_vnd_powerbuilder7, 
      application_vnd_powerbuilder7_s, 
      application_vnd_powerbuilder75, 
      application_vnd_powerbuilder75_s, 
      application_vnd_previewsystems_box, 
      application_vnd_publishare_delta_tree, 
      application_vnd_pvi_ptid1, 
      application_vnd_pwg_multiplexed, 
      application_vnd_pwg_xhtml_print_xml, 
      application_vnd_rapid, 
      application_vnd_s3sms, 
      application_vnd_sealed_doc, 
      application_vnd_sealed_eml, 
      application_vnd_sealed_mht, 
      application_vnd_sealed_net, 
      application_vnd_sealed_ppt, 
      application_vnd_sealed_xls, 
      application_vnd_sealedmedia_softseal_html, 
      application_vnd_sealedmedia_softseal_pdf, 
      application_vnd_seemail, 
      application_vnd_shana_informed_formdata, 
      application_vnd_shana_informed_formtemplate, 
      application_vnd_shana_informed_interchange, 
      application_vnd_shana_informed_package, 
      application_vnd_smaf, 
      application_vnd_sss_cod, 
      application_vnd_sss_dtf, 
      application_vnd_sss_ntf, 
      application_vnd_street_stream, 
      application_vnd_sus_calendar, 
      application_vnd_svd, 
      application_vnd_swiftview_ics, 
      application_vnd_syncml__xml, 
      application_vnd_syncml_ds_notification, 
      application_vnd_triscape_mxs, 
      application_vnd_trueapp, 
      application_vnd_truedoc, 
      application_vnd_ufdl,
      application_vnd_uiq_theme, 
      application_vnd_uplanet_alert, 
      application_vnd_uplanet_alert_wbxml, 
      application_vnd_uplanet_bearer_choice, 
      application_vnd_uplanet_bearer_choice_wbxml, 
      application_vnd_uplanet_cacheop, 
      application_vnd_uplanet_cacheop_wbxml, 
      application_vnd_uplanet_channel, 
      application_vnd_uplanet_channel_wbxml, 
      application_vnd_uplanet_list, 
      application_vnd_uplanet_list_wbxml, 
      application_vnd_uplanet_listcmd, 
      application_vnd_uplanet_listcmd_wbxml, 
      application_vnd_uplanet_signal, 
      application_vnd_vcx, 
      application_vnd_vectorworks, 
      application_vnd_vidsoft_vidconference, 
      application_vnd_visio, 
      application_vnd_visionary, 
      application_vnd_vividence_scriptfile, 
      application_vnd_vsf, 
      application_vnd_wap_sic, 
      application_vnd_wap_slc, 
      application_vnd_wap_wbxml, 
      application_vnd_wap_wmlc, 
      application_vnd_wap_wmlscriptc, 
      application_vnd_webturbo, 
      application_vnd_wordperfect, 
      application_vnd_wqd, 
      application_vnd_wrq_hp3000_labelled, 
      application_vnd_wt_stf, 
      application_vnd_wv_csp_wbxml, 
      application_vnd_wv_csp_xml, 
      application_vnd_wv_ssp_xml, 
      application_vnd_xara, 
      application_vnd_xfdl, 
      application_vnd_yamaha_hv_dic, 
      application_vnd_yamaha_hv_script, 
      application_vnd_yamaha_hv_voice, 
      application_vnd_yamaha_smaf_audio, 
      application_vnd_yamaha_smaf_phrase, 
      application_vnd_yellowriver_custom_menu, 
      application_watcherinfo_xml, 
      application_whoispp_query, 
      application_whoispp_response, 
      application_wita, 
      application_wordperfect5_1, 
      application_x400_bp, 
      application_xhtml_xml, 
      application_xml, 
      application_xml_dtd,
      application_xml_external_parsed_entity, 
      application_xmpp_xml, 
      application_xop_xml, 
      application_zip, 
      audio_32kadpcm, 
      audio_3gpp, 
      audio_AMR, 
      audio_AMR_WB, 
      audio_BV16, 
      audio_BV32, 
      audio_CN, 
      audio_DAT12, 
      audio_DVI4, 
      audio_EVRC, 
      audio_EVRC_QCP, 
      audio_EVRC0, 
      audio_G_722_1, 
      audio_G722, 
      audio_G723, 
      audio_G726_16, 
      audio_G726_24, 
      audio_G726_32, 
      audio_G726_40, 
      audio_G728, 
      audio_G729, 
      audio_G729D, 
      audio_G729E, 
      audio_GSM, 
      audio_GSM_EFR, 
      audio_L16, 
      audio_L20, 
      audio_L24, 
      audio_L8, 
      audio_LPC, 
      audio_MP4A_LATM, 
      audio_MPA, 
      audio_PCMA, 
      audio_PCMU, 
      audio_QCELP, 
      audio_RED, 
      audio_SMV, 
      audio_SMV_QCP, 
      audio_SMV0, 
      audio_VDVI, 
      audio_basic, 
      audio_clearmode, 
      audio_dsr_es201108, 
      audio_dsr_es202050, 
      audio_dsr_es202211, 
      audio_dsr_es202212, 
      audio_iLBC,
      audio_mpa_robust, 
      audio_mpeg, 
      audio_mpeg4_generic, 
      audio_parityfec, 
      audio_prs_sid, 
      audio_telephone_event, 
      audio_tone, 
      audio_vnd_3gpp_iufp, 
      audio_vnd_audiokoz, 
      audio_vnd_cisco_nse, 
      audio_vnd_cns_anp1, 
      audio_vnd_cns_inf1, 
      audio_vnd_digital_winds, 
      audio_vnd_everad_plj, 
      audio_vnd_lucent_voice, 
      audio_vnd_nokia_mobile_xmf, 
      audio_vnd_nortel_vbk, 
      audio_vnd_nuera_ecelp4800, 
      audio_vnd_nuera_ecelp7470, 
      audio_vnd_nuera_ecelp9600, 
      audio_vnd_octel_sbc, 
      audio_vnd_qcelp, 
      audio_vnd_rhetorex_32kadpcm, 
      audio_vnd_sealedmedia_softseal_mpeg, 
      audio_vnd_vmx_cvsd, 
      image_cgm, 
      image_fits, 
      image_g3fax, 
      image_gif, 
      image_ief, 
      image_jp2, 
      image_jpeg, 
      image_jpm, 
      image_jpx, 
      image_naplps, 
      image_png, 
      image_prs_btif, 
      image_prs_pti, 
      image_t38, 
      image_tiff, 
      image_tiff_fx, 
      image_vnd_cns_inf2, 
      image_vnd_djvu, 
      image_vnd_dwg, 
      image_vnd_dxf, 
      image_vnd_fastbidsheet, 
      image_vnd_fpx, 
      image_vnd_fst, 
      image_vnd_fujixerox_edmics_mmr, 
      image_vnd_fujixerox_edmics_rlc, 
      image_vnd_globalgraphics_pgb,
      image_vnd_microsoft_icon, 
      image_vnd_mix, 
      image_vnd_ms_modi, 
      image_vnd_net_fpx, 
      image_vnd_sealed_png, 
      image_vnd_sealedmedia_softseal_gif, 
      image_vnd_sealedmedia_softseal_jpg, 
      image_vnd_svf, 
      image_vnd_wap_wbmp, 
      image_vnd_xiff, 
      message_CPIM, 
      message_delivery_status, 
      message_disposition_notification, 
      message_external_body, 
      message_http, 
      message_news, 
      message_partial, 
      message_rfc822, 
      message_s_http, 
      message_sip, 
      message_sipfrag, 
      message_tracking_status, 
      model_iges, 
      model_mesh, 
      model_vnd_dwf, 
      model_vnd_flatland_3dml, 
      model_vnd_gdl, 
      model_vnd_gs_gdl, 
      model_vnd_gtw, 
      model_vnd_mts, 
      model_vnd_parasolid_transmit_binary, 
      model_vnd_parasolid_transmit_text, 
      model_vnd_vtu, 
      model_vrml, 
      multipart_alternative, 
      multipart_appledouble, 
      multipart_byteranges, 
      multipart_digest, 
      multipart_encrypted, 
      multipart_form_data, 
      multipart_header_set, 
      multipart_mixed, 
      multipart_parallel, 
      multipart_related, 
      multipart_report, 
      multipart_signed, 
      multipart_voice_message, 
      text_RED, 
      text_calendar, 
      text_css, 
      text_csv,
      text_directory, 
      text_dns, 
      text_enriched, 
      text_html, 
      text_parityfec, 
      text_plain, 
      text_prs_fallenstein_rst, 
      text_prs_lines_tag, 
      text_rfc822_headers, 
      text_richtext, 
      text_rtf, 
      text_sgml, 
      text_t140, 
      text_tab_separated_values, 
      text_troff, 
      text_uri_list, 
      text_vnd_DMClientScript, 
      text_vnd_IPTC_NITF, 
      text_vnd_IPTC_NewsML, 
      text_vnd_abc, 
      text_vnd_curl, 
      text_vnd_esmertec_theme_descriptor, 
      text_vnd_fly, 
      text_vnd_fmi_flexstor, 
      text_vnd_in3d_3dml, 
      text_vnd_in3d_spot, 
      text_vnd_latex_z, 
      text_vnd_motorola_reflex, 
      text_vnd_ms_mediapackage, 
      text_vnd_net2phone_commcenter_command, 
      text_vnd_sun_j2me_app_descriptor, 
      text_vnd_wap_si, 
      text_vnd_wap_sl, 
      text_vnd_wap_wml, 
      text_vnd_wap_wmlscript, 
      text_xml, 
      text_xml_external_parsed_entity, 
      video_3gpp, 
      video_BMPEG, 
      video_BT656, 
      video_CelB, 
      video_DV, 
      video_H261, 
      video_H263, 
      video_H263_1998, 
      video_H263_2000, 
      video_H264, 
      video_JPEG, 
      video_MJ2, 
      video_MP1S, 
      video_MP2P,
      video_MP2T, 
      video_MP4V_ES, 
      video_MPV, 
      video_SMPTE292M, 
      video_mpeg, 
      video_mpeg4_generic, 
      video_nv, 
      video_parityfec, 
      video_pointer, 
      video_quicktime, 
      video_raw, 
      video_vnd_fvt, 
      video_vnd_motorola_video, 
      video_vnd_motorola_videop, 
      video_vnd_mpegurl, 
      video_vnd_nokia_interleaved_multimedia, 
      video_vnd_objectvideo, 
      video_vnd_sealed_mpeg1, 
      video_vnd_sealed_mpeg4, 
      video_vnd_sealed_swf, 
      video_vnd_sealedmedia_softseal_mov, 
      video_vnd_vivo
  );

  { "urn:un:unece:uncefact:codelist:specification:66411:2001"[GblSmpl] }
  UnitCodeContentType = (
      _04, 
      _05, 
      _08, 
      _10, 
      _11, 
      _13, 
      _14, 
      _15, 
      _16, 
      _17, 
      _18, 
      _19, 
      _20, 
      _21, 
      _22, 
      _23, 
      _24, 
      _25, 
      _26, 
      _27, 
      _28, 
      _29, 
      _30, 
      _31, 
      _32,
      _33, 
      _34, 
      _35, 
      _36, 
      _37, 
      _38, 
      _40, 
      _41, 
      _43, 
      _44, 
      _45, 
      _46, 
      _47, 
      _48, 
      _53, 
      _54, 
      _56, 
      _57, 
      _58, 
      _59, 
      _60, 
      _61, 
      _62, 
      _63, 
      _64, 
      _66, 
      _69, 
      _71, 
      _72, 
      _73, 
      _74, 
      _76, 
      _77, 
      _78, 
      _80, 
      _81, 
      _84, 
      _85, 
      _87, 
      _89, 
      _90, 
      _91, 
      _92, 
      _93, 
      _94, 
      _95, 
      _96, 
      _97, 
      _98, 
      _1A, 
      _1B,
      _1C, 
      _1D, 
      _1E, 
      _1F, 
      _1G, 
      _1H, 
      _1I, 
      _1J, 
      _1K, 
      _1L, 
      _1M, 
      _1X, 
      _2A, 
      _2B, 
      _2C, 
      _2I, 
      _2J, 
      _2K, 
      _2L, 
      _2M, 
      _2N, 
      _2P, 
      _2Q, 
      _2R, 
      _2U, 
      _2V, 
      _2W, 
      _2X, 
      _2Y, 
      _2Z, 
      _3B, 
      _3C, 
      _3E, 
      _3G, 
      _3H, 
      _3I, 
      _4A, 
      _4B, 
      _4C, 
      _4E, 
      _4G, 
      _4H, 
      _4K, 
      _4L, 
      _4M, 
      _4N, 
      _4O, 
      _4P, 
      _4Q, 
      _4R, 
      _4T,
      _4U, 
      _4W, 
      _4X, 
      _5A, 
      _5B, 
      _5C, 
      _5E, 
      _5F, 
      _5G, 
      _5H, 
      _5I, 
      _5J, 
      _5K, 
      _5P, 
      _5Q, 
      A1, 
      A10, 
      A11, 
      A12, 
      A13, 
      A14, 
      A15, 
      A16, 
      A17, 
      A18, 
      A19, 
      A2, 
      A20, 
      A21, 
      A22, 
      A23, 
      A24, 
      A25, 
      A26, 
      A27, 
      A28, 
      A29, 
      A3, 
      A30, 
      A31, 
      A32, 
      A33, 
      A34, 
      A35, 
      A36, 
      A37, 
      A38, 
      A39, 
      A4, 
      A40, 
      A41,
      A42, 
      A43, 
      A44, 
      A45, 
      A47, 
      A48, 
      A49, 
      A5, 
      A50, 
      A51, 
      A52, 
      A53, 
      A54, 
      A55, 
      A56, 
      A57, 
      A58, 
      A6, 
      A60, 
      A61, 
      A62, 
      A63, 
      A64, 
      A65, 
      A66, 
      A67, 
      A68, 
      A69, 
      A7, 
      A70, 
      A71, 
      A73, 
      A74, 
      A75, 
      A76, 
      A77, 
      A78, 
      A79, 
      A8, 
      A80, 
      A81, 
      A82, 
      A83, 
      A84, 
      A85, 
      A86, 
      A87, 
      A88, 
      A89, 
      A9, 
      A90,
      A91, 
      A93, 
      A94, 
      A95, 
      A96, 
      A97, 
      A98, 
      AA, 
      AB, 
      ACR, 
      AD, 
      AE, 
      AH, 
      AI, 
      AJ, 
      AK, 
      AL, 
      AM, 
      AMH, 
      AMP, 
      ANN, 
      AP, 
      APZ, 
      AQ, 
      AR, 
      ARE, 
      AS_, 
      ASM_, 
      ASU, 
      ATM, 
      ATT, 
      AV, 
      AW, 
      AY, 
      AZ, 
      B0, 
      B1, 
      B11, 
      B12, 
      B13, 
      B14, 
      B15, 
      B16, 
      B18, 
      B2, 
      B20, 
      B21, 
      B22, 
      B23, 
      B24, 
      B25,
      B26, 
      B27, 
      B28, 
      B29, 
      B3, 
      B31, 
      B32, 
      B33, 
      B34, 
      B35, 
      B36, 
      B37, 
      B38, 
      B39, 
      B4, 
      B40, 
      B41, 
      B42, 
      B43, 
      B44, 
      B45, 
      B46, 
      B47, 
      B48, 
      B49, 
      B5, 
      B50, 
      B51, 
      B52, 
      B53, 
      B54, 
      B55, 
      B56, 
      B57, 
      B58, 
      B59, 
      B6, 
      B60, 
      B61, 
      B62, 
      B63, 
      B64, 
      B65, 
      B66, 
      B67, 
      B69, 
      B7, 
      B70, 
      B71, 
      B72, 
      B73,
      B74, 
      B75, 
      B76, 
      B77, 
      B78, 
      B79, 
      B8, 
      B81, 
      B83, 
      B84, 
      B85, 
      B86, 
      B87, 
      B88, 
      B89, 
      B9, 
      B90, 
      B91, 
      B92, 
      B93, 
      B94, 
      B95, 
      B96, 
      B97, 
      B98, 
      B99, 
      BAR, 
      BB, 
      BD, 
      BE, 
      BFT, 
      BG, 
      BH, 
      BHP, 
      BIL, 
      BJ, 
      BK, 
      BL, 
      BLD, 
      BLL, 
      BO, 
      BP, 
      BQL, 
      BR, 
      BT, 
      BTU, 
      BUA, 
      BUI, 
      BW, 
      BX, 
      BZ,
      C0, 
      C1, 
      C10, 
      C11, 
      C12, 
      C13, 
      C14, 
      C15, 
      C16, 
      C17, 
      C18, 
      C19, 
      C2, 
      C20, 
      C22, 
      C23, 
      C24, 
      C25, 
      C26, 
      C27, 
      C28, 
      C29, 
      C3, 
      C30, 
      C31, 
      C32, 
      C33, 
      C34, 
      C35, 
      C36, 
      C38, 
      C39, 
      C4, 
      C40, 
      C41, 
      C42, 
      C43, 
      C44, 
      C45, 
      C46, 
      C47, 
      C48, 
      C49, 
      C5, 
      C50, 
      C51, 
      C52, 
      C53, 
      C54, 
      C55, 
      C56,
      C57, 
      C58, 
      C59, 
      C6, 
      C60, 
      C61, 
      C62, 
      C63, 
      C64, 
      C65, 
      C66, 
      C67, 
      C68, 
      C69, 
      C7, 
      C70, 
      C71, 
      C72, 
      C73, 
      C75, 
      C76, 
      C77, 
      C78, 
      C8, 
      C80, 
      C81, 
      C82, 
      C83, 
      C84, 
      C85, 
      C86, 
      C87, 
      C88, 
      C89, 
      C9, 
      C90, 
      C91, 
      C92, 
      C93, 
      C94, 
      C95, 
      C96, 
      C97, 
      C98, 
      C99, 
      CA, 
      CCT, 
      CDL, 
      CEL, 
      CEN, 
      CG,
      CGM, 
      CH, 
      CJ, 
      CK, 
      CKG, 
      CL, 
      CLF, 
      CLT, 
      CMK, 
      CMQ, 
      CMT, 
      CNP, 
      CNT, 
      CO, 
      COU, 
      CQ, 
      CR, 
      CS, 
      CT, 
      CTM, 
      CU, 
      CUR, 
      CV, 
      CWA, 
      CWI, 
      CY, 
      CZ, 
      D1, 
      D10, 
      D12, 
      D13, 
      D14, 
      D15, 
      D16, 
      D17, 
      D18, 
      D19, 
      D2, 
      D20, 
      D21, 
      D22, 
      D23, 
      D24, 
      D25, 
      D26, 
      D27, 
      D28, 
      D29, 
      D30, 
      D31, 
      D32,
      D33, 
      D34, 
      D35, 
      D37, 
      D38, 
      D39, 
      D40, 
      D41, 
      D42, 
      D43, 
      D44, 
      D45, 
      D46, 
      D47, 
      D48, 
      D49, 
      D5, 
      D50, 
      D51, 
      D52, 
      D53, 
      D54, 
      D55, 
      D56, 
      D57, 
      D58, 
      D59, 
      D6, 
      D60, 
      D61, 
      D62, 
      D63, 
      D64, 
      D65, 
      D66, 
      D67, 
      D69, 
      D7, 
      D70, 
      D71, 
      D72, 
      D73, 
      D74, 
      D75, 
      D76, 
      D77, 
      D79, 
      D8, 
      D80, 
      D81, 
      D82,
      D83, 
      D85, 
      D86, 
      D87, 
      D88, 
      D89, 
      D9, 
      D90, 
      D91, 
      D92, 
      D93, 
      D94, 
      D95, 
      D96, 
      D97, 
      D98, 
      D99, 
      DAA, 
      DAD, 
      DAY, 
      DB, 
      DC, 
      DD, 
      DE, 
      DEC, 
      DG, 
      DI, 
      DJ, 
      DLT, 
      DMK, 
      DMQ, 
      DMT, 
      DN, 
      DPC, 
      DPR, 
      DPT, 
      DQ, 
      DR, 
      DRA, 
      DRI, 
      DRL, 
      DRM, 
      DS, 
      DT, 
      DTN, 
      DU, 
      DWT, 
      DX, 
      DY, 
      DZN, 
      DZP,
      E2, 
      E3, 
      E4, 
      E5, 
      EA, 
      EB, 
      EC, 
      EP, 
      EQ, 
      EV, 
      F1, 
      F9, 
      FAH, 
      FAR_, 
      FB, 
      FC, 
      FD, 
      FE, 
      FF, 
      FG, 
      FH, 
      FL, 
      FM, 
      FOT, 
      FP, 
      FR, 
      FS, 
      FTK, 
      FTQ, 
      G2, 
      G3, 
      G7, 
      GB, 
      GBQ, 
      GC, 
      GD, 
      GE, 
      GF, 
      GFI, 
      GGR, 
      GH, 
      GIA, 
      GII, 
      GJ, 
      GK, 
      GL, 
      GLD, 
      GLI, 
      GLL, 
      GM, 
      GN,
      GO, 
      GP, 
      GQ, 
      GRM, 
      GRN, 
      GRO, 
      GRT, 
      GT, 
      GV, 
      GW, 
      GWH, 
      GY, 
      GZ, 
      H1, 
      H2, 
      HA, 
      HAR, 
      HBA, 
      HBX, 
      HC, 
      HD, 
      HE, 
      HF, 
      HGM, 
      HH, 
      HI, 
      HIU, 
      HJ, 
      HK, 
      HL, 
      HLT, 
      HM, 
      HMQ, 
      HMT, 
      HN, 
      HO, 
      HP, 
      HPA, 
      HS, 
      HT, 
      HTZ, 
      HUR, 
      HY, 
      IA, 
      IC, 
      IE, 
      IF_, 
      II, 
      IL, 
      IM, 
      INH,
      INK, 
      INQ, 
      IP, 
      IT, 
      IU, 
      IV, 
      J2, 
      JB, 
      JE, 
      JG, 
      JK, 
      JM, 
      JO, 
      JOU, 
      JR, 
      K1, 
      K2, 
      K3, 
      K5, 
      K6, 
      KA, 
      KB, 
      KBA, 
      KD, 
      KEL, 
      KF, 
      KG, 
      KGM, 
      KGS, 
      KHZ, 
      KI, 
      KJ, 
      KJO, 
      KL, 
      KMH, 
      KMK, 
      KMQ, 
      KNI, 
      KNS, 
      KNT, 
      KO, 
      KPA, 
      KPH, 
      KPO, 
      KPP, 
      KR, 
      KS, 
      KSD, 
      KSH, 
      KT, 
      KTM,
      KTN, 
      KUR, 
      KVA, 
      KVR, 
      KVT, 
      KW, 
      KWH, 
      KWT, 
      KX, 
      L2, 
      LA, 
      LBR, 
      LBT, 
      LC, 
      LD, 
      LE, 
      LEF, 
      LF, 
      LH, 
      LI, 
      LJ, 
      LK, 
      LM, 
      LN, 
      LO, 
      LP, 
      LPA, 
      LR, 
      LS, 
      LTN, 
      LTR, 
      LUM, 
      LUX, 
      LX, 
      LY, 
      M0, 
      M1, 
      M4, 
      M5, 
      M7, 
      M9, 
      MA, 
      MAL, 
      MAM, 
      MAW, 
      MBE, 
      MBF, 
      MBR, 
      MC, 
      MCU, 
      MD,
      MF, 
      MGM, 
      MHZ, 
      MIK, 
      MIL, 
      MIN, 
      MIO, 
      MIU, 
      MK, 
      MLD, 
      MLT, 
      MMK, 
      MMQ, 
      MMT, 
      MON, 
      MPA, 
      MQ, 
      MQH, 
      MQS, 
      MSK, 
      MT, 
      MTK, 
      MTQ, 
      MTR, 
      MTS, 
      MV, 
      MVA, 
      MWH, 
      N1, 
      N2, 
      N3, 
      NA, 
      NAR, 
      NB, 
      NBB, 
      NC, 
      NCL, 
      ND, 
      NE, 
      NEW, 
      NF, 
      NG, 
      NH, 
      NI, 
      NIU, 
      NJ, 
      NL, 
      NMI, 
      NMP, 
      NN, 
      NPL,
      NPR, 
      NPT, 
      NQ, 
      NR, 
      NRL, 
      NT, 
      NTT, 
      NU, 
      NV, 
      NX, 
      NY, 
      OA, 
      OHM, 
      ON_, 
      ONZ, 
      OP, 
      OT, 
      OZ, 
      OZA, 
      OZI, 
      P0, 
      P1, 
      P2, 
      P3, 
      P4, 
      P5, 
      P6, 
      P7, 
      P8, 
      P9, 
      PA, 
      PAL, 
      PB, 
      PD, 
      PE, 
      PF, 
      PG, 
      PGL, 
      PI, 
      PK, 
      PL, 
      PM, 
      PN, 
      PO, 
      PQ, 
      PR, 
      PS, 
      PT, 
      PTD, 
      PTI, 
      PTL,
      PU, 
      PV, 
      PW, 
      PY, 
      PZ, 
      Q3, 
      QA, 
      QAN, 
      QB, 
      QD, 
      QH, 
      QK, 
      QR, 
      QT, 
      QTD, 
      QTI, 
      QTL, 
      QTR, 
      R1, 
      R4, 
      R9, 
      RA, 
      RD, 
      RG, 
      RH, 
      RK, 
      RL, 
      RM, 
      RN, 
      RO, 
      RP, 
      RPM, 
      RPS, 
      RS, 
      RT, 
      RU, 
      S3, 
      S4, 
      S5, 
      S6, 
      S7, 
      S8, 
      SA, 
      SAN, 
      SCO, 
      SCR, 
      SD, 
      SE, 
      SEC, 
      SET_, 
      SG,
      SHT, 
      SIE, 
      SK, 
      SL, 
      SMI, 
      SN, 
      SO, 
      SP, 
      SQ, 
      SR, 
      SS, 
      SST, 
      ST, 
      STI, 
      STN, 
      SV, 
      SW, 
      SX, 
      T0, 
      T1, 
      T3, 
      T4, 
      T5, 
      T6, 
      T7, 
      T8, 
      TA, 
      TAH, 
      TC, 
      TD, 
      TE, 
      TF, 
      TI, 
      TJ, 
      TK, 
      TL, 
      TN, 
      TNE, 
      TP, 
      TPR, 
      TQ, 
      TQD, 
      TR, 
      TRL, 
      TS, 
      TSD, 
      TSH, 
      TT, 
      TU, 
      TV, 
      TW,
      TY, 
      U1, 
      U2, 
      UA, 
      UB, 
      UC, 
      UD, 
      UE, 
      UF, 
      UH, 
      UM, 
      VA, 
      VI, 
      VLT, 
      VQ, 
      VS, 
      W2, 
      W4, 
      WA, 
      WB, 
      WCD, 
      WE, 
      WEB, 
      WEE, 
      WG, 
      WH, 
      WHR, 
      WI, 
      WM, 
      WR, 
      WSD, 
      WTT, 
      WW, 
      X1, 
      YDK, 
      YDQ, 
      YL, 
      YRD, 
      YT, 
      Z1, 
      Z2, 
      Z3, 
      Z4, 
      Z5, 
      Z6, 
      Z8, 
      ZP, 
      ZZ
  );

  { "urn:un:unece:uncefact:codelist:specification:54217:2001"[GblSmpl] }
  CurrencyCodeContentType = (
      AED, 
      AFN, 
      ALL, 
      AMD, 
      ANG, 
      AOA, 
      ARS, 
      AUD, 
      AWG, 
      AZM, 
      BAM, 
      BBD, 
      BDT, 
      BGN, 
      BHD, 
      BIF, 
      BMD, 
      BND, 
      BOB, 
      BRL, 
      BSD, 
      BTN, 
      BWP, 
      BYR, 
      BZD, 
      CAD, 
      CDF, 
      CHF, 
      CLP, 
      CNY, 
      COP, 
      CRC, 
      CUP, 
      CVE, 
      CYP, 
      CZK, 
      DJF, 
      DKK, 
      DOP, 
      DZD, 
      EEK, 
      EGP, 
      ERN, 
      ETB, 
      EUR, 
      FJD, 
      FKP, 
      GBP, 
      GEL, 
      GHC,
      GIP, 
      GMD, 
      GNF, 
      GTQ, 
      GYD, 
      HKD, 
      HNL, 
      HRK, 
      HTG, 
      HUF, 
      IDR, 
      ILS, 
      INR, 
      IQD, 
      IRR, 
      ISK, 
      JMD, 
      JOD, 
      JPY, 
      KES, 
      KGS, 
      KHR, 
      KMF, 
      KPW, 
      KRW, 
      KWD, 
      KYD, 
      KZT, 
      LAK, 
      LBP, 
      LKR, 
      LRD, 
      LSL, 
      LTL, 
      LVL, 
      LYD, 
      MAD, 
      MDL, 
      MGF, 
      MKD, 
      MMK, 
      MNT, 
      MOP, 
      MRO, 
      MTL, 
      MUR, 
      MVR, 
      MWK, 
      MXN, 
      MYR, 
      MZM,
      NAD, 
      NGN, 
      NIO, 
      NOK, 
      NPR, 
      NZD, 
      OMR, 
      PAB, 
      PEN, 
      PGK, 
      PHP, 
      PKR, 
      PLN, 
      PYG, 
      QAR, 
      ROL, 
      RUB, 
      RWF, 
      SAR, 
      SBD, 
      SCR, 
      SDD, 
      SEK, 
      SGD, 
      SHP, 
      SIT, 
      SKK, 
      SLL, 
      SOS, 
      SRG, 
      STD, 
      SVC, 
      SYP, 
      SZL, 
      THB, 
      TJS, 
      TMM, 
      TND, 
      TOP, 
      TRL, 
      TTD, 
      TWD, 
      TZS, 
      UAH, 
      UGX, 
      USD, 
      UYU, 
      UZS, 
      VEB, 
      VND, 
      VUV,
      WST, 
      XAF, 
      XAG, 
      XAU, 
      XCD, 
      XDR, 
      XOF, 
      XPD, 
      XPF, 
      XPT, 
      YER, 
      YUM, 
      ZAR, 
      ZMK, 
      ZWD
  );

  { "http://schemas.i2i.com/ei/wsdl"[GblSmpl] }
  USERCONTENTTYPE = (PROCESSUSER, CANCELUSER);

  { "http://schemas.i2i.com/ei/wsdl"[GblSmpl] }
  USERTYPE = (USER, ARCHIVE);

  { "http://schemas.i2i.com/ei/wsdl"[GblSmpl] }
  SIGNTYPE = (HSM_CUSTOMER, HSM_ENTEGRATOR, HSM_CLIENT_SIGNED, TOKEN_CUSTOMER, TOKEN_ENTEGRATOR);

  {$SCOPEDENUMS OFF}



  // ************************************************************************ //
  // XML       : SendInvoiceResponseWithServerSignResponse, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponseWithServerSignResponse2 = class(TRemotable)
  private
    FREQUEST_RETURN: REQUEST_RETURNType;
    FREQUEST_RETURN_Specified: boolean;
    procedure SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
    function  REQUEST_RETURN_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property REQUEST_RETURN: REQUEST_RETURNType  Index (IS_OPTN or IS_UNQL) read FREQUEST_RETURN write SetREQUEST_RETURN stored REQUEST_RETURN_Specified;
  end;

  GetUserListResponse2 = array of GIBUSER;      { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  PrepareInvoiceResponseResponse2 = array of base64Binary;   { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }


  // ************************************************************************ //
  // XML       : SendInvoiceResponseResponse, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponseResponse2 = class(TRemotable)
  private
    FREQUEST_RETURN: REQUEST_RETURNType;
    FREQUEST_RETURN_Specified: boolean;
    procedure SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
    function  REQUEST_RETURN_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property REQUEST_RETURN: REQUEST_RETURNType  Index (IS_OPTN or IS_UNQL) read FREQUEST_RETURN write SetREQUEST_RETURN stored REQUEST_RETURN_Specified;
  end;



  // ************************************************************************ //
  // XML       : LoadInvoiceResponse, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  LoadInvoiceResponse2 = class(TRemotable)
  private
    FREQUEST_RETURN: REQUEST_RETURNType;
    FREQUEST_RETURN_Specified: boolean;
    procedure SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
    function  REQUEST_RETURN_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property REQUEST_RETURN: REQUEST_RETURNType  Index (IS_OPTN or IS_UNQL) read FREQUEST_RETURN write SetREQUEST_RETURN stored REQUEST_RETURN_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetInvoiceStatusResponse, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  GetInvoiceStatusResponse2 = class(TRemotable)
  private
    FINVOICE_STATUS: INVOICE_STATUS;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property INVOICE_STATUS: INVOICE_STATUS  Index (IS_UNQL) read FINVOICE_STATUS write FINVOICE_STATUS;
  end;

  CheckUserResponse2 = array of GIBUSER;        { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }
  GetUserListResponse =  type GetUserListResponse2;      { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }


  // ************************************************************************ //
  // XML       : SendInvoiceResponseWithServerSignResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponseWithServerSignResponse = class(SendInvoiceResponseWithServerSignResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceResponseResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponseResponse = class(SendInvoiceResponseResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : LoadInvoiceResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  LoadInvoiceResponse = class(LoadInvoiceResponse2)
  private
  published
  end;

  Array_Of_ATTRIBUTESTYPE = array of ATTRIBUTESTYPE;   { "http://schemas.i2i.com/ei/common"[GblUbnd] }
  CheckUserResponse =  type CheckUserResponse2;      { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }


  // ************************************************************************ //
  // XML       : GetInvoiceStatusResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  GetInvoiceStatusResponse = class(GetInvoiceStatusResponse2)
  private
  published
  end;

  PrepareInvoiceResponseResponse =  type PrepareInvoiceResponseResponse2;      { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }


  // ************************************************************************ //
  // XML       : AmountType, global, <complexType>
  // Namespace : urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2
  // ************************************************************************ //
  AmountType = class(TRemotable)
  private
    FText: TXSDecimal;
    FcurrencyID: CurrencyCodeContentType;
  public
    destructor Destroy; override;
  published
    property Text:       TXSDecimal               Index (IS_TEXT) read FText write FText;
    property currencyID: CurrencyCodeContentType  Index (IS_ATTR) read FcurrencyID write FcurrencyID;
  end;



  // ************************************************************************ //
  // XML       : MeasureType, global, <complexType>
  // Namespace : urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2
  // ************************************************************************ //
  MeasureType = class(TRemotable)
  private
    FText: TXSDecimal;
    FunitCode: UnitCodeContentType;
  public
    destructor Destroy; override;
  published
    property Text:     TXSDecimal           Index (IS_TEXT) read FText write FText;
    property unitCode: UnitCodeContentType  Index (IS_ATTR) read FunitCode write FunitCode;
  end;



  // ************************************************************************ //
  // XML       : IdentifierType, global, <complexType>
  // Namespace : urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2
  // ************************************************************************ //
  IdentifierType = class(TRemotable)
  private
    FText: string;
    FschemeID: string;
    FschemeID_Specified: boolean;
    procedure SetschemeID(Index: Integer; const Astring: string);
    function  schemeID_Specified(Index: Integer): boolean;
  published
    property Text:     string  Index (IS_TEXT) read FText write FText;
    property schemeID: string  Index (IS_ATTR or IS_OPTN) read FschemeID write SetschemeID stored schemeID_Specified;
  end;



  // ************************************************************************ //
  // XML       : CHANGE_INFOType, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/common
  // ************************************************************************ //
  CHANGE_INFOType = class(TRemotable)
  private
    FCDATE: TXSDate;
    FCPOSITION_ID: Int64;
    FCUSER_ID: Int64;
    FUDATE: TXSDate;
    FUDATE_Specified: boolean;
    FUPOSITION_ID: Int64;
    FUPOSITION_ID_Specified: boolean;
    FUUSER_ID: Int64;
    FUUSER_ID_Specified: boolean;
    procedure SetUDATE(Index: Integer; const ATXSDate: TXSDate);
    function  UDATE_Specified(Index: Integer): boolean;
    procedure SetUPOSITION_ID(Index: Integer; const AInt64: Int64);
    function  UPOSITION_ID_Specified(Index: Integer): boolean;
    procedure SetUUSER_ID(Index: Integer; const AInt64: Int64);
    function  UUSER_ID_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property CDATE:        TXSDate  Index (IS_UNQL) read FCDATE write FCDATE;
    property CPOSITION_ID: Int64    Index (IS_UNQL) read FCPOSITION_ID write FCPOSITION_ID;
    property CUSER_ID:     Int64    Index (IS_UNQL) read FCUSER_ID write FCUSER_ID;
    property UDATE:        TXSDate  Index (IS_OPTN or IS_UNQL) read FUDATE write SetUDATE stored UDATE_Specified;
    property UPOSITION_ID: Int64    Index (IS_OPTN or IS_UNQL) read FUPOSITION_ID write SetUPOSITION_ID stored UPOSITION_ID_Specified;
    property UUSER_ID:     Int64    Index (IS_OPTN or IS_UNQL) read FUUSER_ID write SetUUSER_ID stored UUSER_ID_Specified;
  end;



  // ************************************************************************ //
  // XML       : ATTRIBUTESTYPE, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/common
  // ************************************************************************ //
  ATTRIBUTESTYPE = class(TRemotable)
  private
    FNAME_: string;
  published
    property NAME_: string  Index (IS_ATTR) read FNAME_ write FNAME_;
  end;



  // ************************************************************************ //
  // XML       : BinaryObjectType, global, <complexType>
  // Namespace : urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2
  // ************************************************************************ //
  BinaryObjectType = class(TRemotable)
  private
    FText: TByteDynArray;
    Fformat: string;
    Fformat_Specified: boolean;
    FmimeCode: BinaryObjectMimeCodeContentType;
    FencodingCode: string;
    FencodingCode_Specified: boolean;
    FcharacterSetCode: string;
    FcharacterSetCode_Specified: boolean;
    Furi: string;
    Furi_Specified: boolean;
    Ffilename: string;
    Ffilename_Specified: boolean;
    procedure Setformat(Index: Integer; const Astring: string);
    function  format_Specified(Index: Integer): boolean;
    procedure SetencodingCode(Index: Integer; const Astring: string);
    function  encodingCode_Specified(Index: Integer): boolean;
    procedure SetcharacterSetCode(Index: Integer; const Astring: string);
    function  characterSetCode_Specified(Index: Integer): boolean;
    procedure Seturi(Index: Integer; const Astring: string);
    function  uri_Specified(Index: Integer): boolean;
    procedure Setfilename(Index: Integer; const Astring: string);
    function  filename_Specified(Index: Integer): boolean;
  published
    property Text:             TByteDynArray                    Index (IS_TEXT) read FText write FText;
    property format:           string                           Index (IS_ATTR or IS_OPTN) read Fformat write Setformat stored format_Specified;
    property mimeCode:         BinaryObjectMimeCodeContentType  Index (IS_ATTR) read FmimeCode write FmimeCode;
    property encodingCode:     string                           Index (IS_ATTR or IS_OPTN) read FencodingCode write SetencodingCode stored encodingCode_Specified;
    property characterSetCode: string                           Index (IS_ATTR or IS_OPTN) read FcharacterSetCode write SetcharacterSetCode stored characterSetCode_Specified;
    property uri:              string                           Index (IS_ATTR or IS_OPTN) read Furi write Seturi stored uri_Specified;
    property filename:         string                           Index (IS_ATTR or IS_OPTN) read Ffilename write Setfilename stored filename_Specified;
  end;



  // ************************************************************************ //
  // XML       : CodeType, global, <complexType>
  // Namespace : urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2
  // ************************************************************************ //
  CodeType = class(TRemotable)
  private
    FText: string;
    FlistID: string;
    FlistID_Specified: boolean;
    FlistAgencyName: string;
    FlistAgencyName_Specified: boolean;
    FlistName: string;
    FlistName_Specified: boolean;
    FlistVersionID: string;
    FlistVersionID_Specified: boolean;
    procedure SetlistID(Index: Integer; const Astring: string);
    function  listID_Specified(Index: Integer): boolean;
    procedure SetlistAgencyName(Index: Integer; const Astring: string);
    function  listAgencyName_Specified(Index: Integer): boolean;
    procedure SetlistName(Index: Integer; const Astring: string);
    function  listName_Specified(Index: Integer): boolean;
    procedure SetlistVersionID(Index: Integer; const Astring: string);
    function  listVersionID_Specified(Index: Integer): boolean;
  published
    property Text:           string  Index (IS_TEXT) read FText write FText;
    property listID:         string  Index (IS_ATTR or IS_OPTN) read FlistID write SetlistID stored listID_Specified;
    property listAgencyName: string  Index (IS_ATTR or IS_OPTN) read FlistAgencyName write SetlistAgencyName stored listAgencyName_Specified;
    property listName:       string  Index (IS_ATTR or IS_OPTN) read FlistName write SetlistName stored listName_Specified;
    property listVersionID:  string  Index (IS_ATTR or IS_OPTN) read FlistVersionID write SetlistVersionID stored listVersionID_Specified;
  end;

  contentType     =  type string;      { "http://www.w3.org/2005/05/xmlmime"[GblAttr] }


  // ************************************************************************ //
  // XML       : base64Binary, global, <complexType>
  // Namespace : http://www.w3.org/2005/05/xmlmime
  // ************************************************************************ //
  base64Binary = class(TRemotable)
  private
    FText: TByteDynArray;
    FcontentType: contentType;
    FcontentType_Specified: boolean;
    procedure SetcontentType(Index: Integer; const AcontentType: contentType);
    function  contentType_Specified(Index: Integer): boolean;
  published
    property Text:        TByteDynArray  Index (IS_TEXT) read FText write FText;
    property contentType: contentType    Index (IS_ATTR or IS_OPTN) read FcontentType write SetcontentType stored contentType_Specified;
  end;



  // ************************************************************************ //
  // XML       : hexBinary, global, <complexType>
  // Namespace : http://www.w3.org/2005/05/xmlmime
  // ************************************************************************ //
  hexBinary = class(TRemotable)
  private
    FText: string;
    FcontentType: contentType;
    FcontentType_Specified: boolean;
    procedure SetcontentType(Index: Integer; const AcontentType: contentType);
    function  contentType_Specified(Index: Integer): boolean;
  published
    property Text:        string       Index (IS_TEXT) read FText write FText;
    property contentType: contentType  Index (IS_ATTR or IS_OPTN) read FcontentType write SetcontentType stored contentType_Specified;
  end;

  Array_Of_string = array of string;            { "http://www.w3.org/2001/XMLSchema"[GblUbnd] }


  // ************************************************************************ //
  // XML       : GIBUSER, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  GIBUSER = class(TRemotable)
  private
    FIDENTIFIER: string;
    FIDENTIFIER_Specified: boolean;
    FALIAS: string;
    FALIAS_Specified: boolean;
    FTITLE: string;
    FTITLE_Specified: boolean;
    FTYPE_: string;
    FTYPE__Specified: boolean;
    FREGISTER_TIME: string;
    FREGISTER_TIME_Specified: boolean;
    FUNIT_: string;
    FUNIT__Specified: boolean;
    procedure SetIDENTIFIER(Index: Integer; const Astring: string);
    function  IDENTIFIER_Specified(Index: Integer): boolean;
    procedure SetALIAS(Index: Integer; const Astring: string);
    function  ALIAS_Specified(Index: Integer): boolean;
    procedure SetTITLE(Index: Integer; const Astring: string);
    function  TITLE_Specified(Index: Integer): boolean;
    procedure SetTYPE_(Index: Integer; const Astring: string);
    function  TYPE__Specified(Index: Integer): boolean;
    procedure SetREGISTER_TIME(Index: Integer; const Astring: string);
    function  REGISTER_TIME_Specified(Index: Integer): boolean;
    procedure SetUNIT_(Index: Integer; const Astring: string);
    function  UNIT__Specified(Index: Integer): boolean;
  published
    property IDENTIFIER:    string  Index (IS_OPTN or IS_UNQL) read FIDENTIFIER write SetIDENTIFIER stored IDENTIFIER_Specified;
    property ALIAS:         string  Index (IS_OPTN or IS_UNQL) read FALIAS write SetALIAS stored ALIAS_Specified;
    property TITLE:         string  Index (IS_OPTN or IS_UNQL) read FTITLE write SetTITLE stored TITLE_Specified;
    property TYPE_:         string  Index (IS_OPTN or IS_UNQL) read FTYPE_ write SetTYPE_ stored TYPE__Specified;
    property REGISTER_TIME: string  Index (IS_OPTN or IS_UNQL) read FREGISTER_TIME write SetREGISTER_TIME stored REGISTER_TIME_Specified;
    property UNIT_:         string  Index (IS_OPTN or IS_UNQL) read FUNIT_ write SetUNIT_ stored UNIT__Specified;
  end;



  // ************************************************************************ //
  // XML       : REQUEST_RETURNType, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/entity
  // ************************************************************************ //
  REQUEST_RETURNType = class(TRemotable)
  private
    FINTL_TXN_ID: Int64;
    FCLIENT_TXN_ID: string;
    FCLIENT_TXN_ID_Specified: boolean;
    FRETURN_CODE: Integer;
    FWARNINGS: Array_Of_string;
    FWARNINGS_Specified: boolean;
    procedure SetCLIENT_TXN_ID(Index: Integer; const Astring: string);
    function  CLIENT_TXN_ID_Specified(Index: Integer): boolean;
    procedure SetWARNINGS(Index: Integer; const AArray_Of_string: Array_Of_string);
    function  WARNINGS_Specified(Index: Integer): boolean;
  published
    property INTL_TXN_ID:   Int64            Index (IS_UNQL) read FINTL_TXN_ID write FINTL_TXN_ID;
    property CLIENT_TXN_ID: string           Index (IS_OPTN or IS_UNQL) read FCLIENT_TXN_ID write SetCLIENT_TXN_ID stored CLIENT_TXN_ID_Specified;
    property RETURN_CODE:   Integer          Index (IS_UNQL) read FRETURN_CODE write FRETURN_CODE;
    property WARNINGS:      Array_Of_string  Index (IS_OPTN or IS_UNBD or IS_UNQL) read FWARNINGS write SetWARNINGS stored WARNINGS_Specified;
  end;



  // ************************************************************************ //
  // XML       : CancelUserResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  CancelUserResponse = class(REQUEST_RETURNType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ProcessUserResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  ProcessUserResponse = class(REQUEST_RETURNType)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : RequestFault, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Fault
  // Base Types: REQUEST_ERRORType
  // ************************************************************************ //
  RequestFault = class(ERemotableException)
  private
    FINTL_TXN_ID: Int64;
    FCLIENT_TXN_ID: string;
    FCLIENT_TXN_ID_Specified: boolean;
    FERROR_CODE: Integer;
    FERROR_SHORT_DES: string;
    FERROR_LONG_DES: string;
    FERROR_LONG_DES_Specified: boolean;
    FSTACKTRACE: string;
    FSTACKTRACE_Specified: boolean;
    FERROR_ELEMENT_INDEX: Integer;
    FERROR_ELEMENT_INDEX_Specified: boolean;
    procedure SetCLIENT_TXN_ID(Index: Integer; const Astring: string);
    function  CLIENT_TXN_ID_Specified(Index: Integer): boolean;
    procedure SetERROR_LONG_DES(Index: Integer; const Astring: string);
    function  ERROR_LONG_DES_Specified(Index: Integer): boolean;
    procedure SetSTACKTRACE(Index: Integer; const Astring: string);
    function  STACKTRACE_Specified(Index: Integer): boolean;
    procedure SetERROR_ELEMENT_INDEX(Index: Integer; const AInteger: Integer);
    function  ERROR_ELEMENT_INDEX_Specified(Index: Integer): boolean;
  published
    property INTL_TXN_ID:         Int64    Index (IS_UNQL) read FINTL_TXN_ID write FINTL_TXN_ID;
    property CLIENT_TXN_ID:       string   Index (IS_OPTN or IS_UNQL) read FCLIENT_TXN_ID write SetCLIENT_TXN_ID stored CLIENT_TXN_ID_Specified;
    property ERROR_CODE:          Integer  Index (IS_UNQL) read FERROR_CODE write FERROR_CODE;
    property ERROR_SHORT_DES:     string   Index (IS_UNQL) read FERROR_SHORT_DES write FERROR_SHORT_DES;
    property ERROR_LONG_DES:      string   Index (IS_OPTN or IS_UNQL) read FERROR_LONG_DES write SetERROR_LONG_DES stored ERROR_LONG_DES_Specified;
    property STACKTRACE:          string   Index (IS_OPTN or IS_UNQL) read FSTACKTRACE write SetSTACKTRACE stored STACKTRACE_Specified;
    property ERROR_ELEMENT_INDEX: Integer  Index (IS_OPTN or IS_UNQL) read FERROR_ELEMENT_INDEX write SetERROR_ELEMENT_INDEX stored ERROR_ELEMENT_INDEX_Specified;
  end;



  // ************************************************************************ //
  // XML       : REQUEST_ERRORType, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/entity
  // ************************************************************************ //
  REQUEST_ERRORType = class(TRemotable)
  private
    FINTL_TXN_ID: Int64;
    FCLIENT_TXN_ID: string;
    FCLIENT_TXN_ID_Specified: boolean;
    FERROR_CODE: Integer;
    FERROR_SHORT_DES: string;
    FERROR_LONG_DES: string;
    FERROR_LONG_DES_Specified: boolean;
    FSTACKTRACE: string;
    FSTACKTRACE_Specified: boolean;
    FERROR_ELEMENT_INDEX: Integer;
    FERROR_ELEMENT_INDEX_Specified: boolean;
    procedure SetCLIENT_TXN_ID(Index: Integer; const Astring: string);
    function  CLIENT_TXN_ID_Specified(Index: Integer): boolean;
    procedure SetERROR_LONG_DES(Index: Integer; const Astring: string);
    function  ERROR_LONG_DES_Specified(Index: Integer): boolean;
    procedure SetSTACKTRACE(Index: Integer; const Astring: string);
    function  STACKTRACE_Specified(Index: Integer): boolean;
    procedure SetERROR_ELEMENT_INDEX(Index: Integer; const AInteger: Integer);
    function  ERROR_ELEMENT_INDEX_Specified(Index: Integer): boolean;
  published
    property INTL_TXN_ID:         Int64    Index (IS_UNQL) read FINTL_TXN_ID write FINTL_TXN_ID;
    property CLIENT_TXN_ID:       string   Index (IS_OPTN or IS_UNQL) read FCLIENT_TXN_ID write SetCLIENT_TXN_ID stored CLIENT_TXN_ID_Specified;
    property ERROR_CODE:          Integer  Index (IS_UNQL) read FERROR_CODE write FERROR_CODE;
    property ERROR_SHORT_DES:     string   Index (IS_UNQL) read FERROR_SHORT_DES write FERROR_SHORT_DES;
    property ERROR_LONG_DES:      string   Index (IS_OPTN or IS_UNQL) read FERROR_LONG_DES write SetERROR_LONG_DES stored ERROR_LONG_DES_Specified;
    property STACKTRACE:          string   Index (IS_OPTN or IS_UNQL) read FSTACKTRACE write SetSTACKTRACE stored STACKTRACE_Specified;
    property ERROR_ELEMENT_INDEX: Integer  Index (IS_OPTN or IS_UNQL) read FERROR_ELEMENT_INDEX write SetERROR_ELEMENT_INDEX stored ERROR_ELEMENT_INDEX_Specified;
  end;



  // ************************************************************************ //
  // XML       : REQUEST, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/entity
  // ************************************************************************ //
  REQUEST = class(TRemotable)
  private
    FREQUEST_HEADER: REQUEST_HEADERType;
  public
    destructor Destroy; override;
  published
    property REQUEST_HEADER: REQUEST_HEADERType  Index (IS_UNQL) read FREQUEST_HEADER write FREQUEST_HEADER;
  end;



  // ************************************************************************ //
  // XML       : GetInvoiceStatusRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  GetInvoiceStatusRequest2 = class(REQUEST)
  private
    FINVOICE: INVOICE;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property INVOICE: INVOICE  Index (IS_UNQL) read FINVOICE write FINVOICE;
  end;



  // ************************************************************************ //
  // XML       : GetInvoiceStatusRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  GetInvoiceStatusRequest = class(GetInvoiceStatusRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : CheckUserRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  CheckUserRequest2 = class(REQUEST)
  private
    FUSER: GIBUSER;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property USER: GIBUSER  Index (IS_UNQL) read FUSER write FUSER;
  end;



  // ************************************************************************ //
  // XML       : CheckUserRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  CheckUserRequest = class(CheckUserRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceResponseRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponseRequest2 = class(REQUEST)
  private
    FAPPRESPONSE: PrepareInvoiceResponseResponse2;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property APPRESPONSE: PrepareInvoiceResponseResponse2  Index (IS_UNBD or IS_UNQL) read FAPPRESPONSE write FAPPRESPONSE;
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceResponseRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponseRequest = class(SendInvoiceResponseRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : REQUEST_HEADERType, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/entity
  // ************************************************************************ //
  REQUEST_HEADERType = class(TRemotable)
  private
    FSESSION_ID: string;
    FCLIENT_TXN_ID: string;
    FCLIENT_TXN_ID_Specified: boolean;
    FINTL_TXN_ID: Int64;
    FINTL_TXN_ID_Specified: boolean;
    FINTL_PARENT_TXN_ID: Int64;
    FINTL_PARENT_TXN_ID_Specified: boolean;
    FACTION_DATE: TXSDateTime;
    FACTION_DATE_Specified: boolean;
    FCHANGE_INFO: CHANGE_INFOType;
    FCHANGE_INFO_Specified: boolean;
    FREASON: string;
    FREASON_Specified: boolean;
    FAPPLICATION_NAME: string;
    FAPPLICATION_NAME_Specified: boolean;
    FHOSTNAME: string;
    FHOSTNAME_Specified: boolean;
    FCHANNEL_NAME: string;
    FCHANNEL_NAME_Specified: boolean;
    FSIMULATION_FLAG: string;
    FSIMULATION_FLAG_Specified: boolean;
    FCOMPRESSED: string;
    FCOMPRESSED_Specified: boolean;
    FATTRIBUTES: Array_Of_ATTRIBUTESTYPE;
    FATTRIBUTES_Specified: boolean;
    procedure SetCLIENT_TXN_ID(Index: Integer; const Astring: string);
    function  CLIENT_TXN_ID_Specified(Index: Integer): boolean;
    procedure SetINTL_TXN_ID(Index: Integer; const AInt64: Int64);
    function  INTL_TXN_ID_Specified(Index: Integer): boolean;
    procedure SetINTL_PARENT_TXN_ID(Index: Integer; const AInt64: Int64);
    function  INTL_PARENT_TXN_ID_Specified(Index: Integer): boolean;
    procedure SetACTION_DATE(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  ACTION_DATE_Specified(Index: Integer): boolean;
    procedure SetCHANGE_INFO(Index: Integer; const ACHANGE_INFOType: CHANGE_INFOType);
    function  CHANGE_INFO_Specified(Index: Integer): boolean;
    procedure SetREASON(Index: Integer; const Astring: string);
    function  REASON_Specified(Index: Integer): boolean;
    procedure SetAPPLICATION_NAME(Index: Integer; const Astring: string);
    function  APPLICATION_NAME_Specified(Index: Integer): boolean;
    procedure SetHOSTNAME(Index: Integer; const Astring: string);
    function  HOSTNAME_Specified(Index: Integer): boolean;
    procedure SetCHANNEL_NAME(Index: Integer; const Astring: string);
    function  CHANNEL_NAME_Specified(Index: Integer): boolean;
    procedure SetSIMULATION_FLAG(Index: Integer; const Astring: string);
    function  SIMULATION_FLAG_Specified(Index: Integer): boolean;
    procedure SetCOMPRESSED(Index: Integer; const Astring: string);
    function  COMPRESSED_Specified(Index: Integer): boolean;
    procedure SetATTRIBUTES(Index: Integer; const AArray_Of_ATTRIBUTESTYPE: Array_Of_ATTRIBUTESTYPE);
    function  ATTRIBUTES_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property SESSION_ID:         string                   Index (IS_UNQL) read FSESSION_ID write FSESSION_ID;
    property CLIENT_TXN_ID:      string                   Index (IS_OPTN or IS_UNQL) read FCLIENT_TXN_ID write SetCLIENT_TXN_ID stored CLIENT_TXN_ID_Specified;
    property INTL_TXN_ID:        Int64                    Index (IS_OPTN or IS_UNQL) read FINTL_TXN_ID write SetINTL_TXN_ID stored INTL_TXN_ID_Specified;
    property INTL_PARENT_TXN_ID: Int64                    Index (IS_OPTN or IS_UNQL) read FINTL_PARENT_TXN_ID write SetINTL_PARENT_TXN_ID stored INTL_PARENT_TXN_ID_Specified;
    property ACTION_DATE:        TXSDateTime              Index (IS_OPTN or IS_UNQL) read FACTION_DATE write SetACTION_DATE stored ACTION_DATE_Specified;
    property CHANGE_INFO:        CHANGE_INFOType          Index (IS_OPTN or IS_UNQL) read FCHANGE_INFO write SetCHANGE_INFO stored CHANGE_INFO_Specified;
    property REASON:             string                   Index (IS_OPTN or IS_UNQL) read FREASON write SetREASON stored REASON_Specified;
    property APPLICATION_NAME:   string                   Index (IS_OPTN or IS_UNQL) read FAPPLICATION_NAME write SetAPPLICATION_NAME stored APPLICATION_NAME_Specified;
    property HOSTNAME:           string                   Index (IS_OPTN or IS_UNQL) read FHOSTNAME write SetHOSTNAME stored HOSTNAME_Specified;
    property CHANNEL_NAME:       string                   Index (IS_OPTN or IS_UNQL) read FCHANNEL_NAME write SetCHANNEL_NAME stored CHANNEL_NAME_Specified;
    property SIMULATION_FLAG:    string                   Index (IS_OPTN or IS_UNQL) read FSIMULATION_FLAG write SetSIMULATION_FLAG stored SIMULATION_FLAG_Specified;
    property COMPRESSED:         string                   Index (IS_OPTN or IS_UNQL) read FCOMPRESSED write SetCOMPRESSED stored COMPRESSED_Specified;
    property ATTRIBUTES:         Array_Of_ATTRIBUTESTYPE  Index (IS_OPTN or IS_UNBD or IS_UNQL) read FATTRIBUTES write SetATTRIBUTES stored ATTRIBUTES_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetUserListRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  GetUserListRequest2 = class(REQUEST)
  private
    FREGISTER_TIME_START: TXSDateTime;
    FREGISTER_TIME_START_Specified: boolean;
    procedure SetREGISTER_TIME_START(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  REGISTER_TIME_START_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property REGISTER_TIME_START: TXSDateTime  Index (IS_OPTN or IS_UNQL) read FREGISTER_TIME_START write SetREGISTER_TIME_START stored REGISTER_TIME_START_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetUserListAsCSVRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  GetUserListAsCSVRequest = class(GetUserListRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : GetUserListRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  GetUserListRequest = class(GetUserListRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : QuantityType, global, <complexType>
  // Namespace : urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2
  // ************************************************************************ //
  QuantityType = class(TRemotable)
  private
    FText: TXSDecimal;
    FunitCode: UnitCodeContentType;
  public
    destructor Destroy; override;
  published
    property Text:     TXSDecimal           Index (IS_TEXT) read FText write FText;
    property unitCode: UnitCodeContentType  Index (IS_ATTR) read FunitCode write FunitCode;
  end;



  // ************************************************************************ //
  // XML       : SENDER, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  SENDER = class(TRemotable)
  private
    Fvkn: string;
    Fvkn_Specified: boolean;
    Falias: string;
    Falias_Specified: boolean;
    procedure Setvkn(Index: Integer; const Astring: string);
    function  vkn_Specified(Index: Integer): boolean;
    procedure Setalias(Index: Integer; const Astring: string);
    function  alias_Specified(Index: Integer): boolean;
  published
    property vkn:   string  Index (IS_ATTR or IS_OPTN) read Fvkn write Setvkn stored vkn_Specified;
    property alias: string  Index (IS_ATTR or IS_OPTN) read Falias write Setalias stored alias_Specified;
  end;



  // ************************************************************************ //
  // XML       : RECEIVER, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  RECEIVER = class(TRemotable)
  private
    Fvkn: string;
    Fvkn_Specified: boolean;
    Falias: string;
    Falias_Specified: boolean;
    procedure Setvkn(Index: Integer; const Astring: string);
    function  vkn_Specified(Index: Integer): boolean;
    procedure Setalias(Index: Integer; const Astring: string);
    function  alias_Specified(Index: Integer): boolean;
  published
    property vkn:   string  Index (IS_ATTR or IS_OPTN) read Fvkn write Setvkn stored vkn_Specified;
    property alias: string  Index (IS_ATTR or IS_OPTN) read Falias write Setalias stored alias_Specified;
  end;

  UserResponse = array of USERCONTENT;          { "http://schemas.i2i.com/ei/wsdl"[GblCplx] }


  // ************************************************************************ //
  // XML       : UserRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  UserRequest = class(REQUEST)
  private
    FUSERCONTENT: UserResponse;
  public
    destructor Destroy; override;
  published
    property USERCONTENT: UserResponse  Index (IS_UNBD or IS_UNQL) read FUSERCONTENT write FUSERCONTENT;
  end;



  // ************************************************************************ //
  // XML       : PrepareProcessUserRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  PrepareProcessUserRequest = class(UserRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : CancelUserRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  CancelUserRequest = class(UserRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : PrepareCancelUserRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  PrepareCancelUserRequest = class(UserRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ProcessUserRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  ProcessUserRequest = class(UserRequest)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceResponse, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponse2 = class(TRemotable)
  private
    FREQUEST_RETURN: REQUEST_RETURNType;
    FREQUEST_RETURN_Specified: boolean;
    procedure SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
    function  REQUEST_RETURN_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property REQUEST_RETURN: REQUEST_RETURNType  Index (IS_OPTN or IS_UNQL) read FREQUEST_RETURN write SetREQUEST_RETURN stored REQUEST_RETURN_Specified;
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponse = class(SendInvoiceResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MarkInvoiceRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  MarkInvoiceRequest2 = class(REQUEST)
  private
    FMARK: MARK;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property MARK: MARK  Index (IS_UNQL) read FMARK write FMARK;
  end;



  // ************************************************************************ //
  // XML       : MarkInvoiceRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  MarkInvoiceRequest = class(MarkInvoiceRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MarkInvoiceResponse, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  MarkInvoiceResponse2 = class(TRemotable)
  private
    FREQUEST_RETURN: REQUEST_RETURNType;
    FREQUEST_RETURN_Specified: boolean;
    procedure SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
    function  REQUEST_RETURN_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property REQUEST_RETURN: REQUEST_RETURNType  Index (IS_OPTN or IS_UNQL) read FREQUEST_RETURN write SetREQUEST_RETURN stored REQUEST_RETURN_Specified;
  end;



  // ************************************************************************ //
  // XML       : MarkInvoiceResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  MarkInvoiceResponse = class(MarkInvoiceResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : GetInvoiceRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  GetInvoiceRequest2 = class(REQUEST)
  private
    FINVOICE_SEARCH_KEY: INVOICE_SEARCH_KEY;
    FHEADER_ONLY: string;
    FHEADER_ONLY_Specified: boolean;
    procedure SetHEADER_ONLY(Index: Integer; const Astring: string);
    function  HEADER_ONLY_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property INVOICE_SEARCH_KEY: INVOICE_SEARCH_KEY  Index (IS_UNQL) read FINVOICE_SEARCH_KEY write FINVOICE_SEARCH_KEY;
    property HEADER_ONLY:        string              Index (IS_OPTN or IS_UNQL) read FHEADER_ONLY write SetHEADER_ONLY stored HEADER_ONLY_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetInvoiceRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  GetInvoiceRequest = class(GetInvoiceRequest2)
  private
  published
  end;

  GetInvoiceResponse2 = array of INVOICE;       { "http://schemas.i2i.com/ei/wsdl"[Lit][GblCplx] }


  // ************************************************************************ //
  // XML       : MARK, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  MARK = class(TRemotable)
  private
    Fvalue: string;
    Fvalue_Specified: boolean;
    FINVOICE: GetInvoiceResponse2;
    procedure Setvalue(Index: Integer; const Astring: string);
    function  value_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property value:   string               Index (IS_ATTR or IS_OPTN) read Fvalue write Setvalue stored value_Specified;
    property INVOICE: GetInvoiceResponse2  Index (IS_UNBD or IS_UNQL) read FINVOICE write FINVOICE;
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceRequest2 = class(REQUEST)
  private
    FSENDER: SENDER;
    FRECEIVER: RECEIVER;
    FINVOICE: GetInvoiceResponse2;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property SENDER:   SENDER               Index (IS_UNQL) read FSENDER write FSENDER;
    property RECEIVER: RECEIVER             Index (IS_UNQL) read FRECEIVER write FRECEIVER;
    property INVOICE:  GetInvoiceResponse2  Index (IS_UNBD or IS_UNQL) read FINVOICE write FINVOICE;
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceRequest = class(SendInvoiceRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : PrepareInvoiceResponseRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  PrepareInvoiceResponseRequest2 = class(REQUEST)
  private
    FSTATUS: string;
    FINVOICE: GetInvoiceResponse2;
    FDESCRIPTION: Array_Of_string;
    FDESCRIPTION_Specified: boolean;
    procedure SetDESCRIPTION(Index: Integer; const AArray_Of_string: Array_Of_string);
    function  DESCRIPTION_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property STATUS:      string               Index (IS_UNQL) read FSTATUS write FSTATUS;
    property INVOICE:     GetInvoiceResponse2  Index (IS_UNBD or IS_UNQL) read FINVOICE write FINVOICE;
    property DESCRIPTION: Array_Of_string      Index (IS_OPTN or IS_UNBD or IS_UNQL) read FDESCRIPTION write SetDESCRIPTION stored DESCRIPTION_Specified;
  end;



  // ************************************************************************ //
  // XML       : PrepareInvoiceResponseRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  PrepareInvoiceResponseRequest = class(PrepareInvoiceResponseRequest2)
  private
  published
  end;

  GetInvoiceResponse =  type GetInvoiceResponse2;      { "http://schemas.i2i.com/ei/wsdl"[Lit][GblElm] }


  // ************************************************************************ //
  // XML       : LoadInvoiceRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  LoadInvoiceRequest2 = class(REQUEST)
  private
    FINVOICE: GetInvoiceResponse2;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property INVOICE: GetInvoiceResponse2  Index (IS_UNBD or IS_UNQL) read FINVOICE write FINVOICE;
  end;



  // ************************************************************************ //
  // XML       : LoadInvoiceRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  LoadInvoiceRequest = class(LoadInvoiceRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceResponseWithServerSignRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponseWithServerSignRequest2 = class(REQUEST)
  private
    FSTATUS: string;
    FINVOICE: GetInvoiceResponse2;
    FDESCRIPTION: Array_Of_string;
    FDESCRIPTION_Specified: boolean;
    procedure SetDESCRIPTION(Index: Integer; const AArray_Of_string: Array_Of_string);
    function  DESCRIPTION_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property STATUS:      string               Index (IS_UNQL) read FSTATUS write FSTATUS;
    property INVOICE:     GetInvoiceResponse2  Index (IS_UNBD or IS_UNQL) read FINVOICE write FINVOICE;
    property DESCRIPTION: Array_Of_string      Index (IS_OPTN or IS_UNBD or IS_UNQL) read FDESCRIPTION write SetDESCRIPTION stored DESCRIPTION_Specified;
  end;



  // ************************************************************************ //
  // XML       : SendInvoiceResponseWithServerSignRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  SendInvoiceResponseWithServerSignRequest = class(SendInvoiceResponseWithServerSignRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : INVOICE_SEARCH_KEY, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  INVOICE_SEARCH_KEY = class(TRemotable)
  private
    FLIMIT: Integer;
    FLIMIT_Specified: boolean;
    FID: string;
    FID_Specified: boolean;
    FUUID: string;
    FUUID_Specified: boolean;
    FFROM: string;
    FFROM_Specified: boolean;
    FTO_: string;
    FTO__Specified: boolean;
    FSTART_DATE: TXSDate;
    FSTART_DATE_Specified: boolean;
    FEND_DATE: TXSDate;
    FEND_DATE_Specified: boolean;
    FREAD_INCLUDED: Boolean;
    FREAD_INCLUDED_Specified: boolean;
    FDIRECTION: string;
    FDIRECTION_Specified: boolean;
    FSENDER: string;
    FSENDER_Specified: boolean;
    FRECEIVER: string;
    FRECEIVER_Specified: boolean;
    procedure SetLIMIT(Index: Integer; const AInteger: Integer);
    function  LIMIT_Specified(Index: Integer): boolean;
    procedure SetID(Index: Integer; const Astring: string);
    function  ID_Specified(Index: Integer): boolean;
    procedure SetUUID(Index: Integer; const Astring: string);
    function  UUID_Specified(Index: Integer): boolean;
    procedure SetFROM(Index: Integer; const Astring: string);
    function  FROM_Specified(Index: Integer): boolean;
    procedure SetTO_(Index: Integer; const Astring: string);
    function  TO__Specified(Index: Integer): boolean;
    procedure SetSTART_DATE(Index: Integer; const ATXSDate: TXSDate);
    function  START_DATE_Specified(Index: Integer): boolean;
    procedure SetEND_DATE(Index: Integer; const ATXSDate: TXSDate);
    function  END_DATE_Specified(Index: Integer): boolean;
    procedure SetREAD_INCLUDED(Index: Integer; const ABoolean: Boolean);
    function  READ_INCLUDED_Specified(Index: Integer): boolean;
    procedure SetDIRECTION(Index: Integer; const Astring: string);
    function  DIRECTION_Specified(Index: Integer): boolean;
    procedure SetSENDER(Index: Integer; const Astring: string);
    function  SENDER_Specified(Index: Integer): boolean;
    procedure SetRECEIVER(Index: Integer; const Astring: string);
    function  RECEIVER_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property LIMIT:         Integer  Index (IS_OPTN or IS_UNQL) read FLIMIT write SetLIMIT stored LIMIT_Specified;
    property ID:            string   Index (IS_OPTN or IS_UNQL) read FID write SetID stored ID_Specified;
    property UUID:          string   Index (IS_OPTN or IS_UNQL) read FUUID write SetUUID stored UUID_Specified;
    property FROM:          string   Index (IS_OPTN or IS_UNQL) read FFROM write SetFROM stored FROM_Specified;
    property TO_:           string   Index (IS_OPTN or IS_UNQL) read FTO_ write SetTO_ stored TO__Specified;
    property START_DATE:    TXSDate  Index (IS_OPTN or IS_UNQL) read FSTART_DATE write SetSTART_DATE stored START_DATE_Specified;
    property END_DATE:      TXSDate  Index (IS_OPTN or IS_UNQL) read FEND_DATE write SetEND_DATE stored END_DATE_Specified;
    property READ_INCLUDED: Boolean  Index (IS_OPTN or IS_UNQL) read FREAD_INCLUDED write SetREAD_INCLUDED stored READ_INCLUDED_Specified;
    property DIRECTION:     string   Index (IS_OPTN or IS_UNQL) read FDIRECTION write SetDIRECTION stored DIRECTION_Specified;
    property SENDER:        string   Index (IS_OPTN or IS_UNQL) read FSENDER write SetSENDER stored SENDER_Specified;
    property RECEIVER:      string   Index (IS_OPTN or IS_UNQL) read FRECEIVER write SetRECEIVER stored RECEIVER_Specified;
  end;



  // ************************************************************************ //
  // XML       : INVOICE, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  INVOICE = class(TRemotable)
  private
    FID: string;
    FID_Specified: boolean;
    FUUID: string;
    FUUID_Specified: boolean;
    FHEADER: HEADER;
    FHEADER_Specified: boolean;
    FCONTENT: base64Binary;
    FCONTENT_Specified: boolean;
    procedure SetID(Index: Integer; const Astring: string);
    function  ID_Specified(Index: Integer): boolean;
    procedure SetUUID(Index: Integer; const Astring: string);
    function  UUID_Specified(Index: Integer): boolean;
    procedure SetHEADER(Index: Integer; const AHEADER: HEADER);
    function  HEADER_Specified(Index: Integer): boolean;
    procedure SetCONTENT(Index: Integer; const Abase64Binary: base64Binary);
    function  CONTENT_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property ID:      string        Index (IS_ATTR or IS_OPTN) read FID write SetID stored ID_Specified;
    property UUID:    string        Index (IS_ATTR or IS_OPTN) read FUUID write SetUUID stored UUID_Specified;
    property HEADER:  HEADER        Index (IS_OPTN or IS_UNQL) read FHEADER write SetHEADER stored HEADER_Specified;
    property CONTENT: base64Binary  Index (IS_OPTN or IS_UNQL) read FCONTENT write SetCONTENT stored CONTENT_Specified;
  end;



  // ************************************************************************ //
  // XML       : INVOICE_STATUS, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  INVOICE_STATUS = class(INVOICE)
  private
    FSTATUS: string;
    FSTATUS_DESCRIPTION: string;
    FGIB_STATUS_CODE: Integer;
    FGIB_STATUS_CODE_Specified: boolean;
    FGIB_STATUS_DESCRIPTION: string;
    FGIB_STATUS_DESCRIPTION_Specified: boolean;
    procedure SetGIB_STATUS_CODE(Index: Integer; const AInteger: Integer);
    function  GIB_STATUS_CODE_Specified(Index: Integer): boolean;
    procedure SetGIB_STATUS_DESCRIPTION(Index: Integer; const Astring: string);
    function  GIB_STATUS_DESCRIPTION_Specified(Index: Integer): boolean;
  published
    property STATUS:                 string   Index (IS_UNQL) read FSTATUS write FSTATUS;
    property STATUS_DESCRIPTION:     string   Index (IS_UNQL) read FSTATUS_DESCRIPTION write FSTATUS_DESCRIPTION;
    property GIB_STATUS_CODE:        Integer  Index (IS_OPTN or IS_UNQL) read FGIB_STATUS_CODE write SetGIB_STATUS_CODE stored GIB_STATUS_CODE_Specified;
    property GIB_STATUS_DESCRIPTION: string   Index (IS_OPTN or IS_UNQL) read FGIB_STATUS_DESCRIPTION write SetGIB_STATUS_DESCRIPTION stored GIB_STATUS_DESCRIPTION_Specified;
  end;



  // ************************************************************************ //
  // XML       : HEADER, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  HEADER = class(TRemotable)
  private
    FSENDER: string;
    FSENDER_Specified: boolean;
    FRECEIVER: string;
    FRECEIVER_Specified: boolean;
    FSUPPLIER: string;
    FSUPPLIER_Specified: boolean;
    FCUSTOMER: string;
    FCUSTOMER_Specified: boolean;
    FISSUE_DATE: TXSDate;
    FISSUE_DATE_Specified: boolean;
    FPAYABLE_AMOUNT: AmountType;
    FPAYABLE_AMOUNT_Specified: boolean;
    FFROM: string;
    FFROM_Specified: boolean;
    FTO_: string;
    FTO__Specified: boolean;
    FPROFILEID: string;
    FPROFILEID_Specified: boolean;
    FSTATUS: string;
    FSTATUS_Specified: boolean;
    procedure SetSENDER(Index: Integer; const Astring: string);
    function  SENDER_Specified(Index: Integer): boolean;
    procedure SetRECEIVER(Index: Integer; const Astring: string);
    function  RECEIVER_Specified(Index: Integer): boolean;
    procedure SetSUPPLIER(Index: Integer; const Astring: string);
    function  SUPPLIER_Specified(Index: Integer): boolean;
    procedure SetCUSTOMER(Index: Integer; const Astring: string);
    function  CUSTOMER_Specified(Index: Integer): boolean;
    procedure SetISSUE_DATE(Index: Integer; const ATXSDate: TXSDate);
    function  ISSUE_DATE_Specified(Index: Integer): boolean;
    procedure SetPAYABLE_AMOUNT(Index: Integer; const AAmountType: AmountType);
    function  PAYABLE_AMOUNT_Specified(Index: Integer): boolean;
    procedure SetFROM(Index: Integer; const Astring: string);
    function  FROM_Specified(Index: Integer): boolean;
    procedure SetTO_(Index: Integer; const Astring: string);
    function  TO__Specified(Index: Integer): boolean;
    procedure SetPROFILEID(Index: Integer; const Astring: string);
    function  PROFILEID_Specified(Index: Integer): boolean;
    procedure SetSTATUS(Index: Integer; const Astring: string);
    function  STATUS_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property SENDER:         string      Index (IS_OPTN or IS_UNQL) read FSENDER write SetSENDER stored SENDER_Specified;
    property RECEIVER:       string      Index (IS_OPTN or IS_UNQL) read FRECEIVER write SetRECEIVER stored RECEIVER_Specified;
    property SUPPLIER:       string      Index (IS_OPTN or IS_UNQL) read FSUPPLIER write SetSUPPLIER stored SUPPLIER_Specified;
    property CUSTOMER:       string      Index (IS_OPTN or IS_UNQL) read FCUSTOMER write SetCUSTOMER stored CUSTOMER_Specified;
    property ISSUE_DATE:     TXSDate     Index (IS_OPTN or IS_UNQL) read FISSUE_DATE write SetISSUE_DATE stored ISSUE_DATE_Specified;
    property PAYABLE_AMOUNT: AmountType  Index (IS_OPTN or IS_UNQL) read FPAYABLE_AMOUNT write SetPAYABLE_AMOUNT stored PAYABLE_AMOUNT_Specified;
    property FROM:           string      Index (IS_OPTN or IS_UNQL) read FFROM write SetFROM stored FROM_Specified;
    property TO_:            string      Index (IS_OPTN or IS_UNQL) read FTO_ write SetTO_ stored TO__Specified;
    property PROFILEID:      string      Index (IS_OPTN or IS_UNQL) read FPROFILEID write SetPROFILEID stored PROFILEID_Specified;
    property STATUS:         string      Index (IS_OPTN or IS_UNQL) read FSTATUS write SetSTATUS stored STATUS_Specified;
  end;



  // ************************************************************************ //
  // XML       : TextType, global, <complexType>
  // Namespace : urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2
  // ************************************************************************ //
  TextType = class(TRemotable)
  private
    FText: string;
    FlanguageID: string;
    FlanguageID_Specified: boolean;
    procedure SetlanguageID(Index: Integer; const Astring: string);
    function  languageID_Specified(Index: Integer): boolean;
  published
    property Text:       string  Index (IS_TEXT) read FText write FText;
    property languageID: string  Index (IS_ATTR or IS_OPTN) read FlanguageID write SetlanguageID stored languageID_Specified;
  end;



  // ************************************************************************ //
  // XML       : NameType, global, <complexType>
  // Namespace : urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2
  // ************************************************************************ //
  NameType = class(TRemotable)
  private
    FText: string;
    FlanguageID: string;
    FlanguageID_Specified: boolean;
    procedure SetlanguageID(Index: Integer; const Astring: string);
    function  languageID_Specified(Index: Integer): boolean;
  published
    property Text:       string  Index (IS_TEXT) read FText write FText;
    property languageID: string  Index (IS_ATTR or IS_OPTN) read FlanguageID write SetlanguageID stored languageID_Specified;
  end;



  // ************************************************************************ //
  // XML       : LoginRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  LoginRequest2 = class(REQUEST)
  private
    FUSER_NAME: string;
    FPASSWORD: string;
  public
    constructor Create; override;
  published
    property USER_NAME: string  Index (IS_UNQL) read FUSER_NAME write FUSER_NAME;
    property PASSWORD:  string  Index (IS_UNQL) read FPASSWORD write FPASSWORD;
  end;



  // ************************************************************************ //
  // XML       : LoginRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  LoginRequest = class(LoginRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : USERCONTENT, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // ************************************************************************ //
  USERCONTENT = class(base64Binary)
  private
    FUSERID: string;
    FUSERID_Specified: boolean;
    FUSERTYPE: USERTYPE;
    FUSERTYPE_Specified: boolean;
    FSIGNTYPE: SIGNTYPE;
    FSIGNTYPE_Specified: boolean;
    FTYPE_: USERCONTENTTYPE;
    FTYPE__Specified: boolean;
    procedure SetUSERID(Index: Integer; const Astring: string);
    function  USERID_Specified(Index: Integer): boolean;
    procedure SetUSERTYPE(Index: Integer; const AUSERTYPE: USERTYPE);
    function  USERTYPE_Specified(Index: Integer): boolean;
    procedure SetSIGNTYPE(Index: Integer; const ASIGNTYPE: SIGNTYPE);
    function  SIGNTYPE_Specified(Index: Integer): boolean;
    procedure SetTYPE_(Index: Integer; const AUSERCONTENTTYPE: USERCONTENTTYPE);
    function  TYPE__Specified(Index: Integer): boolean;
  published
    property USERID:   string           Index (IS_ATTR or IS_OPTN) read FUSERID write SetUSERID stored USERID_Specified;
    property USERTYPE: USERTYPE         Index (IS_ATTR or IS_OPTN) read FUSERTYPE write SetUSERTYPE stored USERTYPE_Specified;
    property SIGNTYPE: SIGNTYPE         Index (IS_ATTR or IS_OPTN) read FSIGNTYPE write SetSIGNTYPE stored SIGNTYPE_Specified;
    property TYPE_:    USERCONTENTTYPE  Index (IS_ATTR or IS_OPTN) read FTYPE_ write SetTYPE_ stored TYPE__Specified;
  end;



  // ************************************************************************ //
  // XML       : LoginResponse, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  LoginResponse2 = class(TRemotable)
  private
    FREQUEST_RETURN: REQUEST_RETURNType;
    FREQUEST_RETURN_Specified: boolean;
    FSESSION_ID: string;
    procedure SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
    function  REQUEST_RETURN_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property REQUEST_RETURN: REQUEST_RETURNType  Index (IS_OPTN or IS_UNQL) read FREQUEST_RETURN write SetREQUEST_RETURN stored REQUEST_RETURN_Specified;
    property SESSION_ID:     string              Index (IS_UNQL) read FSESSION_ID write FSESSION_ID;
  end;



  // ************************************************************************ //
  // XML       : LoginResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  LoginResponse = class(LoginResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : LogoutRequest, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  LogoutRequest2 = class(REQUEST)
  private
  public
    constructor Create; override;
  published
  end;



  // ************************************************************************ //
  // XML       : LogoutRequest, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  LogoutRequest = class(LogoutRequest2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : LogoutResponse, global, <complexType>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Serializtn: [xoLiteralParam]
  // Info      : Wrapper
  // ************************************************************************ //
  LogoutResponse2 = class(TRemotable)
  private
    FREQUEST_RETURN: REQUEST_RETURNType;
    FREQUEST_RETURN_Specified: boolean;
    procedure SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
    function  REQUEST_RETURN_Specified(Index: Integer): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property REQUEST_RETURN: REQUEST_RETURNType  Index (IS_OPTN or IS_UNQL) read FREQUEST_RETURN write SetREQUEST_RETURN stored REQUEST_RETURN_Specified;
  end;



  // ************************************************************************ //
  // XML       : LogoutResponse, global, <element>
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // Info      : Wrapper
  // ************************************************************************ //
  LogoutResponse = class(LogoutResponse2)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://schemas.i2i.com/ei/wsdl
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // use       : literal
  // binding   : EFaturaOIBPortBinding
  // service   : EFaturaOIB
  // port      : EFaturaOIBPort
  // URL       : https://efatura.izibiz.com.tr:2443/EFaturaOIB
  // ************************************************************************ //
  EFaturaOIBPort = interface(IInvokable)
  ['{78A5D2BC-2D11-6A64-DB25-37E881787C35}']

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    //     - More than one strictly out element was found
    function  Login(const request: LoginRequest): LoginResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  Logout(const request: LogoutRequest): LogoutResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  LoadInvoice(const request: LoadInvoiceRequest): LoadInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  SendInvoice(const request: SendInvoiceRequest): SendInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  GetInvoice(const request: GetInvoiceRequest): GetInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  MarkInvoice(const request: MarkInvoiceRequest): MarkInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  GetUserList(const request: GetUserListRequest): GetUserListResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  CheckUser(const request: CheckUserRequest): CheckUserResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  GetInvoiceStatus(const request: GetInvoiceStatusRequest): GetInvoiceStatusResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  PrepareInvoiceResponse(const request: PrepareInvoiceResponseRequest): PrepareInvoiceResponseResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  SendInvoiceResponse(const request: SendInvoiceResponseRequest): SendInvoiceResponseResponse; stdcall;

    // Cannot unwrap: 
    //     - Input element wrapper name does not match operation's name
    function  SendInvoiceResponseWithServerSign(const request: SendInvoiceResponseWithServerSignRequest): SendInvoiceResponseWithServerSignResponse; stdcall;
  end;

function GetEFaturaOIBPort(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): EFaturaOIBPort;


implementation
  uses SysUtils;

function GetEFaturaOIBPort(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): EFaturaOIBPort;
const
  defWSDL = 'https://efatura.izibiz.com.tr:2443/EFaturaOIB?wsdl';
  defURL  = 'https://efatura.izibiz.com.tr:2443/EFaturaOIB';
  defSvc  = 'EFaturaOIB';
  defPrt  = 'EFaturaOIBPort';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as EFaturaOIBPort);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


constructor SendInvoiceResponseWithServerSignResponse2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SendInvoiceResponseWithServerSignResponse2.Destroy;
begin
  SysUtils.FreeAndNil(FREQUEST_RETURN);
  inherited Destroy;
end;

procedure SendInvoiceResponseWithServerSignResponse2.SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
begin
  FREQUEST_RETURN := AREQUEST_RETURNType;
  FREQUEST_RETURN_Specified := True;
end;

function SendInvoiceResponseWithServerSignResponse2.REQUEST_RETURN_Specified(Index: Integer): boolean;
begin
  Result := FREQUEST_RETURN_Specified;
end;

constructor SendInvoiceResponseResponse2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SendInvoiceResponseResponse2.Destroy;
begin
  SysUtils.FreeAndNil(FREQUEST_RETURN);
  inherited Destroy;
end;

procedure SendInvoiceResponseResponse2.SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
begin
  FREQUEST_RETURN := AREQUEST_RETURNType;
  FREQUEST_RETURN_Specified := True;
end;

function SendInvoiceResponseResponse2.REQUEST_RETURN_Specified(Index: Integer): boolean;
begin
  Result := FREQUEST_RETURN_Specified;
end;

constructor LoadInvoiceResponse2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor LoadInvoiceResponse2.Destroy;
begin
  SysUtils.FreeAndNil(FREQUEST_RETURN);
  inherited Destroy;
end;

procedure LoadInvoiceResponse2.SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
begin
  FREQUEST_RETURN := AREQUEST_RETURNType;
  FREQUEST_RETURN_Specified := True;
end;

function LoadInvoiceResponse2.REQUEST_RETURN_Specified(Index: Integer): boolean;
begin
  Result := FREQUEST_RETURN_Specified;
end;

constructor GetInvoiceStatusResponse2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor GetInvoiceStatusResponse2.Destroy;
begin
  SysUtils.FreeAndNil(FINVOICE_STATUS);
  inherited Destroy;
end;

destructor AmountType.Destroy;
begin
  SysUtils.FreeAndNil(FText);
  inherited Destroy;
end;

destructor MeasureType.Destroy;
begin
  SysUtils.FreeAndNil(FText);
  inherited Destroy;
end;

procedure IdentifierType.SetschemeID(Index: Integer; const Astring: string);
begin
  FschemeID := Astring;
  FschemeID_Specified := True;
end;

function IdentifierType.schemeID_Specified(Index: Integer): boolean;
begin
  Result := FschemeID_Specified;
end;

destructor CHANGE_INFOType.Destroy;
begin
  SysUtils.FreeAndNil(FCDATE);
  SysUtils.FreeAndNil(FUDATE);
  inherited Destroy;
end;

procedure CHANGE_INFOType.SetUDATE(Index: Integer; const ATXSDate: TXSDate);
begin
  FUDATE := ATXSDate;
  FUDATE_Specified := True;
end;

function CHANGE_INFOType.UDATE_Specified(Index: Integer): boolean;
begin
  Result := FUDATE_Specified;
end;

procedure CHANGE_INFOType.SetUPOSITION_ID(Index: Integer; const AInt64: Int64);
begin
  FUPOSITION_ID := AInt64;
  FUPOSITION_ID_Specified := True;
end;

function CHANGE_INFOType.UPOSITION_ID_Specified(Index: Integer): boolean;
begin
  Result := FUPOSITION_ID_Specified;
end;

procedure CHANGE_INFOType.SetUUSER_ID(Index: Integer; const AInt64: Int64);
begin
  FUUSER_ID := AInt64;
  FUUSER_ID_Specified := True;
end;

function CHANGE_INFOType.UUSER_ID_Specified(Index: Integer): boolean;
begin
  Result := FUUSER_ID_Specified;
end;

procedure BinaryObjectType.Setformat(Index: Integer; const Astring: string);
begin
  Fformat := Astring;
  Fformat_Specified := True;
end;

function BinaryObjectType.format_Specified(Index: Integer): boolean;
begin
  Result := Fformat_Specified;
end;

procedure BinaryObjectType.SetencodingCode(Index: Integer; const Astring: string);
begin
  FencodingCode := Astring;
  FencodingCode_Specified := True;
end;

function BinaryObjectType.encodingCode_Specified(Index: Integer): boolean;
begin
  Result := FencodingCode_Specified;
end;

procedure BinaryObjectType.SetcharacterSetCode(Index: Integer; const Astring: string);
begin
  FcharacterSetCode := Astring;
  FcharacterSetCode_Specified := True;
end;

function BinaryObjectType.characterSetCode_Specified(Index: Integer): boolean;
begin
  Result := FcharacterSetCode_Specified;
end;

procedure BinaryObjectType.Seturi(Index: Integer; const Astring: string);
begin
  Furi := Astring;
  Furi_Specified := True;
end;

function BinaryObjectType.uri_Specified(Index: Integer): boolean;
begin
  Result := Furi_Specified;
end;

procedure BinaryObjectType.Setfilename(Index: Integer; const Astring: string);
begin
  Ffilename := Astring;
  Ffilename_Specified := True;
end;

function BinaryObjectType.filename_Specified(Index: Integer): boolean;
begin
  Result := Ffilename_Specified;
end;

procedure CodeType.SetlistID(Index: Integer; const Astring: string);
begin
  FlistID := Astring;
  FlistID_Specified := True;
end;

function CodeType.listID_Specified(Index: Integer): boolean;
begin
  Result := FlistID_Specified;
end;

procedure CodeType.SetlistAgencyName(Index: Integer; const Astring: string);
begin
  FlistAgencyName := Astring;
  FlistAgencyName_Specified := True;
end;

function CodeType.listAgencyName_Specified(Index: Integer): boolean;
begin
  Result := FlistAgencyName_Specified;
end;

procedure CodeType.SetlistName(Index: Integer; const Astring: string);
begin
  FlistName := Astring;
  FlistName_Specified := True;
end;

function CodeType.listName_Specified(Index: Integer): boolean;
begin
  Result := FlistName_Specified;
end;

procedure CodeType.SetlistVersionID(Index: Integer; const Astring: string);
begin
  FlistVersionID := Astring;
  FlistVersionID_Specified := True;
end;

function CodeType.listVersionID_Specified(Index: Integer): boolean;
begin
  Result := FlistVersionID_Specified;
end;

procedure base64Binary.SetcontentType(Index: Integer; const AcontentType: contentType);
begin
  FcontentType := AcontentType;
  FcontentType_Specified := True;
end;

function base64Binary.contentType_Specified(Index: Integer): boolean;
begin
  Result := FcontentType_Specified;
end;

procedure hexBinary.SetcontentType(Index: Integer; const AcontentType: contentType);
begin
  FcontentType := AcontentType;
  FcontentType_Specified := True;
end;

function hexBinary.contentType_Specified(Index: Integer): boolean;
begin
  Result := FcontentType_Specified;
end;

procedure GIBUSER.SetIDENTIFIER(Index: Integer; const Astring: string);
begin
  FIDENTIFIER := Astring;
  FIDENTIFIER_Specified := True;
end;

function GIBUSER.IDENTIFIER_Specified(Index: Integer): boolean;
begin
  Result := FIDENTIFIER_Specified;
end;

procedure GIBUSER.SetALIAS(Index: Integer; const Astring: string);
begin
  FALIAS := Astring;
  FALIAS_Specified := True;
end;

function GIBUSER.ALIAS_Specified(Index: Integer): boolean;
begin
  Result := FALIAS_Specified;
end;

procedure GIBUSER.SetTITLE(Index: Integer; const Astring: string);
begin
  FTITLE := Astring;
  FTITLE_Specified := True;
end;

function GIBUSER.TITLE_Specified(Index: Integer): boolean;
begin
  Result := FTITLE_Specified;
end;

procedure GIBUSER.SetTYPE_(Index: Integer; const Astring: string);
begin
  FTYPE_ := Astring;
  FTYPE__Specified := True;
end;

function GIBUSER.TYPE__Specified(Index: Integer): boolean;
begin
  Result := FTYPE__Specified;
end;

procedure GIBUSER.SetREGISTER_TIME(Index: Integer; const Astring: string);
begin
  FREGISTER_TIME := Astring;
  FREGISTER_TIME_Specified := True;
end;

function GIBUSER.REGISTER_TIME_Specified(Index: Integer): boolean;
begin
  Result := FREGISTER_TIME_Specified;
end;

procedure GIBUSER.SetUNIT_(Index: Integer; const Astring: string);
begin
  FUNIT_ := Astring;
  FUNIT__Specified := True;
end;

function GIBUSER.UNIT__Specified(Index: Integer): boolean;
begin
  Result := FUNIT__Specified;
end;

procedure REQUEST_RETURNType.SetCLIENT_TXN_ID(Index: Integer; const Astring: string);
begin
  FCLIENT_TXN_ID := Astring;
  FCLIENT_TXN_ID_Specified := True;
end;

function REQUEST_RETURNType.CLIENT_TXN_ID_Specified(Index: Integer): boolean;
begin
  Result := FCLIENT_TXN_ID_Specified;
end;

procedure REQUEST_RETURNType.SetWARNINGS(Index: Integer; const AArray_Of_string: Array_Of_string);
begin
  FWARNINGS := AArray_Of_string;
  FWARNINGS_Specified := True;
end;

function REQUEST_RETURNType.WARNINGS_Specified(Index: Integer): boolean;
begin
  Result := FWARNINGS_Specified;
end;

procedure RequestFault.SetCLIENT_TXN_ID(Index: Integer; const Astring: string);
begin
  FCLIENT_TXN_ID := Astring;
  FCLIENT_TXN_ID_Specified := True;
end;

function RequestFault.CLIENT_TXN_ID_Specified(Index: Integer): boolean;
begin
  Result := FCLIENT_TXN_ID_Specified;
end;

procedure RequestFault.SetERROR_LONG_DES(Index: Integer; const Astring: string);
begin
  FERROR_LONG_DES := Astring;
  FERROR_LONG_DES_Specified := True;
end;

function RequestFault.ERROR_LONG_DES_Specified(Index: Integer): boolean;
begin
  Result := FERROR_LONG_DES_Specified;
end;

procedure RequestFault.SetSTACKTRACE(Index: Integer; const Astring: string);
begin
  FSTACKTRACE := Astring;
  FSTACKTRACE_Specified := True;
end;

function RequestFault.STACKTRACE_Specified(Index: Integer): boolean;
begin
  Result := FSTACKTRACE_Specified;
end;

procedure RequestFault.SetERROR_ELEMENT_INDEX(Index: Integer; const AInteger: Integer);
begin
  FERROR_ELEMENT_INDEX := AInteger;
  FERROR_ELEMENT_INDEX_Specified := True;
end;

function RequestFault.ERROR_ELEMENT_INDEX_Specified(Index: Integer): boolean;
begin
  Result := FERROR_ELEMENT_INDEX_Specified;
end;

procedure REQUEST_ERRORType.SetCLIENT_TXN_ID(Index: Integer; const Astring: string);
begin
  FCLIENT_TXN_ID := Astring;
  FCLIENT_TXN_ID_Specified := True;
end;

function REQUEST_ERRORType.CLIENT_TXN_ID_Specified(Index: Integer): boolean;
begin
  Result := FCLIENT_TXN_ID_Specified;
end;

procedure REQUEST_ERRORType.SetERROR_LONG_DES(Index: Integer; const Astring: string);
begin
  FERROR_LONG_DES := Astring;
  FERROR_LONG_DES_Specified := True;
end;

function REQUEST_ERRORType.ERROR_LONG_DES_Specified(Index: Integer): boolean;
begin
  Result := FERROR_LONG_DES_Specified;
end;

procedure REQUEST_ERRORType.SetSTACKTRACE(Index: Integer; const Astring: string);
begin
  FSTACKTRACE := Astring;
  FSTACKTRACE_Specified := True;
end;

function REQUEST_ERRORType.STACKTRACE_Specified(Index: Integer): boolean;
begin
  Result := FSTACKTRACE_Specified;
end;

procedure REQUEST_ERRORType.SetERROR_ELEMENT_INDEX(Index: Integer; const AInteger: Integer);
begin
  FERROR_ELEMENT_INDEX := AInteger;
  FERROR_ELEMENT_INDEX_Specified := True;
end;

function REQUEST_ERRORType.ERROR_ELEMENT_INDEX_Specified(Index: Integer): boolean;
begin
  Result := FERROR_ELEMENT_INDEX_Specified;
end;

destructor REQUEST.Destroy;
begin
  SysUtils.FreeAndNil(FREQUEST_HEADER);
  inherited Destroy;
end;

constructor GetInvoiceStatusRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor GetInvoiceStatusRequest2.Destroy;
begin
  SysUtils.FreeAndNil(FINVOICE);
  inherited Destroy;
end;

constructor CheckUserRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor CheckUserRequest2.Destroy;
begin
  SysUtils.FreeAndNil(FUSER);
  inherited Destroy;
end;

constructor SendInvoiceResponseRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SendInvoiceResponseRequest2.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FAPPRESPONSE)-1 do
    SysUtils.FreeAndNil(FAPPRESPONSE[I]);
  System.SetLength(FAPPRESPONSE, 0);
  inherited Destroy;
end;

destructor REQUEST_HEADERType.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FATTRIBUTES)-1 do
    SysUtils.FreeAndNil(FATTRIBUTES[I]);
  System.SetLength(FATTRIBUTES, 0);
  SysUtils.FreeAndNil(FACTION_DATE);
  SysUtils.FreeAndNil(FCHANGE_INFO);
  inherited Destroy;
end;

procedure REQUEST_HEADERType.SetCLIENT_TXN_ID(Index: Integer; const Astring: string);
begin
  FCLIENT_TXN_ID := Astring;
  FCLIENT_TXN_ID_Specified := True;
end;

function REQUEST_HEADERType.CLIENT_TXN_ID_Specified(Index: Integer): boolean;
begin
  Result := FCLIENT_TXN_ID_Specified;
end;

procedure REQUEST_HEADERType.SetINTL_TXN_ID(Index: Integer; const AInt64: Int64);
begin
  FINTL_TXN_ID := AInt64;
  FINTL_TXN_ID_Specified := True;
end;

function REQUEST_HEADERType.INTL_TXN_ID_Specified(Index: Integer): boolean;
begin
  Result := FINTL_TXN_ID_Specified;
end;

procedure REQUEST_HEADERType.SetINTL_PARENT_TXN_ID(Index: Integer; const AInt64: Int64);
begin
  FINTL_PARENT_TXN_ID := AInt64;
  FINTL_PARENT_TXN_ID_Specified := True;
end;

function REQUEST_HEADERType.INTL_PARENT_TXN_ID_Specified(Index: Integer): boolean;
begin
  Result := FINTL_PARENT_TXN_ID_Specified;
end;

procedure REQUEST_HEADERType.SetACTION_DATE(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  FACTION_DATE := ATXSDateTime;
  FACTION_DATE_Specified := True;
end;

function REQUEST_HEADERType.ACTION_DATE_Specified(Index: Integer): boolean;
begin
  Result := FACTION_DATE_Specified;
end;

procedure REQUEST_HEADERType.SetCHANGE_INFO(Index: Integer; const ACHANGE_INFOType: CHANGE_INFOType);
begin
  FCHANGE_INFO := ACHANGE_INFOType;
  FCHANGE_INFO_Specified := True;
end;

function REQUEST_HEADERType.CHANGE_INFO_Specified(Index: Integer): boolean;
begin
  Result := FCHANGE_INFO_Specified;
end;

procedure REQUEST_HEADERType.SetREASON(Index: Integer; const Astring: string);
begin
  FREASON := Astring;
  FREASON_Specified := True;
end;

function REQUEST_HEADERType.REASON_Specified(Index: Integer): boolean;
begin
  Result := FREASON_Specified;
end;

procedure REQUEST_HEADERType.SetAPPLICATION_NAME(Index: Integer; const Astring: string);
begin
  FAPPLICATION_NAME := Astring;
  FAPPLICATION_NAME_Specified := True;
end;

function REQUEST_HEADERType.APPLICATION_NAME_Specified(Index: Integer): boolean;
begin
  Result := FAPPLICATION_NAME_Specified;
end;

procedure REQUEST_HEADERType.SetHOSTNAME(Index: Integer; const Astring: string);
begin
  FHOSTNAME := Astring;
  FHOSTNAME_Specified := True;
end;

function REQUEST_HEADERType.HOSTNAME_Specified(Index: Integer): boolean;
begin
  Result := FHOSTNAME_Specified;
end;

procedure REQUEST_HEADERType.SetCHANNEL_NAME(Index: Integer; const Astring: string);
begin
  FCHANNEL_NAME := Astring;
  FCHANNEL_NAME_Specified := True;
end;

function REQUEST_HEADERType.CHANNEL_NAME_Specified(Index: Integer): boolean;
begin
  Result := FCHANNEL_NAME_Specified;
end;

procedure REQUEST_HEADERType.SetSIMULATION_FLAG(Index: Integer; const Astring: string);
begin
  FSIMULATION_FLAG := Astring;
  FSIMULATION_FLAG_Specified := True;
end;

function REQUEST_HEADERType.SIMULATION_FLAG_Specified(Index: Integer): boolean;
begin
  Result := FSIMULATION_FLAG_Specified;
end;

procedure REQUEST_HEADERType.SetCOMPRESSED(Index: Integer; const Astring: string);
begin
  FCOMPRESSED := Astring;
  FCOMPRESSED_Specified := True;
end;

function REQUEST_HEADERType.COMPRESSED_Specified(Index: Integer): boolean;
begin
  Result := FCOMPRESSED_Specified;
end;

procedure REQUEST_HEADERType.SetATTRIBUTES(Index: Integer; const AArray_Of_ATTRIBUTESTYPE: Array_Of_ATTRIBUTESTYPE);
begin
  FATTRIBUTES := AArray_Of_ATTRIBUTESTYPE;
  FATTRIBUTES_Specified := True;
end;

function REQUEST_HEADERType.ATTRIBUTES_Specified(Index: Integer): boolean;
begin
  Result := FATTRIBUTES_Specified;
end;

constructor GetUserListRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor GetUserListRequest2.Destroy;
begin
  SysUtils.FreeAndNil(FREGISTER_TIME_START);
  inherited Destroy;
end;

procedure GetUserListRequest2.SetREGISTER_TIME_START(Index: Integer; const ATXSDateTime: TXSDateTime);
begin
  FREGISTER_TIME_START := ATXSDateTime;
  FREGISTER_TIME_START_Specified := True;
end;

function GetUserListRequest2.REGISTER_TIME_START_Specified(Index: Integer): boolean;
begin
  Result := FREGISTER_TIME_START_Specified;
end;

destructor QuantityType.Destroy;
begin
  SysUtils.FreeAndNil(FText);
  inherited Destroy;
end;

procedure SENDER.Setvkn(Index: Integer; const Astring: string);
begin
  Fvkn := Astring;
  Fvkn_Specified := True;
end;

function SENDER.vkn_Specified(Index: Integer): boolean;
begin
  Result := Fvkn_Specified;
end;

procedure SENDER.Setalias(Index: Integer; const Astring: string);
begin
  Falias := Astring;
  Falias_Specified := True;
end;

function SENDER.alias_Specified(Index: Integer): boolean;
begin
  Result := Falias_Specified;
end;

procedure RECEIVER.Setvkn(Index: Integer; const Astring: string);
begin
  Fvkn := Astring;
  Fvkn_Specified := True;
end;

function RECEIVER.vkn_Specified(Index: Integer): boolean;
begin
  Result := Fvkn_Specified;
end;

procedure RECEIVER.Setalias(Index: Integer; const Astring: string);
begin
  Falias := Astring;
  Falias_Specified := True;
end;

function RECEIVER.alias_Specified(Index: Integer): boolean;
begin
  Result := Falias_Specified;
end;

destructor UserRequest.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FUSERCONTENT)-1 do
    SysUtils.FreeAndNil(FUSERCONTENT[I]);
  System.SetLength(FUSERCONTENT, 0);
  inherited Destroy;
end;

constructor SendInvoiceResponse2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SendInvoiceResponse2.Destroy;
begin
  SysUtils.FreeAndNil(FREQUEST_RETURN);
  inherited Destroy;
end;

procedure SendInvoiceResponse2.SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
begin
  FREQUEST_RETURN := AREQUEST_RETURNType;
  FREQUEST_RETURN_Specified := True;
end;

function SendInvoiceResponse2.REQUEST_RETURN_Specified(Index: Integer): boolean;
begin
  Result := FREQUEST_RETURN_Specified;
end;

constructor MarkInvoiceRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor MarkInvoiceRequest2.Destroy;
begin
  SysUtils.FreeAndNil(FMARK);
  inherited Destroy;
end;

constructor MarkInvoiceResponse2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor MarkInvoiceResponse2.Destroy;
begin
  SysUtils.FreeAndNil(FREQUEST_RETURN);
  inherited Destroy;
end;

procedure MarkInvoiceResponse2.SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
begin
  FREQUEST_RETURN := AREQUEST_RETURNType;
  FREQUEST_RETURN_Specified := True;
end;

function MarkInvoiceResponse2.REQUEST_RETURN_Specified(Index: Integer): boolean;
begin
  Result := FREQUEST_RETURN_Specified;
end;

constructor GetInvoiceRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor GetInvoiceRequest2.Destroy;
begin
  SysUtils.FreeAndNil(FINVOICE_SEARCH_KEY);
  inherited Destroy;
end;

procedure GetInvoiceRequest2.SetHEADER_ONLY(Index: Integer; const Astring: string);
begin
  FHEADER_ONLY := Astring;
  FHEADER_ONLY_Specified := True;
end;

function GetInvoiceRequest2.HEADER_ONLY_Specified(Index: Integer): boolean;
begin
  Result := FHEADER_ONLY_Specified;
end;

destructor MARK.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FINVOICE)-1 do
    SysUtils.FreeAndNil(FINVOICE[I]);
  System.SetLength(FINVOICE, 0);
  inherited Destroy;
end;

procedure MARK.Setvalue(Index: Integer; const Astring: string);
begin
  Fvalue := Astring;
  Fvalue_Specified := True;
end;

function MARK.value_Specified(Index: Integer): boolean;
begin
  Result := Fvalue_Specified;
end;

constructor SendInvoiceRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SendInvoiceRequest2.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FINVOICE)-1 do
    SysUtils.FreeAndNil(FINVOICE[I]);
  System.SetLength(FINVOICE, 0);
  SysUtils.FreeAndNil(FSENDER);
  SysUtils.FreeAndNil(FRECEIVER);
  inherited Destroy;
end;

constructor PrepareInvoiceResponseRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor PrepareInvoiceResponseRequest2.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FINVOICE)-1 do
    SysUtils.FreeAndNil(FINVOICE[I]);
  System.SetLength(FINVOICE, 0);
  inherited Destroy;
end;

procedure PrepareInvoiceResponseRequest2.SetDESCRIPTION(Index: Integer; const AArray_Of_string: Array_Of_string);
begin
  FDESCRIPTION := AArray_Of_string;
  FDESCRIPTION_Specified := True;
end;

function PrepareInvoiceResponseRequest2.DESCRIPTION_Specified(Index: Integer): boolean;
begin
  Result := FDESCRIPTION_Specified;
end;

constructor LoadInvoiceRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor LoadInvoiceRequest2.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FINVOICE)-1 do
    SysUtils.FreeAndNil(FINVOICE[I]);
  System.SetLength(FINVOICE, 0);
  inherited Destroy;
end;

constructor SendInvoiceResponseWithServerSignRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor SendInvoiceResponseWithServerSignRequest2.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FINVOICE)-1 do
    SysUtils.FreeAndNil(FINVOICE[I]);
  System.SetLength(FINVOICE, 0);
  inherited Destroy;
end;

procedure SendInvoiceResponseWithServerSignRequest2.SetDESCRIPTION(Index: Integer; const AArray_Of_string: Array_Of_string);
begin
  FDESCRIPTION := AArray_Of_string;
  FDESCRIPTION_Specified := True;
end;

function SendInvoiceResponseWithServerSignRequest2.DESCRIPTION_Specified(Index: Integer): boolean;
begin
  Result := FDESCRIPTION_Specified;
end;

destructor INVOICE_SEARCH_KEY.Destroy;
begin
  SysUtils.FreeAndNil(FSTART_DATE);
  SysUtils.FreeAndNil(FEND_DATE);
  inherited Destroy;
end;

procedure INVOICE_SEARCH_KEY.SetLIMIT(Index: Integer; const AInteger: Integer);
begin
  FLIMIT := AInteger;
  FLIMIT_Specified := True;
end;

function INVOICE_SEARCH_KEY.LIMIT_Specified(Index: Integer): boolean;
begin
  Result := FLIMIT_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetID(Index: Integer; const Astring: string);
begin
  FID := Astring;
  FID_Specified := True;
end;

function INVOICE_SEARCH_KEY.ID_Specified(Index: Integer): boolean;
begin
  Result := FID_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetUUID(Index: Integer; const Astring: string);
begin
  FUUID := Astring;
  FUUID_Specified := True;
end;

function INVOICE_SEARCH_KEY.UUID_Specified(Index: Integer): boolean;
begin
  Result := FUUID_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetFROM(Index: Integer; const Astring: string);
begin
  FFROM := Astring;
  FFROM_Specified := True;
end;

function INVOICE_SEARCH_KEY.FROM_Specified(Index: Integer): boolean;
begin
  Result := FFROM_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetTO_(Index: Integer; const Astring: string);
begin
  FTO_ := Astring;
  FTO__Specified := True;
end;

function INVOICE_SEARCH_KEY.TO__Specified(Index: Integer): boolean;
begin
  Result := FTO__Specified;
end;

procedure INVOICE_SEARCH_KEY.SetSTART_DATE(Index: Integer; const ATXSDate: TXSDate);
begin
  FSTART_DATE := ATXSDate;
  FSTART_DATE_Specified := True;
end;

function INVOICE_SEARCH_KEY.START_DATE_Specified(Index: Integer): boolean;
begin
  Result := FSTART_DATE_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetEND_DATE(Index: Integer; const ATXSDate: TXSDate);
begin
  FEND_DATE := ATXSDate;
  FEND_DATE_Specified := True;
end;

function INVOICE_SEARCH_KEY.END_DATE_Specified(Index: Integer): boolean;
begin
  Result := FEND_DATE_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetREAD_INCLUDED(Index: Integer; const ABoolean: Boolean);
begin
  FREAD_INCLUDED := ABoolean;
  FREAD_INCLUDED_Specified := True;
end;

function INVOICE_SEARCH_KEY.READ_INCLUDED_Specified(Index: Integer): boolean;
begin
  Result := FREAD_INCLUDED_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetDIRECTION(Index: Integer; const Astring: string);
begin
  FDIRECTION := Astring;
  FDIRECTION_Specified := True;
end;

function INVOICE_SEARCH_KEY.DIRECTION_Specified(Index: Integer): boolean;
begin
  Result := FDIRECTION_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetSENDER(Index: Integer; const Astring: string);
begin
  FSENDER := Astring;
  FSENDER_Specified := True;
end;

function INVOICE_SEARCH_KEY.SENDER_Specified(Index: Integer): boolean;
begin
  Result := FSENDER_Specified;
end;

procedure INVOICE_SEARCH_KEY.SetRECEIVER(Index: Integer; const Astring: string);
begin
  FRECEIVER := Astring;
  FRECEIVER_Specified := True;
end;

function INVOICE_SEARCH_KEY.RECEIVER_Specified(Index: Integer): boolean;
begin
  Result := FRECEIVER_Specified;
end;

destructor INVOICE.Destroy;
begin
  SysUtils.FreeAndNil(FHEADER);
  SysUtils.FreeAndNil(FCONTENT);
  inherited Destroy;
end;

procedure INVOICE.SetID(Index: Integer; const Astring: string);
begin
  FID := Astring;
  FID_Specified := True;
end;

function INVOICE.ID_Specified(Index: Integer): boolean;
begin
  Result := FID_Specified;
end;

procedure INVOICE.SetUUID(Index: Integer; const Astring: string);
begin
  FUUID := Astring;
  FUUID_Specified := True;
end;

function INVOICE.UUID_Specified(Index: Integer): boolean;
begin
  Result := FUUID_Specified;
end;

procedure INVOICE.SetHEADER(Index: Integer; const AHEADER: HEADER);
begin
  FHEADER := AHEADER;
  FHEADER_Specified := True;
end;

function INVOICE.HEADER_Specified(Index: Integer): boolean;
begin
  Result := FHEADER_Specified;
end;

procedure INVOICE.SetCONTENT(Index: Integer; const Abase64Binary: base64Binary);
begin
  FCONTENT := Abase64Binary;
  FCONTENT_Specified := True;
end;

function INVOICE.CONTENT_Specified(Index: Integer): boolean;
begin
  Result := FCONTENT_Specified;
end;

procedure INVOICE_STATUS.SetGIB_STATUS_CODE(Index: Integer; const AInteger: Integer);
begin
  FGIB_STATUS_CODE := AInteger;
  FGIB_STATUS_CODE_Specified := True;
end;

function INVOICE_STATUS.GIB_STATUS_CODE_Specified(Index: Integer): boolean;
begin
  Result := FGIB_STATUS_CODE_Specified;
end;

procedure INVOICE_STATUS.SetGIB_STATUS_DESCRIPTION(Index: Integer; const Astring: string);
begin
  FGIB_STATUS_DESCRIPTION := Astring;
  FGIB_STATUS_DESCRIPTION_Specified := True;
end;

function INVOICE_STATUS.GIB_STATUS_DESCRIPTION_Specified(Index: Integer): boolean;
begin
  Result := FGIB_STATUS_DESCRIPTION_Specified;
end;

destructor HEADER.Destroy;
begin
  SysUtils.FreeAndNil(FISSUE_DATE);
  SysUtils.FreeAndNil(FPAYABLE_AMOUNT);
  inherited Destroy;
end;

procedure HEADER.SetSENDER(Index: Integer; const Astring: string);
begin
  FSENDER := Astring;
  FSENDER_Specified := True;
end;

function HEADER.SENDER_Specified(Index: Integer): boolean;
begin
  Result := FSENDER_Specified;
end;

procedure HEADER.SetRECEIVER(Index: Integer; const Astring: string);
begin
  FRECEIVER := Astring;
  FRECEIVER_Specified := True;
end;

function HEADER.RECEIVER_Specified(Index: Integer): boolean;
begin
  Result := FRECEIVER_Specified;
end;

procedure HEADER.SetSUPPLIER(Index: Integer; const Astring: string);
begin
  FSUPPLIER := Astring;
  FSUPPLIER_Specified := True;
end;

function HEADER.SUPPLIER_Specified(Index: Integer): boolean;
begin
  Result := FSUPPLIER_Specified;
end;

procedure HEADER.SetCUSTOMER(Index: Integer; const Astring: string);
begin
  FCUSTOMER := Astring;
  FCUSTOMER_Specified := True;
end;

function HEADER.CUSTOMER_Specified(Index: Integer): boolean;
begin
  Result := FCUSTOMER_Specified;
end;

procedure HEADER.SetISSUE_DATE(Index: Integer; const ATXSDate: TXSDate);
begin
  FISSUE_DATE := ATXSDate;
  FISSUE_DATE_Specified := True;
end;

function HEADER.ISSUE_DATE_Specified(Index: Integer): boolean;
begin
  Result := FISSUE_DATE_Specified;
end;

procedure HEADER.SetPAYABLE_AMOUNT(Index: Integer; const AAmountType: AmountType);
begin
  FPAYABLE_AMOUNT := AAmountType;
  FPAYABLE_AMOUNT_Specified := True;
end;

function HEADER.PAYABLE_AMOUNT_Specified(Index: Integer): boolean;
begin
  Result := FPAYABLE_AMOUNT_Specified;
end;

procedure HEADER.SetFROM(Index: Integer; const Astring: string);
begin
  FFROM := Astring;
  FFROM_Specified := True;
end;

function HEADER.FROM_Specified(Index: Integer): boolean;
begin
  Result := FFROM_Specified;
end;

procedure HEADER.SetTO_(Index: Integer; const Astring: string);
begin
  FTO_ := Astring;
  FTO__Specified := True;
end;

function HEADER.TO__Specified(Index: Integer): boolean;
begin
  Result := FTO__Specified;
end;

procedure HEADER.SetPROFILEID(Index: Integer; const Astring: string);
begin
  FPROFILEID := Astring;
  FPROFILEID_Specified := True;
end;

function HEADER.PROFILEID_Specified(Index: Integer): boolean;
begin
  Result := FPROFILEID_Specified;
end;

procedure HEADER.SetSTATUS(Index: Integer; const Astring: string);
begin
  FSTATUS := Astring;
  FSTATUS_Specified := True;
end;

function HEADER.STATUS_Specified(Index: Integer): boolean;
begin
  Result := FSTATUS_Specified;
end;

procedure TextType.SetlanguageID(Index: Integer; const Astring: string);
begin
  FlanguageID := Astring;
  FlanguageID_Specified := True;
end;

function TextType.languageID_Specified(Index: Integer): boolean;
begin
  Result := FlanguageID_Specified;
end;

procedure NameType.SetlanguageID(Index: Integer; const Astring: string);
begin
  FlanguageID := Astring;
  FlanguageID_Specified := True;
end;

function NameType.languageID_Specified(Index: Integer): boolean;
begin
  Result := FlanguageID_Specified;
end;

constructor LoginRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

procedure USERCONTENT.SetUSERID(Index: Integer; const Astring: string);
begin
  FUSERID := Astring;
  FUSERID_Specified := True;
end;

function USERCONTENT.USERID_Specified(Index: Integer): boolean;
begin
  Result := FUSERID_Specified;
end;

procedure USERCONTENT.SetUSERTYPE(Index: Integer; const AUSERTYPE: USERTYPE);
begin
  FUSERTYPE := AUSERTYPE;
  FUSERTYPE_Specified := True;
end;

function USERCONTENT.USERTYPE_Specified(Index: Integer): boolean;
begin
  Result := FUSERTYPE_Specified;
end;

procedure USERCONTENT.SetSIGNTYPE(Index: Integer; const ASIGNTYPE: SIGNTYPE);
begin
  FSIGNTYPE := ASIGNTYPE;
  FSIGNTYPE_Specified := True;
end;

function USERCONTENT.SIGNTYPE_Specified(Index: Integer): boolean;
begin
  Result := FSIGNTYPE_Specified;
end;

procedure USERCONTENT.SetTYPE_(Index: Integer; const AUSERCONTENTTYPE: USERCONTENTTYPE);
begin
  FTYPE_ := AUSERCONTENTTYPE;
  FTYPE__Specified := True;
end;

function USERCONTENT.TYPE__Specified(Index: Integer): boolean;
begin
  Result := FTYPE__Specified;
end;

constructor LoginResponse2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor LoginResponse2.Destroy;
begin
  SysUtils.FreeAndNil(FREQUEST_RETURN);
  inherited Destroy;
end;

procedure LoginResponse2.SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
begin
  FREQUEST_RETURN := AREQUEST_RETURNType;
  FREQUEST_RETURN_Specified := True;
end;

function LoginResponse2.REQUEST_RETURN_Specified(Index: Integer): boolean;
begin
  Result := FREQUEST_RETURN_Specified;
end;

constructor LogoutRequest2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

constructor LogoutResponse2.Create;
begin
  inherited Create;
  FSerializationOptions := [xoLiteralParam];
end;

destructor LogoutResponse2.Destroy;
begin
  SysUtils.FreeAndNil(FREQUEST_RETURN);
  inherited Destroy;
end;

procedure LogoutResponse2.SetREQUEST_RETURN(Index: Integer; const AREQUEST_RETURNType: REQUEST_RETURNType);
begin
  FREQUEST_RETURN := AREQUEST_RETURNType;
  FREQUEST_RETURN_Specified := True;
end;

function LogoutResponse2.REQUEST_RETURN_Specified(Index: Integer): boolean;
begin
  Result := FREQUEST_RETURN_Specified;
end;

procedure Initialize22;
begin
  InvRegistry.RegisterInterface(TypeInfo(EFaturaOIBPort), 'http://schemas.i2i.com/ei/wsdl', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(EFaturaOIBPort), '');
  InvRegistry.RegisterInvokeOptions(TypeInfo(EFaturaOIBPort), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(EFaturaOIBPort), ioLiteral);
  RemClassRegistry.RegisterXSClass(SendInvoiceResponseWithServerSignResponse2, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponseWithServerSignResponse2', 'SendInvoiceResponseWithServerSignResponse');
  RemClassRegistry.RegisterSerializeOptions(SendInvoiceResponseWithServerSignResponse2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetUserListResponse2), 'http://schemas.i2i.com/ei/wsdl', 'GetUserListResponse2', 'GetUserListResponse');
  RemClassRegistry.RegisterSerializeOptions(TypeInfo(GetUserListResponse2), [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(PrepareInvoiceResponseResponse2), 'http://schemas.i2i.com/ei/wsdl', 'PrepareInvoiceResponseResponse2', 'PrepareInvoiceResponseResponse');
  RemClassRegistry.RegisterSerializeOptions(TypeInfo(PrepareInvoiceResponseResponse2), [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(SendInvoiceResponseResponse2, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponseResponse2', 'SendInvoiceResponseResponse');
  RemClassRegistry.RegisterSerializeOptions(SendInvoiceResponseResponse2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(LoadInvoiceResponse2, 'http://schemas.i2i.com/ei/wsdl', 'LoadInvoiceResponse2', 'LoadInvoiceResponse');
  RemClassRegistry.RegisterSerializeOptions(LoadInvoiceResponse2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(GetInvoiceStatusResponse2, 'http://schemas.i2i.com/ei/wsdl', 'GetInvoiceStatusResponse2', 'GetInvoiceStatusResponse');
  RemClassRegistry.RegisterSerializeOptions(GetInvoiceStatusResponse2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(CheckUserResponse2), 'http://schemas.i2i.com/ei/wsdl', 'CheckUserResponse2', 'CheckUserResponse');
  RemClassRegistry.RegisterSerializeOptions(TypeInfo(CheckUserResponse2), [xoLiteralParam]);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetUserListResponse), 'http://schemas.i2i.com/ei/wsdl', 'GetUserListResponse');
  RemClassRegistry.RegisterXSClass(SendInvoiceResponseWithServerSignResponse, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponseWithServerSignResponse');
  RemClassRegistry.RegisterXSClass(SendInvoiceResponseResponse, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponseResponse');
  RemClassRegistry.RegisterXSClass(LoadInvoiceResponse, 'http://schemas.i2i.com/ei/wsdl', 'LoadInvoiceResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_ATTRIBUTESTYPE), 'http://schemas.i2i.com/ei/common', 'Array_Of_ATTRIBUTESTYPE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(CheckUserResponse), 'http://schemas.i2i.com/ei/wsdl', 'CheckUserResponse');
  RemClassRegistry.RegisterXSClass(GetInvoiceStatusResponse, 'http://schemas.i2i.com/ei/wsdl', 'GetInvoiceStatusResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(BinaryObjectMimeCodeContentType), 'urn:un:unece:uncefact:codelist:specification:IANAMIMEMediaType:2003', 'BinaryObjectMimeCodeContentType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_CSTAdata_xml', 'application/CSTAdata+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_EDI_Consent', 'application/EDI-Consent');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_EDI_X12', 'application/EDI-X12');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_EDIFACT', 'application/EDIFACT');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_activemessage', 'application/activemessage');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_andrew_inset', 'application/andrew-inset');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_applefile', 'application/applefile');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_atomicmail', 'application/atomicmail');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_batch_SMTP', 'application/batch-SMTP');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_beep_xml', 'application/beep+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_cals_1840', 'application/cals-1840');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_cnrp_xml', 'application/cnrp+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_commonground', 'application/commonground');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_cpl_xml', 'application/cpl+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_csta_xml', 'application/csta+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_cybercash', 'application/cybercash');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_dca_rft', 'application/dca-rft');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_dec_dx', 'application/dec-dx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_dialog_info_xml', 'application/dialog-info+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_dicom', 'application/dicom');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_dns', 'application/dns');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_dvcs', 'application/dvcs');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_epp_xml', 'application/epp+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_eshop', 'application/eshop');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_fits', 'application/fits');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_font_tdpfr', 'application/font-tdpfr');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_http', 'application/http');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_hyperstudio', 'application/hyperstudio');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_iges', 'application/iges');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_im_iscomposing_xml', 'application/im-iscomposing+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_index', 'application/index');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_index_cmd', 'application/index.cmd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_index_obj', 'application/index.obj');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_index_response', 'application/index.response');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_index_vnd', 'application/index.vnd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_iotp', 'application/iotp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_ipp', 'application/ipp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_isup', 'application/isup');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_kpml_request_xml', 'application/kpml-request+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_kpml_response_xml', 'application/kpml-response+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_mac_binhex40', 'application/mac-binhex40');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_macwriteii', 'application/macwriteii');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_marc', 'application/marc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_mathematica', 'application/mathematica');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_mbox', 'application/mbox');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_mikey', 'application/mikey');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_mpeg4_generic', 'application/mpeg4-generic');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_msword', 'application/msword');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_news_message_id', 'application/news-message-id');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_news_transmission', 'application/news-transmission');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_ocsp_request', 'application/ocsp-request');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_ocsp_response', 'application/ocsp-response');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_octet_stream', 'application/octet-stream');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_oda', 'application/oda');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_ogg', 'application/ogg');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_parityfec', 'application/parityfec');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pdf', 'application/pdf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pgp_encrypted', 'application/pgp-encrypted');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pgp_keys', 'application/pgp-keys');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pgp_signature', 'application/pgp-signature');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pidf_xml', 'application/pidf+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pkcs10', 'application/pkcs10');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pkcs7_mime', 'application/pkcs7-mime');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pkcs7_signature', 'application/pkcs7-signature');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pkix_cert', 'application/pkix-cert');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pkix_crl', 'application/pkix-crl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pkix_pkipath', 'application/pkix-pkipath');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_pkixcmp', 'application/pkixcmp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_postscript', 'application/postscript');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_prs_alvestrand_titrax_sheet', 'application/prs.alvestrand.titrax-sheet');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_prs_cww', 'application/prs.cww');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_prs_nprend', 'application/prs.nprend');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_prs_plucker', 'application/prs.plucker');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_qsig', 'application/qsig');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_rdf_xml', 'application/rdf+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_reginfo_xml', 'application/reginfo+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_remote_printing', 'application/remote-printing');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_resource_lists_xml', 'application/resource-lists+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_riscos', 'application/riscos');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_rls_services_xml', 'application/rls-services+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_rtf', 'application/rtf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_samlassertion_xml', 'application/samlassertion+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_samlmetadata_xml', 'application/samlmetadata+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_sbml_xml', 'application/sbml+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_sdp', 'application/sdp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_set_payment', 'application/set-payment');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_set_payment_initiation', 'application/set-payment-initiation');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_set_registration', 'application/set-registration');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_set_registration_initiation', 'application/set-registration-initiation');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_sgml', 'application/sgml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_sgml_open_catalog', 'application/sgml-open-catalog');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_shf_xml', 'application/shf+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_sieve', 'application/sieve');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_simple_filter_xml', 'application/simple-filter+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_simple_message_summary', 'application/simple-message-summary');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_slate', 'application/slate');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_soap_xml', 'application/soap+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_spirits_event_xml', 'application/spirits-event+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_timestamp_query', 'application/timestamp-query');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_timestamp_reply', 'application/timestamp-reply');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_tve_trigger', 'application/tve-trigger');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vemmi', 'application/vemmi');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_3M_Post_it_Notes', 'application/vnd.3M.Post-it-Notes');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_3gpp_pic_bw_large', 'application/vnd.3gpp.pic-bw-large');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_3gpp_pic_bw_small', 'application/vnd.3gpp.pic-bw-small');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_3gpp_pic_bw_var', 'application/vnd.3gpp.pic-bw-var');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_3gpp_sms', 'application/vnd.3gpp.sms');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_FloGraphIt', 'application/vnd.FloGraphIt');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Kinar', 'application/vnd.Kinar');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Mobius_DAF', 'application/vnd.Mobius.DAF');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Mobius_DIS', 'application/vnd.Mobius.DIS');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Mobius_MBK', 'application/vnd.Mobius.MBK');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Mobius_MQY', 'application/vnd.Mobius.MQY');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Mobius_MSL', 'application/vnd.Mobius.MSL');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Mobius_PLC', 'application/vnd.Mobius.PLC');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Mobius_TXF', 'application/vnd.Mobius.TXF');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_Quark_QuarkXPress', 'application/vnd.Quark.QuarkXPress');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_RenLearn_rlprint', 'application/vnd.RenLearn.rlprint');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_accpac_simply_aso', 'application/vnd.accpac.simply.aso');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_accpac_simply_imp', 'application/vnd.accpac.simply.imp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_acucobol', 'application/vnd.acucobol');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_acucorp', 'application/vnd.acucorp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_adobe_xfdf', 'application/vnd.adobe.xfdf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_aether_imp', 'application/vnd.aether.imp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_amiga_ami', 'application/vnd.amiga.ami');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_anser_web_certificate_issue_initiation', 'application/vnd.anser-web-certificate-issue-initiation');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_anser_web_funds_transfer_initiation', 'application/vnd.anser-web-funds-transfer-initiation');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_audiograph', 'application/vnd.audiograph');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_blueice_multipass', 'application/vnd.blueice.multipass');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_bmi', 'application/vnd.bmi');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_businessobjects', 'application/vnd.businessobjects');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_canon_cpdl', 'application/vnd.canon-cpdl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_canon_lips', 'application/vnd.canon-lips');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_cinderella', 'application/vnd.cinderella');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_claymore', 'application/vnd.claymore');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_commerce_battelle', 'application/vnd.commerce-battelle');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_commonspace', 'application/vnd.commonspace');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_contact_cmsg', 'application/vnd.contact.cmsg');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_cosmocaller', 'application/vnd.cosmocaller');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_criticaltools_wbs_xml', 'application/vnd.criticaltools.wbs+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ctc_posml', 'application/vnd.ctc-posml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_cups_postscript', 'application/vnd.cups-postscript');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_cups_raster', 'application/vnd.cups-raster');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_cups_raw', 'application/vnd.cups-raw');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_curl', 'application/vnd.curl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_cybank', 'application/vnd.cybank');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_data_vision_rdz', 'application/vnd.data-vision.rdz');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_dna', 'application/vnd.dna');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_dpgraph', 'application/vnd.dpgraph');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_dreamfactory', 'application/vnd.dreamfactory');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_dxr', 'application/vnd.dxr');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ecdis_update', 'application/vnd.ecdis-update');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ecowin_chart', 'application/vnd.ecowin.chart');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ecowin_filerequest', 'application/vnd.ecowin.filerequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ecowin_fileupdate', 'application/vnd.ecowin.fileupdate');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ecowin_series', 'application/vnd.ecowin.series');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ecowin_seriesrequest', 'application/vnd.ecowin.seriesrequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ecowin_seriesupdate', 'application/vnd.ecowin.seriesupdate');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_enliven', 'application/vnd.enliven');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_epson_esf', 'application/vnd.epson.esf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_epson_msf', 'application/vnd.epson.msf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_epson_quickanime', 'application/vnd.epson.quickanime');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_epson_salt', 'application/vnd.epson.salt');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_epson_ssf', 'application/vnd.epson.ssf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ericsson_quickcall', 'application/vnd.ericsson.quickcall');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_eudora_data', 'application/vnd.eudora.data');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fdf', 'application/vnd.fdf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ffsns', 'application/vnd.ffsns');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fints', 'application/vnd.fints');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_framemaker', 'application/vnd.framemaker');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fsc_weblaunch', 'application/vnd.fsc.weblaunch');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fujitsu_oasys', 'application/vnd.fujitsu.oasys');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fujitsu_oasys2', 'application/vnd.fujitsu.oasys2');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fujitsu_oasys3', 'application/vnd.fujitsu.oasys3');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fujitsu_oasysgp', 'application/vnd.fujitsu.oasysgp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fujitsu_oasysprs', 'application/vnd.fujitsu.oasysprs');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fujixerox_ddd', 'application/vnd.fujixerox.ddd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fujixerox_docuworks', 'application/vnd.fujixerox.docuworks');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fujixerox_docuworks_binder', 'application/vnd.fujixerox.docuworks.binder');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_fut_misnet', 'application/vnd.fut-misnet');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_genomatix_tuxedo', 'application/vnd.genomatix.tuxedo');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_grafeq', 'application/vnd.grafeq');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_groove_account', 'application/vnd.groove-account');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_groove_help', 'application/vnd.groove-help');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_groove_identity_message', 'application/vnd.groove-identity-message');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_groove_injector', 'application/vnd.groove-injector');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_groove_tool_message', 'application/vnd.groove-tool-message');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_groove_tool_template', 'application/vnd.groove-tool-template');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_groove_vcard', 'application/vnd.groove-vcard');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hbci', 'application/vnd.hbci');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hcl_bireports', 'application/vnd.hcl-bireports');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hhe_lesson_player', 'application/vnd.hhe.lesson-player');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hp_HPGL', 'application/vnd.hp-HPGL');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hp_PCL', 'application/vnd.hp-PCL');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hp_PCLXL', 'application/vnd.hp-PCLXL');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hp_hpid', 'application/vnd.hp-hpid');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hp_hps', 'application/vnd.hp-hps');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_httphone', 'application/vnd.httphone');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_hzn_3d_crossword', 'application/vnd.hzn-3d-crossword');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ibm_MiniPay', 'application/vnd.ibm.MiniPay');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ibm_afplinedata', 'application/vnd.ibm.afplinedata');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ibm_electronic_media', 'application/vnd.ibm.electronic-media');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ibm_modcap', 'application/vnd.ibm.modcap');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ibm_rights_management', 'application/vnd.ibm.rights-management');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ibm_secure_container', 'application/vnd.ibm.secure-container');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_informix_visionary', 'application/vnd.informix-visionary');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_intercon_formnet', 'application/vnd.intercon.formnet');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_intertrust_digibox', 'application/vnd.intertrust.digibox');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_intertrust_nncp', 'application/vnd.intertrust.nncp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_intu_qbo', 'application/vnd.intu.qbo');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_intu_qfx', 'application/vnd.intu.qfx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ipunplugged_rcprofile', 'application/vnd.ipunplugged.rcprofile');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_irepository_package_xml', 'application/vnd.irepository.package+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_is_xpr', 'application/vnd.is-xpr');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_japannet_directory_service', 'application/vnd.japannet-directory-service');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_japannet_jpnstore_wakeup', 'application/vnd.japannet-jpnstore-wakeup');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_japannet_payment_wakeup', 'application/vnd.japannet-payment-wakeup');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_japannet_registration', 'application/vnd.japannet-registration');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_japannet_registration_wakeup', 'application/vnd.japannet-registration-wakeup');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_japannet_setstore_wakeup', 'application/vnd.japannet-setstore-wakeup');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_japannet_verification', 'application/vnd.japannet-verification');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_japannet_verification_wakeup', 'application/vnd.japannet-verification-wakeup');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_jisp', 'application/vnd.jisp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kde_karbon', 'application/vnd.kde.karbon');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kde_kchart', 'application/vnd.kde.kchart');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kde_kformula', 'application/vnd.kde.kformula');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kde_kivio', 'application/vnd.kde.kivio');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kde_kontour', 'application/vnd.kde.kontour');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kde_kpresenter', 'application/vnd.kde.kpresenter');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kde_kspread', 'application/vnd.kde.kspread');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kde_kword', 'application/vnd.kde.kword');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kenameaapp', 'application/vnd.kenameaapp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_kidspiration', 'application/vnd.kidspiration');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_koan', 'application/vnd.koan');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_liberty_request_xml', 'application/vnd.liberty-request+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_llamagraphics_life_balance_desktop', 'application/vnd.llamagraphics.life-balance.desktop');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_llamagraphics_life_balance_exchange_xml', 'application/vnd.llamagraphics.life-balance.exchange+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_lotus_1_2_3', 'application/vnd.lotus-1-2-3');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_lotus_approach', 'application/vnd.lotus-approach');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_lotus_freelance', 'application/vnd.lotus-freelance');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_lotus_notes', 'application/vnd.lotus-notes');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_lotus_organizer', 'application/vnd.lotus-organizer');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_lotus_screencam', 'application/vnd.lotus-screencam');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_lotus_wordpro', 'application/vnd.lotus-wordpro');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mcd', 'application/vnd.mcd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mediastation_cdkey', 'application/vnd.mediastation.cdkey');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_meridian_slingshot', 'application/vnd.meridian-slingshot');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mfmp', 'application/vnd.mfmp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_micrografx_flo', 'application/vnd.micrografx.flo');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_micrografx_igx', 'application/vnd.micrografx.igx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mif', 'application/vnd.mif');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_minisoft_hp3000_save', 'application/vnd.minisoft-hp3000-save');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mitsubishi_misty_guard_trustweb', 'application/vnd.mitsubishi.misty-guard.trustweb');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mophun_application', 'application/vnd.mophun.application');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mophun_certificate', 'application/vnd.mophun.certificate');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_motorola_flexsuite', 'application/vnd.motorola.flexsuite');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_motorola_flexsuite_adsi', 'application/vnd.motorola.flexsuite.adsi');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_motorola_flexsuite_fis', 'application/vnd.motorola.flexsuite.fis');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_motorola_flexsuite_gotap', 'application/vnd.motorola.flexsuite.gotap');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_motorola_flexsuite_kmr', 'application/vnd.motorola.flexsuite.kmr');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_motorola_flexsuite_ttc', 'application/vnd.motorola.flexsuite.ttc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_motorola_flexsuite_wem', 'application/vnd.motorola.flexsuite.wem');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mozilla_xul_xml', 'application/vnd.mozilla.xul+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_artgalry', 'application/vnd.ms-artgalry');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_asf', 'application/vnd.ms-asf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_excel', 'application/vnd.ms-excel');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_lrm', 'application/vnd.ms-lrm');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_powerpoint', 'application/vnd.ms-powerpoint');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_project', 'application/vnd.ms-project');
end;

initialization
  { EFaturaOIBPort }
  Initialize22;
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_tnef', 'application/vnd.ms-tnef');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_works', 'application/vnd.ms-works');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ms_wpl', 'application/vnd.ms-wpl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_mseq', 'application/vnd.mseq');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_msign', 'application/vnd.msign');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_music_niff', 'application/vnd.music-niff');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_musician', 'application/vnd.musician');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_nervana', 'application/vnd.nervana');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_netfpx', 'application/vnd.netfpx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_noblenet_directory', 'application/vnd.noblenet-directory');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_noblenet_sealer', 'application/vnd.noblenet-sealer');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_noblenet_web', 'application/vnd.noblenet-web');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_nokia_landmark_wbxml', 'application/vnd.nokia.landmark+wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_nokia_landmark_xml', 'application/vnd.nokia.landmark+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_nokia_landmarkcollection_xml', 'application/vnd.nokia.landmarkcollection+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_nokia_radio_preset', 'application/vnd.nokia.radio-preset');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_nokia_radio_presets', 'application/vnd.nokia.radio-presets');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_novadigm_EDM', 'application/vnd.novadigm.EDM');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_novadigm_EDX', 'application/vnd.novadigm.EDX');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_novadigm_EXT', 'application/vnd.novadigm.EXT');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_obn', 'application/vnd.obn');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_omads_email_xml', 'application/vnd.omads-email+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_omads_file_xml', 'application/vnd.omads-file+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_omads_folder_xml', 'application/vnd.omads-folder+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_osa_netdeploy', 'application/vnd.osa.netdeploy');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_palm', 'application/vnd.palm');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_paos_xml', 'application/vnd.paos.xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_pg_format', 'application/vnd.pg.format');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_pg_osasli', 'application/vnd.pg.osasli');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_picsel', 'application/vnd.picsel');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_powerbuilder6', 'application/vnd.powerbuilder6');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_powerbuilder6_s', 'application/vnd.powerbuilder6-s');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_powerbuilder7', 'application/vnd.powerbuilder7');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_powerbuilder7_s', 'application/vnd.powerbuilder7-s');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_powerbuilder75', 'application/vnd.powerbuilder75');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_powerbuilder75_s', 'application/vnd.powerbuilder75-s');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_previewsystems_box', 'application/vnd.previewsystems.box');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_publishare_delta_tree', 'application/vnd.publishare-delta-tree');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_pvi_ptid1', 'application/vnd.pvi.ptid1');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_pwg_multiplexed', 'application/vnd.pwg-multiplexed');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_pwg_xhtml_print_xml', 'application/vnd.pwg-xhtml-print+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_rapid', 'application/vnd.rapid');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_s3sms', 'application/vnd.s3sms');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sealed_doc', 'application/vnd.sealed.doc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sealed_eml', 'application/vnd.sealed.eml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sealed_mht', 'application/vnd.sealed.mht');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sealed_net', 'application/vnd.sealed.net');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sealed_ppt', 'application/vnd.sealed.ppt');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sealed_xls', 'application/vnd.sealed.xls');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sealedmedia_softseal_html', 'application/vnd.sealedmedia.softseal.html');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sealedmedia_softseal_pdf', 'application/vnd.sealedmedia.softseal.pdf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_seemail', 'application/vnd.seemail');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_shana_informed_formdata', 'application/vnd.shana.informed.formdata');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_shana_informed_formtemplate', 'application/vnd.shana.informed.formtemplate');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_shana_informed_interchange', 'application/vnd.shana.informed.interchange');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_shana_informed_package', 'application/vnd.shana.informed.package');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_smaf', 'application/vnd.smaf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sss_cod', 'application/vnd.sss-cod');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sss_dtf', 'application/vnd.sss-dtf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sss_ntf', 'application/vnd.sss-ntf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_street_stream', 'application/vnd.street-stream');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_sus_calendar', 'application/vnd.sus-calendar');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_svd', 'application/vnd.svd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_swiftview_ics', 'application/vnd.swiftview-ics');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_syncml__xml', 'application/vnd.syncml.+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_syncml_ds_notification', 'application/vnd.syncml.ds.notification');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_triscape_mxs', 'application/vnd.triscape.mxs');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_trueapp', 'application/vnd.trueapp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_truedoc', 'application/vnd.truedoc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_ufdl', 'application/vnd.ufdl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uiq_theme', 'application/vnd.uiq.theme');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_alert', 'application/vnd.uplanet.alert');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_alert_wbxml', 'application/vnd.uplanet.alert-wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_bearer_choice', 'application/vnd.uplanet.bearer-choice');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_bearer_choice_wbxml', 'application/vnd.uplanet.bearer-choice-wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_cacheop', 'application/vnd.uplanet.cacheop');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_cacheop_wbxml', 'application/vnd.uplanet.cacheop-wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_channel', 'application/vnd.uplanet.channel');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_channel_wbxml', 'application/vnd.uplanet.channel-wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_list', 'application/vnd.uplanet.list');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_list_wbxml', 'application/vnd.uplanet.list-wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_listcmd', 'application/vnd.uplanet.listcmd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_listcmd_wbxml', 'application/vnd.uplanet.listcmd-wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_uplanet_signal', 'application/vnd.uplanet.signal');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_vcx', 'application/vnd.vcx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_vectorworks', 'application/vnd.vectorworks');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_vidsoft_vidconference', 'application/vnd.vidsoft.vidconference');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_visio', 'application/vnd.visio');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_visionary', 'application/vnd.visionary');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_vividence_scriptfile', 'application/vnd.vividence.scriptfile');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_vsf', 'application/vnd.vsf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wap_sic', 'application/vnd.wap.sic');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wap_slc', 'application/vnd.wap.slc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wap_wbxml', 'application/vnd.wap.wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wap_wmlc', 'application/vnd.wap.wmlc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wap_wmlscriptc', 'application/vnd.wap.wmlscriptc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_webturbo', 'application/vnd.webturbo');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wordperfect', 'application/vnd.wordperfect');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wqd', 'application/vnd.wqd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wrq_hp3000_labelled', 'application/vnd.wrq-hp3000-labelled');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wt_stf', 'application/vnd.wt.stf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wv_csp_wbxml', 'application/vnd.wv.csp+wbxml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wv_csp_xml', 'application/vnd.wv.csp+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_wv_ssp_xml', 'application/vnd.wv.ssp+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_xara', 'application/vnd.xara');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_xfdl', 'application/vnd.xfdl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_yamaha_hv_dic', 'application/vnd.yamaha.hv-dic');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_yamaha_hv_script', 'application/vnd.yamaha.hv-script');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_yamaha_hv_voice', 'application/vnd.yamaha.hv-voice');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_yamaha_smaf_audio', 'application/vnd.yamaha.smaf-audio');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_yamaha_smaf_phrase', 'application/vnd.yamaha.smaf-phrase');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_vnd_yellowriver_custom_menu', 'application/vnd.yellowriver-custom-menu');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_watcherinfo_xml', 'application/watcherinfo+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_whoispp_query', 'application/whoispp-query');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_whoispp_response', 'application/whoispp-response');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_wita', 'application/wita');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_wordperfect5_1', 'application/wordperfect5.1');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_x400_bp', 'application/x400-bp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_xhtml_xml', 'application/xhtml+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_xml', 'application/xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_xml_dtd', 'application/xml-dtd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_xml_external_parsed_entity', 'application/xml-external-parsed-entity');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_xmpp_xml', 'application/xmpp+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_xop_xml', 'application/xop+xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'application_zip', 'application/zip');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_32kadpcm', 'audio/32kadpcm');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_3gpp', 'audio/3gpp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_AMR', 'audio/AMR');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_AMR_WB', 'audio/AMR-WB');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_BV16', 'audio/BV16');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_BV32', 'audio/BV32');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_CN', 'audio/CN');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_DAT12', 'audio/DAT12');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_DVI4', 'audio/DVI4');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_EVRC', 'audio/EVRC');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_EVRC_QCP', 'audio/EVRC-QCP');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_EVRC0', 'audio/EVRC0');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G_722_1', 'audio/G.722.1');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G722', 'audio/G722');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G723', 'audio/G723');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G726_16', 'audio/G726-16');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G726_24', 'audio/G726-24');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G726_32', 'audio/G726-32');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G726_40', 'audio/G726-40');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G728', 'audio/G728');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G729', 'audio/G729');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G729D', 'audio/G729D');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_G729E', 'audio/G729E');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_GSM', 'audio/GSM');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_GSM_EFR', 'audio/GSM-EFR');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_L16', 'audio/L16');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_L20', 'audio/L20');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_L24', 'audio/L24');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_L8', 'audio/L8');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_LPC', 'audio/LPC');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_MP4A_LATM', 'audio/MP4A-LATM');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_MPA', 'audio/MPA');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_PCMA', 'audio/PCMA');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_PCMU', 'audio/PCMU');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_QCELP', 'audio/QCELP');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_RED', 'audio/RED');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_SMV', 'audio/SMV');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_SMV_QCP', 'audio/SMV-QCP');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_SMV0', 'audio/SMV0');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_VDVI', 'audio/VDVI');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_basic', 'audio/basic');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_clearmode', 'audio/clearmode');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_dsr_es201108', 'audio/dsr-es201108');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_dsr_es202050', 'audio/dsr-es202050');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_dsr_es202211', 'audio/dsr-es202211');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_dsr_es202212', 'audio/dsr-es202212');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_iLBC', 'audio/iLBC');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_mpa_robust', 'audio/mpa-robust');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_mpeg', 'audio/mpeg');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_mpeg4_generic', 'audio/mpeg4-generic');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_parityfec', 'audio/parityfec');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_prs_sid', 'audio/prs.sid');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_telephone_event', 'audio/telephone-event');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_tone', 'audio/tone');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_3gpp_iufp', 'audio/vnd.3gpp.iufp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_audiokoz', 'audio/vnd.audiokoz');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_cisco_nse', 'audio/vnd.cisco.nse');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_cns_anp1', 'audio/vnd.cns.anp1');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_cns_inf1', 'audio/vnd.cns.inf1');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_digital_winds', 'audio/vnd.digital-winds');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_everad_plj', 'audio/vnd.everad.plj');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_lucent_voice', 'audio/vnd.lucent.voice');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_nokia_mobile_xmf', 'audio/vnd.nokia.mobile-xmf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_nortel_vbk', 'audio/vnd.nortel.vbk');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_nuera_ecelp4800', 'audio/vnd.nuera.ecelp4800');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_nuera_ecelp7470', 'audio/vnd.nuera.ecelp7470');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_nuera_ecelp9600', 'audio/vnd.nuera.ecelp9600');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_octel_sbc', 'audio/vnd.octel.sbc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_qcelp', 'audio/vnd.qcelp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_rhetorex_32kadpcm', 'audio/vnd.rhetorex.32kadpcm');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_sealedmedia_softseal_mpeg', 'audio/vnd.sealedmedia.softseal.mpeg');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'audio_vnd_vmx_cvsd', 'audio/vnd.vmx.cvsd');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_cgm', 'image/cgm');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_fits', 'image/fits');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_g3fax', 'image/g3fax');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_gif', 'image/gif');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_ief', 'image/ief');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_jp2', 'image/jp2');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_jpeg', 'image/jpeg');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_jpm', 'image/jpm');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_jpx', 'image/jpx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_naplps', 'image/naplps');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_png', 'image/png');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_prs_btif', 'image/prs.btif');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_prs_pti', 'image/prs.pti');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_t38', 'image/t38');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_tiff', 'image/tiff');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_tiff_fx', 'image/tiff-fx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_cns_inf2', 'image/vnd.cns.inf2');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_djvu', 'image/vnd.djvu');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_dwg', 'image/vnd.dwg');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_dxf', 'image/vnd.dxf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_fastbidsheet', 'image/vnd.fastbidsheet');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_fpx', 'image/vnd.fpx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_fst', 'image/vnd.fst');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_fujixerox_edmics_mmr', 'image/vnd.fujixerox.edmics-mmr');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_fujixerox_edmics_rlc', 'image/vnd.fujixerox.edmics-rlc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_globalgraphics_pgb', 'image/vnd.globalgraphics.pgb');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_microsoft_icon', 'image/vnd.microsoft.icon');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_mix', 'image/vnd.mix');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_ms_modi', 'image/vnd.ms-modi');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_net_fpx', 'image/vnd.net-fpx');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_sealed_png', 'image/vnd.sealed.png');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_sealedmedia_softseal_gif', 'image/vnd.sealedmedia.softseal.gif');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_sealedmedia_softseal_jpg', 'image/vnd.sealedmedia.softseal.jpg');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_svf', 'image/vnd.svf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_wap_wbmp', 'image/vnd.wap.wbmp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'image_vnd_xiff', 'image/vnd.xiff');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_CPIM', 'message/CPIM');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_delivery_status', 'message/delivery-status');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_disposition_notification', 'message/disposition-notification');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_external_body', 'message/external-body');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_http', 'message/http');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_news', 'message/news');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_partial', 'message/partial');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_rfc822', 'message/rfc822');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_s_http', 'message/s-http');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_sip', 'message/sip');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_sipfrag', 'message/sipfrag');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'message_tracking_status', 'message/tracking-status');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_iges', 'model/iges');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_mesh', 'model/mesh');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_dwf', 'model/vnd.dwf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_flatland_3dml', 'model/vnd.flatland.3dml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_gdl', 'model/vnd.gdl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_gs_gdl', 'model/vnd.gs-gdl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_gtw', 'model/vnd.gtw');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_mts', 'model/vnd.mts');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_parasolid_transmit_binary', 'model/vnd.parasolid.transmit.binary');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_parasolid_transmit_text', 'model/vnd.parasolid.transmit.text');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vnd_vtu', 'model/vnd.vtu');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'model_vrml', 'model/vrml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_alternative', 'multipart/alternative');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_appledouble', 'multipart/appledouble');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_byteranges', 'multipart/byteranges');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_digest', 'multipart/digest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_encrypted', 'multipart/encrypted');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_form_data', 'multipart/form-data');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_header_set', 'multipart/header-set');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_mixed', 'multipart/mixed');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_parallel', 'multipart/parallel');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_related', 'multipart/related');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_report', 'multipart/report');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_signed', 'multipart/signed');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'multipart_voice_message', 'multipart/voice-message');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_RED', 'text/RED');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_calendar', 'text/calendar');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_css', 'text/css');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_csv', 'text/csv');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_directory', 'text/directory');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_dns', 'text/dns');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_enriched', 'text/enriched');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_html', 'text/html');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_parityfec', 'text/parityfec');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_plain', 'text/plain');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_prs_fallenstein_rst', 'text/prs.fallenstein.rst');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_prs_lines_tag', 'text/prs.lines.tag');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_rfc822_headers', 'text/rfc822-headers');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_richtext', 'text/richtext');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_rtf', 'text/rtf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_sgml', 'text/sgml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_t140', 'text/t140');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_tab_separated_values', 'text/tab-separated-values');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_troff', 'text/troff');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_uri_list', 'text/uri-list');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_DMClientScript', 'text/vnd.DMClientScript');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_IPTC_NITF', 'text/vnd.IPTC.NITF');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_IPTC_NewsML', 'text/vnd.IPTC.NewsML');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_abc', 'text/vnd.abc');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_curl', 'text/vnd.curl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_esmertec_theme_descriptor', 'text/vnd.esmertec.theme-descriptor');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_fly', 'text/vnd.fly');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_fmi_flexstor', 'text/vnd.fmi.flexstor');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_in3d_3dml', 'text/vnd.in3d.3dml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_in3d_spot', 'text/vnd.in3d.spot');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_latex_z', 'text/vnd.latex-z');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_motorola_reflex', 'text/vnd.motorola.reflex');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_ms_mediapackage', 'text/vnd.ms-mediapackage');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_net2phone_commcenter_command', 'text/vnd.net2phone.commcenter.command');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_sun_j2me_app_descriptor', 'text/vnd.sun.j2me.app-descriptor');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_wap_si', 'text/vnd.wap.si');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_wap_sl', 'text/vnd.wap.sl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_wap_wml', 'text/vnd.wap.wml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_vnd_wap_wmlscript', 'text/vnd.wap.wmlscript');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_xml', 'text/xml');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'text_xml_external_parsed_entity', 'text/xml-external-parsed-entity');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_3gpp', 'video/3gpp');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_BMPEG', 'video/BMPEG');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_BT656', 'video/BT656');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_CelB', 'video/CelB');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_DV', 'video/DV');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_H261', 'video/H261');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_H263', 'video/H263');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_H263_1998', 'video/H263-1998');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_H263_2000', 'video/H263-2000');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_H264', 'video/H264');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_JPEG', 'video/JPEG');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_MJ2', 'video/MJ2');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_MP1S', 'video/MP1S');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_MP2P', 'video/MP2P');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_MP2T', 'video/MP2T');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_MP4V_ES', 'video/MP4V-ES');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_MPV', 'video/MPV');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_SMPTE292M', 'video/SMPTE292M');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_mpeg', 'video/mpeg');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_mpeg4_generic', 'video/mpeg4-generic');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_nv', 'video/nv');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_parityfec', 'video/parityfec');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_pointer', 'video/pointer');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_quicktime', 'video/quicktime');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_raw', 'video/raw');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_fvt', 'video/vnd.fvt');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_motorola_video', 'video/vnd.motorola.video');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_motorola_videop', 'video/vnd.motorola.videop');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_mpegurl', 'video/vnd.mpegurl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_nokia_interleaved_multimedia', 'video/vnd.nokia.interleaved-multimedia');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_objectvideo', 'video/vnd.objectvideo');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_sealed_mpeg1', 'video/vnd.sealed.mpeg1');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_sealed_mpeg4', 'video/vnd.sealed.mpeg4');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_sealed_swf', 'video/vnd.sealed.swf');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_sealedmedia_softseal_mov', 'video/vnd.sealedmedia.softseal.mov');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectMimeCodeContentType), 'video_vnd_vivo', 'video/vnd.vivo');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UnitCodeContentType), 'urn:un:unece:uncefact:codelist:specification:66411:2001', 'UnitCodeContentType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_04', '04');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_05', '05');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_08', '08');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_10', '10');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_11', '11');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_13', '13');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_14', '14');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_15', '15');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_16', '16');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_17', '17');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_18', '18');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_19', '19');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_20', '20');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_21', '21');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_22', '22');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_23', '23');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_24', '24');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_25', '25');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_26', '26');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_27', '27');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_28', '28');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_29', '29');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_30', '30');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_31', '31');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_32', '32');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_33', '33');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_34', '34');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_35', '35');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_36', '36');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_37', '37');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_38', '38');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_40', '40');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_41', '41');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_43', '43');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_44', '44');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_45', '45');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_46', '46');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_47', '47');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_48', '48');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_53', '53');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_54', '54');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_56', '56');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_57', '57');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_58', '58');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_59', '59');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_60', '60');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_61', '61');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_62', '62');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_63', '63');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_64', '64');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_66', '66');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_69', '69');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_71', '71');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_72', '72');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_73', '73');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_74', '74');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_76', '76');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_77', '77');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_78', '78');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_80', '80');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_81', '81');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_84', '84');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_85', '85');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_87', '87');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_89', '89');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_90', '90');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_91', '91');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_92', '92');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_93', '93');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_94', '94');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_95', '95');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_96', '96');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_97', '97');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_98', '98');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1A', '1A');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1B', '1B');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1C', '1C');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1D', '1D');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1E', '1E');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1F', '1F');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1G', '1G');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1H', '1H');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1I', '1I');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1J', '1J');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1K', '1K');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1L', '1L');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1M', '1M');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_1X', '1X');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2A', '2A');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2B', '2B');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2C', '2C');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2I', '2I');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2J', '2J');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2K', '2K');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2L', '2L');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2M', '2M');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2N', '2N');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2P', '2P');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2Q', '2Q');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2R', '2R');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2U', '2U');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2V', '2V');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2W', '2W');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2X', '2X');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2Y', '2Y');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_2Z', '2Z');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_3B', '3B');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_3C', '3C');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_3E', '3E');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_3G', '3G');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_3H', '3H');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_3I', '3I');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4A', '4A');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4B', '4B');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4C', '4C');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4E', '4E');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4G', '4G');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4H', '4H');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4K', '4K');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4L', '4L');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4M', '4M');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4N', '4N');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4O', '4O');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4P', '4P');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4Q', '4Q');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4R', '4R');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4T', '4T');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4U', '4U');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4W', '4W');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_4X', '4X');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5A', '5A');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5B', '5B');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5C', '5C');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5E', '5E');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5F', '5F');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5G', '5G');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5H', '5H');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5I', '5I');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5J', '5J');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5K', '5K');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5P', '5P');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), '_5Q', '5Q');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), 'AS_', 'AS');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), 'ASM_', 'ASM');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), 'FAR_', 'FAR');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), 'IF_', 'IF');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), 'ON_', 'ON');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UnitCodeContentType), 'SET_', 'SET');
  RemClassRegistry.RegisterXSInfo(TypeInfo(PrepareInvoiceResponseResponse), 'http://schemas.i2i.com/ei/wsdl', 'PrepareInvoiceResponseResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(CurrencyCodeContentType), 'urn:un:unece:uncefact:codelist:specification:54217:2001', 'CurrencyCodeContentType');
  RemClassRegistry.RegisterXSClass(AmountType, 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', 'AmountType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(AmountType), 'currencyID', '[Namespace="urn:un:unece:uncefact:codelist:specification:54217:2001"]');
  RemClassRegistry.RegisterXSClass(MeasureType, 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', 'MeasureType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(MeasureType), 'unitCode', '[Namespace="urn:un:unece:uncefact:codelist:specification:66411:2001"]');
  RemClassRegistry.RegisterXSClass(IdentifierType, 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', 'IdentifierType');
  RemClassRegistry.RegisterXSClass(CHANGE_INFOType, 'http://schemas.i2i.com/ei/common', 'CHANGE_INFOType');
  RemClassRegistry.RegisterXSClass(ATTRIBUTESTYPE, 'http://schemas.i2i.com/ei/common', 'ATTRIBUTESTYPE');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ATTRIBUTESTYPE), 'NAME_', '[ExtName="NAME"]');
  RemClassRegistry.RegisterXSClass(BinaryObjectType, 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', 'BinaryObjectType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(BinaryObjectType), 'mimeCode', '[Namespace="urn:un:unece:uncefact:codelist:specification:IANAMIMEMediaType:2003"]');
  RemClassRegistry.RegisterXSClass(CodeType, 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', 'CodeType');
  RemClassRegistry.RegisterXSInfo(TypeInfo(contentType), 'http://www.w3.org/2005/05/xmlmime', 'contentType');
  RemClassRegistry.RegisterXSClass(base64Binary, 'http://www.w3.org/2005/05/xmlmime', 'base64Binary');
  RemClassRegistry.RegisterXSClass(hexBinary, 'http://www.w3.org/2005/05/xmlmime', 'hexBinary');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_string), 'http://www.w3.org/2001/XMLSchema', 'Array_Of_string');
  RemClassRegistry.RegisterXSClass(GIBUSER, 'http://schemas.i2i.com/ei/wsdl', 'GIBUSER');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(GIBUSER), 'TYPE_', '[ExtName="TYPE"]');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(GIBUSER), 'UNIT_', '[ExtName="UNIT"]');
  RemClassRegistry.RegisterXSClass(REQUEST_RETURNType, 'http://schemas.i2i.com/ei/entity', 'REQUEST_RETURNType');
  RemClassRegistry.RegisterXSClass(CancelUserResponse, 'http://schemas.i2i.com/ei/wsdl', 'CancelUserResponse');
  RemClassRegistry.RegisterXSClass(ProcessUserResponse, 'http://schemas.i2i.com/ei/wsdl', 'ProcessUserResponse');
  RemClassRegistry.RegisterXSClass(RequestFault, 'http://schemas.i2i.com/ei/wsdl', 'RequestFault');
  RemClassRegistry.RegisterXSClass(REQUEST_ERRORType, 'http://schemas.i2i.com/ei/entity', 'REQUEST_ERRORType');
  RemClassRegistry.RegisterXSClass(REQUEST, 'http://schemas.i2i.com/ei/entity', 'REQUEST');
  RemClassRegistry.RegisterXSClass(GetInvoiceStatusRequest2, 'http://schemas.i2i.com/ei/wsdl', 'GetInvoiceStatusRequest2', 'GetInvoiceStatusRequest');
  RemClassRegistry.RegisterSerializeOptions(GetInvoiceStatusRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(GetInvoiceStatusRequest, 'http://schemas.i2i.com/ei/wsdl', 'GetInvoiceStatusRequest');
  RemClassRegistry.RegisterXSClass(CheckUserRequest2, 'http://schemas.i2i.com/ei/wsdl', 'CheckUserRequest2', 'CheckUserRequest');
  RemClassRegistry.RegisterSerializeOptions(CheckUserRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(CheckUserRequest, 'http://schemas.i2i.com/ei/wsdl', 'CheckUserRequest');
  RemClassRegistry.RegisterXSClass(SendInvoiceResponseRequest2, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponseRequest2', 'SendInvoiceResponseRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(SendInvoiceResponseRequest2), 'APPRESPONSE', '[ArrayItemName="APPRESPONSE"]');
  RemClassRegistry.RegisterSerializeOptions(SendInvoiceResponseRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(SendInvoiceResponseRequest, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponseRequest');
  RemClassRegistry.RegisterXSClass(REQUEST_HEADERType, 'http://schemas.i2i.com/ei/entity', 'REQUEST_HEADERType');
  RemClassRegistry.RegisterXSClass(GetUserListRequest2, 'http://schemas.i2i.com/ei/wsdl', 'GetUserListRequest2', 'GetUserListRequest');
  RemClassRegistry.RegisterSerializeOptions(GetUserListRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(GetUserListAsCSVRequest, 'http://schemas.i2i.com/ei/wsdl', 'GetUserListAsCSVRequest');
  RemClassRegistry.RegisterXSClass(GetUserListRequest, 'http://schemas.i2i.com/ei/wsdl', 'GetUserListRequest');
  RemClassRegistry.RegisterXSClass(QuantityType, 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', 'QuantityType');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(QuantityType), 'unitCode', '[Namespace="urn:un:unece:uncefact:codelist:specification:66411:2001"]');
  RemClassRegistry.RegisterXSClass(SENDER, 'http://schemas.i2i.com/ei/wsdl', 'SENDER');
  RemClassRegistry.RegisterXSClass(RECEIVER, 'http://schemas.i2i.com/ei/wsdl', 'RECEIVER');
  RemClassRegistry.RegisterXSInfo(TypeInfo(USERCONTENTTYPE), 'http://schemas.i2i.com/ei/wsdl', 'USERCONTENTTYPE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(UserResponse), 'http://schemas.i2i.com/ei/wsdl', 'UserResponse');
  RemClassRegistry.RegisterXSClass(UserRequest, 'http://schemas.i2i.com/ei/wsdl', 'UserRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(UserRequest), 'USERCONTENT', '[ArrayItemName="USERCONTENT"]');
  RemClassRegistry.RegisterXSClass(PrepareProcessUserRequest, 'http://schemas.i2i.com/ei/wsdl', 'PrepareProcessUserRequest');
  RemClassRegistry.RegisterXSClass(CancelUserRequest, 'http://schemas.i2i.com/ei/wsdl', 'CancelUserRequest');
  RemClassRegistry.RegisterXSClass(PrepareCancelUserRequest, 'http://schemas.i2i.com/ei/wsdl', 'PrepareCancelUserRequest');
  RemClassRegistry.RegisterXSClass(ProcessUserRequest, 'http://schemas.i2i.com/ei/wsdl', 'ProcessUserRequest');
  RemClassRegistry.RegisterXSClass(SendInvoiceResponse2, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponse2', 'SendInvoiceResponse');
  RemClassRegistry.RegisterSerializeOptions(SendInvoiceResponse2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(SendInvoiceResponse, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponse');
  RemClassRegistry.RegisterXSClass(MarkInvoiceRequest2, 'http://schemas.i2i.com/ei/wsdl', 'MarkInvoiceRequest2', 'MarkInvoiceRequest');
  RemClassRegistry.RegisterSerializeOptions(MarkInvoiceRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(MarkInvoiceRequest, 'http://schemas.i2i.com/ei/wsdl', 'MarkInvoiceRequest');
  RemClassRegistry.RegisterXSClass(MarkInvoiceResponse2, 'http://schemas.i2i.com/ei/wsdl', 'MarkInvoiceResponse2', 'MarkInvoiceResponse');
  RemClassRegistry.RegisterSerializeOptions(MarkInvoiceResponse2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(MarkInvoiceResponse, 'http://schemas.i2i.com/ei/wsdl', 'MarkInvoiceResponse');
  RemClassRegistry.RegisterXSClass(GetInvoiceRequest2, 'http://schemas.i2i.com/ei/wsdl', 'GetInvoiceRequest2', 'GetInvoiceRequest');
  RemClassRegistry.RegisterSerializeOptions(GetInvoiceRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(GetInvoiceRequest, 'http://schemas.i2i.com/ei/wsdl', 'GetInvoiceRequest');
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetInvoiceResponse2), 'http://schemas.i2i.com/ei/wsdl', 'GetInvoiceResponse2', 'GetInvoiceResponse');
  RemClassRegistry.RegisterSerializeOptions(TypeInfo(GetInvoiceResponse2), [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(MARK, 'http://schemas.i2i.com/ei/wsdl', 'MARK');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(MARK), 'INVOICE', '[ArrayItemName="INVOICE"]');
  RemClassRegistry.RegisterXSClass(SendInvoiceRequest2, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceRequest2', 'SendInvoiceRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(SendInvoiceRequest2), 'INVOICE', '[ArrayItemName="INVOICE"]');
  RemClassRegistry.RegisterSerializeOptions(SendInvoiceRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(SendInvoiceRequest, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceRequest');
  RemClassRegistry.RegisterXSClass(PrepareInvoiceResponseRequest2, 'http://schemas.i2i.com/ei/wsdl', 'PrepareInvoiceResponseRequest2', 'PrepareInvoiceResponseRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(PrepareInvoiceResponseRequest2), 'INVOICE', '[ArrayItemName="INVOICE"]');
  RemClassRegistry.RegisterSerializeOptions(PrepareInvoiceResponseRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(PrepareInvoiceResponseRequest, 'http://schemas.i2i.com/ei/wsdl', 'PrepareInvoiceResponseRequest');
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetInvoiceResponse), 'http://schemas.i2i.com/ei/wsdl', 'GetInvoiceResponse');
  RemClassRegistry.RegisterXSClass(LoadInvoiceRequest2, 'http://schemas.i2i.com/ei/wsdl', 'LoadInvoiceRequest2', 'LoadInvoiceRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(LoadInvoiceRequest2), 'INVOICE', '[ArrayItemName="INVOICE"]');
  RemClassRegistry.RegisterSerializeOptions(LoadInvoiceRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(LoadInvoiceRequest, 'http://schemas.i2i.com/ei/wsdl', 'LoadInvoiceRequest');
  RemClassRegistry.RegisterXSClass(SendInvoiceResponseWithServerSignRequest2, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponseWithServerSignRequest2', 'SendInvoiceResponseWithServerSignRequest');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(SendInvoiceResponseWithServerSignRequest2), 'INVOICE', '[ArrayItemName="INVOICE"]');
  RemClassRegistry.RegisterSerializeOptions(SendInvoiceResponseWithServerSignRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(SendInvoiceResponseWithServerSignRequest, 'http://schemas.i2i.com/ei/wsdl', 'SendInvoiceResponseWithServerSignRequest');
  RemClassRegistry.RegisterXSClass(INVOICE_SEARCH_KEY, 'http://schemas.i2i.com/ei/wsdl', 'INVOICE_SEARCH_KEY');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(INVOICE_SEARCH_KEY), 'TO_', '[ExtName="TO"]');
  RemClassRegistry.RegisterXSClass(INVOICE, 'http://schemas.i2i.com/ei/wsdl', 'INVOICE');
  RemClassRegistry.RegisterXSClass(INVOICE_STATUS, 'http://schemas.i2i.com/ei/wsdl', 'INVOICE_STATUS');
  RemClassRegistry.RegisterXSClass(HEADER, 'http://schemas.i2i.com/ei/wsdl', 'HEADER');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(HEADER), 'TO_', '[ExtName="TO"]');
  RemClassRegistry.RegisterXSClass(TextType, 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', 'TextType');
  RemClassRegistry.RegisterXSClass(NameType, 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2', 'NameType');
  RemClassRegistry.RegisterXSClass(LoginRequest2, 'http://schemas.i2i.com/ei/wsdl', 'LoginRequest2', 'LoginRequest');
  RemClassRegistry.RegisterSerializeOptions(LoginRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(LoginRequest, 'http://schemas.i2i.com/ei/wsdl', 'LoginRequest');
  RemClassRegistry.RegisterXSInfo(TypeInfo(USERTYPE), 'http://schemas.i2i.com/ei/wsdl', 'USERTYPE');
  RemClassRegistry.RegisterXSInfo(TypeInfo(SIGNTYPE), 'http://schemas.i2i.com/ei/wsdl', 'SIGNTYPE');
  RemClassRegistry.RegisterXSClass(USERCONTENT, 'http://schemas.i2i.com/ei/wsdl', 'USERCONTENT');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(USERCONTENT), 'TYPE_', '[ExtName="TYPE"]');
  RemClassRegistry.RegisterXSClass(LoginResponse2, 'http://schemas.i2i.com/ei/wsdl', 'LoginResponse2', 'LoginResponse');
  RemClassRegistry.RegisterSerializeOptions(LoginResponse2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(LoginResponse, 'http://schemas.i2i.com/ei/wsdl', 'LoginResponse');
  RemClassRegistry.RegisterXSClass(LogoutRequest2, 'http://schemas.i2i.com/ei/wsdl', 'LogoutRequest2', 'LogoutRequest');
  RemClassRegistry.RegisterSerializeOptions(LogoutRequest2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(LogoutRequest, 'http://schemas.i2i.com/ei/wsdl', 'LogoutRequest');
  RemClassRegistry.RegisterXSClass(LogoutResponse2, 'http://schemas.i2i.com/ei/wsdl', 'LogoutResponse2', 'LogoutResponse');
  RemClassRegistry.RegisterSerializeOptions(LogoutResponse2, [xoLiteralParam]);
  RemClassRegistry.RegisterXSClass(LogoutResponse, 'http://schemas.i2i.com/ei/wsdl', 'LogoutResponse');

end.