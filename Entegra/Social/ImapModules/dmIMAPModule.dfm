object IMAPModule: TIMAPModule
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 480
  Width = 640
  object IdIMAP4: TIdIMAP4
    Intercept = IdConnectionIntercept1
    IOHandler = IdSSLIOHandler
    SASLMechanisms = <>
    MilliSecsToWaitToClearBuffer = 10
    Left = 111
    Top = 172
  end
  object IdSSLIOHandler: TIdSSLIOHandlerSocketOpenSSL
    Destination = ':143'
    Intercept = IdConnectionIntercept1
    MaxLineAction = maException
    Port = 143
    DefaultPort = 0
    SSLOptions.Method = sslvSSLv23
    SSLOptions.SSLVersions = [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2]
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 111
    Top = 244
  end
  object IdConnectionIntercept1: TIdConnectionIntercept
    OnReceive = IdConnectionIntercept1Receive
    OnSend = IdConnectionIntercept1Send
    Left = 491
    Top = 254
  end
end
