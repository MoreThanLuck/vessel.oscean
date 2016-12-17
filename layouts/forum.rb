#!/bin/env ruby
# encoding: utf-8

class CorpseHttp # Layout

  def style
    
     return "<style>
thread { display: block;font-family: monospace;font-size: 14px;line-height: 30px;border-top: 1px solid #ccc;}
thread comment { display:block;}
thread a { text-decoration:underline}
thread .timestamp { color:#999 }
thread .activity { color:#000}
p.error { background:red; color:white}
p.success { background:#72dec2}
</style>"
     
  end
  
  def view
    
    html = "\n"
    html += "<p>The {_/forum_} displays a collection of active topics across {{Nataniev}}.</p>\n".markup
    html += "<p>New topics can be created by adding the suffix {_:forum_} to any search query.</p>".markup
 
    if @module
      html += run_command(@module)+"\n"
    end
    
    # List topics
    
    comments = Memory_Array.new("forum",@host.path)
    
    topics = {}
    comments.to_a("comment").reverse.each do |comment|
      if !topics[comment.topic]
        topics[comment.topic] = {}
        topics[comment.topic]['threads'] = []
        topics[comment.topic]['replies'] = []
        topics[comment.topic]['active'] = comment.timestamp
      end
      if comment.nest
        topics[comment.topic]['replies'].push(comment)
      else
        topics[comment.topic]['threads'].push(comment)
      end
    end
    
    topics.each do |topic,content|
      html += "<thread>"
      html += "<span class='activity'>#{content['replies'].length.to_s.prepend('0',2)}#{content['threads'].length.to_s.prepend('0',2)}</span> <a href='/#{topic}:forum'>#{topic}</a> <span class='timestamp'>#{content['active'].ago}</span>\n"
      html += "</thread>"
    end
  
    return html

  end
  
  def run_command cmd
    
    topic   = nil
    reply   = nil
    message = cmd.gsub('+',' ')
    
    if message.split(" ").first[0,6] == "topic-"
      topic = message.split(" ")[0].split("-").last
      message = message.sub("topic-#{topic}","").strip
    end

    if message.split(" ").length > 0 && message.split(" ").first[0,6] == "reply-"
      reply = message.split(" ")[0].split("-").last.to_i
      message = message.sub("reply-#{reply}","").strip
    end
    
    comments = Memory_Array.new("forum",@host.path)

    # Check if topic exists
    if topic.to_s == "" || message.to_s == "" then return "<p class='error'>Something went wrong with the topic attached.</p>" end
    
    message = message.gsub(',,','.')

    # Check for badwords
    bad_dict = ["dick","pussy","asshole","nigger"]
    bad_dict.each do |word|
      if message.include? word then return "<p class='error'>You cannot use the word <i>#{word}</i> on the forum.</p>" end
    end
    
    # Check if message already exists
    comments.to_a("comment").each do |comment|
      if !comment.message then next end
      if !comment.topic.to_s.like(topic) then next end
      if comment.message.to_s.downcase.gsub(/[^a-z0-9\s]/i, '').like(message.downcase.gsub(/[^a-z0-9\s]/i, '')) then return "<p class='error'>Your comment is a duplicate.</p>" end
    end

    # Save
    comments.append("#{Timestamp.new.to_s.append(' ',14)} #{topic.to_s.capitalize.append(' ',20)} #{reply.to_s.append(' ',4)} #{message}")
    
    return "<p>Your comment on <a href='/#{topic}:forum'>#{topic}</a> has been saved.</p>"
    
  end
  
end
