object dmFaceBook: TdmFaceBook
  Height = 480
  Width = 640
  object fb_GET_ACCESS_TOKEN_Client1: TRESTClient
    BaseURL = 'https://graph.facebook.com/oauth/access_token'
    ContentType = 'application/json'
    Params = <>
    RaiseExceptionOn500 = False
    SynchronizedEvents = False
    Left = 344
    Top = 24
  end
  object fb_GET_ACCESS_TOKEN_Request: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = fb_GET_ACCESS_TOKEN_Client1
    Params = <>
    Response = fb_GET_ACCESS_TOKEN_Response
    SynchronizedEvents = False
    Left = 344
    Top = 80
  end
  object fb_GET_ACCESS_TOKEN_Response: TRESTResponse
    Left = 344
    Top = 136
  end
  object RESTDataSetAdapter1: TRESTResponseDataSetAdapter
    Dataset = fb_GET_ACCESS_Table
    FieldDefs = <>
    ResponseJSON = fb_GET_ACCESS_TOKEN_Response
    Left = 488
    Top = 224
  end
  object fb_GET_ACCESS_Table: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    FormatOptions.AssignedValues = [fvInlineDataSize]
    FormatOptions.InlineDataSize = 8192
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 337
    Top = 208
  end
  object fb_GGET_ACCESS_DataSource: TDataSource
    DataSet = fb_GET_ACCESS_Table
    Left = 360
    Top = 288
  end
  object fb_GET_PAGE_FEED_Client: TRESTClient
    BaseURL = 
      'https://graph.facebook.com/v18.0/164408166754533/?fields=fan_cou' +
      'nt%2Cfollowers_count%2Clink%2Cmessaging_feature_status%2Cname%2C' +
      'page_token%2Cfeed%7Blikes%2Cactions%2Cid%2Cmessage%2Ccomments%7B' +
      'reactions%7Bid%2Cname%2Cprofile_type%2Ctype%2Cusername%7D%2Cid%2' +
      'Clike_count%2Cmessage%2Ccomment_count%2Cuser_likes%2Clikes%7Bid%' +
      '2Cname%2Cusername%7D%2Ccomments%7Bfrom%2Cid%2Cmessage%2Cuser_lik' +
      'es%2Ccomments%7D%7D%7D'
    Params = <>
    RaiseExceptionOn500 = False
    SynchronizedEvents = False
    Left = 72
    Top = 32
  end
  object fb_GET_PAGE_FEED_Request: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = fb_GET_PAGE_FEED_Client
    Params = <
      item
        Name = 'access_token'
        Value = 
          'EAAJFC5NMtMcBOZCpHHvfn7L0YSCjuk1C1GjUE4TDV9MXeZCZCZCYKZBu78w2bWq' +
          'HZA8nHu8Np67DNweEpK4zPKOwn12UBn4vqdwK9DKQ4HxZCHaSxudTHNvIZCtTp8j' +
          'lm88wgTk8LCVlppjP0Lmawz1ww7ALRwkZCI1h1E1eW0XIKsouZCjiPyvdsE1g7fy' +
          'UHGOu9dHNad3kLglZACu82kZD'
      end>
    Response = fb_GET_PAGE_FEED_Response
    SynchronizedEvents = False
    Left = 72
    Top = 96
  end
  object fb_GET_PAGE_FEED_Response: TRESTResponse
    Left = 72
    Top = 192
  end
  object fb_GET_INFO_Client: TRESTClient
    BaseURL = 'https://graph.facebook.com/me'
    Params = <>
    RaiseExceptionOn500 = False
    SynchronizedEvents = False
    Left = 184
    Top = 256
  end
  object fb_GET_INFO_Request: TRESTRequest
    AssignedValues = [rvHandleRedirects, rvConnectTimeout, rvReadTimeout]
    Client = fb_GET_INFO_Client
    Params = <
      item
        Name = 'access_token'
        Value = 
          'EAAJFC5NMtMcBO9NeixWjqwbwdPVyrMpUBQmieZBebnZCJZA5d55rcrjt0L5cb7j' +
          't31STtz3NyRZBPUgaU7ZCJFBQopmco1r9UqGLoO6NsDZCi4oA7CdvUAS8QEiuPpJ' +
          'FrtIGYdUKV53ewCN1VWW376FoXPMZAUit0VhZCzmX3U6cCFc3Jj8sohGKFM80IS6' +
          'dyPZCQwplMcM35'
      end
      item
        Name = 'fields'
        Value = 
          'email,name,first_name,last_name,middle_name,link,id,gender,birth' +
          'day,website,relationship_status,timezone,locale,verified,updated' +
          '_time,location,hometown,significant_other'
      end>
    Response = fb_GET_INFO_Response
    ConnectTimeout = 0
    ReadTimeout = 0
    SynchronizedEvents = False
    Left = 192
    Top = 312
  end
  object fb_GET_INFO_Response: TRESTResponse
    Left = 200
    Top = 376
  end
end
