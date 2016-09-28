require 'tk'
require 'ui/tk/util'
require 'ui/tk/widgets'
require 'view'
require 'ui/tk/help'

require 'tk/spinbox'
require 'tk/timer'
require 'service'

include View

module TkUi
   class Reader
      def initialize root,vol
         @vol_viewer=VolViewer.new(vol)
         
         @ctrl_modes={'manul'=>'手工翻页','auto'=>'自动翻页'}
         @ctrl_mode=TkVariable.new("manul")
         @ctrl_mode_text=TkVariable.new(@ctrl_modes[@ctrl_mode.value])
                  
         @title=vol.book_name+"("+vol.vol_name+")"
        
         @r=Window.new('title'=>@title)
         @r.focus()
         
         TkUtil.screen_center(@r,400,300)
                          
         # Key events
         # More keysyms, refer to here: http://www.krugle.org/kse/files?query=keysymdef.h#4
                  
         @r.bind("KeyPress-Prior",proc{
             if @ctrl_mode.value=='manul'
               if @vol_viewer.has_prev?
                  render(@vol_viewer.prev_page.img_path) 
               else
                  Tk.messageBox('message'=>'已到第一页','title'=>'信息','icon'=>'info')
                  @r.focus()
                end
            end
         })
         @r.bind("KeyPress-Next",proc{
             if @ctrl_mode.value=='manul'
                if @vol_viewer.has_next?
                  render(@vol_viewer.next_page.img_path)
                else
                  Tk.messageBox('message'=>'已到最后一页','title'=>'信息','icon'=>'info')
                  @r.focus()
                end
             end
         })
         @r.bind("KeyPress-Down",proc{
             #~ @canvas.yview_moveto(1)
             @canvas.yview_scroll(1, "units")
         })
         @r.bind("KeyPress-Up",proc{
             #~ @canvas.yview_moveto(0)
             @canvas.yview_scroll(-1, "units")
         })
         @r.bind("KeyPress-Left",proc{
             #~ @canvas.xview_moveto(0)
             @canvas.xview_scroll(-1, "units")
         })
         @r.bind("KeyPress-Right",proc{
              #~ @canvas.xview_moveto(1)
              @canvas.xview_scroll(1, "units")
         })
         @r.bind("KeyPress-Escape",proc{to_normal()})
         @r.bind("KeyPress-F1",proc{
            HelpWin.new(@r)
         })
         
         # The panel to place the control buttons
         @ctrl_panel=TkFrame.new(@r,:relief=>'groove').pack(:side=>'bottom','fill'=>'x')
         
         # The button to switch the auto/manul modes
         switch = OptionMenubutton.new(@ctrl_panel, @ctrl_mode,@ctrl_mode_text,@ctrl_modes,proc{change_ctrl_mode}).pack(:side=>'right',:anchor=>'e')
         
         @auto_bar=TkFrame.new(@ctrl_panel)
         TkLabel.new(@auto_bar,'text'=>"时间间隔",:font=>@@font).pack(:side=>'left')         
         interval=TkSpinbox.new(@auto_bar, 'from' =>3, 'to' => 100, 'increment' => 1,:width=>3).pack(:side=>'left')
         TkLabel.new(@auto_bar,'text'=>"(秒)",:font=>@@font).pack(:side=>'left')
         @auto_btn=TkButton.new(@auto_bar,:text=>'开始',:font=>@@font).pack(:side=>'left')
         @auto_btn.command=lambda{
            if @auto_state=='running'
              @timer.stop
              @auto_state='stopped'
              @auto_btn.configure('text'=>"开始")
            else
              interval_value=interval.value.to_i
              if interval_value>0 
                @timer=TkTimer.new(interval_value*1000,-1,proc{render(@vol_viewer.next_page.img_path)})
                @timer.start
                @auto_state='running'
                @auto_btn.configure('text'=>"暂停")
              else
                Tk.messageBox('message'=>'时间间隔值无效！','title'=>'信息','icon'=>'info')
                interval.focus()
              end
            end
         }
         
         # next/pre navigation buttons
         @man_bar=TkFrame.new(@ctrl_panel).pack(:side=>'right',:ipadx=>5,:ipady=>3)
         @btn_pre=TkButton.new(@man_bar,'text'=>'上一页','font'=>@@font).pack('side'=>'left')
         @btn_pre.command=lambda{
            render(@vol_viewer.prev_page.img_path)
         }
         
         @page_status=TkLabel.new(@man_bar) do
            font @@font
            pack 'side'=>'left'            
         end
        
         @btn_next=TkButton.new(@man_bar,'text'=>'下一页','font'=>@@font).pack('side'=>'left')
         @btn_next.command=lambda{
            render(@vol_viewer.next_page.img_path)
         }
         
         # jump buttons
         jump_bar=TkFrame.new(@man_bar).pack(:side=>'right',:ipadx=>5)
         jump_num=TkEntry.new(jump_bar,:width=>5).pack(:side=>'left')
         jump_btn=TkButton.new(jump_bar,:text=>'跳转',:font=>@@font).pack(:side=>'left')
         jump_btn.command=lambda{
            page_num=jump_num.value.to_i
            if page_num>=1 && page_num<=@vol_viewer.page_count
              render(@vol_viewer.jump_to_page(page_num).img_path)
            end
         }
         
          # The button to switch to full screen
         fullscreen=Button.new(@ctrl_panel,:text=>'全屏').pack(:side=>'left',:anchor=>'w',:padx=>5)
         fullscreen.command=lambda{to_fullscreen}
         
         # The panel to display the images
        @main_panel=TkFrame.new(@r).pack(:side=>'top','fill'=>'both','expand'=>'true')
        
        @canvas = TkCanvas.new(@main_panel)
        @vbar = TkScrollbar.new(@main_panel) { orient 'vert' }
        @hbar = TkScrollbar.new(@main_panel) { orient 'horiz' }
        
        @canvas.xscrollbar(@hbar)
        @canvas.yscrollbar(@vbar)


        TkGrid.grid(@canvas, 'row'=>0,'column'=>0,'sticky'=>'ns')
        TkGrid.grid(@vbar, 'row'=>0,'column'=>1,'sticky'=>'ns')
        TkGrid.grid(@hbar,         'sticky'=>'ew')

        TkGrid.columnconfigure(@main_panel, 0, 'weight'=>1)
        TkGrid.rowconfigure(@main_panel, 0, 'weight'=>1)
        
        render(@vol_viewer.first_page.img_path)
        update_page_status(@vol_viewer.page_status)        
      end
      
      def to_normal
        @r.geometry(@geo)
        @main_panel.pack_forget
        @ctrl_panel.pack(:side=>'bottom','fill'=>'x')
        @main_panel.pack(:side=>'top','fill'=>'both','expand'=>'true')
        @r.overrideredirect(0)       
      end
      
      def to_fullscreen
        @geo=@r.geometry
        TkUtil.fullscreen(@r)
        @ctrl_panel.pack_forget
        @r.overrideredirect(1)
      end
      
      def change_ctrl_mode
        if @ctrl_mode.value=='manul'
              @man_bar.pack(:side=>'right',:ipadx=>5,:ipady=>3)
              @auto_bar.pack_forget
              if @timer && @timer.running?
                @timer.stop
                @auto_btn.configure('text'=>"开始")
              end
            else
              @auto_bar.pack(:side=>'right',:ipadx=>5,:ipady=>3)
              @man_bar.pack_forget
            end
        @ctrl_mode_text.value=@ctrl_modes[@ctrl_mode.value]    
      end
      
      def update_page_status status
        @page_status.text(status)
        page_num=@vol_viewer.page_num
        page_count=@vol_viewer.page_count
        
        if page_num<=1
            @btn_pre.configure('state'=>'disabled')
        else
            @btn_pre.configure('state'=>'active')   
        end
          
        if page_num==page_count
            @btn_next.configure('state'=>'disabled')
        else
            @btn_next.configure('state'=>'active')
        end
      end  
      
      def render img_path
         @canvas.yview_moveto(0)
         @canvas.xview_moveto(0)
        
         @canvas.delete("image")
         
         @img.delete if @img # Or the memory leak will occur
         
         @img = TkPhotoImage.new { file img_path }
         
         #~ bbox=TkGrid.bbox(@main_panel, 0, 0)
         #~ bb_w=bbox[2]
         #~ bb_h=bbox[3]
                  
         img_h=@img.height
         img_w=@img.width
         
         @canvas.configure('width'=>img_w)
         @canvas.configure('height'=>img_h)
         
         c_h=@canvas.height
         c_w=@canvas.width
         
         if c_h>img_h
           y=c_h
         else
           y=img_h
         end
         y=y/2
         if c_w>img_w
           x=c_w
         else
           x=img_w
         end
         x=x/2
                  
         @c_img=TkcImage.new(@canvas,x,y,'image'=>@img,'tags'=>'image')
         @canvas.configure('scrollregion'=>'0 0 '+img_w.to_s+' '+img_h.to_s)

         update_page_status(@vol_viewer.page_status)
         @r.configure('title'=>@title+"  "+@vol_viewer.page_status)
      end
   end
end