module Gamas
    using Morphs; 形態素
    using Tries; トライノード
    using Costs; コスト行列構築
    using Lattices; ラティスノード

    export init_gama, tokenize
    
    struct Gama
        トライ木::トライノード
        形態素配列::Vector{形態素}
        文字コード辞書::Dict{Char, Int64}
        コスト行列::Matrix{Int64}
    end


    """
    指定された辞書で初期化を行う。
    初期化処理の内容は以下の通り
    - 辞書で使用されている文字にIDを付番する
    - 共通接頭辞検索をするためのトライ木を構築する
    - 遷移コスト情報の読み込む
    """
    function init_gama(dict_name::String)::Gama

        dict_name = replace(ENV["GAMA"], "\\"=>"/") * "/dict/" * dict_name * "/"
        形態素配列 = 形態素配列構築(dict_name)
        圧縮!(形態素配列)
        文字コード辞書 = 文字コード辞書構築(形態素配列)
        Gama(
            トライ木構築(形態素配列, 文字コード辞書), 
            形態素配列, 
            文字コード辞書, 
            コスト行列構築(dict_name)
        )

    end


    """
    ビタビアルゴリズムを用いて、形態素解析を行う。
    """
    function tokenize(gama::Gama, text::String)::Vector{形態素}
        
        ラティス = ラティス構築(text, gama.トライ木, gama.文字コード辞書, gama.コスト行列)
        ビタビ系列算出(ラティス)
    
    end
    
end