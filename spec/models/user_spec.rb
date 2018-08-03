# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  username         :string(255)      not null
#  email            :string(255)      not null
#  labo             :integer
#  role             :integer
#  crypted_password :string(255)
#  salt             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_username  (username) UNIQUE
#

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Validation" do
    it "is valid at it aoyama user" do
      user = build(:it_aoyama_user)
      expect(user).to be_valid
    end

    it "is valid without labo" do
      user = build(:no_labo_user)
      expect(user).to be_valid
    end

    it "is not valid without email" do
      user = build(:no_mail_user)
      expect(user).not_to be_valid
    end

    it "is not valid without username" do
      user = build(:no_name_user)
      expect(user).not_to be_valid
    end
  
    it "is not valid without password" do
      user = build(:no_password_user)
      expect(user).not_to be_valid
    end
  end

  describe "Mail address uniqueness" do
    let(:it_aoyama_user) {create(:it_aoyama_user)}
    let(:user) {build(:user)}
    
    it "is not valid when two user post the same address" do
      user.email = it_aoyama_user.email
      expect(user).not_to be_valid
    end

    it "is valid when two user post different e-mail addresses" do
      expect(user).to be_valid
    end
  end
end
