class Hydramata::Group < ActiveRecord::Base
  self.table_name = 'hydramata_groups'
  has_many :hydramata_group_members, class_name: "Hydramata::GroupMember"
  has_many :users, through: :hydramata_group_members
end
