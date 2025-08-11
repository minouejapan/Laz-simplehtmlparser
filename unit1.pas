{
  LazHTMLParserサンプル
  小説家になろう簡易ダウンローダー
}
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, WinINet, RegExpr;

type
  TNvStat = record
    NvlStat,
    AuthURL: string;
    TotalPg: integer;
  end;

  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    URL: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    function GetNvStat(Src: string): TNvStat;
    procedure NarouDL(URLAddr: string);
  public

  end;

var
  Form1: TForm1;

const
  UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';

function LoadFromHTML(URLadr: string): string;

implementation

{$R *.lfm}

uses
  LazHTMLParser;

{ TForm1 }

// WinINetを用いたHTMLファイルのダウンロード
function LoadFromHTML(URLadr: string): string;
var
  hSession    : HINTERNET;
  hService    : HINTERNET;
  dwBytesRead : DWORD;
  dwFlag      : DWORD;
  lpBuffer    : PChar;
  RBuff       : TMemoryStream;
  TBuff       : TStringList;
begin
  Result   := '';
  hSession := InternetOpen(PChar(UA), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then
  begin
    InternetSetOption(hSession, INTERNET_OPTION_USER_AGENT, PChar(ua), Length(ua));
    dwFlag   := INTERNET_FLAG_RELOAD;
    hService := InternetOpenUrl(hSession, PChar(URLadr), nil, 0, dwFlag, 0);
    if Assigned(hService ) then
    begin
      RBuff := TMemoryStream.Create;
      try
        lpBuffer := AllocMem(65536);
        try
          dwBytesRead := 65535;
          while True do
          begin
            if InternetReadFile(hService, lpBuffer, 65535,{SizeOf(lpBuffer),}dwBytesRead) then
            begin
              if dwBytesRead = 0 then
                break;
              RBuff.WriteBuffer(lpBuffer^, dwBytesRead);
            end else
              break;
          end;
        finally
          FreeMem(lpBuffer);
        end;
        TBuff := TStringList.Create;
        try
          RBuff.Position := 0;
          TBuff.LoadFromStream(RBuff, TEncoding.UTF8);
          Result := TBuff.Text;
        finally
          TBuff.Free;
        end;
      finally
        RBuff.Free;
      end;
    end;
    InternetCloseHandle(hService);
  end;
end;

function TForm1.GetNvStat(Src: string): TNvStat;
var
  aurl, res, sn: string;
  pn: integer;
begin
  Result.TotalPg := 0;
  Result.AuthURL := '';
  aurl := GetRegExText('<a class="c-menu__item c-menu__item--headnav" href="', '">作品情報</a>', Src);
  res := LoadFromHTML(aurl);
  Result.NvlStat := GetRegExText('<span class="p-infotop-type__type.*?">', '</span>', res);
  Result.AuthURL := GetRegExText('<dd class="p-infotop-data__value"><a href="', '">', res);
  sn := getNodeText('span', 'class', 'p-infotop-type__allep', res);
  sn := ReplaceRegExpr('全', ReplaceRegExpr('エピソード', sn, ''), '');
  try
    pn := StrToInt(sn);
  except
    pn := 0;
  end;
  Result.TotalPg := pn;
end;

procedure TForm1.NarouDL(URLAddr: string);
var
  res, aurl, txt: string;
  stat: TNvStat;
  i: integer;
begin
  res := LoadFromHTML(URLAddr);

  // トップページ
  stat :=  GetNvStat(res);
  txt := GetNodeText('h1', 'class', 'p-novel__title', res);
  Memo1.Lines.Add('【' + stat.NvlStat + '】' + txt);
  txt := GetNodeText('div', 'class', 'p-novel__author', res);
  txt := StringReplace(txt, '作者：', '', []);
  Memo1.Lines.Add(txt);
  txt := GetNodeText('div', 'class', 'p-novel__summary', res);
  Memo1.Lines.Add('［＃ここから罫囲み］'#13#10 + txt + #13#10 + '［＃ここで罫囲み終わり］'#13#10'［＃改ページ］');
  // 各話を取得する
  for i := 1 to stat.TotalPg do
  begin
    aurl := URLAddr + IntToStr(i) + '/';
    res := LoadFromHTML(aurl);
    txt := GetNodeText('h1', 'class', 'p-novel__title p-novel__title--rensai', res);
    Memo1.Lines.Add('［＃中見出し］' + txt + '［＃中見出し終わり］');
    txt := GetNodeText('div', 'class', 'js-novel-text p-novel__text', res);
    Memo1.Lines.Add(txt + #13#10 + '［＃改ページ］');
    Application.ProcessMessages;
    Sleep(500);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  aurl: string;
  re: TRegExpr;
begin
  Memo1.Lines.Clear;

  aurl := URL.Text;
  re := TregExpr.Create;
  try
    Re.Expression := '^https://ncode.syosetu.com/n\d{4}\w{1,2}/';
    Re.InputString:= aurl;
    if not Re.Exec then
      Memo1.Lines.Add('URLが違います.')
    else
      NarouDL(aurl);
  finally
    re.Free;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

end.

