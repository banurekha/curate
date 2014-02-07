class Hydramata::GroupMember < ActiveRecord::Base
  belongs_to :user, class_name: "::User", foreign_key: "user_id"
  belongs_to :group, class_name: "::Hydramata::Group", foreign_key: "hydramata_group_id"
  self.table_name = 'hydramata_group_members'
end
