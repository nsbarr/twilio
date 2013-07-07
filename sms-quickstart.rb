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
  else
  
  case poem_status
    
  when 0
    if poets.include? params[:From] && session["counter"] == 0 # if this is the first message from a poet, we should assume it's a poem.
      poem = params[:Body] #the body is the poem 
      message = "Thanks for the poem! Can you remind me the topic?"
    elsif poets.include? params[:From] && session["counter"] == 1 # if this is the second message from a poet, we should assume it's the topic.
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
    elsif poets.exclude? params[:From] && session["counter"] == 0  # it's our first time chatting with the requester
       message = "Hi there, what would you like me to write you a poem about?"
    elsif poets.exclude? params[:From] && session["counter"] == 1 # we just got a request from the user
      topic = params[:Body]
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
      poem_status = 1
    else
      message = "Hey, I'm working on it! These poems don't just write themselves."
    end
  when 1
    if poets.include? params[:From]
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
      poem_status = 2
    else 
      message = "Hey, I'm working on it! These poems don't just write themselves."
    end
  when 2
    if poets.include? params[:From]
      message = "Dude I sent them your poem."
    else 
      message = "Dude you got your poem."
    end
  else
    message = "How did we get here?"
  end
end
  twiml = Twilio::TwiML::Response.new do |r|
    r.Sms message
  end
  session["counter"] += 1
  twiml.text
end 
