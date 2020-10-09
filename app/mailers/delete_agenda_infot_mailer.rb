class DeleteAgendaInfotMailer < ApplicationMailer
  def delete_agenda_infot_mail(informed_members)
    @informed_members = informed_members
    mail to: @informed_members.map(&:email), subject: 'inform_delete_agenda'
  end
end
