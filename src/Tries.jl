module Tries
    export トライノード, トライ木構築, 共通接頭辞検索
    
    using GamaUtils; str_slice, find
    using Morphs; 形態素
    
    mutable struct トライノード
        子供達::Vector{トライノード}
        文字コード::Int64
        形態素集合::Set{形態素}
    end

    
    """
    トライ木を構築する
    """
    function トライ木構築(形態素配列::Vector{形態素}, 文字コード辞書::Dict{Char, Int64})::トライノード
        
        ルートノード = トライノード(トライノード[], ' ', Set{形態素}())

        for 形態素要素 in 形態素配列
            子供達 = ルートノード.子供達
            単語 = 形態素要素.表層形
            文字列長 = length(単語)
            for (n文字目, 文字) in enumerate(単語)
                文字コード = 文字コード辞書[文字]
                if length(子供達) == 0 || 子供達[length(子供達)].文字コード != 文字コード
                    push!(子供達, トライノード(トライノード[], 文字コード, Set{形態素}()))
                end
                if n文字目 == 文字列長
                    push!(子供達[length(子供達)].形態素集合, 形態素要素)
                end
                子供達 = 子供達[length(子供達)].子供達
            end
        end

        ルートノード
    end


    """
    トライ木を使用し、共通接頭辞を検索する
    """
    function 共通接頭辞検索(木::トライノード, 文字コード辞書::Dict{Char,Int64}, 文字列::String)::Vector{形態素}
        
        単語配列 = 形態素[]
        ノード = 木
        
        for 文字 in 文字列

            if !haskey(文字コード辞書, 文字)
                break
            end

            文字コード = 文字コード辞書[文字]
            if length(ノード.子供達) == 0
                break
            end

            次ノード位置 = find(map(x->x.文字コード, ノード.子供達), 文字コード)
            if 次ノード位置 < 0
                break
            end

            ノード = ノード.子供達[次ノード位置]
            単語配列 = vcat(単語配列, collect(ノード.形態素集合))
        end

        単語配列
    end


    """
    トライ木を使用し、最長一致単語分割する
    """
    function 最長一致単語分割(形態素配列::Vector{形態素}, 木::トライノード, 文字コード辞書::Dict{Char,Int64}, 文字列::String)::Vector{形態素}
        
        単語配列 = 形態素[]
        文字数 = length(文字列)
        検索開始位置 = 1
        未知文字列 = ""

        while 検索開始位置 <= 文字数
            単語ID配列 = 共通接頭辞検索(木, 文字コード辞書, str_slice(文字列, 検索開始位置, 文字数))

            if length(単語ID配列) > 0
                単語長配列 = map(x->length(形態素配列[x].表層形), 単語ID配列)
                単語 = 形態素配列[単語ID配列[argmax(単語長配列)]]
                if 未知文字列 != ""
                    未知単語 = 形態素(未知文字列, "未知語", 未知文字列, 0)
                    push!(単語配列, 未知文字列)
                    未知文字列 = ""
                end
                push!(単語配列, 単語)
                検索開始位置 += length(単語.表層形)
            else
                未知文字列 *= str_slice(文字列, 検索開始位置, 検索開始位置)
                検索開始位置 += 1
            end
        end

        単語配列
    end
end