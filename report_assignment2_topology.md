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

また，課題とは直接関係がないが，
graphvizモードにおいてスイッチ間リンクを表す辺について，
スイッチ間リンクは双方向のリンクであることから辺の両端の形状を変更している．

#<a name="addhoststate">追加でホストの接続関係を表示する
課題用リポジトリに含まれるコントローラは，
その出力にホスト及びスイッチ-ホスト間リンクを含まない．
そのため，該当プログラムを変更することでホスト及びスイッチ-ホスト間リンクを出力する．

変更前のプログラムは，
ホストから送られたパケットがスイッチに到着することによって引き起こされたパケットインをコントローラが受け取ると，
ホストのMACアドレス及びIPアドレスを，パケットインを送信したスイッチのDPID及び受信ポートの情報とともに配列へ格納するが，
これをトポロジの一部として出力することはない．

そのため，変更後のプログラムにおいては，
格納されたホストの情報をもとにトポロジの一部として出力し，
さらに，スイッチ-ホスト間のリンクについても，
スイッチ間リンクと同様に専用のクラスを作成して情報を保管，
トポロジの一部として出力する．

##ホストの情報を出力する
本節においては，ホストの情報をトポロジの一部として出力するための変更点を述べる．

変更前のプログラムは，ホストから送られたパケットがスイッチに到着することによって
引き起こされたパケットインの情報から，
ホストの情報（ホストのMACアドレス及びIPアドレス，パケットインを送信したスイッチのDPID及び受信ポート）を@hostsという配列に格納している．

そのため，各オブザーバに対してこれらの情報をもとに，
スイッチと接続されたホストの情報を出力するように
各プログラムを変更すればよい．

###topology.rb
各オブザーバがホストの情報を得たいときに利用する関数メソッドhostsを追加した．
本メソッドを実行すると，
トポロジに含まれるホストのMACアドレスの配列を戻り値として返す．
```ruby
def hosts
  tmp = []
  @hosts.each do |each|
    tmp << each[0].to_s
  end
  return tmp
end
```

###text.rb
テキストモードのオブザーバにホストの追加を出力するためのメソッドを追加する．
本メソッドはtopology.rbに追加したhostsメソッドを利用することで，
該当ホストを追加後のホストのMACアドレス一覧を出力している．
```ruby
def add_host(mac_address, port, topology)
  show_status("Host #{mac_address} added",
              topology.hosts)
end
```

###graphviz.view
graphvizモードのオブザーバにホストの追加を出力するための処理を追加する．
graphvizモードは，テキストモードとは異なり，追加分の情報だけを出力するのではなく，
トポロジの変更通知を受け取ると，変更されていない部分を含めた最新のトポロジを出力する．

そのため，
出力情報をファイルに書き出すメソッドgviz.outputを実行する前に，
配列@hostsに格納されているすべてのホストのMACアドレスを，
出力結果における各ノードのラベルとして利用し，
出力ノードを追加する．
```ruby
hosts = topology.hosts.each_with_object([]) do |each|
          gviz.add_nodes(each.to_s, shape: 'ellipse')
        end
```

##スイッチ-ホスト間のリンクを追加する
本節においては，スイッチ-ホスト間リンクの情報をトポロジの一部として出力するための変更点を述べる．

###hslink.rb
まず，スイッチ-ホスト間のリンクをHSLinkクラスとして定義する．
クラスファイルはスイッチ間リンクをもとに作成した．

HSLinkクラスはその情報としてスイッチのDPID及び接続ポート，
ホストのMACアドレス及びIPアドレスを保持する．
```ruby
require 'rubygems'
require 'pio/lldp'

#
# Edges between two switches.
#
class HSlink
  attr_reader :dpid
  attr_reader :ip_address
  attr_reader :mac_address
  attr_reader :port

  def initialize(dpid, packet_in)
    data = packet_in.data
    @dpid = dpid
    @ip_address = packet_in.source_ip_address
    @mac_address = packet_in.source_mac
    @port = packet_in.in_port
  end

  # rubocop:disable AbcSize
  # rubocop:disable CyclomaticComplexity
  # rubocop:disable PerceivedComplexity
  def ==(other)
    ((@dpid == other.dpid) &&
     (@ip_address == other.ip_address) &&
     (@mac_address == other.mac_address) &&
     (@port == other.port))
  end
  # rubocop:enable AbcSize
  # rubocop:enable CyclomaticComplexity
  # rubocop:enable PerceivedComplexity

  def <=>(other)
    to_s <=> other.to_s
  end

  def to_s
    format '%#x-%#s', *([dpid, mac_address])
  end

  def connect_to?(port)
    dpid = port.dpid
    port_no = port.number
    (@dpid == dpid) && (@port == port_no)
  end
end
```

