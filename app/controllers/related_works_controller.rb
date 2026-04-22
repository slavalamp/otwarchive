class RelatedWorksController < ApplicationController

  before_action :load_user, only: [:index]
  before_action :users_only, except: [:index]
  before_action :get_instance_variables, except: [:index]

  def index
    @page_subtitle = t(".page_title", login: @user.login)

    translations_of_user = @user.related_works.posted.translations
    remixes_of_user = @user.related_works.posted.remixes
    translations_by_user = @user.parent_work_relationships.posted.translations
    remixes_by_user = @user.parent_work_relationships.posted.remixes

    @can_access_unapproved_related_works = @user && (@user == current_user || (logged_in_as_admin? && policy(:related_work).access_unapproved?))

    @requests_exist = @user.related_works.posted.non_approved.present?
    @declined_works_exist = @requests_exist || @user.parent_work_relationships.posted.non_approved.present?

    if @can_access_unapproved_related_works && params[:requests] && @requests_exist
      @translations_of_user = translations_of_user.non_approved
      @remixes_of_user = remixes_of_user.non_approved
    elsif @can_access_unapproved_related_works && params[:declined]
      @translations_of_user = translations_of_user.non_approved
      @remixes_of_user = remixes_of_user.non_approved
      @translations_by_user = translations_by_user.non_approved
      @remixes_by_user = remixes_by_user.non_approved
    elsif @can_access_unapproved_related_works
      @translations_of_user = translations_of_user.approved
      @remixes_of_user = remixes_of_user.approved
      @translations_by_user = translations_by_user.approved
      @remixes_by_user = remixes_by_user.approved
    else
      @translations_of_user = translations_of_user.visible_to_all
      @remixes_of_user = remixes_of_user.visible_to_all
      @translations_by_user = translations_by_user.visible_to_all
      @remixes_by_user = remixes_by_user.visible_to_all
    end
  end

  # GET /related_works/1
  # GET /related_works/1.xml
  def show
  end

  def update
    # updates are done by the owner of the parent, to approve or remove links on the parent work.
    unless @user
      if current_user_owns?(@child)
        flash[:error] = ts("Sorry, but you don't have permission to do that. Try removing the link from your own work.")
        redirect_to user_related_works_path(current_user)
      else
        flash[:error] = ts("Sorry, but you don't have permission to do that.")
        redirect_to root_path
      end
      return
    end
    # the assumption here is that any update is a toggle from what was before
    @related_work.reciprocal = !@related_work.reciprocal?
    if @related_work.update_attribute(:reciprocal, @related_work.reciprocal)
      notice = @related_work.reciprocal? ?  ts("Link was successfully approved") :
                                            ts("Link was successfully removed")
      flash[:notice] = notice
      redirect_to(@related_work.parent)
    else
      flash[:error] = ts('Sorry, something went wrong.')
      redirect_to(@related_work)
    end
  end

  def destroy
    # destroys are done by the owner of the child, to remove links to the parent work which also removes the link back if it exists.
    unless current_user_owns?(@child)
      if @user
        flash[:error] = ts("Sorry, but you don't have permission to do that. You can only approve or remove the link from your own work.")
        redirect_to user_related_works_path(current_user)
      else
        flash[:error] = ts("Sorry, but you don't have permission to do that.")
        redirect_to root_path
      end
      return
    end
    @related_work.destroy
    redirect_back_or_to user_related_works_path(current_user)
  end

  private

  def load_user
    @user = User.find_by!(login: params[:user_id])
  end

  def get_instance_variables
    @related_work = RelatedWork.find(params[:id])
    @child = @related_work.work
    if @related_work.parent.is_a? (Work)
      @owners = @related_work.parent.pseuds.map(&:user)
      @user = current_user if @owners.include?(current_user)
    end
  end

end
