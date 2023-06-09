class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :department, class_name: "Department", foreign_key: :department_id
  belongs_to :position, class_name: "Position", foreign_key: :position_id

  # validates  :code, exclusion: {in:->(record) {[record.code]}, message: "Employee ID must be unique" }

end
