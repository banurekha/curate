module Curate
  module UserBehavior
    module Base
      extend ActiveSupport::Concern

      included do
        has_many :hydramata_group_members, class_name: "Hydramata::GroupMember"
        has_many :hydramata_groups, through: :hydramata_group_members
      end
      def repository_noid
        Sufia::Noid.noidify(repository_id)
      end

      def repository_noid?
        repository_id?
      end

      def agree_to_terms_of_service!
        update_column(:agreed_to_terms_of_service, true)
      end

      def collections
        Collection.where(Hydra.config[:permissions][:edit][:individual] => user_key)
      end

      def organizations
        Organization.where(Hydra.config[:permissions][:edit][:individual] => user_key)
      end

      def get_value_from_ldap(attribute)
        # override
      end

      def name
        read_attribute(:name) || user_key
      end
    end
  end
end
