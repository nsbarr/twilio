require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
 
enable :sessions

get '/sms-quickstart' do
  #twilio info
  twilio_sid = "ACfff561dd3ac397a29183f7bf7d68e370"
  twilio_token = "cbb3471db9d83b61598159b5210404f1"
  twilio_phone_number = "+16464900303"
  #list of poets 
  poet_to_send_to = ["4782277137"].sample
  #sender is the phone number of whoever just texted you
  sender = params[:From]
  #magical sms counter
  session["counter"] ||= 0
  sms_count = session["counter"]
  #i need a line of code to check whether the app has written a poem for this session yet.
  session["gotpoem"] ||= false
  #for now, always assume we just got the request from the user
  topic = params[:Body]
  #logic on what to send the user
  if sms_count == 0 #ask the user for a topic
    message = "Hi there, what would you like me to write you a poem about?"
  elsif sms_count == 1 #acknowledge topic and send request to poet
    message = "OK, I'll write a poem about #{topic}. Give me a few minutes, will 'ya?"
    @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token

    @twilio_client.account.sms.messages.create(
      :from => "+1#{twilio_phone_number}",
      :to => poet_to_send_to,
      :body => "Oh hey, won't you write someone a poem about #{topic}? Just post your poem as a reply."
      )
  else #tell the user to calm down
    message = "Hey, I'm working on it! These poems don't just write themselves."
  end
  twiml = Twilio::TwiML::Response.new do |r|
    r.Sms message
  end
  session["counter"] += 1
  twiml.text
end