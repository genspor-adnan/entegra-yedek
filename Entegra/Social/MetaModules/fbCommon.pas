unit fbCommon;

interface

uses
    System.NetEncoding
    , uSocialCommon
    , uOrtakLog;

//type
//  TFacebookLogMethod = procedure (_Message : string) of object;

const
    cgraphFacebookURL = 'https://graph.facebook.com';
    cGetaccessToke = 'oauth/access_token';
    cFacebookPageCount = 1;//2;
    cMetaApiVer = 'v18.0'; //v19.0 da olabilir

type

   recApi = record
     appName : string;
     appClientID : string;
     appSecret : string;
     appClientToken : string;
     PageToken : string;
     UserToken : string;
   end;

   recPage = record
     pageName : string;
     pageID : string;
     //pageToken : string;
   end;

(*********************************************
{
  "created_time": "2023-12-03T23:19:00+0000",
  "id": "1406838526896656",
  "field_data": [
    {
      "name": "FULL_NAME",
      "values": [
        "Mücahit Yaðmur"
      ]
    },
    {
      "name": "EMAIL",
      "values": [
        "mucahit.yagmur@msn.com"
      ]
    },
    {
      "name": "PHONE",
      "values": [
        "+905322304572"
      ]
    },
    {
      "name": "STREET_ADDRESS",
      "values": [
        "Açelya Sokak 2/4 Esentepe Mah Bursa Türkiye"
      ]
    },
    {
      "name": "GENDER",
      "values": [
        "Erkek"
      ]
    }
  ]
}

**********************************************)

   TMessageDataRec = record
     created_time : string;
     Title     : string;
     PageName  : string;
     error     : string;
     from_name : string;
     from_eMail : string;
     from_id : string;
     &message : string;
     message_formName : string;
     message_UserName : string;
     message_Phone    : string;
     message_email    : string;
   end;

var
  varBaseURL : string = cgraphFacebookURL;
  { WITH PAGE ACCESS TOKEN
    me?fields=business    Ýþletme hesabý
    me?fields=about       Sayfa Hakkýnda bilgi

  }
  { APPLICATIONS
  ----------------------------------------
                        ID                ClientToken                       App Secret                         Page Token
    GranitCRMapp      : 844158464121713   21b55b642581c85c8c4d04573803bac5  cc07908043b5e5b6a1d8bbd8bf65d57c   EAALZCwfVjW3EBO8LKq4vLDyGXoP5ZBTh3FMzgRWn0AxmZAon0y2FtKqnagadncvzOyJOmRfKtvtmTqgRZCEsgIKgZCNirwbcU5PMpWq3mzGRebwAkW8l6x7HKoSDFSU1ULnailbEpYtZC2yOFHRcZBqHIRm4Xbo3298WGKpv3ZBZAbhayHi7BSw1czoAqY5ZAO5frGak8SrHOZCbUaErQAZD          EAALZCwfVjW3EBOxGcunqEVLpN9P6LkWZA2QarQIv9Ys5fko29fTrzWEDaWZADDIqpZAAE3ZAWbl7YNXgmvep1aY8S6QNxFO5v6TlnYC2Mw3auAp12GRPssu4hOUEf4gwZBslI8cAvBYSQ3m0PaPDj9gNthjMebWwW4v1WzpXC8bo2tlBgoWjfI3ZC03REXxwsAR0fEFEGSn8YNwI4wZD    EAALZCwfVjW3EBO3TIpq7yInU7YjoofEoePe58mlRjdrrQLG3DFWEjlTcB7MtJp7QyF3Im0RLAgSJ1ifciXHtmv8HVwZCedzbGb1HnBbjQxhWhF4d7zMd7WBbx9PCOmq6aBebHqnM0R6zsU5ZA53GieD2SnnZAg7ONVrRUVmg5EW93KyOvJYxzIZAH4yBVIIUCWVBlZCaGE
    GranitAPP         : 691907186221176   e11d414abd29d1f0dad078caf2fc2877  d5c29fc293f665aa907f9f052a4bf41c
    GranitTestApp     : 364498649441365   bb0293939ad0b8e3e9c4c01b22b24a3a  597ad90e5c535d6041aed610e147a5cf
  }

  { PAGES
  ----------------------------------------
    Name                 ID                Facebook/Page

    Granit               164408166754533  facebook.com/gentegre.granit
    Logix Yazýlým        193888073799204  facebook.com/logixyazilim

  }

  { FORMS
  ----------------------------------------

  271076412223919		Form_3.12.2023
  1569153207222534		Granit'(n)in 2 Aralýk 2023 Cumartesi 14:31 tarihinde oluþturduðu form
  				https://graph.facebook.com/v18.0/1569153207222534?fields=organic_leads_count,name,id,page,created_time,status,leads,expired_leads_count

  2184820375186596		Ýletiþim formu oluþturma zamaný: 12/02/2023 9:05:10
  1489718305293779		FormX-Türkçe

  }


  var_AppClientID : string = '';//'691907186221176';//'638865971655879';
  var_AppSecret   : string = '';//'d5c29fc293f665aa907f9f052a4bf41c';
  var_AppClientToken : string = '';//'e11d414abd29d1f0dad078caf2fc2877';
  //var_PageID         : string = '164408166754533'; //granit
  var_CRMAccount_Id  : string = '';//'122107969766094797';

