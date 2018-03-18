# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  body       :text(65535)
#  user_id    :integer
#  labo_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_messages_on_labo_id  (labo_id)
#  index_messages_on_user_id  (user_id)
#

FactoryGirl.define do
  factory :message do
    body "MyText"
  end
end
