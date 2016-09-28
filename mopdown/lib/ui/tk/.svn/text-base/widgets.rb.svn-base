require 'tk'

module TkUi
  class Window<TkToplevel
     def initialize *args
       super(*args)
       icon=TkPhotoImage.new{file File.join($image_dir,'logo.gif')}
       self.iconphoto(icon)
     end
   end
   
   class Button<TkButton
     def initialize *args
       super(*args)
       self.configure('font'=>@@font)
     end
   end  
   
   class Label<TkLabel
     def initialize *args
       super(*args)
       self.configure('font'=>@@font)
     end
   end 

   class OptionMenubutton<TkOptionMenubutton
      def initialize(parent,value_var,label_var,hash,opt_cmd)
        init_value=value_var.value
        @label_var=label_var
        @opt_cmd=opt_cmd
        
        @hash=hash
        values=hash.keys
        super(parent,value_var,*values)
        @variable.value=init_value
        
        values.each_index{|i|
            entryconfigure(i,'command',proc{exec})
            entryconfigure(i,'label',@hash.values[i])
            entryconfigure(i,'variable',@variable)
        }
        
        configure("textvariable"=>@label_var)    
        configure("font"=>@@font)    
      end
      
      private :exec
      def exec
        @label_var.value=@hash[self.value]
        @opt_cmd.call
      end

    end
   
end