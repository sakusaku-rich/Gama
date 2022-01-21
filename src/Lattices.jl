module Lattices
    export ラティスノード, ラティス構築, ビタビ系列算出
    
    using Distributed: @distributed, @sync
    using Morphs; 形態素
    using Tries; トライノード, 共通接頭辞検索
    using GamaUtils; str_slice

    mutable struct ラティスノード
        単語::形態素
        最小コスト::Int64
        開始位置::Int64
        終了位置::Int64
        最小コスト前ノード位置::Int64
    end


    """
    ラティスを構築する
    """
    function ラティス構築(文字列::String, トライ木::トライノード, 文字コード辞書::Dict{Char, Int64}, コスト行列::Matrix{Int64})::Vector{ラティスノード}
        
        ラティス = ラティスノード[]
        文字列長 = length(文字列)
        終了位置集合 = Set{Int64}([0])

        @sync @distributed for n文字目 in range(1, 文字列長)
            単語配列 = 共通接頭辞検索(トライ木, 文字コード辞書, str_slice(文字列, n文字目, length(文字列)))
            @sync @distributed for 単語 in 単語配列
                終了位置 = n文字目 + length(単語.表層形) - 1
                push!(終了位置集合, 終了位置)
                if n文字目 - 1 in 終了位置集合
                    push!(ラティス, ラティスノード(単語, typemax(Int), n文字目, 終了位置, -1))
                end
            end
        end

        未知語追加!(ラティス, 文字列)
        pushfirst!(ラティス, ラティスノード(形態素("[BOS]", 0, 0, 0, "[BOS]", "[BOS]", 0), typemax(Int), 0, 0, -1))
        終端位置 = length(文字列)+1
        push!(ラティス, ラティスノード(形態素("[EOS]", 0, 0, 0, "[EOS]", "[EOS]", 0), typemax(Int), 終端位置, 終端位置, -1))
        順方向最小コスト算出!(ラティス, コスト行列)
        ラティス
    end


    """
    未知語をラティスに追加する
    """
    function 未知語追加!(ラティス::Vector{ラティスノード}, 文字列::String)
        未知語構成マスク = 未知語構成文字マスク作成(ラティス)
        未知文字列 = ""

        for (n文字目, 未知) in enumerate(未知語構成マスク)
            if !(未知 || 未知文字列 == "")
                未知語 = 形態素(未知文字列, 0, 0, typemax(Int), "未知語", 未知文字列, 0)
                push!(ラティス, ラティスノード(未知語, typemax(Int), n文字目-length(未知文字列), n文字目-1, -1))
                未知文字列 = ""
            end
            if 未知
                未知文字列 *= str_slice(文字列, n文字目, n文字目)
            end
        end

        if 未知文字列 != ""
            未知語 = 形態素(未知文字列, 0, 0, typemax(Int), "未知語", 未知文字列, 0)
            push!(ラティス, ラティスノード(未知語, typemax(Int), length(未知語構成マスク)-length(未知文字列)+1, length(未知語構成マスク), -1))
        end
    end


    """
    ラティスを順方向に辿り、各ノードに到達するまでの最小コストを算出する
    """
    function 順方向最小コスト算出!(ラティス::Vector{ラティスノード}, コスト行列::Matrix{Int64})
        
        状態配列 = sort(collect(Set(map(x->x.開始位置, ラティス))))
        
        for 状態 in 状態配列
            右連接ノード添字配列 = findall(x->x.開始位置==状態, ラティス) 
            for 右連接ノード添字 in 右連接ノード添字配列
                左連接ノード添字配列 = findall(x->x.終了位置==状態-1, ラティス)
                for 左連接ノード添字 in 左連接ノード添字配列
                    遷移コスト = ラティス[左連接ノード添字].最小コスト + ラティス[右連接ノード添字].単語.コスト + コスト行列[ラティス[左連接ノード添字].単語.左連接状態番号+1, ラティス[右連接ノード添字].単語.右連接状態番号+1]
                    if 遷移コスト < ラティス[右連接ノード添字].最小コスト
                        ラティス[右連接ノード添字].最小コスト = 遷移コスト
                        ラティス[右連接ノード添字].最小コスト前ノード位置 = 左連接ノード添字
                    end
                end
            end
        end

    end

    """
    未知語を構成している文字のマスクを取得する
    """
    function 未知語構成文字マスク作成(ラティス::Vector)::Vector{Bool}
        
        未知語構成文字位置 = repeat([true], ラティス[length(ラティス)].終了位置)
        
        @sync @distributed for ノード in ラティス
            未知語構成文字位置[ノード.開始位置:ノード.終了位置] .= false
        end
        
        未知語構成文字位置
    end

    """
    ラティスからビタビ系列を算出する
    """
    function ビタビ系列算出(ラティス::Vector{ラティスノード})
        
        ビタビ系列 = 形態素[]
        次単語位置 = ラティス[length(ラティス)].最小コスト前ノード位置
        
        while 次単語位置 != 1
            push!(ビタビ系列, ラティス[次単語位置].単語)
            次単語位置 = ラティス[次単語位置].最小コスト前ノード位置
        end
        
        reverse!(ビタビ系列)
        ビタビ系列
    end
end