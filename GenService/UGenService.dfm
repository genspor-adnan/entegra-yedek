object GenServiceDlg: TGenServiceDlg
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'Gentegre Uygulama Servisi '
  Interactive = True
  OnContinue = ServiceContinue
  OnExecute = ServiceExecute
  OnPause = ServicePause
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 408
  Width = 606
  object Server: TIdTCPServer
    OnStatus = ServerStatus
    Bindings = <
      item
        IP = '127.0.0.1'
        Port = 7777
      end>
    DefaultPort = 7777
    OnExecute = ServerExecute
    Left = 52
    Top = 31
  end
end
