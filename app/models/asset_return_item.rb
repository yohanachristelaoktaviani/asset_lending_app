class AssetReturnItem < ActiveRecord::Base
  belongs_to :asset_return, class_name: "AssetReturn", foreign_key: :asset_return_id
  belongs_to :item_name, class_name: "Item", foreign_key: :item_id
  belongs_to :item_condition, class_name: "Item", foreign_key: :item_id
  belongs_to :admin, class_name: "User", foreign_key: :admin_id

end
