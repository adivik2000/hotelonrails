class ReportMailer < ActionMailer::Base
  default :from => "brightspark@gmail.com"

  def daily_report(checkins)
    logger.info('here')
    @checkins = checkins
    logger.info(@checkins)
    mail(:to => "sachin@ednexa.com",
     :subject => "Daily Report")
  end
end
