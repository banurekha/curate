module Curate::OrganizationsHelper

  # Displays the Organizations create organization button.
  def button_for_create_new_organization(label = 'Create Organization')
    render partial: 'button_create_organization', locals:{label:label}
  end

  def has_any_organizations?
    #false
    current_user.organizations.count > 0 if current_user
  end

  def list_people_in_organization(organization, terminate=false)
    content_tag :ul, class: 'collection-listing' do
      organization.members.inject('') do |output, member|
        output << organization_member_line_item(organization, member, terminate)
      end.html_safe
    end
  end

  def organization_member_line_item(organization, member, terminate)
    content_tag :li, class: organization_line_item_class(organization), data: { noid: member.noid }do
      markup = organization_line_item(member, terminate)
      if can? :edit, organization
        markup << organization_member_actions(organization, member)
      end
    end  
  end

  def organization_line_item_class(organization)
    css_class = 'collection-member'
    css_class << ' with-controls' if can? :edit,organization
    css_class
  end

  def organization_line_item(person, terminate)
    list_people = content_tag :h3, class: 'collection-section-heading' do
      link_to(person.to_s, person_path(person))
    end
    list_people
  end

  def organization_member_actions(organization, member)
    content_tag :span, class: 'collection-member-actions' do
      if member.respond_to?(:members)
        markup = organization_actions_for_member(organization, member)
        markup << organization_actions_for_profile_section(organization, member)
      else
        organization_actions_for_member(organization, member)
      end
    end
  end

  # NOTE: Profile Sections and Collections are being rendered the same way.
  def organization_actions_for_profile_section(organization, member)
    if can? :edit, organization
      link_to edit_organization_path(id: member.to_param), class: 'btn' do
        raw('<i class="icon-pencil"></i> Edit')
      end
    end
  end

  def organization_actions_for_member(organization, member)
    button_to remove_member_collections_path(id: organization.to_param, item_id: member.pid), data: { confirm: 'Are you sure you want to remove this person from the organizaton?' }, method: :put, id: "remove-#{member.noid}", class: 'btn btn-danger', form_class: 'remove-member', remote: true do
      raw('<i class="icon-white icon-minus"></i> Remove')
    end
  end

  def current_users_organizations
    current_user ? current_user.organizations.to_a : []
  end

  def person_organizations_list(person)
    person.collections.to_a.select {|j| j.is_a?(Organization)}
  end

  def available_organizations(person = nil)
    if person.present?
      current_users_organizations.reject {|n| person_organizations_list(person).include?(n) }
    else
      current_users_organizations
    end
  end

end
