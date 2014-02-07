class Hydramata::Group < ActiveRecord::Base
  self.table_name = 'hydramata_groups'
  has_many :group_members, class_name: "::Hydramata::GroupMember", foreign_key: "hydramata_group_id"
  has_many :users, class_name: "::User", through: :group_members
end
