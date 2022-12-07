module Notifications
  class TwilioErrorThresholdPassedNotification < ::NotificationType
    def mailer_message
      "Twilio Error Threshold has been passed. #{formatted_percent}% of messages have failed to deliver. " \
        'Check twilio logs for more details'
    end

    def subject_record
      nil
    end

    private

      def formatted_percent
        ActiveSupport::NumberHelper.number_to_percentage(payload * 100)
      end
  end
end
