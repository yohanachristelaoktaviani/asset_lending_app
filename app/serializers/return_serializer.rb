class ReturnSerializer < ActiveModel::Serializer
  attributes :code, :asset_loan_id, :user_id, :actual_return_datetime
  has_many :return_items
end
