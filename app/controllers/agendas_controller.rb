class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda')
    else
      render :new
    end
  end

  def destroy
    agenda = Agenda.find(params[:id])
     team_members = agenda.team.members

     agenda_user = agenda.user_id
     owner_id = agenda.team.owner_id
     puts "agenda_user:#{agenda_user}"
     puts "owener_id:#{owner_id}"
     puts "current_user:#{current_user.id}"

     if current_user.id != agenda_user && current_user.id != owner_id
       redirect_to dashboard_url, notice: 'agendaの作成者及びチームリーダーのみ削除できます。'
     elsif agenda.destroy
       team_members.each do | member |
         AssignMailer.del_agenda_mail(member.email, agenda.title).deliver
       end
       redirect_to dashboard_url, notice: 'アジェンダを削除しました。'
     else
       redirect_to dashboard_url, notice: '削除に失敗しました。'
     end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end

end
