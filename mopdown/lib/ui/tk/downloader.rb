require 'tk'
require 'ui/tk/util'
require 'ui/tk/widgets'
require 'util'

module TkUi
  class ProgressBar
    def initialize(parent,bar_width,bar_height)
       @h_margin=5
       @w_margin=5
       @bar_width=bar_width
       @bar_height=bar_height
              
       @c=TkCanvas.new(parent,'height'=>@bar_height,'width'=>@bar_width).pack('padx'=>0,'pady'=>0,'fill'=>'both','expand'=>true)
       @c.create(TkcRectangle, 0, 0, @bar_width, @bar_height, 'fill'=>'grey','width'=>0)
    end
     
    def update(per_value)
      @c.delete("pbar")
      if per_value>=0.99
         bar_color='green'
      else
         bar_color='orange'
      end      
      @c.create(TkcRectangle, @w_margin, @h_margin, @w_margin+((@bar_width-2*@w_margin)*per_value).to_i, @bar_height-@h_margin, 'fill'=>bar_color,'tags'=>'pbar','width'=>0)
    end      

  end

  class Downloader
     def initialize root,vol
       @book_name=vol.book_name
       @vol=vol
       
       @d=Window.new('title'=>"下载任务："+@book_name+"("+vol.vol_name+")")
       
       g=TkUtil.center(root,450,200)
       @d.geometry(g)
       
       # progress bar
       frm_progress=TkFrame.new(@d).pack('side'=>'top','fill'=>'x')
       frm_progress_bar=TkFrame.new(frm_progress).pack('side'=>'left','fill'=>'x')
       progress_bar=ProgressBar.new(frm_progress_bar,390,30)
       progress_text=TkLabel.new(frm_progress,'background'=>'#ece9d8','relief'=>'groove').pack('side'=>'left','expand'=>'true','pady'=>2,'fill'=>'both')
       
       # status message output
      frm_msg=TkFrame.new(@d).pack('side'=>'top','expand'=>true,'fill'=>'both')            
      msg_list=TkListbox.new(frm_msg,'font'=>@@font,'selectmode'=>'single','background'=>'#ece9d8','relief'=>'groove').pack('side'=>'left','fill'=>'both','expand'=>'true')
      scroll_bar = TkScrollbar.new(frm_msg) do
        orient 'vertical'
        command {|*args| msg_list.yview(*args) }
        pack 'side' => 'left', 'fill' => 'y'
      end
      msg_list.yscrollcommand {|first,last| scroll_bar.set(first,last) }
       
       #buttons panel
       frm_buttons=TkFrame.new(@d).pack('side'=>'bottom')
       
       frm_count=TkFrame.new(frm_buttons).pack('side'=>'left',:padx=>10,:pady=>2)
       count_label=TkLabel.new(frm_count,:font=>@@font,:text=>"同时下载数:").pack(:side=>'left')
       count=TkSpinbox.new(frm_count, 'from' =>3, 'to' => 100, 'increment' => 1,:width=>3).pack(:side=>'left')

       down_state="running"
       btn_ctrl=TkButton.new(frm_buttons,'text'=>'暂停','font'=>@@font).pack('side'=>'left','padx'=>10,'pady'=>2)
       btn_ctrl.command=lambda{
          begin
             if down_state=="running"
                @helper.stop
                btn_ctrl.configure('text'=>'继续')
                down_state="pause"
             else
                @helper.start(count.value)
                btn_ctrl.configure('text'=>'暂停')
                down_state="running"
             end   
          end
       }
              
       btn_cleartext=TkButton.new(frm_buttons,'text'=>'清除信息','font'=>@@font).pack('side'=>'left','padx'=>10,'pady'=>2)
       btn_cleartext.command=lambda{ msg_list.delete(0,'end') }
       
       btn_cancel=TkButton.new(frm_buttons,'text'=>'结束','font'=>@@font).pack('side'=>'left','padx'=>10,'pady'=>2)
       btn_cancel.command=lambda{
          begin
             @helper.stop
             @d.withdraw
          end
       }
       
       btn_preview=TkButton.new(frm_buttons,'text'=>'预览','font'=>@@font).pack('side'=>'left','padx'=>10,'pady'=>2)
       btn_preview.command=lambda{
          begin
             Reader.new(@d,@vol)
          end
       }
       
       # start to download
       @helper=Util::VolDownHelper.new(@vol,MsgPipe.new(msg_list,progress_bar,progress_text))
       @helper.start(count.value)
    end   
  end
            
  class MsgPipe

    def initialize receiver,progress_bar,progress_text
         @reciever=receiver
         @progress_bar=progress_bar
         @progress_text=progress_text
    end  
      
    def put msg,persent=nil,text=nil
        @reciever.insert('end',msg)
        if persent
          @progress_bar.update(persent)          
        end
        if text
          @progress_text.text(text)
        end
    end
       
  end

end