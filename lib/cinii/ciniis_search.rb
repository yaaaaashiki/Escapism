require 'uri'
require 'open-uri'
require 'open_uri_redirections'

class CiniisSearch
  MAX_SEARCH_SIZE = 100

  def self.url_encoding(keyword)
    # TODO: start=0で始めるかstart=変数にするかどうか検討が必要
    URI.escape("http://ci.nii.ac.jp/search?q=#{keyword}&range=0&count=#{MAX_SEARCH_SIZE}&sortorder=1&type=0")
  end
  
  def self.crawling(url)
    # TODO: 取得できなかった場合のError処理をどうしようか検討が必要
    Nokogiri::HTML.parse(open(url, :allow_redirections => :all))
  end
  
  def self.scraping(html)
    data = [] 
    html.css('#itemlistbox > ul > li').each_with_index do |article, i|
      data[i] = ArticleParser.return_data(article, i + 1)
   end
    data.to_json
  end
  
  def self.create_json(search_keyword)
    # search_keywordは配列を想定
    keyword = search_keyword.join("+")
    html = crawling(url_encoding(keyword))
    scraping(html)
  end
end

# テスト
#test_keyword = ["Ruby", "国際化"]
#main(search_keyword=test_keyword)
