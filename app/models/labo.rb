# == Schema Information
#
# Table name: labos
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  features   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Labo < ApplicationRecord
  @@SYMBOL_LABO_NAMES = %i(sumi durst sakuta ohara komiyama tobe harada lopez )
  @@ARRAY_LABO_DIRECTORY_NAMES = %w(durst harada komiyama lopez ohara sakuta sumi tobe ) # yamaguchi)
  @@ARRAY_LABO_NAMES = ['鷲見研究室', 'Dürst 研究室', '佐久田研究室', '大原研究室', '小宮山研究室', '戸辺研究室', '原田研究室', 'lopez 研究室']
  @@LABO_HASH = {'鷲見研究室' => 'sumi'  , 'Dürst 研究室' => 'durst'  , '佐久田研究室' => 'sakuta'   ,
              '大原研究室' => 'ohara' , '小宮山研究室' => 'komiyama', '戸辺研究室'   => 'tobe'     ,
              '原田研究室' => 'harada', 'lopez 研究室'  => 'lopez'   , # '山口研究室'   => 'yamaguchi',
  }

  @@NO_LABO_ID = -1

  has_many :users
  has_many :theses
  serialize :features

  def self.NO_LABO_ID
    @@NO_LABO_ID
  end

  def self.ARRAY_LABO_NAMES
    @@ARRAY_LABO_NAMES
  end

  def self.ARRAY_LABO_DIRECTORY_NAMES
    @@ARRAY_LABO_DIRECTORY_NAMES
  end

  def self.LABO_HASH
    @@LABO_HASH
  end

  def self.parse_labo_name(path)
    if path.include?("durst")
      'Dürst 研究室'
    elsif path.include?("harada")
      '原田研究室'
    elsif path.include?("komiyama")
      '小宮山研究室'
    elsif path.include?("lopez")
      'lopez 研究室'
    elsif path.include?("ohara")
      '大原研究室'
    elsif path.include?("sakuta")
      '佐久田研究室'
    elsif path.include?("sumi")
      '鷲見研究室'
    elsif path.include?("tobe")
      '戸辺研究室'
    end
  end
end