###topology_controller.rb
topology_controller.rbには，
ホストのパケット送信によってスイッチからパケットインが発生した場合に，
ホストの追加だけではなくスイッチ-ホスト間のリンクを行うためのメソッド（@topology.maybe_add_hslink）を実行する．
```ruby
def packet_in(dpid, packet_in)
  if packet_in.lldp?
    @topology.maybe_add_link Link.new(dpid, packet_in)
  else
    @topology.maybe_add_host(packet_in.source_mac,
                             packet_in.source_ip_address,
                             dpid,
                             packet_in.in_port)
    @topology.maybe_add_hslink HSlink.new(dpid, packet_in)
  end
end
```

###topology.rb
topology.rbには，スイッチ-ホスト間リンクを追加するために，
その情報の保管及び各オブザーバへの通知を行う．

まず，以下の記述により，HSlinkクラスを記述したファイルを読み込む．
```ruby
require 'link'
require 'hslink'
```

また，以下の記述により，
クラスやモジュールにインスタンス変数を読み出すためのアクセサメソッドを定義する．
これにより，hslinksというメソッドを実行することで配列@hslinksの中身を出力することができる．
```ruby
attr_reader :links
attr_reader :ports
attr_reader :hslinks
```

また，initializeメソッドにおいては，
スイッチ-ホスト間リンクを格納するための配列@hslinksを初期化する．
```ruby
def initialize
  @observers = []
  @ports = Hash.new { [].freeze }
  @links = []
  @hosts = []
  @hslinks = []
end
```

また，スイッチ-ホスト間リンクを格納するためのメソッドmaybe_add_hslinkを追加する．
このメソッドは，配列@hslinksに引数として受け取った追加候補のリンクが含まれているかを判別する．
このとき，配列に追加候補のリンクが含まれていない場合には，新たに追加し，
その情報をオブザーバに:add_hslinkというコマンド名を付与して通知する．
```ruby
def maybe_add_hslink(hslink)
  return if @hslinks.include?(hslink)
  @hslinks << hslink
  host = hslink.mac_address
  sw_port = Port.new(hslink.dpid, hslink.port)
  maybe_send_handler :add_hslink, host, sw_port, self
end
```

###text.rb
テキストモードのオブザーバにおいては，
引数として受け取ったホスト及びスイッチの情報をもとにスイッチ-ホスト間リンクの追加を出力する．
```ruby
def add_hslink(host, sw_port, topology)
  link = format('%#x-%#s', *([sw_port.dpid, host]))
  show_status "HSlink #{link} added", topology.hslinks
end
```

###graphviz.view
graphvizモードのオブザーバにおいては，
配列@hslinksに格納されているスイッチ-ホスト間リンクの情報をもとに，
スイッチとホストの間をつなぐ辺を出力する．
```ruby
topology.hslinks.each do |each|
  gviz.add_edges each.mac_address.to_s, each.dpid.to_hex, "arrowhead" => "none"
end
```

##ホスト及びスイッチ-ホスト間リンクを削除する
本節においては，ホスト及びスイッチ-ホスト間リンクの情報をトポロジから削除するための変更点を述べる．

ホストは，パケットを送信する際にスイッチからパケットインが起こることで検出される．
そのため，コントローラはホストの動作状態を直接知ることができない．
そこで，スイッチのポートが閉じることでホストが孤立状態になると，
ホストはトポロジから外れたとみなすことにする．
なお，スイッチが孤立状態になった場合については，
コントローラとの接続が保たれている限りは動作状態が確認できることから，
孤立したスイッチについてもトポロジの一部であるものとみなす．

したがって，ホスト及びスイッチ-ホスト間リンクのトポロジからの削除は以下のように発生する．
1. ホストと接続しているスイッチの接続ポートが閉じる（またはスイッチが停止する）
2. スイッチ-ホスト間のリンクが切れる
3. ホストが他のスイッチ-ホスト間リンクを持っていない場合，ホストがトポロジから削除される

###topology.rb
topology.rbにおいては，
まず，スイッチのポートが閉じられた際に，
スイッチ間リンクだけではなくスイッチ-ホスト間のリンクの削除メソッド（maybe_delete_hslink）を実行する．
```ruby
def delete_port(port)
  @ports[port.dpid].delete_if { |each| each.number == port.number }
  maybe_send_handler :delete_port, Port.new(port.dpid, port.number), self
  maybe_delete_link port
  maybe_delete_hslink port
end
```

