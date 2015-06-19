class SheetWorker
  include Sidekiq::Worker
  sidekiq_options queue: :sheet
  sidekiq_options retry: false

  def perform(id)
    puts %(#{Time.now} sheet_id: #{id} => create score and static start)
    version = Abilitysheet::Application.config.iidx_version
    User.all.each { |u| Score.create(user_id: u.id, sheet_id: id, version: version) }
    d = 99.99
    Static.create(
      sheet_id: id,
      fc: d, exh: d, h: d, c: d, e: d, aaa: d
    )
    puts %(#{Time.now} sheet_id: #{id} => create score and static end)
  end
end
