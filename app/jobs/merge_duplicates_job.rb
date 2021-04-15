class MergeDuplicatesJob < ApplicationJob
  queue_as :default

  def perform(duplicate_keys, model_class, model_id, user_id)
    current_user = User.find(user_id)
    model = model_class.constantize
    record = model.find(model_id)
    error = nil

    duplicate_keys.each do |key|
      error = cleanup_duplicate(key, model, record, current_user)
      break if error
    end

    if error.present?
      message = "Unable to process duplicates for #{model_class} #{model_id}"
      RadbearMailer.simple_message(current_user, message, error).deliver_later
    else
      record.process_duplicates
      message = "The duplicates for #{model_class} #{model_id} were successfully resolved."
      RadbearMailer.simple_message(current_user, message, message).deliver_later
    end
  end

  def cleanup_duplicate(key, model, record, current_user)
    error = nil
    duplicate_record = model.find_by(id: key)
    if duplicate_record
      if Pundit.policy!(current_user, duplicate_record).destroy?
        duplicate_record.clean_up_duplicate(record)
        duplicate_record.reload
        unless duplicate_record.destroy
          error = "Could not remove the unused duplicate record id #{duplicate_record.id}: #{duplicate_record.errors.full_messages.join(', ')}"
        end
      else
        error = 'You do not have authorization to merge these duplicates.'
      end
    else
      error = 'Invalid record data, perhaps something has changed or another user has resolved these duplicates.'
    end

    error
  end
end
