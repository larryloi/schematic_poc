errfile = ARGV[0]
smtp_host = ARGV[1]
subject = ARGV[2]
recipients = ARGV[3]
sender = ARGV[4]
service = ARGV[5]
env = ARGV[6]

require 'net/smtp'
require 'socket'

#ARGV.each do|a|
#  puts "Argument: #{a}"
#end
msg = File.readlines(errfile).join()
recipients_list = recipients.gsub('"','').gsub("'",'').gsub(',',';').split(';')

mail_header = "From: No-Reply #{sender}\n"\
              "To: #{recipients_list}\n"\
              "Subject: #{subject}\n\n"\
              "Report Detail.\n"\
              "Severity: Sev.2\n"\
              "Host: #{Socket.gethostname}\n"\
              "Service: #{service}\n"\
              "Environment: #{env}\n"\
              "Detected at: #{Time.now.utc}\n\n"

Net::SMTP.start(smtp_host, 25) do |smtp|
  smtp.send_message mail_header + msg,
  sender,
  recipients_list
end


