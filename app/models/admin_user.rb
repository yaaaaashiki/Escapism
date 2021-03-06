# == Schema Information
#
# Table name: admin_users
#
#  id              :integer          not null, primary key
#  username        :string(255)      not null
#  password_digest :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AdminUser < ApplicationRecord
  validates :username, presence: true, uniqueness: true, length: { in: 1..30 }
  has_secure_password
end
