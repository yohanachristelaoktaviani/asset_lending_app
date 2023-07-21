class ReturnItemSerializer < ActiveModel::Serializer
  belongs_to :admin, class_name: "User", foreign_key: :admin_id, optional: true

  attributes :item_id, :actual_item_condition, :admin_id, :asset_return_id
end
