{
  Beautifulisoup4.findと同じような感じで使用できる簡易HTMLパーサー
}
unit LazHTMLParser;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DOM, DOM_HTML, SAX_HTML, XPath, RegExpr;

function GetNodeText(Tag, Attrib, AName, HTMLSrc: string): string;
function GetRegExText(PatternL, PatternR, HTMLSrc: string): string;

implementation

// PythonのBeautifulsoup4と同じような感じで使用できるHTMLパーサー
// Tag, Attrib, ANameで指定された」HTMLノードからテキストを抽出する
function GetNodeText(Tag, Attrib, AName, HTMLSrc: string): string;
var
  param: string;
  doc: THTMLDocument;
  XPathResult: TXPathVariable;
begin
  Result := '';
  try
    ReadHTMLFile(doc, TStringStream.create(HTMLSrc));
    if Attrib = '' then
      param := '//' + Tag
    else // Attrib以降があれば検索式を構成する
      param := '//' + Tag + '[@' + Attrib + '="' + AName + '"]';
    XPathResult := EvaluateXPathExpression(param, doc.DocumentElement);
    Result := XPathResult.AsText;
  finally
    doc.Free;
    XPathResult.Free;
  end;
end;

// 正規表現を用いてetNodeTextでは抽出できないテキスト用
// 正規表現パターンPatternL/PatternRで囲まれたテキストを抽出する
function GetRegExText(PatternL, PatternR, HTMLSrc: string): string;
var
  r: TRegExpr;
  ptn, s: string;
begin
  Result := '';

  ptn := PatternL + '.*?' + PatternR;
  r := TRegExpr.Create;
  try
    r.Expression  := ptn;
    r.InputString := HTMLSrc;
    if r.Exec then
    begin
      s := r.Match[0];
      s := ReplaceRegExpr(PatternR, ReplaceRegExpr(PatternL, s, ''), '');
      Result := s;
    end;
  finally
    r.Free;
  end;
end;

end.

