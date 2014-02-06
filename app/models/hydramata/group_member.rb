class Hydramata::GroupMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :hydramata_group, class_name: "Hydramata::Group"
  self.table_name = 'hydramata_group_members'
end
