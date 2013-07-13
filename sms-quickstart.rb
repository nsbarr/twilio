require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
 
enable :sessions 

request_log = Hash.new                              # topic -> phone number. this should match phone numbers 
                                                    # with topics so we know who to text poems to across all sessions

poem = "foo"                                        # just introduce poem variable

get '/' do                                          # placeholder webview for homepage
  erb :index
end

get '/sms-quickstart' do
  

  poets = ["+14782277137"]                          # array of poets
  poet_to_send_to = ["+14782277137"].sample         # pick random poet
  
  session["counter"] ||= 0                          # keeps track of messages the user has sent
    
  
  if params[:Body] == "counter"                     # behavior for special keyword "counter"
    message = session["counter"]
    
  elsif params[:Body] == "reset"                    # behavior for special keyword "reset"
    session["counter"] = -1
  
  elsif poets.include? params[:From]                # if the text is from the poet...
    if session["counter"] == 0                      # and counter is 0
      poem = params[:Body]                          # the text is the poem 
      message = "Thanks for the poem! Can you remind me the topic?"
    elsif session["counter"] == 1                   # if the counter is 1
      topic = params[:Body]                         # the text is the topic.
      message = "Got it, thanks!"
      
      if request_log[topic] == nil                  # if the topic doesn't map to a phone number throw an error.
        message = "Hm, I don't recognize that topic. Try again?"
        session["counter"] = 0                      # set the counter to 0. it should increment up to 1 at the end of the GET
      else                                          # otherwise send the poem to the topic requester.
      #twilio info
      twilio_sid = "ACfff561dd3ac397a29183f7bf7d68e370"
      twilio_token = "cbb3471db9d83b61598159b5210404f1"
      twilio_phone_number = "+16464900303"
      @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token
      @twilio_client.account.sms.messages.create(
          :from => twilio_phone_number,
          :to => request_log[topic],
          :body => poem
      )
      session["counter"] = -1                       # set the counter to -1. it should increment up to 0 at the end of the GET
      end
    else                                            # the poet should always be in a counter state of 0 or 1. error handling.
      message = "We're in a weird place. check counter"
    end
  
  elsif !poets.include? params[:From]
    if session["counter"] == 0
      message = "Hi there, what would you like me to write you a poem about?"
    elsif session["counter"] == 1
      requester = params[:From]
      topic = params[:Body]
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
      message = "I think you've had enough poetry for today. Try again tomorrow!" 
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
