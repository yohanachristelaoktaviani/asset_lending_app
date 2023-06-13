class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :department, class_name: "Department", foreign_key: :department_id
  belongs_to :position, class_name: "Position", foreign_key: :position_id

  validates :code, presence: true
  validates :name, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters" }

  # validates  :code, exclusion: {in:->(record) {[record.code]}, message: "Employee ID must be unique" }

  validates :code, presence: true, uniqueness: {scope: :code}

end
