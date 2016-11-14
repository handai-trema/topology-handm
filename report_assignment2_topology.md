#Report: 実機でトポロジを動かそう
Submission: &nbsp; Nov./14/2016<br>
Branch: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; develop<br>


##目次
* [提出者](#submitter)
* [課題内容](#assignment)
* [追加でホストの接続関係を表示する](#addhoststate)
* [ブラウザで表示する機能を追加する](#addhtmlmode)
* [関連リンク](#links)



##<a name="submitter">提出者: H&Mグループ
###メンバー
<table>
  <tr>
    <td><B>氏名</B></td>
    <td><B>学籍番号</B></td>
    <td><B>所属研究室</B></td>
  </tr>
  <tr>
    <td>阿部修也</td>
    <td>33E16002</td>
    <td>松岡研究室</td>
  </tr>
  <tr>
    <td>信家悠司</td>
    <td>33E16017</td>
    <td>松岡研究室</td>
  </tr>
  <tr>
    <td>満越貴志</td>
    <td>33E16019</td>
    <td>長谷川研究室</td>
  </tr>
  <tr>
    <td>辻　健太</td>
    <td>33E16012</td>
    <td>長谷川研究室</td>
  </tr>
</table>




##<a name="assignment">課題内容
```
課題2(トポロジコントローラの拡張)
スイッチの接続関係に加えて，ホストの接続関係を表示する
ブラウザで表示する機能を追加する．
```

#<a name="addhoststate">追加でホストの接続関係を表示する

#<a name="addhtmlmode">ブラウザで表示する機能を追加する
今回追加する機能は，既存の２種類の視覚化方法に加えて，ウェブブラウザでの表示が可能となるように，HTML・JavaScriptファイルを生成する．
今回のオプションとともにtremaを実行することで生成が逐次行われるが，それをウェブブラウザで開くことで現在のトポロジを表示する．

## コマンドの設定
まずtremaからコマンドを呼び出すことができるように，[command_line.rb](/lib/command_line.rb)に追記した．
編集内容は次のようにした．まずpublic部分に

```
  def define_html_command
    desc 'Displays topology information (html mode)'
    arg_name 'output_file'
    command :html do |cmd|
      cmd.action(&method(:create_html_view))
    end
```
と記述し，コマンドオプションをprivateのcreate_html_viewメソッドを実行する．そのメソッドは次のようになる．

```
  def create_html_view(_global_options, _options, args)
    require 'view/html'
    if args.empty?
      @view = View::Html.new()
    else
      @view = View::Html.new(args[0])
    end
```
もし引数があれば，それとともに，Htmlクラスのインスタンス@viewを初期化する．

## Htmlクラスの記述
[html.rb](/lib/view/html.rb)に，今回記述したhtml・JavaScriptファイル生成プログラムを示す．

### インスタンス変数の初期化

```
    def initialize(output = 'topology.html')
      @nodes=[]
      @edges=[]
      @output = output
    end
```
存在するノード，エッジを記録するためのインスタンス変数@nodes,@edgesを空の配列として宣言し，出力先ファイル名@outputを引数より受け取る．
### ノードとエッジの追加メソッド

```
  def pushnode(id,ishost)
    if ishost then
      @nodes.push({id:id,label:id,image:"./lib/view/laptop.png",shape:'image'}) 
    else
      @nodes.push({id:id,label:id.to_hex,image:"./lib/view/switch.png",shape:"image"})
    end
  end
  def pushedge(from,to)
    @edges.push({from:from,to:to})
  end
```
pushnodeは，ノードのID,表示名，アイコン画像，形状（画像）を具体的に記述した配列を@nodesに格納する．引数としてはidとホストかどうかである．
ホストかスイッチかどうかは引数で指定する．そしてIDと表示名は同一としている．このように記述された配列は今回のJavaScriptファイルで，１つのノードとして解釈され，指定の表示名と画像が表示される．

pushedgeは，2ノード間のエッジを作成するための配列を格納する．順序は関係がない．

### updateに対する挙動

```
  def update(_event, _changed, topology)
      @nodes=[]
      topology.switches.each_with_object({}) do |each,tmp|
        pushnode(each,false) 
      end
      topology.hosts.each_with_object([]) do |each|
        pushnode(each.to_s,true)
      end  
      topology.links.each do |each|
        pushedge(each.dpid_a,each.dpid_b)
      end
      topology.hslinks.each do |each|
        pushedge(each.mac_address.to_s,each.dpid)
      end
      @edges = @edges.uniq
    output()
  end
```
updateは，トポロジの情報が更新されたときに実行され，topologyに格納されている各種情報をもとに，pushnodeやpushedgeを実行し，output処理を行う．
消えたノードを確実の削除するために@nodesは空の配列で初期化する．
スイッチ，ホスト，スイッチ間リンク，スイッチホスト間リンクの順に，先程示したメソッドを呼び出す．@edgesは重複を防ぐためにuniqを実行する．

### 出力

```
  def output()
    base =File.read("./lib/view/create_vis_base.txt")
    base2 =File.read("./lib/view/create_vis_base2.txt")
    result= base+JSON.generate(@nodes)+";\n edges ="+JSON.generate(@edges)+base2
    File.write(@output, result)
  end
```

outputにおいて，まず不変の部分をローカルファイルから読み込みbase,base2とする．
そして，nodesとedgesのJSON化を行い，文字列の結合を行ったものを，指定のファイル名で保存する．

### 実行結果

#### フルメッシュ型トポロジの視覚化
スイッチとホストが10台ずつ互いに接続されているトポロジであるフルメッシュ型のトポロジを出力した初期状態の結果は次のようになる．

|<img src="/img/html_fullmesh_initial.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図1                                                     |  

パケットを送信し，ホストが現れたときには次のようになる．

|<img src="/img/html_fullmesh_withhost.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図2                                                     |  

#### トライアングル型トポロジの視覚化とホストが消えたとき
３つのスイッチが互いに接続されているトポロジであるトライアングル型のトポロジを出力した初期状態の結果は次の様になる．


|<img src="/img/html_triangle_initial.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図3                                                     |  

パケットを送信し，ホストが現れたときには次のようになる．


|<img src="/img/html_triangle_withhost.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図4                                                    |  

あるポートをダウンさせてホストをトポロジから消失させたときには次のようになる．

|<img src="/img/html_triangle_withtwohost.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図5                                                     |  



##<a name="links">関連リンク
* [課題 (トポロジコントローラの拡張)](https://github.com/handai-trema/deck/blob/develop/week6/assignment2_topology.md)
* [lib/view/html.rb](/lib/view/html.rb)
* [lib/command_line.rb](/lib/command_line.rb)