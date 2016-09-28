#~ def autoload(mod, fname)
#~ end

#~ TkEvent = Module.new
#~ TkPack  = Module.new
#~ TkWinfo = Module.new

require "tk"
#~ require "tk/event"
#~ require "tk/wm"
#~ require "tk/label"
#~ require "tk/font"
#~ require "tk/virtevent"
#~ require "tk/entry"
#~ require "tk/listbox"
#~ require "tk/scrollbar"
#~ require "tk/text"
#~ require "tk/grid"
#~ require "tk/winfo"
#~ require "tk/button"
#~ require "tk/pack"
#~ require "tk/root"
#~ require "tk/package"
#~ require "tk/image"
require "tkextlib/tkimg/jpeg"
#~ require "tk/variable"
#~ require "tk/menubar"
#~ require "tk/frame"
#~ require "tk/canvas"
#~ require "tk/bindtag"
#~ require "tk/menuspec"
#~ require "tk/toplevel"
#~ require "tk/menu"
#~ require "tk/spinbox"

require "rubyscript2exe"

require 'service'
require 'model'
require 'ui/tk/downloader'
require 'ui/tk/cat_downloader'
require 'ui/tk/reader'
require 'ui/tk/aboutwin'
require 'ui/tk/widgets'
require 'util'

include Model
include Service
include Util

@@font='simsun 9 normal'

module TkUi

