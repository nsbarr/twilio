require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
 
enable :sessions

get '/sms-quickstart' do
  

  poets = ["+14782277137"] #array of poets
  poet_to_send_to = ["+14782277137"].sample
  request_log = Hash.new # topic -> phone number
  poem = "foo"
  session["counter"] ||= 0 #keeps track of messages the user has sent
    
  session["request_status"] ||= 0
  # 0 = no request initiated
  # 1 = request initiated, waiting for poem
  # 2 = poem sent
  
  poem_status = session["request_status"]
  
  if params[:Body] == "counter"
    message = session["counter"]
  elsif params[:Body] == "poemstatus"
    message = poem_status
  elsif params[:Body] == "reset"
    session["counter"] = -1
    poem_status = 0
  
  elsif poets.include? params[:From]
    if session["counter"] == 0
      poem = params[:Body] #the body is the poem 
      message = "Thanks for the poem! Can you remind me the topic?"
    elsif session["counter"] == 1 
      topic_reminder = params[:Body]
      message = "Got it, thanks!"
      #twilio info
      twilio_sid = "ACfff561dd3ac397a29183f7bf7d68e370"
      twilio_token = "cbb3471db9d83b61598159b5210404f1"
      twilio_phone_number = "+16464900303"
      @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token
      @twilio_client.account.sms.messages.create(
          :from => twilio_phone_number,
          :to => request_log[topic_reminder],
          :body => poem
      )
    else
      message = "Hush now, poet."
    end
  
  elsif !poets.include? params[:From]
    if session["counter"] == 0
      message = "Hi there, what would you like me to write you a poem about?"
    elsif session["counter"] == 1
      requester = params[:From]
      request_log[topic] = requester
      message = "OK, I'll write a poem about #{topic}. Give me a few minutes, will ya?"
      #twilio info
      twilio_sid = "ACfff561dd3ac397a29183f7bf7d68e370"
      twilio_token = "cbb3471db9d83b61598159b5210404f1"
      twilio_phone_number = "+16464900303"
      @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token

      @twilio_client.account.sms.messages.create(
        :from => twilio_phone_number,
        :to => poet_to_send_to,
        :body => "Oh hey, won't you write someone a poem about #{topic}? Just post your poem as a reply."
        )
    else
      message = "hush now, requester." 
    end
  else 
    message = "This is message number #{session["counter"]} and I don't know how to handle it."
  end 
  twiml = Twilio::TwiML::Response.new do |r|
    r.Sms message
  end
  session["counter"] += 1
  twiml.text
end 
