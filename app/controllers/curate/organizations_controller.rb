class Curate::OrganizationsController < ApplicationController
  include Blacklight::Catalog
  include Hydra::CollectionsControllerBehavior
  include Hydra::AccessControlsEnforcement
  include Sufia::Noid

  Curate::OrganizationsController.solr_search_params_logic += [:only_organizations] 

  prepend_before_filter :normalize_identifier, only: [:show]
  respond_to(:html)
  with_themed_layout '1_column'

  add_breadcrumb 'Organizations', lambda {|controller| controller.request.path }

  skip_load_and_authorize_resource only: [:add_member_form, :add_member, :remove_member]
  before_filter :load_and_authorize_organization, only: [:show, :edit, :delete, :update, :add_member_form, :add_member]
  before_filter :load_and_authorize_collectible, only: [:add_member_form, :add_member]
  before_filter :authenticate_user!, except: :show
  before_filter :agreed_to_terms_of_service!
  before_filter :force_update_user_profile!

  def index
    super
  end

  def new
    @organization = Organization.new
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def edit
    @organization = Organization.find(params[:id])
    super
  end

  def create
    @organization = Organization.new(params[:organization])
    @organization.apply_depositor_metadata(current_user.user_key)
    if @organization.save
      flash[:notice] = "Organization created successfully."
      redirect_to organizations_path
    else
      flash[:error] = "Organization was not created."
      render action: :new
    end
  end

  def add_member_form
    render 'add_member_form'
  end

  def add_member
    @organization = ActiveFedora::Base.find(params[:organization_id], cast: true)
    if @organization && @organization.add_member(@collectible)
      flash[:notice] = "\"#{@collectible}\" has been added to \"#{@organization}\""
    else
      flash[:error] = 'Unable to add person to organization.'
    end
    redirect_to params.fetch(:redirect_to) { catalog_index_path }
  end

  def remove_member
    @organization = ActiveFedora::Base.find(params[:id], cast: true)
    item = ActiveFedora::Base.find(params[:item_id], cast:true)
    @organization.remove_member(item)
    redirect_to params.fetch(:redirect_to) { organization_path(params[:id]) }
  end

  def update
    @orgnization = Organization.find(params[:id])
    if @organization.update_attributes(params[:organization])
      flash[:notice] = "Ogranization updated successfully."
      redirect_to organization_path(@organization)
    else
      flash[:error] = "Organization was not updated."
      render action: :edit
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    title = @organization.to_s
    @organization.destroy
    after_destroy_response(title)
  end

  def after_destroy_response(title)
    flash[:notice] = "Deleted #{title}"
    respond_with { |wants|
      wants.html { redirect_to catalog_index_path }
    }
  end
  protected :after_destroy_response

  private

  def load_and_authorize_collectible
    id = id_from_params(:collectible_id)
    return nil unless id
    @collectible = ActiveFedora::Base.find(id, cast: true)
    authorize! :show, @collectible
  end

  def load_and_authorize_organization
    id = id_from_params(:collection_id)
    return nil unless id
    @organization = ActiveFedora::Base.find(id, cast: true)
    authorize! :update, @organization
  end

  def id_from_params(key)
    if params[key] && !params[key].empty?
      params[key]
    end
  end

  def after_add_member(collectible)
    @organization.apply_depositor_metadata(collectible.user.user_key)
  end

  def organizations
    self
  end

  ### Turn off this filter query if it's the index action
  def include_collection_ids(solr_parameters, user_parameters)
    return if params[:action] == 'index'
    super
  end

  def only_organizations(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "has_model_ssim:\"info:fedora/afmodel:Organization\""
    return solr_parameters
  end
end