const
   constComboApplication : array[0..2] of recApi =(
   (//appName : 'GranitCRMapp';  appClientID: '844158464121713'; appSecret: 'cc07908043b5e5b6a1d8bbd8bf65d57c';appClientToken:'21b55b642581c85c8c4d04573803bac5';
   appName : 'GranitCRMapp';  appClientID: ''; appSecret: '';appClientToken:'';
    PageToken : '';//'EAALZCwfVjW3EBO8LKq4vLDyGXoP5ZBTh3FMzgRWn0AxmZAon0y2FtKqnagadncvzOyJOmRfKtvtmTqgRZCEsgIKgZCNirwbcU5PMpWq3mzGRebwAkW8l6x7HKoSDFSU1ULnailbEpYtZC2yOFHRcZBqHIRm4Xbo3298WGKpv3ZBZAbhayHi7BSw1czoAqY5ZAO5frGak8SrHOZCbUaErQAZD';
    UserToken : '' //'EAALZCwfVjW3EBO3TIpq7yInU7YjoofEoePe58mlRjdrrQLG3DFWEjlTcB7MtJp7QyF3Im0RLAgSJ1ifciXHtmv8HVwZCedzbGb1HnBbjQxhWhF4d7zMd7WBbx9PCOmq6aBebHqnM0R6zsU5ZA53GieD2SnnZAg7ONVrRUVmg5EW93KyOvJYxzIZAH4yBVIIUCWVBlZCaGE'
    )
   ,
   (
    //appName : 'GranitAPP';     appClientID: '691907186221176'; appSecret: 'd5c29fc293f665aa907f9f052a4bf41c';appClientToken:'e11d414abd29d1f0dad078caf2fc2877';
    appName : 'GranitAPP';     appClientID: ''; appSecret: '';appClientToken:'';
    PageToken : '';
    UserToken : ''
   )
   ,
   (//appName : 'GranitTestApp'; appClientID: '364498649441365'; appSecret: '597ad90e5c535d6041aed610e147a5cf';appClientToken:'bb0293939ad0b8e3e9c4c01b22b24a3a';
    appName : 'GranitTestApp'; appClientID: ''; appSecret: '';appClientToken:'';
    PageToken : '';
    UserToken : ''
   )
   );

   constComboPages : array[0..cFacebookPageCount-1] of recPage =(
     (pageName: 'Granit'; pageId : '164408166754533'{;        pageToken : 'EAALZCwfVjW3EBOxGcunqEVLpN9P6LkWZA2QarQIv9Ys5fko29fTrzWEDaWZADDIqpZAAE3ZAWbl7YNXgmvep1aY8S6QNxFO5v6TlnYC2Mw3auAp12GRPssu4hOUEf4gwZBslI8cAvBYSQ3m0PaPDj9gNthjMebWwW4v1WzpXC8bo2tlBgoWjfI3ZC03REXxwsAR0fEFEGSn8YNwI4wZD'})
     //,(pageName: 'Logix Yazýlým'; pageId : '193888073799204'{; pageToken : 'EAAJFC5NMtMcBO84wgp6ydDSH9gkVwTBER6Lzi0jbllb4NgIqB6d8BZBTc7tt4CSjrRcg3pRDRZACjx8gJZCCSH7dAZACSMDBFDdZCZCjW5HUYHKQGeAheWQnbwW5U4pvaVV4FFzDpJteIcc69taAvQ5EDaK7ar7n9IZACqGZA1TkEF4JiqiXF0QEZAj7FzpscuTEtalpnZBg32l1OchBwZD'})
   );


  //'fan_count%2Cfollowers_count%2Clink%2Cname%2Cpage_token%2Cfeed%7B'+
  //'likes%2Cactions%2Cid%2Cmessage%2Ccomments%7Breactions%7Bid%2Cname%2Cprofile_type%2Ctype%2C'+
  //'username%7D%2Cid%2Clike_count%2Cmessage%2Ccomment_count%2Cuser_likes%2Clikes%7Bid%2Cname%2C'+
  //'username%7D%2Ccomments%7Bfrom%2Cid%2Cmessage%2Cuser_likes%2Ccomments%7D%7D%7D'

  // 'fan_count,followers_count,link,messaging_feature_status,name,page_token,feed{likes,actions,id,message,comments{reactions{id,name,profile_type,type,username},id,like_count,message,comment_count,user_likes,likes{id,name,username},comments{from,id,message,user_likes,comments}}}'

