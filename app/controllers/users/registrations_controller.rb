# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    pre_user = User.select(:id).count
    super
    after_user = User.select(:id).count
    sync_score if pre_user < after_user
  end

  def destroy
    Slack::UserDispatcher.delete_user_notify(current_user.id)
    super
  end

  private

  def sync_score
    iidxid = request.env['rack.request.form_hash']['user']['iidxid']
    user_id = User.find_by(iidxid: iidxid).try(:id)
    return unless user_id
    Slack::UserDispatcher.new_register_notify(user_id)
    unless SidekiqDispatcher.exists?
      Slack::SidekiqDispatcher.notify
      return
    end
    ManagerJob.perform_later(user_id)
    IidxmeJob.perform_later(user_id)
  end
end
