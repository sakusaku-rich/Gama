module Costs
    export コスト行列構築

    using StringEncodings: @enc_str

    """
    連接コスト情報を読み込み、ベクトル化する。
    """
    function コスト行列構築(辞書パス::String)::Matrix{Int64}
        
        全行 = readlines(辞書パス * "matrix.def", enc"EUC-JP");
        行列サイズ = Int64(sqrt(length(全行)-1))
        コスト行列 = Array{Int64}(undef, 行列サイズ, 行列サイズ)
        
        @views for 行 in 全行[2:length(全行)]
            項目配列 = split(行, " ") # [前件文脈ID, 後件文脈ID, 連接コスト]
            コスト行列[parse(Int64, 項目配列[1])+1, parse(Int64, 項目配列[2])+1] = parse(Int64, 項目配列[3])
        end
        
        コスト行列
    end

end