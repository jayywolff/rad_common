module Notifications
  class NewDivisionNotification < ::NotificationType
    def mailer_class
      'RadbearMailer'
    end

    def mailer_method
      'simple_message'
    end

    def mailer_subject
      "Division '#{payload}' was Updated"
    end

    def mailer_message
      "Your division '#{payload}' was updated and we thought you might like to know."
    end

    def mailer_options
      { email_action: { message: 'Click here to view the details.',
                        button_text: 'View',
                        button_url: Rails.application.routes.url_helpers.division_url(payload) } }
    end

    def feed_content
      mailer_subject
    end

    def feed_record
      payload
    end

    def sms_content
      "Division '#{payload}' was updated: #{Rails.application.routes.url_helpers.division_url(payload)}"
    end

    def absolute_user_id
      payload.owner_id
    end
  end
end
