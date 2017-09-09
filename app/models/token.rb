# == Schema Information
#
# Table name: tokens
#
#  id              :integer          not null, primary key
#  mail_address_id :integer
#  token           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_tokens_on_mail_address_id  (mail_address_id)
#

class Token < ApplicationRecord
  validates :mail_address_id, presence: true, uniqueness: true
end
