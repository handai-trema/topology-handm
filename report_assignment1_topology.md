#Report: 実機でトポロジを動かそう
Submission: &nbsp; Nov./9/2016<br>
Branch: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; develop<br>






##提出者: H&Mグループ
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




##課題内容
```
課題1 (実機でトポロジを動かそう)

1. 実機スイッチ上に VSI x16 を作成 (各VSIは2ポート以上)
2. 全ポートを適当にケーブリング
3. Topologyを使ってトポロジを表示
4. ケーブルを抜き差ししてトポロジ画像が更新されることを確認
レポートには次のことを書いてください。

・表示できたトポロジ画像。何パターンかあると良いです
・ケーブルを抜き差ししたときの画像
・実機スイッチのセットアップ情報。作業中の写真なども入れるとグーです
```





##実機スイッチの設定
16つのVLANをつくり，それぞれのVLANに3ポートずつ割り当てた．<br>
具体的には，下記３つのことを行った．<br>


###１．VLANの作成
下記コマンドによってVLANを作成する．<br>
ちなみに，idが１のVLANは最初に実機を使った演習で作成したいたため，２〜１６のidを持つVLANを作成した．<br>
```
vlan <VLAN id>
```

###２．VSIを作成
以下のコマンド群によって一つずつのVSIを作成した．<br>
ここで，VLANと同様，VSIのidが１のものは既に作成していたため，<VSI id>は2~16のものを作成した．<br>
そして，dpidには<VSI id>と同じ数字を指定した．<br>
さらに，<VLAN id>も同様に，<VSI id>と同じものを指定した．<br>
```
openflow openflow-id <VSI id> virtual-switch
controller controller-name cntl1 1 <IP address of controller> port 6653
dpid <dpid>
openflow-vlan <VLAN id>
miss-action controller
enable
exit
```

最後に，実機へログイン後の`show`コマンドによる出力を
[text/machine_setting.txt](https://github.com/handai-trema/topology-handm/blob/develop/text/machine_setting)
に示す．<br>






##実行結果
以下４つのことを行った．<br>


###１．複数のパッチをランダムに生成する．
実機のポートを２つずランダムに選び，複数のパッチを形成した．<br>


###２．[lib/topology.rb](https://github.com/handai-trema/topology-handm/blob/develop/lib/topology.rb)を実行し，画像の出力を得る．
以下のコマンドを実行した．<br>
このコマンドはTopolgyを起動し，形成されているトポロジを`tmp`ディレクトリに`topology.png`として画像を保存する．<br>
そして，図１がこのコマンドによって得られたトポロジ画像である．<br>
```
./bin/trema run ./lib/topology_controller.rb -- graphviz /tmp/topology.png
```

|<img src="https://github.com/handai-trema/topology-handm/blob/develop/img/topology_initial.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図１                                                     |  


###３．17番ポートのケーブルを抜く．
17番ポートのケーブルを抜くと図２のトポロジ画像を得た．<br>

|<img src="https://github.com/handai-trema/topology-handm/blob/develop/img/topology_pull_from17.png" width="420px">|  
|:----------------------------------------------------------------------------------------------------------------:|  
|                                                       図２                                                        |  


###４．17番ポートか抜いたケーブルを41番ポートへさす．
17番ポートか抜いたケーブルを41番ポートへさすと図３のトポロジ画像を得た．<br>

|<img src="https://github.com/handai-trema/topology-handm/blob/develop/img/topology_insert41_from17.png" width="420px">|  
|:--------------------------------------------------------------------------------------------------------------------:|  
|                                                         図３                                                          |  



##作業風景

|<img src="https://github.com/handai-trema/topology-handm/blob/develop/img/working2.jpg" width="420px">|  
|:----------------------------------------------------------------------------------------------------:|  
|                                   ケーブルの抜きさしを行っているところ                                     |  




##関連リンク
* [課題 (実機でトポロジを動かそう)](https://github.com/handai-trema/deck/blob/develop/week6/assignment1_topology.md#課題1-実機でトポロジを動かそう)
* [lib/topology.rb](https://github.com/handai-trema/topology-handm/blob/develop/lib/topology.rb)
* [実機スイッチの設定](https://github.com/handai-trema/topology-handm/blob/develop/text/machine_setting)
* [関連画像](https://github.com/handai-trema/topology-handm/tree/develop/img)