class MainUi
  # three values: my_books, letters, search
    
  def initialize
    @na_img=File.join($image_dir,'na.jpg')
    @view_modes={'letters'=>'字母索引','search'=>'本地搜索','my_books'=>'我的书库'}
    
    @view_mode=TkVariable.new('my_books')
    @view_mode_text=TkVariable.new(@view_modes[@view_mode.value])
    
    @service=FileDataService.instance
    
    @root=TkRoot.new{title '猫扑漫画 - MopDown'}
    icon=TkPhotoImage.new{file "../images/logo.gif"}
    @root.iconphoto(icon)
    build_menus @root
    build_statusbar @root
    build_toolbar @root
    build_catalog @root
    build_thumb_panel @root

    chg_view_mode()
    
    exit if RUBYSCRIPT2EXE.is_compiling?
    Tk.mainloop
  end
  
  def chg_view_mode
    @toolbar.pack_slaves.each{|w|
      w.pack_forget
    }
    
    reset
    
    if @view_mode=='letters'
      @letters_bar.pack    
      switch_text="字母索引"      
    elsif @view_mode=='search'
      @search_bar.pack
      if !@service.si_exists?
        say_msg('正在构建搜索索引...')
        @service.build_search_index
        say_msg('成功构建搜索索引！')
      end
      switch_text="本地搜索"  
    elsif @view_mode=='my_books'
      @lib_bar.pack      
      display_mybooks()      
      switch_text="我的书库"
    end
    
    @view_mode_text.value=@view_modes[@view_mode.value]
    
    #~ @view_mode_switch.text(switch_text)
  end
  
  def display_mybooks
      books=@service.get_mybooks
      @@catalog_list.delete(0,@@catalog_list.size-1)
      books.each{|b_name|
         @@catalog_list.insert('end',b_name)
      }
      lib_info="您共有"+books.size.to_s+"本藏书"
      @lib_bar.text(lib_info)
    end
    
  def popup_catdownloader
     Thread.new do
        TkUi::CatDownloader.new(@root)
     end
  end

  def build_menus parent
        menu_spec=[        
        [['文件'],
            {:label=>'退出',:command=>proc{exit}}],
        [['视图'],
           ['目录模式',[
             {:type=>'radiobutton',:label=>'字母索引',:command=>proc{chg_view_mode},:variable=>@view_mode,:value=>'letters'},
             {:type=>'radiobutton',:label=>'我的书库',:command=>proc{chg_view_mode},:variable=>@view_mode,:value=>'my_books'},
             {:type=>'radiobutton',:label=>'本地搜索',:command=>proc{chg_view_mode},:variable=>@view_mode,:value=>'search'}
           ]]
        ],
        [['工具'],
            {:label=>'下载目录',:command=>proc{popup_catdownloader}}],
        [['帮助'],
            {:label=>'关于',:command=>proc{AboutWin.new(@root)}}]
        ]
    
        menubar = TkMenubar.new(parent, menu_spec,
                        'tearoff'=>false,'font'=>@@font)

        menubar.pack('side' => 'top', 'fill' => 'x')
      end
      
    def build_toolbar parent
        #tool frame
        @toolbar=TkFrame.new(parent,'borderwidth'=>2,'relief'=>'groove').pack('side'=>'top','fill'=>'x')
        
        #letters bar
        @letters_bar=TkFrame.new(@toolbar)
        frm_letters_1=TkFrame.new(@letters_bar).pack('side'=>'top')
        ('A'..'Z').each{|letter|
            btn=TkButton.new(frm_letters_1,'text'=>letter).pack('side'=>'left')
            btn.configure('state'=>'disabled') unless @service.letter_exists?(letter)
            btn.command=lambda{
              begin
                subcat=@service.load_subcat(letter.downcase)
                @cat_viewer=LetterCatViewer.new(subcat)        
                display_page(@cat_viewer.first_page )
              end
            }
        }
        
        #search bar
        @search_bar=TkFrame.new(@toolbar)
        s_key=TkEntry.new(@search_bar,:font=>@@font,'relief'=>'groove').pack('side'=>'left')
        s_btn=TkButton.new(@search_bar,'text'=>'搜索',:font=>@@font).pack('side'=>'left')
        s_btn.command=lambda{
           key=s_key.value.lstrip.rstrip
           search(key)
        }
        s_key.bind('KeyPress-Return',proc{search(s_key.value.lstrip.rstrip)})
        
        #my books bar
        @lib_bar=TkLabel.new(@toolbar,'text'=>'library info',:font=>@@font)
      end
      
    def search key
          if key!=''
              @@catalog_list.delete(0,@@catalog_list.size-1)
              results=SearchUtil.instance.search_byname(key)
              results.each{|sii|
                 @@catalog_list.insert('end',sii.book_name)
              }
           else
              Tk.messageBox('message'=>'请输入关键字','title'=>'警告','icon'=>'warn')
           end
    end
      
    def display_page page
        @@curr_page_num.text(@cat_viewer.page_status)
        
        @@catalog_list.delete(0,@@catalog_list.size-1)
        page.thumb_list.each{|t|
           @@catalog_list.insert('end',t.book_name)
        }
        
        update_btn_state     
    end
      
    def update_btn_state        
        page_num=@cat_viewer.page_num
        page_count=@cat_viewer.page_count
        
        if page_num<=1
            @@pre_btn.configure('state'=>'disabled')
        else
            @@pre_btn.configure('state'=>'active')   
        end
          
        if page_num==page_count
            @@next_btn.configure('state'=>'disabled')
        else
            @@next_btn.configure('state'=>'active')
        end
      end
      
    def build_statusbar parent
      status_panel=TkFrame.new(parent,'borderwidth'=>1,'relief'=>'groove').pack(:side=>'bottom',:fill=>'x')
      @statusbar_w=TkLabel.new(status_panel,'relief'=>'flat','font'=>@@font).pack('side'=>'left','fill'=>'both','expand'=>true)
      
      switch = OptionMenubutton.new(status_panel, @view_mode,@view_mode_text,@view_modes,proc{chg_view_mode}).pack(:side=>'right',:anchor=>'e')
      
    end      
        
    def build_catalog parent
      #list frame
      frm_catalog=TkFrame.new(parent).pack('side'=>'left','fill'=>'y')
      
      #paging buttons
      frm_paging=TkFrame.new(frm_catalog).pack('side'=>'bottom','fill'=>'x')
      @@pre_btn=TkButton.new(frm_paging,'text'=>'上一页','state'=>'disabled','font'=>@@font).pack('side'=>'left')
      @@pre_btn.command=lambda{
        display_page(@cat_viewer.prev_page) if @cat_viewer.has_prev?
      }
      
      @@curr_page_num=TkLabel.new(frm_paging){
         text '0/0'
         pack 'side'=>'left'
         justify 'center'
         width 10
      }
      
      @@next_btn=TkButton.new(frm_paging,'text'=>'下一页','state'=>'disabled','font'=>@@font).pack('side'=>'right')
      @@next_btn.command=lambda{
        display_page(@cat_viewer.next_page) if @cat_viewer.has_next?
      }

      #catalog list     
      @@catalog_list=TkListbox.new(frm_catalog,'font'=>@@font,'selectmode'=>'single','background'=>'#ece9d8').pack('side'=>'left','fill'=>'both','expand'=>'true')
      scroll_bar = TkScrollbar.new(frm_catalog) do
        orient 'vertical'
        command {|*args| @@catalog_list.yview(*args) }
        pack 'side' => 'left', 'fill' => 'y'
      end
      @@catalog_list.yscrollcommand {|first,last| scroll_bar.set(first,last) }
      @@catalog_list.bind("ButtonRelease-1") do
        busy do
          #Only when a book is selected, proceed the following code
          return if @@catalog_list.curselection.size==0
            
          book_name = @@catalog_list.get(*@@catalog_list.curselection)
          
          if @view_mode=="letters"
              @book=@cat_viewer.get_page.get_thumb_by_name(book_name)     
              @book.letter=@cat_viewer.letter
          else
              @book=@service.get_thumb(book_name)
          end            
          display_thumb_details(@book)
          
        end
      end
    end
    
    def display_thumb_details book
          book_name=book.book_name
          letter=book.letter
      
          img_name=book.img_url.split('/').last
          img_path=File.join($root_dir,'catalog',letter,'cover',img_name)
          
          # display the command buttons
          if @view_mode=='letters'
            @bookmark.pack(:side=>'right',:padx=>3) unless @service.in_lib?(book)
          elsif @view_mode=='search'
            @bookmark.pack(:side=>'right',:padx=>3) unless @service.in_lib?(book)
          elsif @view_mode=='my_books'
            @delete_book.pack(:side=>'right',:padx=>3)
          end            
          
          #Check if the image has been downloaded. If not, download it right now.
          if !File.exists?img_path
            if !@service.down_cover(letter,book)
              say_msg("下载 《"+book_name+"》封面图片失败，请检查网络连接")
              img_path=@na_img
            else
              say_msg("下载 《"+book_name+"》封面图片成功")
            end  
          end
          
          tmp_img = TkPhotoImage.new { file img_path}
          @@cover_w.copy(tmp_img)
          @@cover_w.pack
          @@cover_label.text(book_name)
          
          @@author_w.text("漫画作者："+book.author)
          
          @@abstract_w.delete('1.0','end')
          @@abstract_w.insert("1.0",book.abstract)
          
          #place the vol download buttons
          clean_btns_area
          
          # Build the buttons to start downloading or reading window.
          col_num=3
          vols=book.vols
          vols.each_index{|i|
            v=vols[i]    
            v.book_name=book_name
            btn_text="[#{v.vol_name}]"            
            existing_page_count=@service.get_finished_page_count(book_name,v)
            
            vol_menu=TkMenu.new(@@frm_vols,'tearoff'=>false)
            
            if existing_page_count==v.page_count
               foreground='blue'
               vol_menu.add('command', 'label'=>'我看！', 'command'=>proc { popup_reader(v) })
               vol_menu.add('command', 'label'=>'我删！', 'command'=>proc { delete_vol(v) })
               image=File.join($image_dir,'full.gif')
            elsif existing_page_count>0
               foreground='red'
               vol_menu.add('command', 'label'=>'我看！', 'command'=>proc { popup_reader(v) })
               vol_menu.add('command', 'label'=>'我下！', 'command'=>proc { popup_downloader(v)})
               vol_menu.add('command', 'label'=>'我删！', 'command'=>proc { delete_vol(v) })
               image=File.join($image_dir,'half.gif')
            else
               foreground='black'
               vol_menu.add('command', 'label'=>'我下！', 'command'=>proc { popup_downloader(v)})
               image=File.join($image_dir,'blank.gif')
             end  
             
            icon=TkPhotoImage.new{file image}
                        
            vol_btn=Label.new(@@frm_vols,'text'=>btn_text,'image'=>icon,'compound'=>'left','relief'=>'flat','padx'=>6,'pady'=>3,'cursor'=>'hand2','foreground'=>foreground).grid('column'=>i%col_num,'row'=>i/col_num,'padx'=>'3','pady'=>'2')
            vol_btn.bind('ButtonPress-1',
              proc{ |x,y| vol_menu.popup( x, y ) },
              "%X %Y"
            ) 
            vol_btn.bind('Enter',proc{vol_btn.configure('background'=>'orange')})
            vol_btn.bind('Leave',proc{vol_btn.configure('background'=>'#ece9d8')})
            
          }
        end
        
    def clean_btns_area
      size=@@frm_vols.grid_size
          col_count=size[0]
          row_count=size[1]
          col_count.times{|col|
            row_count.times{|row|
                @@frm_vols.grid_slaves('column'=>col,'row'=>row).each{|w|
                   w.grid_forget
                }
            }
      }
    end     

    def delete_book book
         confirm=Tk.messageBox(
              'type'=>'yesno',
              'icon'=>'question',
              'title'=>'确认',
              'message'=>'你确定要从您的书库中删除该书内容吗？'
            )
            
            if confirm=='yes'
              flag=Service::FileDataService.instance.delete_book(book)
              if flag
                Tk.messageBox(
                  'type'=>'ok',
                  'icon'=>'info',
                  'title'=>'信息',
                  'message'=>"《"+@book.book_name+"》已成功从您的书库中删除！"
                )
                display_mybooks()
                reset_thumb_view()
              else
                Tk.messageBox(
                  'type'=>'ok',
                  'icon'=>'info',
                  'title'=>'信息',
                  'message'=>'删除过程中遇到错误'
                )
              end
            elsif confirm=='no'
              @root.focus
            end
    end
    
    def delete_vol vol
           confirm=Tk.messageBox(
              'type'=>'yesno',
              'icon'=>'question',
              'title'=>'确认',
              'message'=>'你确定要删除该卷内容吗？'
            )
            
            if confirm=='yes'
              flag=Service::FileDataService.instance.delete_vol(vol)
              if flag
                Tk.messageBox(
                  'type'=>'ok',
                  'icon'=>'info',
                  'title'=>'信息',
                  'message'=>'本卷内容已成功删除'
                )
                display_thumb_details(@book) if @book!=nil
              else
                Tk.messageBox(
                  'type'=>'ok',
                  'icon'=>'info',
                  'title'=>'信息',
                  'message'=>'删除过程中遇到错误'
                )
              end
            elsif confirm=='no'
              @root.focus
            end
    end
    
    def popup_downloader vol
         Downloader.new(@root,vol)
    end  
       
    def popup_reader vol
         if @service.vol_exist?(vol)
            Reader.new(@root,vol)
         else
           say_msg("《"+vol.book_name+"》("+vol.vol_name+")已被删除，请刷新当前界面")
         end   
    end    
    
    # Run a block with a 'wait' cursor
    def busy
      @root.cursor "watch" # Set a watch cursor
      yield
    ensure
      @root.cursor "" # Back to original
    end
    
    def reset
      @@catalog_list.delete(0,@@catalog_list.size-1)
      reset_thumb_view
      say_msg('')
      @@next_btn.configure('state'=>'disabled')
      @@pre_btn.configure('state'=>'disabled')
      @@curr_page_num.text('0/0')
      @bookmark.pack_forget
      @delete_book.pack_forget
    end
    
    def reset_thumb_view
      @@cover_label.text('名称暂无')
      @@author_w.text('漫画作者：暂无')
      @@abstract_w.delete('1.0','end')
      @@cover_w.configure('file'=>@na_img)
      clean_btns_area
    end
    
    def say_msg msg
      @statusbar_w.text(msg)
    end
    
    def build_thumb_panel parent
       #thumb frame
      frm_thumb=TkFrame.new(parent).pack('side'=>'top','fill'=>'y')
      
      #command frame
      cmd_panel=TkFrame.new(frm_thumb).pack('side'=>'top','fill'=>'x')
      refresh=Button.new(cmd_panel,'text'=>'刷新').pack('side'=>'right')
      refresh.command=lambda{      
           display_thumb_details(@book) if @book!=nil
      }
      
      @bookmark=Button.new(cmd_panel,'text'=>'收藏')
      @bookmark.command=lambda{
          @service.bookmark(@book)
          Tk.messageBox('message'=>"《"+@book.book_name+"》已添加到您的书库！",'title'=>'信息','icon'=>'info')
      }
      
      @delete_book=Button.new(cmd_panel,'text'=>'删除')
      @delete_book.command=lambda{
          delete_book(@book)
      }
      
      # thumb image
      @@cover_w=TkPhotoImage.new{file @na_img}
      @@cover_label=TkLabel.new(frm_thumb) do
          text "名称暂无"
          image @@cover_w
          compound 'top'
          pack 'side'=>'left','anchor'=>'n','padx'=>'4','pady'=>'4'
          relief 'groove'
          font @@font
        end
        
      @@author_w=TkLabel.new(frm_thumb) do
        pack 'side'=>'top','anchor'=>'w','padx'=>3,'pady'=>3
        text '漫画作者：暂无'
        font @@font
      end
      
      @@abstract_w=TkText.new(frm_thumb) do
        pack 'side'=>'left'
        width 30
        height 12
        background '#ece9d8'
        relief 'groove'
        font @@font
      end
      scroll_bar=TkScrollbar.new(frm_thumb)do
          orient 'vertical'
          pack :fill=>'both',:side=>'left'
      end
      scroll_bar.command(proc { |*args|
          @@abstract_w.yview(*args)
      })
      @@abstract_w.yscrollcommand(proc { |first, last|
          scroll_bar.set(first, last)
      })
      
      @@frm_vols=TkFrame.new(parent).pack('side'=>'right','expand'=>'true','padx'=>'4','pady'=>'4') 
    end
  end

end
