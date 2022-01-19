module Morphs
    export 形態素配列構築, 文字コード辞書構築, 形態素, 圧縮!

    using Distributed: @distributed, @sync
    using StringEncodings: @enc_str

    mutable struct 形態素
        表層形::String
        左連接状態番号::Int64
        右連接状態番号::Int64
        コスト::Int64
        品詞::String
        # 品詞細分類1::String
        # 品詞細分類2::String
        # 品詞細分類3::String
        # 活用型::String
        # 活用形::String
        基本形::String
        # 読み::String
        # 発音::String
        ID::Int64
    end


    """
    形態素構造体のコンストラクタ
    MeCabのipadic辞書用
    """
    function 形態素(
        表層形::SubString{String},
        左連接状態番号::SubString{String},
        右連接状態番号::SubString{String},
        コスト::SubString{String},
        品詞::SubString{String},
        品詞細分類1::SubString{String},
        品詞細分類2::SubString{String},
        品詞細分類3::SubString{String},
        活用型::SubString{String},
        活用形::SubString{String},
        基本形::SubString{String},
        読み::SubString{String},
        発音::SubString{String})
        形態素(
            String(表層形),
            parse(Int64, 左連接状態番号),
            parse(Int64, 右連接状態番号),
            parse(Int64, コスト),
            String(品詞),
            # String(品詞細分類1),
            # String(品詞細分類2),
            # String(品詞細分類3),
            # String(活用型),
            # String(活用形),
            String(基本形),
            # String(読み),
            # String(発音),
            0
        )
    end

    """
    形態素構造体のコンストラクタ
    MeCabのjuman辞書用
    """
    function 形態素(
        表層形::SubString{String},
        左連接状態番号::SubString{String},
        右連接状態番号::SubString{String},
        コスト::SubString{String},
        品詞::SubString{String},
        品詞細分類1::SubString{String},
        品詞細分類2::SubString{String},
        活用形::SubString{String},
        基本形::SubString{String},
        読み::SubString{String},
        発音::SubString{String})
        形態素(
            String(表層形),
            parse(Int64, 左連接状態番号),
            parse(Int64, 右連接状態番号),
            parse(Int64, コスト),
            String(品詞),
            # String(品詞細分類1),
            # String(品詞細分類2),
            # String(品詞細分類3),
            # String(活用型),
            # String(活用形),
            String(基本形),
            # String(読み),
            # String(発音),
            0
        )
    end


    """
    形態素構造体のコンストラクタ
    空のオブジェクトを作成する用
    """
    function 形態素()

        形態素("", 0, 0, 0, "", "", 0)
    
    end


    """
    MeCabの辞書の1行から形態素オブジェクトを生成する
    """
    function 行から形態素を作成(行::String)::形態素

        return 形態素(split(行, ",")...)
    
    end


    """
    MeCabの辞書に含まれている全ての単語の形態素オブジェクトを生成し、ベクトル化する
    """
    function 形態素配列構築(辞書パス::String)::Vector{形態素}
        
        形態素配列 = 形態素[]

        for (ルート, ディレクトリベクトル, ファイルベクトル) in walkdir(辞書パス)
            @sync @distributed for ファイル in ファイルベクトル
                ファイル名の長さ = length(ファイル)
                if ファイル[ファイル名の長さ-2:ファイル名の長さ] == "csv"
                    try
                        全行 = readlines(辞書パス * ファイル, enc"EUC-JP")
                        形態素配列 = vcat(形態素配列, map(行->行から形態素を作成(行), 全行))
                    catch
                        全行 = readlines(辞書パス * ファイル)
                        形態素配列 = vcat(形態素配列, map(行->行から形態素を作成(行), 全行))
                    end
                end
            end
        end

        形態素配列
    end

    
    """
    指定された辞書内で使用されている文字に対してIDを付番する
    """
    function 文字コード辞書構築(形態素配列::Vector{形態素})::Dict{Char, Int64}
        文字集合 = Set{Char}()

        @sync @distributed for 形態素 in 形態素配列
            @sync @distributed for 文字 in 形態素.表層形
                push!(文字集合, 文字)
            end
        end

        文字コード辞書 = Dict{Char, Int64}()

        for (文字コード, 文字) in enumerate(文字集合)
            文字コード辞書[文字] = 文字コード
        end
        
        文字コード辞書
    end


    """
    同一と見なせる形態素オブジェクトを形態素ベクトルから削除する
    """
    function 圧縮!(形態素配列::Vector{形態素})

        sort!(形態素配列, by = 形態素 -> 形態素.表層形);
        削除対象ID集合 = Set(Int64[])
        比較対象集合 = Set()
        
        for (添字, 単語) in enumerate(形態素配列)
            比較情報 = (単語.表層形, 単語.品詞, 単語.基本形)
            if 比較情報 in 比較対象集合
                push!(削除対象ID集合, 添字)
            else
                push!(比較対象集合, 比較情報)
            end
        end
        
        削除対象ID配列 = collect(削除対象ID集合)
        sort!(削除対象ID配列, rev=true);
        
        for 削除対象ID in 削除対象ID配列
            deleteat!(形態素配列, 削除対象ID)
        end
        
        ID付番!(形態素配列)
    end


    """
    形態素オブジェクトにIDを付番する
    """
    function ID付番!(形態素配列::Vector{形態素})

        for (単語ID, 形態素) in enumerate(形態素配列)
            形態素.ID = 単語ID
        end
    
    end
end