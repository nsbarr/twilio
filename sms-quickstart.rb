require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
 
enable :sessions
 
get '/sms-quickstart' do
  #sender is the phone number of whoever just texted you
  sender = params[:From]
  #magical sms counter
  session["counter"] ||= 0
  sms_count = session["counter"]
  #for now, always assume we just got the request from the user
  topic = params[:Body]
  #logic on what to send the user
  if sms_count == 0
    message = "Hi there, what would you like me to write you a poem about?"
  else
    message = "OK, I'll write a poem about #{topic}"
  end
  twiml = Twilio::TwiML::Response.new do |r|
    r.Sms message
  end
  session["counter"] += 1
  twiml.text
end