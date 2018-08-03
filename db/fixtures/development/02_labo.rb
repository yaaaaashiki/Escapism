Labo.ARRAY_LABO_NAMES.size.times do |i|
  i += 1
  Labo.seed(:id) do |l|
    l.id = i
    l.name = Labo.ARRAY_LABO_NAMES[i-1]
    l.salt = "asdasdastr4325234324sdfds"
    l.crypted_password = Labo.crypt_password("password", "asdasdastr4325234324sdfds")
  end
end

# ファイルからfeature_hashを取得
FEATURE_HASH_PATH = "lib/feature_getter/feature_hash.json";
# 計算し直すときは以下を使用
# feature_hash = FeaturesGetter.fetch(4)
# File.open(FEATURE_HASH_PATH, 'w') do |file|
#   JSON.dump(feature_hash, file)
# end
# 実行時間の目安：論文3年分で約1時間
# (計測した環境：vagrant経由Ubuntu16.04，メモリ3GB，CPU2.4GHz1コア)
feature_hash = {}
File.open(FEATURE_HASH_PATH) do |file|
  feature_hash = JSON.load(file)
end

## 空白を含むキーがあるため文字列で指定
lab_hash = {'鷲見研究室' => 'sumi', 'Dürst 研究室' => 'durst', '佐久田研究室' => 'sakuta',
            '大原研究室' => 'ohara', '小宮山研究室' => 'komiyama', '戸辺研究室' => 'tobe',
            '原田研究室' => 'harada', 'Lopez 研究室' => 'lopez', '山口研究室' => 'yamaguchi',
}

lab_hash.each do |key, value|
  labo = Labo.find_by!(name: key)
  labo.update!(features: feature_hash[value])
end
