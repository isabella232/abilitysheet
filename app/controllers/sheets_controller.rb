class SheetsController < ApplicationController
  before_action :set_sheet

  def power
    @sheets = Sheet.active.preload(:static)
  end

  def clear
    @sheets = @sheets.order(:ability, :title)
  end

  def hard
    @sheets = @sheets.order(:h_ability, :title)
  end

  private

  def version_check
    @sheets = @sheets.where(version: params[:version]) if params[:version] && params[:version] != '0'
  end

  def set_sheet
    @sheets = Sheet.active
    version_check
    @state_examples = {}
    7.downto(0) { |j| @state_examples[Score.list_name[j]] = Score.list_color[j] }
    @power = Sheet.power
    s = User.find_by(iidxid: params[:iidxid]).scores.where(sheet_id: @sheets.map(&:id))
    @color = Score.convert_color(s)
    @list_color = Score.list_color
    @stat = Score.stat_info(s)
    @versions = [['5',    5,  'btn btn-link'],
                 ['6',    6,  'btn btn-link'],
                 ['7',    7,  'btn btn-link'],
                 ['8',    8,  'btn btn-link'],
                 ['9',    9,  'btn btn-link'],
                 ['10',   10, 'btn btn-link'],
                 ['RED',  11, 'btn btn-danger'],
                 ['HS',   12, 'btn btn-primary'],
                 ['DD',   13, 'btn btn-default'],
                 ['GOLD', 14, 'btn btn-info'],
                 ['DJT',  15, 'btn btn-success'],
                 ['EMP',  16, 'btn btn-danger'],
                 ['SIR',  17, 'btn btn-primary'],
                 ['RA',   18, 'btn btn-warning'],
                 ['Lin',  19, 'btn btn-default'],
                 ['tri',  20, 'btn btn-primary'],
                 ['SPD',  21, 'btn btn-warning'],
                 ['PEN',  22, 'btn btn-danger'],
                 ['ALL',  0,  'btn btn-success']]
  end
end