また，スイッチ-ホスト間のリンクを削除するメソッドmaybe_delete_hslinkを追加する．
動作内容はスイッチ間リンクを削除するメソッドmaybe_delete_linkをもとにしている．
スイッチ-ホスト間リンクの情報を格納し，オブザーバにリンク追加を追加した後に，
ホストの情報をトポロジから削除するためのメソッドmaybe_delete_hostを実行する．
```ruby
def maybe_delete_hslink(port)
  @hslinks.each do |each|
    next unless each.connect_to?(port)
    @hslinks -= [each]
    host = each.mac_address
    sw_port = Port.new(each.dpid, each.port)
    maybe_send_handler :delete_hslink, host, sw_port, self
    maybe_delete_host each
  end
end
```

maybe_delete_hostメソッドにおいては，
まず引数として受け取ったリンクの情報から得たホストの情報をもとに，
ホストの孤立状態を判定する．
ホストが孤立していた場合，そのホストをトポロジから削除するため，
配列@hostsから該当する要素を削除し，
各オブザーバにホストの削除を通知する．
```ruby
def maybe_delete_host(hslink)
 ct = 0
  @hslinks.each do |each|
    if ((each.mac_address == hslink.mac_address) && (each.ip_address == hslink.ip_address)) then
      ct += 1
    end
  end
  if ct == 0 then
    mac_address = hslink.mac_address
    ip_address = hslink.ip_address
    dpid = hslink.dpid
    port_no = hslink.port
    host = [mac_address, ip_address, dpid, port_no]
    @hosts.delete(host)
    maybe_send_handler :delete_host, mac_address, Port.new(dpid, port_no), self
  end
end
```

###text.rb
テキストモードのオブザーバにおいては，
スイッチ-ホスト間リンクの削除通知を受け取ると，その情報を削除後のスイッチ-ホスト間リンク一覧とともに出力する．
```ruby
def delete_hslink(host, sw_port, topology)
  link = format('%#x-%#s', *([sw_port.dpid, host]))
  show_status "HSlink #{link} deleted", topology.hslinks
end
```

また，ホストの削除通知を受け取ると，そのホストの情報を削除後のホストのMACアドレス一覧とともに出力する．
```ruby
def delete_host(mac_address, port, topology)
  show_status("Host #{mac_address} deleted",
              topology.hosts)
end
```

###graphviz.rb
graphvizモードのオブザーバにおいては，
トポロジ変更通知を受け取ることによって最新のトポロジを出力するという仕様から，
削除処理特有の変更はない．

##動作確認
動作確認に用いるトポロジを設定するDSLには，以下に示す triangle.conf を使用する．
本設定ファイルによって形成されるネットワークは，それぞれ3台のスイッチ及びホストを含み，
スイッチ間及びスイッチi-ホストi間にリンクが張られる．
```
[triangle.conf]
vswitch { dpid '0x1' }
vswitch { dpid '0x2' }
vswitch { dpid '0x3' }

vhost ('host1') { ip '192.168.0.1'
                  mac "01:01:01:01:01:01"}
vhost ('host2') { ip '192.168.0.2'
                  mac "02:02:02:02:02:02"}
vhost ('host3') { ip '192.168.0.3'
                  mac "03:03:03:03:03:03"}

link '0x1', '0x2'
link '0x1', '0x3'
link '0x3', '0x2'

link '0x1', 'host1'
link '0x2', 'host2'
link '0x3', 'host3'
```

以下に，本課題における動作確認手順を示す．
各手順を実行後，テキストモード及びgraphvizモードによる出力を確認する．
```
1. 起動し，スイッチを接続
2. host1からhost2へパケットを送信
3. host2からhost3へパケットを送信
4. host1と接続されているswitch1のポートを閉じる
5. host2と接続されているswitch2のポートを閉じる
```
スイッチ及びスイッチ間リンクに関しては，
LLDPパケットの働きにより，
上記トポロジを形成した時点で検出される．
これに対し，
ホスト及びスイッチ-ホスト間リンクに関しては，
ホストがコントローラにLLDPパケットをパケットインさせることはないため，
ホストがパケットを送信し，
スイッチに到着したパケットがパケットインを引き起こすことによって，
ホストの存在及びスイッチ-ホスト間のリンクをコントローラが検出することができる．
すなわち，ホストそのものの動作状態（電源のON，OFF）をコントローラは直接知ることができない．

そのため，本確認手順においては，
手順1において，すべてのスイッチ及びスイッチ間リンクが，
手順2及び手順3によりホスト及びスイッチ-ホスト間リンクが発見される．
さらに，
手順4及び手順5において，
ホストと接続されているスイッチのポートを閉じると，
スイッチ-ホスト間のリンク及び接続先のホストについてもトポロジから削除される．

####1. 起動し，スイッチを接続
コントローラを起動し，設定ファイル（triangle.conf）に書かれたトポロジを形成する．
このとき，ホスト及びスイッチ-ホスト間のリンクは検出することができない．

