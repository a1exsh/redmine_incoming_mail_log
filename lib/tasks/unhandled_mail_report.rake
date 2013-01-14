namespace :redmine do
  namespace :incoming_mail do
    desc 'Report unhandled mail'
    task :report_unhandled, [:date] => :environment do |t, args|
      IncomingMail.unhandled.received_on(args[:date] || Date.today).report!
    end
  end
end
