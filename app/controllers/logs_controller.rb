# frozen_string_literal: true

class LogsController < ApplicationController
  before_action :special_user!, only: %w[update_official]
  before_action :load_user, only: %w[sheet list show]

  def edit
    @log = current_user.logs.find(params[:id])
    render :show_modal
  end

  def update
    log = current_user.logs.find(params[:id])
    log.update(log_params) if params['log']['created_date'].to_date
    render :reload
  end

  def sheet
    @color = Static::COLOR
    @title = 'クリア推移表'
    @sheets = ClearingTransitionTableService.new(@user).execute
  end

  def list
    per_num = 10
    logs = @user.logs.order(created_date: :desc).select(:created_date).distinct
    @logs = logs.page(params[:page]).per(per_num)
    @total_pages = (logs.count / per_num.to_f).ceil
  end

  def manager
    if SidekiqDispatcher.exists?
      ManagerJob.perform_later(current_user.id)
      flash[:notice] = %(同期処理を承りました。逐次反映を行います。)
      flash[:alert] = %(反映されていない場合はマネージャに該当IIDXIDが存在しないと思われます。(登録しているけどIIDXIDを設定していないなど))
    else
      sidekiq_notify
    end
    render :reload
  end

  def iidxme
    if ENV['iidxme'] != 'true'
      flash[:alert] = %(現在動作確認を行っていないため停止中です)
    elsif SidekiqDispatcher.exists?
      IidxmeJob.perform_later(current_user.id)
      flash[:notice] = %(同期処理を承りました。逐次反映を行います。)
      flash[:alert] = %(反映されていない場合はIIDXMEに該当IIDXIDが存在しないと思われます。(登録していないなど))
    else
      sidekiq_notify
    end
    render :reload
  end

  def ist
    if SidekiqDispatcher.exists?
      IstSyncJob.perform_later(current_user)
      flash[:notice] = %(同期処理を承りました。逐次反映を行います。)
      flash[:alert] = %(反映されていない場合はISTに該当IIDXIDが存在しないと思われます。(登録しているけど一度もIST側でスコアを送っていないなど))
    else
      sidekiq_notify
    end
    render :reload
  end

  def show
    date = params[:date].to_date
    @logs = Log.where(user_id: @user.id, created_date: date).preload(:sheet)
    unless @logs.present?
      render_404
      return
    end
    @prev_update, @next_update = Log.prev_next(@user.id, date)
    @color = Static::COLOR
  end

  def destroy
    log = current_user.owner? ? Log.find(params[:id]) : current_user.logs.find(params[:id])
    if log
      flash[:notice] = "#{log.title}のログを削除し，状態を戻しました"
      log.destroy
    else
      flash[:notice] = '存在しないログデータです'
    end
    render :reload
  end

  private

  def sidekiq_notify
    flash[:alert] = '不具合により更新できませんでした。しばらくこの症状が続く場合はお手数ですがご一報下さい'
    Slack::SidekiqDispatcher.notify
  end

  def load_user
    @user = User.find_by_iidxid!(params[:id])
  end

  def log_params
    params.require(:log).permit(:created_date)
  end
end