const
   constComboParams : array[0..2] of string =(

  'fan_count,followers_count,link,name,page_token,feed{likes,actions,id,message,comments'+
  '{reactions{id,name,profile_type,type,username},id,like_count,message,comment_count,'+
  'user_likes,likes{id,name,username},comments{from,id,message,user_likes,comments}}}'
  ,
  'fan_count,followers_count,name,page_token,posts{via,reactions{id,name,type,username,'+
  'profile_type},id,from,message,shares,comments{id,from,likes{id,name,username},'+
  'comments{id,message,likes{id,name,username},user_likes,comments{id,comments{id,message,user_likes,'+
  'likes{id,name,username}}}}}},business,instagram_business_account'
  ,
  {'me?fields=}'followers_count,category,fan_count,phone,feed.limit(20){likes,from,id,message},posts.limit(20){from,comments{id,message}}'
  );

  {
    faceBook graph explorer da üretildiler.
  }
  userAccessToken : string = '';//'EAAJFC5NMtMcBO3ittBKkTLDZC5XgqevELoeMnEk5zReNvScIpP6xuf1ZAaiPXCInrVaqFZCqxEmHwgvKCly4ZAoc3TxSNYtZBEfZCUoiicSj3Y3OnurJVV01iDIbvBLeateM0oj0ljEVlhoEkeIqRro2JZAZC5Mc6lw9hVz4RfD8zG82dIaEPI6TuMxJBoS6ZCLmwtRBIzv5M';

  pageAccessToken : string = '';//'EAAJFC5NMtMcBOZCpHHvfn7L0YSCjuk1C1GjUE4TDV9MXeZCZCZCYKZBu78w2bWqHZA8nHu8Np67DNweEpK4zPKOwn12UBn4vqdwK9DKQ4HxZCHaSxudTHNvIZCtTp8jlm88wgTk8LCVlppjP0Lmawz1ww7ALRwkZCI1h1E1eW0XIKsouZCjiPyvdsE1g7fyUHGOu9dHNad3kLglZACu82kZD';
var
  FacebookLoggerMethod : TLogMethod = nil; //TFacebookLogMethod = nil;
  var_ResponseString : string = '';

procedure LogFacebook( _statusMessage : string);

implementation

procedure LogFacebook( _statusMessage : string);
begin
     if Assigned(FacebookLoggerMethod) then
        FacebookLoggerMethod(_statusMessage)
end;

end.
