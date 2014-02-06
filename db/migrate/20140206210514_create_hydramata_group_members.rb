class CreateHydramataGroupMembers < ActiveRecord::Migration
  def change
    create_table :hydramata_group_members do |t|
      t.belongs_to :user
      t.belongs_to :hydramata_group
      t.string :member_type
      t.timestamps
    end
  end
end
