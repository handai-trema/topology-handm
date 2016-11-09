#Report: 実機でトポロジを動かそう
Submission: &nbsp; Nov./9/2016<br>
Branch: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; develop<br>






##提出者: H&Mグループ
###メンバー
<table>
  <tr>
    <td>氏名</td>
    <td>学籍番号</td>
    <td>所属研究室</td>
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






##VSIの設定


##実行結果
以下のことを行った．<br>

###１．[lib/topology.rb](https://github.com/handai-trema/topology-handm/blob/develop/lib/topology.rb)の実行と画像の出力
以下のコマンドを実行した．<br>
このコマンドはTopolgyを起動し，形成されているトポロジを`tmp`ディレクトリに`topology.png`として画像を保存する．<br>
そして，図１がこのコマンドによって得られたトポロジ画像である．<br>
```
./bin/trema run ./lib/topology_controller.rb -- graphviz /tmp/topology.png
```
|<img src="https://github.com/handai-trema/topology-handm/blob/develop/img/topology_initial.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図１                                                     |  

###２．17番ポートのケーブルを抜く．
17番ポートのケーブルを抜くと図２のトポロジ画像を得た．<br>
|<img src="https://github.com/handai-trema/topology-handm/blob/develop/img/topology_pull_from17.png" width="420px">|  
|:------------------------------------------------------------------------------------------------------------:|  
|                                                      図２                                                     |  

###３．17番ポートか抜いたケーブルを41番ポートへさす．
17番ポートか抜いたケーブルを41番ポートへさすと図３のトポロジ画像を得た．<br>
<figure>
  <img src="https://github.com/handai-trema/topology-handm/blob/develop/img/topology_insert41_from17.png" width="420px">
  <figcaption>図３</figcaption>
</figure>

##関連リンク
* [課題 (実機でトポロジを動かそう)](https://github.com/handai-trema/deck/blob/develop/week6/assignment1_topology.md#課題1-実機でトポロジを動かそう)
* [lib/topology.rb](https://github.com/handai-trema/topology-handm/blob/develop/lib/topology.rb)
