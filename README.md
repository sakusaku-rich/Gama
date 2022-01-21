# Gama（α版）

## 概要

自己学習がてらPure Juliaで実装した形態素解析器です。
MeCabで使用されている辞書を使用して、形態素解析を行います。

## 事前準備

1. 環境変数「GAMA」にGAMAのルートパスを設定する。

    ```shell
    export GAMA = "C:\path\to\Gama"
    ```

2. {Gama}/dict/ にMeCabの辞書を配置する。

    ```
    （例）C:\path\to\Gama\dict\mecab-ipadic-2.7.0-20070801
    ```

## 使用例

コード
```julia
using Gamas; init_gama, tokenize

dict_name = "mecab-ipadic-2.7.0-20070801" # 事前準備(2)で配置した辞書のディレクトリ名
gama = init_gama(dict_name)
text = "お腹が空いたから、チョコレートを食べよう。"
tokens = tokenize(gama, text)
for t in tokens
    println(t)
end

println()
println(tokens[3].表層形 * " / " * tokens[3].品詞 * " / " * tokens[3].基本形)
```

出力結果
```
Morphs.形態素("お腹", 1285, 1285, 7349, "名詞", "お腹", 12719)
Morphs.形態素("が", 148, 148, 3866, "助詞", "が", 16820)
Morphs.形態素("空い", 687, 687, 6316, "動詞", "空く", 261503)
Morphs.形態素("た", 435, 435, 5500, "助動詞", "た", 33803)
Morphs.形態素("から", 297, 297, 5649, "助詞", "から", 16029)
Morphs.形態素("、", 10, 10, -2435, "記号", "、", 99)
Morphs.形態素("チョコレート", 1285, 1285, 3348, "名詞", "チョコレート", 79486)
Morphs.形態素("を", 156, 156, 4183, "助詞", "を", 69026)
Morphs.形態素("食べよ", 621, 621, 7167, "動詞", "食べる", 324245)
Morphs.形態素("う", 506, 506, 7472, "助動詞", "う", 5991)
Morphs.形態素("。", 8, 8, 215, "記号", "。", 100)

空い / 動詞 / 空く
```

## 留意事項

- 現在、FileIOのバグ？でオブジェクトの保存が行えないため、毎度1~2分程度の初期化処理（init_gama()）の実行が必要になります。
- Juliaの仕様上、各関数の1回目の実行時にはプリコンパイルが行われるため、初回の処理実行時にはやや時間が掛かります。

## 今後の対応予定

- 初期化処理結果の保存と読み込み
- パフォーマンス改善