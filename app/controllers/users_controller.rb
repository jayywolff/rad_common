class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy resend_invitation confirm
                                    reset_authy test_email test_sms reactivate]
  before_action :remove_blank_passwords, only: :update

  def index
    authorize User

    if policy(User.new).update?
      @pending = policy_scope(User).includes(:user_status, :security_roles)
                                   .pending
                                   .recent_first
                                   .page(params[:pending_page]).per(3)
    end

    @user_search = UserSearch.new(params, current_user)
    @users = policy_scope(@user_search.results).page(params[:page])
  end

  def export
    authorize User

    respond_to do |format|
      format.csv do
        UserExportJob.perform_later(search_params.to_h, current_user.id)
        flash[:success] = report_generating_message
        redirect_to users_path(search_params.to_h)
      end
    end
  end

  def show
    @permission_categories = RadPermission.user_categories(@user)
    return unless RadicalConfig.user_clients?

    @user_clients = @user.user_clients.sorted
  end

  def new
    @user = User.new(timezone: Company.main.timezone)
    authorize @user
  end

  def edit; end

  def create
    @user = User.new(permitted_params)

    if policy(@user).update_security_roles? && !params[:user][:security_roles].nil?
      @user.security_roles = SecurityRole.resolve_roles(params[:user][:security_roles])
    end

    authorize @user

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def update
    ActiveRecord::Base.transaction do
      @user.assign_attributes(permitted_params)
      @user.approved_by = true_user

      if policy(@user).update_security_roles? && !params[:user][:security_roles].nil?
        @user.security_roles = SecurityRole.resolve_roles(params[:user][:security_roles])
      end

      authorize @user

      if @user.save
        flash[:success] = 'User updated.'
        redirect_to @user
      else
        render :edit
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    destroyed = false

    if @user == current_user
      flash[:error] = "Can't delete yourself."
      redirect_back(fallback_location: users_path)
      return
    end

    if @user.other_audits_created.count.positive?
      flash[:error] = "User has audit history, can't delete"
      redirect_back(fallback_location: users_path)
      return
    elsif @user.audits_created.count.positive?
      @user.audits_created.delete_all
    end

    duplicates = if duplicates_enabled?
                   @user.duplicates
                 else
                   []
                 end

    if @user.destroy
      flash[:success] = 'User deleted.'
      destroyed = true
    else
      flash[:error] = @user.errors.full_messages.join(', ')
    end

    if destroyed
      duplicates.each do |item|
        item[:record].process_duplicates
      end
    end

    if (destroyed && (URI(request.referer).path == user_path(@user))) ||
       (URI(request.referer).path == edit_user_path(@user))
      redirect_to users_path
    else
      redirect_back(fallback_location: users_path)
    end
  end

  def resend_invitation
    @user.invite!(current_user)
    flash[:success] = 'We resent the invitation to the user.'
    redirect_back(fallback_location: root_path)
  end

  def confirm
    @user.confirm
    flash[:success] = 'User was successfully confirmed.'
    redirect_to @user
  end

  def reset_authy
    @user.reset_authy!
    flash[:success] = 'User was successfully reset.'
    redirect_to @user
  end

  def test_email
    @user.test_email!
    flash[:success] = 'A test email was sent to the user.'
    redirect_to @user
  end

  def test_sms
    @user.test_sms! current_user
    flash[:success] = 'A test SMS was sent to the user.'
    redirect_to @user
  end

  def reactivate
    if @user.reactivate
      flash[:success] = 'User was successfully reactivated.'
    else
      flash[:error] = "User could not be reactivated: #{@user.errors.full_messages.to_sentence}"
    end

    redirect_to @user
  end

  private

    def set_user
      @user = User.find(params[:id])
      authorize @user
    end

    def remove_blank_passwords
      return unless params[:user][:password].blank? && params[:user][:password_confirmation].blank?

      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    def base_params
      %i[email user_status_id first_name last_name mobile_phone last_activity_at password password_confirmation external
         timezone avatar authy_sms]
    end

    def permitted_params
      params.require(:user).permit(base_params + RadicalConfig.additional_user_params!)
    end

    def duplicates_enabled?
      RadCommon::AppInfo.new.duplicates_enabled?('User')
    end
end
