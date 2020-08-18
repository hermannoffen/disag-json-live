object DisagJsonLiveUDPService: TDisagJsonLiveUDPService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'Disag Json-Live-Service'
  BeforeInstall = ServiceBeforeInstallOrUninstall
  AfterInstall = ServiceAfterInstall
  BeforeUninstall = ServiceBeforeInstallOrUninstall
  OnContinue = ServiceContinue
  Height = 150
  Width = 215
  object UDPServer: TIdUDPServer
    Bindings = <>
    ThreadedEvent = True
    OnUDPRead = UDPServerUDPRead
    Left = 168
    Top = 8
  end
  object HTTPClient: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'application/json'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 168
    Top = 80
  end
end
