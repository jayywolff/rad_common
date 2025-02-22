module Users
  class DeviseAuthyController < Devise::DeviseAuthyController
    def GET_verify_authy
      if @resource.authy_sms?
        response = Authy::API.request_sms(id: @resource.authy_id, force: true)

        if response.ok?
          flash[:info] = 'A verification token has been texted to you.'
        else
          flash[:alert] = 'The verification code failed to send. Please click "Resend Text".'
        end
      end

      super
    end
  end
end
