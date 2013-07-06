require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
 
enable :sessions
 
get '/sms-quickstart' do
  sender = params[:From]
  friends = {
    "+19143934990" => "Curious George",
  }
  name = friends[sender] || "Mobile Monkey"
  twiml = Twilio::TwiML::Response.new do |r|
    r.Sms "Hello, #{name}. Thanks for the message."
  end
  twiml.text
end