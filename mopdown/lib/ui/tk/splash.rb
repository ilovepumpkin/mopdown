require 'tk'
require 'ui/tk/util'

@@font='simsun 9 normal'
module TkUi
  class Splash<TkToplevel
    def initialize
       logo_image=TkPhotoImage.new{file "../images/logo.gif"}
              
       main_panel=TkLabel.new(self) do
            text "MopDown正在加载中..."
            image logo_image
            compound 'left'
            pack 'side'=>'left','fill'=>'both'
            relief 'flat'
            font @@font
          end
          
       
       
       #~ self.overrideredirect(0) 
       
       Tk.mainloop
       
        
    end
    
  end
end