class AssetReturn < ActiveRecord::Base
  has_many :asset_return_items
  belongs_to :user, class_name: "User", foreign_key: :user_id
end
