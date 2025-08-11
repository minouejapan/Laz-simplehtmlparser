# Laz-simplehtmlparser
Lazarus簡易HTMLパーサー

### 説明
PythonのBeautifulsoup.find的なことをLazarusで実現させるために簡易的なHTMLパーサーを作成して見ました。
+ function GetNodeText(Tag, Attrib, AName, HTMLSrc: string): string; // beautifulsoup.find的なもの
  + Tag: HTMLタグ名(span/div等)
  + Attrib: 属性(class/id等)
  + AName: 属性のラベル
  + HTMKSrc: 抽出元となるHTMLソーステキスト
  + 戻り値: 抽出されたテキスト
  
+ function GetRegExText(PatternL, PatternR, HTMLSrc: string): string; // 正規表現による抽出
  + PatternL: 抽出したいテキストを起点とした左側の検索パターン
  + PatternR: 抽出したいテキストを起点とした右側の検索パターン
  + HTMLSrc: 抽出元となるHTMLソーステキスト
  + 戻り値: 抽出されたテキスト
 

### ライセンス
MIT
