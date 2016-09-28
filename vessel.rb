#!/bin/env ruby
# encoding: utf-8

class Oscea

  include Vessel

  class Corpse

    include CorpseHttp

  end

  class PassiveActions

    include ActionCollection

    def answer q = "Home"

      path = File.expand_path(File.join(File.dirname(__FILE__), "/"))
      load_folder("#{path}/objects/*")

      page   = Page.new(q.include?(":") ? q.split(":") : q)
      page.path = path
      page.start

      corpse = Corpse.new(q)
      corpse.add_meta("description","Works of Devine Lu Linvega")
      corpse.add_meta("keywords","aliceffekt, traumae, devine lu linvega")
      corpse.add_meta("viewport","width=device-width, initial-scale=1, maximum-scale=1")
      corpse.add_meta("apple-mobile-web-app-capable","yes")

      corpse.add_link("style.reset.css")
      corpse.add_link("style.main.css")

      corpse.add_script("jquery.core.js")
      corpse.add_script("jquery.main.js")

      corpse.set_view(page.view)

      corpse.set_title("XXIIVV ∴ #{page.term.name}")
      corpse.set_style(page.style)
      
      return corpse.result

    end

  end
  
  def passive_actions ; return PassiveActions.new(self,self) end

end