* テキストモード
```
Topology started (text mode).
Port 0x3:3 added: 3
Port 0x3:1 added: 1, 3
Port 0x3:2 added: 1, 2, 3
Switch 0x3 added: 0x3
Port 0x2:3 added: 3
Port 0x2:1 added: 1, 3
Port 0x2:2 added: 1, 2, 3
Switch 0x2 added: 0x2, 0x3
Port 0x1:3 added: 3
Port 0x1:1 added: 1, 3
Port 0x1:2 added: 1, 2, 3
Switch 0x1 added: 0x1, 0x2, 0x3
Link 0x1-0x3 added: 0x1-0x3
Link 0x2-0x3 added: 0x1-0x3, 0x2-0x3
Link 0x1-0x2 added: 0x1-0x2, 0x1-0x3, 0x2-0x3
```

* graphvizモード
|<img src="/img/topology_1.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図1                                                     |  

####2. host1からhost2へパケットを送信
host1からhost2へパケットを送信すると，
host1に接続されたスイッチ0x1からパケットインが発生し，
host1及び0x1-host1間のリンクが発見されていることがわかる．

* テキストモード
```
[trema send_packets -s host1 -d host2]
Host 01:01:01:01:01:01 added: 01:01:01:01:01:01
HSlink 0x1-01:01:01:01:01:01 added: 0x1-01:01:01:01:01:01
```

* graphvizモード
|<img src="/img/topology_2.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図2                                                     |  

####3. host2からhost3へパケットを送信
host2からhost3へパケットを送信すると，
host2に接続されたスイッチ0x2からパケットインが発生し，
host2及び0x2-host2間のリンクが発見されていることがわかる．
ここで，複数のホスト及びスイッチ-ホスト間リンクの検出に対応していることがわかる．

* テキストモード
```
[trema send_packets -s host2 -d host3]
Host 02:02:02:02:02:02 added: 01:01:01:01:01:01, 02:02:02:02:02:02
HSlink 0x2-02:02:02:02:02:02 added: 0x1-01:01:01:01:01:01, 0x2-02:02:02:02:02:02
```
* graphvizモード
|<img src="/img/topology_3.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図3                                                     |  

####4. host1と接続されているスイッチ0x1のポートを閉じる
スイッチ0x1はポート3を通してhost1と接続している．
このポート3を閉じると，
そのポートを利用したスイッチ-ホスト間リンク及びホストがトポロジから削除されていることがわかる．

* テキストモード
```
[trema port_down --switch 0x1 --port 3]
Port 0x1:3 deleted: 1, 2
HSlink 0x1-01:01:01:01:01:01 deleted: 0x2-02:02:02:02:02:02
Host 01:01:01:01:01:01 deleted: 02:02:02:02:02:02
```

* graphvizモード
|<img src="/img/topology_4.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図4                                                     |  

####5. host2と接続されているswitch2のポートを閉じる
スイッチ0x2はポート3を通してhost2と接続している．
このポート3を閉じると，
そのポートを利用したスイッチ-ホスト間リンク及びホストがトポロジから削除されていることがわかる．

* テキストモード
```
[trema port_down --switch 0x2 --port 3]
Port 0x2:3 deleted: 1, 2
HSlink 0x2-02:02:02:02:02:02 deleted: 
Host 02:02:02:02:02:02 deleted: 
```

* graphvizモード
|<img src="/img/topology_5.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図5                                                     |  

#<a name="addhtmlmode">ブラウザで表示する機能を追加する
今回追加する機能は，既存の２種類の視覚化方法に加えて，ウェブブラウザでの表示が可能となるように，HTML・JavaScriptファイルを生成する．
今回のオプションとともにtremaを実行することで生成が逐次行われるが，それをウェブブラウザで開くことで現在のトポロジを表示する．

## コマンドの設定
まずtremaからコマンドを呼び出すことができるように，[command_line.rb](/lib/command_line.rb)に追記した．
編集内容は次のようにした．まずpublic部分に

```ruby
  def define_html_command
    desc 'Displays topology information (html mode)'
    arg_name 'output_file'
    command :html do |cmd|
      cmd.action(&method(:create_html_view))
    end
```
と記述し，コマンドオプションをprivateのcreate_html_viewメソッドを実行する．そのメソッドは次のようになる．

```ruby
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

```ruby
    def initialize(output = 'topology.html')
      @nodes=[]
      @edges=[]
      @output = output
    end
```
存在するノード，エッジを記録するためのインスタンス変数@nodes,@edgesを空の配列として宣言し，出力先ファイル名@outputを引数より受け取る．
### ノードとエッジの追加メソッド

```ruby
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

```ruby
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

```ruby
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