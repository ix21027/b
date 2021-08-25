require 'telegram/bot'
require 'nokogiri'
require 'open-uri'

token = ENV['TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
  	begin
    	case message
    	when Telegram::Bot::Types::Message
    	  case message.text
    	  when '/start'
    	    bot.api.send_message(chat_id: message.chat.id, text: 'helo')
    	  when '/today'
      	    m = Nokogiri::HTML(URI.open('https://rivendel.ru/today.php?idr=7')).at(".today")
  				useless = %w[//script //a[contains(.,'>>')]  //a[contains(.,'<<')] ins #region_select_switcher]
  				m.search(*useless).map { _1.remove }
  				m.search('br').map {_1.content="\n"}
  			        doc = m.text.split("\n").map {_1.strip }.filter {!_1.empty?}.join("\n").squeeze(" ").scan /.{1,4096}/m
  				doc.map { bot.api.send_message(chat_id: message.chat.id, text: _1.gsub("\n    ", '')) }
    	  when '/dream'
      	    m = Nokogiri::HTML(URI.open('https://rivendel.ru/dream_lenta.php?idr=7')).at('.workarea')
            m.search('//script').map { _1.remove }
            m.search(%w[ins #region_select_switcher]).map { _1.remove }
            
            doc = m.text.split("\n").drop(1).uniq.join("\n").scan(/(.{1,4096})/m).flatten
            bot.api.send_message(chat_id: message.chat.id, text: doc[0])
    	  end
    	end
    rescue => e
      p e
    end	
  end
end
